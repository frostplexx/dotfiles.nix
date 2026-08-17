import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";
import { ADVISOR_PROMPT, AGENT_PROMPT } from "./prompts";

var ADVISOR_MODE = true;
var agentBudget = 0;
const AGENT_MAX_TASKS = 5;
const WRITE_TOOLS = new Set(["write", "edit"]);
const WRITE_COMMAND_PATTERNS = [
    /\brm\b/, /\bmv\b/, /\bsed\b/, /\bsudo\b/,
    />>/, /\b>(\s|$)/, /\bchmod\b/, /\bchown\b/,
];

export default function(pi: ExtensionAPI) {

    pi.on("before_agent_start", async (event, ctx) => {
        if (ADVISOR_MODE) {
            return {
                systemPrompt: event.systemPrompt + ADVISOR_PROMPT,
            };
        } else {
            return {
                systemPrompt: event.systemPrompt + AGENT_PROMPT,
            };
        }
    });

    pi.on("session_start", async (_event, ctx) => {
        ADVISOR_MODE = true;
        agentBudget = 0;
        ctx.ui.setStatus("advisor", "Advisor");
    });

    // If Advisor mode is active, block write/edit tools and write-capable bash commands.
    pi.on("tool_call", async (event, ctx) => {
        if (!ADVISOR_MODE) return;
        if (WRITE_TOOLS.has(event.toolName)) return {
            block: true,
            reason:
                "Write blocked: advisor mode is active. You cannot modify files. " +
                "Explain what you would change and print it as a diff instead.",
        };
        if (isToolCallEventType("bash", event) && WRITE_COMMAND_PATTERNS.some(pattern => pattern.test(event.input.command))) return {
            block: true,
            reason:
                "Write blocked: advisor mode is active. This command can modify files. " +
                "Explain what you would change and print it as a diff instead.",
        };
    });

    // Agent mode reverts to advisor once the task budget for the current grant is used up.
    pi.on("agent_settled", async (_event, ctx) => {
        if (ADVISOR_MODE) return;
        agentBudget -= 1;
        if (agentBudget <= 0) {
            ADVISOR_MODE = true;
            agentBudget = 0;
            pi.appendEntry("system", "Agent mode ended. Reverted to advisor mode.");
            ctx.ui.notify("Agent mode ended. Back to advisor.", "info");
            ctx.ui.setStatus("advisor", "Advisor");
        }
    });

    // Register a command
    pi.registerCommand("agent", {
        description: "Enable Agent mode",
        handler: async (args, ctx) => {
            if (!args || args.trim().split(/\s+/).length < 5) {
                ctx.ui.notify("Need real reason (5+ words).", "error");
                return;
            }
            pi.appendEntry("system", args);
            agentBudget = AGENT_MAX_TASKS;
            ADVISOR_MODE = false;
            ctx.ui.setStatus("advisor", "Agent: " + args);
        },
    });


    pi.registerCommand("edit", {
        description: "Run one edit task in agent mode, then revert to advisor",
        handler: async (args, ctx) => {
            if (!args || args.trim().split(/\s+/).length < 5) {
                ctx.ui.notify("Need real reason (5+ words).", "error");
                return;
            }
            pi.appendEntry("system", "Edit: " + args);
            agentBudget = 1;
            ADVISOR_MODE = false;
            ctx.ui.setStatus("advisor", "Edit: " + args);
            pi.sendUserMessage(args, { deliverAs: "followUp" });
        },
    });

    pi.registerCommand("advisor", {
        description: "Enable Advisor mode",
        handler: async (args, ctx) => {
            ADVISOR_MODE = true;
            ctx.ui.setStatus("advisor", "Advisor");
        },
    });
}
