import { execFileSync } from "node:child_process"
import { dirname, join } from "node:path"
import { fileURLToPath } from "node:url"

import type { Extension } from "@earendil-works/pi-coding-agent"

const goalBins = process.env.GOAL_CLI_BIN ? [process.env.GOAL_CLI_BIN] : ["goal", "cursor-goal"]
const here = dirname(fileURLToPath(import.meta.url))
const skillPath = join(dirname(here), "../../skills/pi/goal/SKILL.md")

type GoalStatus = {
  status?: string
}

function runGoal(cwd: string, args: string[], input?: string): string {
  let lastError: unknown
  for (const bin of goalBins) {
    try {
      return execFileSync(bin, args, {
        cwd,
        encoding: "utf8",
        input,
        stdio: input === undefined ? ["ignore", "pipe", "pipe"] : ["pipe", "pipe", "pipe"],
      })
    } catch (error) {
      lastError = error
      if ((error as NodeJS.ErrnoException).code !== "ENOENT") throw error
    }
  }
  throw lastError
}

function readGoalStatus(cwd: string): GoalStatus | null {
  try {
    const raw = runGoal(cwd, ["--json"]).trim()
    if (!raw || raw === "null") return null
    return JSON.parse(raw) as GoalStatus
  } catch {
    return null
  }
}

function isActiveGoal(cwd: string): boolean {
  return readGoalStatus(cwd)?.status === "active"
}

function assistantText(message: unknown): string {
  const msg = message as { role?: string; content?: unknown }
  if (!msg || msg.role !== "assistant" || !Array.isArray(msg.content)) return ""
  return msg.content
    .map((part) => {
      const p = part as { type?: string; text?: string }
      return p.type === "text" ? p.text ?? "" : ""
    })
    .join("")
}

function assistantToolCalls(message: unknown): number {
  const msg = message as { role?: string; content?: unknown }
  if (!msg || msg.role !== "assistant" || !Array.isArray(msg.content)) return 0
  return msg.content.filter((part) => (part as { type?: string }).type === "toolCall").length
}

function lastAssistantMessage(messages: unknown[]): unknown | undefined {
  for (let i = messages.length - 1; i >= 0; i -= 1) {
    const msg = messages[i] as { role?: string }
    if (msg?.role === "assistant") return messages[i]
  }
  return undefined
}

function hasGoalDecision(text: string): boolean {
  return /^GOAL_STATUS:\s*(COMPLETE|CONTINUE|BLOCKED)\b/im.test(text)
}

function deliverPrompt(pi: any, ctx: any, prompt: string) {
  // In command/event handlers Pi may not be idle yet. `followUp` gives us the Codex-style
  // continuation behavior instead of quietly dropping the next checkpoint. Cute bug, ugly UX.
  if (ctx.isIdle()) pi.sendUserMessage(prompt)
  else pi.sendUserMessage(prompt, { deliverAs: "followUp" })
}

function notify(ctx: any, message: string, type: "info" | "warning" | "error" = "info") {
  if (ctx.hasUI) ctx.ui.notify(message, type)
  else process.stderr.write(`${message}\n`)
}

function registerAutoCheckpoint(pi: any) {
  let toolCallIds = new Set<string>()
  let checkpointing = false

  pi.on("agent_start", () => {
    toolCallIds = new Set<string>()
  })

  pi.on("tool_call", (event: any) => {
    if (event?.toolCallId) toolCallIds.add(event.toolCallId)
  })

  pi.on("tool_execution_start", (event: any) => {
    if (event?.toolCallId) toolCallIds.add(event.toolCallId)
  })

  pi.on("agent_end", (event: any, ctx: any) => {
    if (checkpointing || !isActiveGoal(ctx.cwd)) return

    const assistant = lastAssistantMessage(event.messages ?? [])
    const text = assistantText(assistant).trim()
    if (!text || !hasGoalDecision(text)) return

    checkpointing = true
    try {
      const toolCalls = Math.max(toolCallIds.size, assistantToolCalls(assistant))
      const checkpoint = runGoal(ctx.cwd, ["checkpoint", "--tool-calls", String(toolCalls)], `${text}\n`).trim()
      if (checkpoint) notify(ctx, checkpoint)

      if (isActiveGoal(ctx.cwd)) {
        const prompt = runGoal(ctx.cwd, ["prompt"]).trim()
        if (prompt) deliverPrompt(pi, ctx, prompt)
      }
    } catch (error) {
      notify(ctx, `goal checkpoint failed: ${error instanceof Error ? error.message : String(error)}`, "warning")
    } finally {
      checkpointing = false
    }
  })
}

function parseCreateArgs(args: string): { objective: string; verify?: string; maxTurns?: string } {
  const tokens = args.match(/(?:[^\s"]+|"[^"]*"|'[^']*')+/g) ?? []
  const positional: string[] = []
  let verify: string | undefined
  let maxTurns: string | undefined

  for (let i = 0; i < tokens.length; i += 1) {
    const raw = tokens[i]
    const token = raw.replace(/^['"]|['"]$/g, "")
    if (token === "--verify" || token === "--validate") {
      const next = tokens[++i]
      verify = next?.replace(/^['"]|['"]$/g, "")
    } else if (token === "--max-turns") {
      const next = tokens[++i]
      maxTurns = next?.replace(/^['"]|['"]$/g, "")
    } else {
      positional.push(token)
    }
  }

  return { objective: positional.join(" ").trim(), verify, maxTurns }
}

const extension: Extension = (pi) => {
  registerAutoCheckpoint(pi)

  pi.on("resources_discover", () => ({
    resources: [
      {
        uri: "skill://goal",
        name: "goal",
        description: "Workspace goal loop: set, resume, checkpoint, verify, and complete goals.",
        mimeType: "text/markdown",
        load: () => execFileSync("cat", [skillPath], { encoding: "utf8" }),
      },
    ],
  }))

  pi.registerCommand("goal", {
    description: "Manage workspace goal loop. Usage: /goal <objective> [--verify CMD] [--max-turns N] | status | resume | prompt | pause | clear",
    handler: async (args: string, ctx) => {
      const trimmed = args.trim()
      try {
        if (!trimmed || trimmed === "status") {
          notify(ctx, runGoal(ctx.cwd, ["status"]).trim())
          return
        }

        if (trimmed === "clear") {
          notify(ctx, runGoal(ctx.cwd, ["clear"]).trim())
          return
        }

        if (trimmed === "pause") {
          notify(ctx, runGoal(ctx.cwd, ["pause"]).trim())
          return
        }

        if (trimmed === "prompt") {
          notify(ctx, runGoal(ctx.cwd, ["prompt"]).trim())
          return
        }

        if (trimmed === "resume") {
          notify(ctx, runGoal(ctx.cwd, ["resume"]).trim())
          const prompt = runGoal(ctx.cwd, ["prompt"]).trim()
          if (prompt) deliverPrompt(pi, ctx, prompt)
          return
        }

        const parsed = parseCreateArgs(trimmed)
        if (!parsed.objective) {
          notify(ctx, "Usage: /goal <objective> [--verify CMD] [--max-turns N]", "warning")
          return
        }

        const cliArgs = [parsed.objective]
        if (parsed.verify) cliArgs.push("--verify", parsed.verify)
        if (parsed.maxTurns) cliArgs.push("--max-turns", parsed.maxTurns)
        notify(ctx, runGoal(ctx.cwd, cliArgs).trim())
        const prompt = runGoal(ctx.cwd, ["prompt"]).trim()
        if (prompt) deliverPrompt(pi, ctx, prompt)
      } catch (error) {
        notify(ctx, `goal command failed: ${error instanceof Error ? error.message : String(error)}`, "error")
      }
    },
  })
}

export default extension
