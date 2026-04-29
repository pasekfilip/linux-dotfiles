import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function(pi: ExtensionAPI) {
    pi.registerCommand("test", {
        description: "test",
        handler: async (args, ctx) => {
            ctx.ui.notify("test");
        }
    })
}
