import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

interface ChatModeState {
    enabled: boolean;
}

const CUSTOM_TYPE = "chat_mode_state";

export default function(pi: ExtensionAPI) {
    let chatModeEnabled = false;

    // Load persisted state from session on startup
    pi.on("session_start", async (_event, ctx) => {
        // Look for saved chat mode state in session entries
        const entries = ctx.sessionManager.getEntries();
        const stateEntry = entries.find(
            (e) => e.type === "custom" && e.customType === CUSTOM_TYPE
        );

        if (stateEntry && stateEntry.type === "custom" && stateEntry.data) {
            try {
                const state = stateEntry.data as ChatModeState;
                chatModeEnabled = state.enabled;
            } catch {
                chatModeEnabled = false;
            }
        }

        if (chatModeEnabled) {
            ctx.ui.notify("💬 Chat mode enabled (no file/bash access)", "info");
            ctx.ui.setStatus("chat-mode", "💬 CHAT MODE");
        }
    });

    // Block tool calls when chat mode is enabled
    pi.on("tool_call", async (event, ctx) => {
        if (chatModeEnabled) {
            return {
                block: true,
                reason: "Chat mode enabled. Use /chat-mode to disable.",
            };
        }
    });

    // Register the toggle command
    pi.registerCommand("chat-mode", {
        description: "Toggle chat-only mode (blocks file/bash/edit access)",
        handler: async (_args, ctx) => {
            chatModeEnabled = !chatModeEnabled;

            // Persist state to session
            pi.appendEntry(CUSTOM_TYPE, { enabled: chatModeEnabled });

            if (chatModeEnabled) {
                ctx.ui.setStatus("chat-mode", "💬 CHAT MODE");
                ctx.ui.notify(
                    "✓ Chat mode enabled - text-only, no file/bash/edit access",
                    "info"
                );
            } else {
                ctx.ui.setStatus("chat-mode", undefined);
                ctx.ui.notify(
                    "✓ Chat mode disabled - full tool access restored",
                    "info"
                );
            }
        },
    });
}
