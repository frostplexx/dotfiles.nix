import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * Temporary shim until pi-sandbox reports program status itself.
 *
 * pi-sandbox shows permission prompts in an inline widget, not as an extension dialog, so Pi never
 * reports `blocked` over OSC 7501 while one waits for approval. pi-sandbox PR #128 adds paired
 * `pi-sandbox:permission-prompt-start` / `-end` events. Released versions only emit
 * `request-attention` before showing the widget, so the wait is ended on the next tool or input
 * activity instead. A `!cmd` prompt has no follow-up event and clears on your next input.
 */

const APP_NAME = "pi";
const LIFECYCLE_START_EVENT = "pi-sandbox:permission-prompt-start";
const LIFECYCLE_END_EVENT = "pi-sandbox:permission-prompt-end";
const ATTENTION_EVENT = "request-attention";
const DEFAULT_TITLE = "Sandbox permission required";
const MAX_MESSAGE_CHARS = 200;
const CONTROL_CHARACTERS = /[\u0000-\u001f\u007f-\u009f]/g;

type State = "idle" | "working" | "blocked";
type Kind = "permission" | "question" | "auth";

interface StatusReport {
  state: State;
  kind?: Kind;
  message?: string;
}

function base64Text(text: string): string {
  return Buffer.from(text.replace(CONTROL_CHARACTERS, " ").slice(0, MAX_MESSAGE_CHARS), "utf8")
    .toString("base64");
}

function reportStatus(report: StatusReport): void {
  const pairs = [`state=${report.state}`, `app=${APP_NAME}`];
  if (report.kind) pairs.push(`kind=${report.kind}`);
  if (report.message) pairs.push(`msg=${base64Text(report.message)}`);
  process.stdout.write(`\x1b]7501;${pairs.join(":")}\x1b\\`);
}

export default function sandboxAttention(pi: ExtensionAPI) {
  const openPromptIds = new Set<string>();
  let unidentifiedPrompts = 0;
  let waitingTitle = DEFAULT_TITLE;
  let runActive = false;
  let lifecycleEventsSeen = false;

  // A report replaces the whole record, so clearing re-sends the state Pi would have shown.
  const publish = (): void => {
    if (openPromptIds.size > 0 || unidentifiedPrompts > 0) {
      reportStatus({ state: "blocked", kind: "permission", message: waitingTitle });
    } else if (runActive) {
      reportStatus({ state: "working", message: pi.getSessionName() });
    } else {
      reportStatus({ state: "idle" });
    }
  };

  const clearUnidentifiedPrompts = (): void => {
    if (unidentifiedPrompts === 0) return;
    unidentifiedPrompts = 0;
    publish();
  };

  pi.events.on(LIFECYCLE_START_EVENT, (data) => {
    lifecycleEventsSeen = true;
    const { id, title } = (data ?? {}) as { id?: string; title?: string };
    if (typeof id === "string") openPromptIds.add(id);
    else unidentifiedPrompts += 1;
    if (typeof title === "string") waitingTitle = title;
    publish();
  });

  pi.events.on(LIFECYCLE_END_EVENT, (data) => {
    const { id } = (data ?? {}) as { id?: string };
    if (typeof id === "string") openPromptIds.delete(id);
    else unidentifiedPrompts = 0;
    publish();
  });

  pi.events.on(ATTENTION_EVENT, () => {
    if (lifecycleEventsSeen) return;
    unidentifiedPrompts += 1;
    waitingTitle = DEFAULT_TITLE;
    publish();
  });

  pi.on("agent_start", () => {
    runActive = true;
  });

  // Pi reports done/error/idle itself once the run settles; only reset our own state.
  pi.on("agent_settled", () => {
    runActive = false;
    openPromptIds.clear();
    unidentifiedPrompts = 0;
  });

  pi.on("tool_execution_start", clearUnidentifiedPrompts);
  pi.on("tool_execution_end", clearUnidentifiedPrompts);
  pi.on("message_start", clearUnidentifiedPrompts);
  pi.on("turn_start", clearUnidentifiedPrompts);
  pi.on("input", clearUnidentifiedPrompts);
}
