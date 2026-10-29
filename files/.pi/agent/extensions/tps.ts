// https://gist.githubusercontent.com/gregjhogan/9b40c77ee7b61c294c0ac79b82633274/raw/15aa38551417fb19bfb53f453fc1678d299c458e/tok-per-sec.ts
/**
 * tok/s display extension.
 *
 * Shows actual tok/s (from API usage data) when the message completes,
 * including TTFT and total time breakdown.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  let turnStartTime = 0;
  let firstChunkTime = 0;
  let messageEndTime = 0;

  pi.on("turn_start", async (_event, _ctx) => {
    turnStartTime = Date.now();
    firstChunkTime = 0;
  });

  pi.on("message_update", async (event, _ctx) => {
    const evt = event.assistantMessageEvent;
    if (firstChunkTime === 0 && (evt.type === "text_delta" || evt.type === "thinking_delta" || evt.type === "toolcall_delta")) {
      firstChunkTime = Date.now();
    }
  });

  pi.on("message_end", async (event, ctx) => {
    if (event.message.role !== "assistant") return;
    messageEndTime = Date.now();

    if ("usage" in event.message && turnStartTime > 0) {
      const usage = (event.message as any).usage;
      if (usage?.output > 0) {
        const totalElapsed = (messageEndTime - turnStartTime) / 1000;
        const ttft = firstChunkTime > 0 ? (firstChunkTime - turnStartTime) / 1000 : 0;
        const streamElapsed = firstChunkTime > 0 ? (messageEndTime - firstChunkTime) / 1000 : totalElapsed;
        const tps = streamElapsed > 0 ? usage.output / streamElapsed : 0;
        ctx.ui.notify(
          `${tps.toFixed(1)} tok/s · ${usage.output} tokens · ${totalElapsed.toFixed(1)}s total · ${ttft.toFixed(1)}s TTFT`,
          "info"
        );
      }
    }
  });
}
