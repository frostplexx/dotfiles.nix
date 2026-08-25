/**
 * Ring bell when pi finishes a turn or needs your attention.
 *
 * Emits the raw BEL control character (0x07) directly to stdout. This is
 * the terminal-native "raise the attention of the user" signal — see
 * https://ghostty.org/docs/vt/control/bel.
 *
 * Configure (optional), e.g. in ~/.pi/agent/settings.json:
 *   {
 *     "extensionConfig": {
 *       "bell-notify": {
 *         "onFinish": true,      // ring when the agent goes idle (default: true)
 *         "onError": true,       // ring (twice) on tool/provider errors (default: true)
 *         "onRetry": false,      // ring on auto-retry-from-error (default: false)
 *         "minMs": 0             // suppress "finish" bell for turns shorter than this (ms)
 *       }
 *     }
 *   }
 *
 * Or toggle live with the /bell command (see below).
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const BEL = "\x07";

interface BellConfig {
    onFinish: boolean;
    onError: boolean;
    onRetry: boolean;
    minMs: number;
}

const DEFAULTS: BellConfig = {
    onFinish: true,
    onError: true,
    onRetry: false,
    minMs: 0,
};

function ring(times = 1) {
    // Fire-and-forget writes straight to the TTY. Spacing them out slightly
    // makes back-to-back BELs register as distinct dings in most terminals
    // instead of collapsing into one.
    for (let i = 0; i < times; i++) {
        setTimeout(() => process.stdout.write(BEL), i * 120);
    }
}

export default function(pi: ExtensionAPI) {
    const config: BellConfig = {
        ...DEFAULTS,
        ...(pi.getConfig?.<Partial<BellConfig>>("bell-notify") ?? {}),
    };

    let turnStartedAt = 0;

    pi.on("turn_start", async () => {
        if (turnStartedAt === 0) turnStartedAt = Date.now();
    });

    // Primary signal: the agent has fully finished responding to the prompt
    // and is idle again, waiting on you. This is the main "I'm done" ding.
    pi.on("agent_end", async (_event, ctx) => {
        if (!config.onFinish) return;
        const elapsed = turnStartedAt ? Date.now() - turnStartedAt : Infinity;
        turnStartedAt = 0;
        if (elapsed < config.minMs) return;
        ring(1);
    });

    // Optional: ring when pi is auto-retrying after a provider/network error.
    pi.on("auto_retry_start", async () => {
        if (config.onRetry) ring(2);
    });

    // Best-effort integration with the community @pi-lab/permissions package,
    // if installed: ring right when a real permission prompt is about to be
    // shown, since that's a genuine "the agent is stuck waiting on you" case
    // that core pi doesn't expose an event for on its own.
    const bus = (pi as any).events;
    if (bus?.on) {
        bus.on("permissions:ask", () => ring(2));
    }
}
