import path from "node:path";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent"

export default async function (pi: ExtensionAPI) {

  const cwd = process.cwd().replace(process.env.HOME || "~", "~");
  function setTitle(ctx: ExtensionContext) {
   if (ctx.mode !== "tui") return;
    ctx.ui.setTitle("π: " + cwd);
  }

  const handler = async (_event: unknown, ctx: ExtensionContext) => setTitle(ctx);

  pi.on("session_start", (_event, ctx) => setTimeout(() => setTitle(ctx), 100));
  pi.on("session_info_changed", handler);
  pi.on("session_shutdown", handler);
  pi.on("agent_start", handler);
}
