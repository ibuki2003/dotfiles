import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";

const STATUS_KEY = "codex-limits";
const REFRESH_MS = 5 * 60_000;

interface Window {
  used_percent?: number;
  reset_at?: number;
  limit_window_seconds?: number;
}

interface Usage {
  rate_limit?: {
    primary_window?: Window;
    secondary_window?: Window;
  };
  credits?: {
    has_credits?: boolean;
    unlimited?: boolean;
    balance?: string;
  };
}

async function credentials(): Promise<{ token: string; accountId?: string } | undefined> {
  try {
    const auth = JSON.parse(
      await readFile(join(homedir(), ".pi", "agent", "auth.json"), "utf8"),
    );
    const codex = auth["openai-codex"];
    if (codex?.access) return { token: codex.access, accountId: codex.accountId };
  } catch {
    // Codex CLI may have its own credentials.
  }

  try {
    const auth = JSON.parse(
      await readFile(
        join(process.env.CODEX_HOME || join(homedir(), ".codex"), "auth.json"),
        "utf8",
      ),
    );
    const token = auth.tokens?.access_token ?? auth.OPENAI_API_KEY;
    if (token) return { token, accountId: auth.tokens?.account_id };
  } catch {
    // No Codex credentials available.
  }
}

function resetIn(timestamp: number | undefined): string {
  if (timestamp === undefined) return "?";
  const minutes = Math.max(0, Math.ceil((timestamp * 1000 - Date.now()) / 60_000));
  if (minutes < 60) return `${minutes}m`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h${minutes % 60}m`;
  return `${Math.floor(hours / 24)}d${hours % 24}h`;
}

function formatWindow(window: Window | undefined): string | undefined {
  if (typeof window?.used_percent !== "number") return undefined;
  const label = window.limit_window_seconds === 5 * 60 * 60
    ? "5h"
    : window.limit_window_seconds === 7 * 24 * 60 * 60
      ? "7d"
      : undefined;
  if (!label) return undefined;
  return `${label} ${Math.round(100 - window.used_percent)}% (${resetIn(window.reset_at)})`;
}

export default function (pi: ExtensionAPI) {
  let timer: ReturnType<typeof setInterval> | undefined;
  let generation = 0;

  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    clearInterval(timer);
    const current = ++generation;

    async function refresh() {
      try {
        const creds = await credentials();
        if (!creds) {
          if (current === generation) ctx.ui.setStatus(STATUS_KEY, undefined);
          return;
        }

        const headers: Record<string, string> = {
          Authorization: `Bearer ${creds.token}`,
          "User-Agent": "pi-agent",
          Accept: "application/json",
        };
        if (creds.accountId) headers["ChatGPT-Account-Id"] = creds.accountId;
        const response = await fetch("https://chatgpt.com/backend-api/wham/usage", {
          headers,
          signal: AbortSignal.timeout(5000),
        });
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        const usage = (await response.json()) as Usage;
        const windows = [
          formatWindow(usage.rate_limit?.primary_window),
          formatWindow(usage.rate_limit?.secondary_window),
        ].filter((value): value is string => value !== undefined);
        const credits = usage.credits;
        if (credits?.has_credits) {
          windows.push(`credits ${credits.unlimited ? "unlimited" : credits.balance ?? "?"}`);
        }
        if (current === generation) ctx.ui.setStatus(STATUS_KEY, windows.join(" | ") || undefined);
      } catch {
        // Keep the last successful value when a refresh fails.
      }
    }

    void refresh();
    timer = setInterval(() => void refresh(), REFRESH_MS);
    timer.unref();
  });

  pi.on("session_shutdown", (_event, ctx) => {
    ++generation;
    clearInterval(timer);
    timer = undefined;
    if (ctx.mode === "tui") ctx.ui.setStatus(STATUS_KEY, undefined);
  });
}
