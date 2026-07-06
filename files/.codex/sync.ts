#!/usr/bin/env -S deno run --allow-read --allow-write --allow-run --allow-env=HOME

import { dirname, fromFileUrl, join } from "jsr:@std/path@1";

type MergeResult =
  | {
    ok: true;
    merged: string;
  }
  | {
    ok: false;
    conflicted: string;
  };

const paths = await resolvePaths();

if (Deno.args.length !== 0) {
  console.error("Usage: sync.ts");
  Deno.exit(2);
}

await sync();

async function sync() {
  const repoCommon = await readRequired(paths.repoCommon, "repo common");
  const actualConfig = await readRequired(paths.actualConfig, "actual config");
  const actual = splitCodexConfig(actualConfig);
  const base = await ensureBase(repoCommon, actual.common);
  let result = await mergeWithGit({
    current: actual.common,
    base,
    other: repoCommon,
  });

  if (!result.ok) {
    result = {
      ok: true,
      merged: await resolveConflictWithVimdiff({
        actual: actual.common,
        conflicted: result.conflicted,
        repo: repoCommon,
      }),
    };
  }

  const mergedCommon = ensureTrailingNewline(result.merged);
  await writeText(paths.repoCommon, mergedCommon);
  await writeText(
    paths.actualConfig,
    combineConfig(mergedCommon, actual.local),
  );
  await writeText(paths.baseCommon, mergedCommon);
  console.log("Synced Codex config.");
}

async function ensureBase(
  repoCommon: string,
  actualCommon: string,
): Promise<string> {
  const base = await readOptional(paths.baseCommon);
  const normalizedRepo = ensureTrailingNewline(repoCommon);
  const normalizedActual = ensureTrailingNewline(actualCommon);

  if (base != null) {
    return base;
  }

  if (normalizedRepo === normalizedActual) {
    await writeText(paths.baseCommon, normalizedRepo);
    console.log(`Created missing base common: ${paths.baseCommon}`);
    return normalizedRepo;
  }

  console.error(`Missing base common: ${paths.baseCommon}`);
  console.error(
    "repo common and actual common differ, so automatic 3-way merge cannot start.",
  );
  console.error(
    "Manually merge them into config.common.toml, copy the same resolved common to the base path above, then run this script again.",
  );
  Deno.exit(1);
}

async function resolveConflictWithVimdiff(
  content: { actual: string; conflicted: string; repo: string },
): Promise<string> {
  const tempDir = await Deno.makeTempDir({
    prefix: ".config-resolve-",
  });

  try {
    const actualPath = join(tempDir, "actual.toml");
    const mergedPath = join(tempDir, "merged.toml");
    const repoPath = join(tempDir, "repo.toml");

    await writeText(actualPath, content.actual);
    await writeText(mergedPath, content.conflicted);
    await writeText(repoPath, content.repo);

    console.error("Merge conflict. Resolve merged.toml in vimdiff.");
    await new Deno.Command("nvim", {
      args: [
        "-d",
        actualPath,
        mergedPath,
        repoPath,
      ],
      stdin: "inherit",
      stdout: "inherit",
      stderr: "inherit",
    }).output();

    const resolved = await readRequired(mergedPath, "resolved common");

    if (hasConflictMarkers(resolved)) {
      const conflictPath = `${paths.repoCommon}.conflict`;
      await writeText(conflictPath, resolved);
      throw new Error(`Conflict markers remain: ${conflictPath}`);
    }

    return resolved;
  } finally {
    await Deno.remove(tempDir, { recursive: true });
  }
}

function splitCodexConfig(config: string): { common: string; local: string } {
  const common: string[] = [];
  const local: string[] = [];
  let current = common;

  for (const line of splitLines(config)) {
    const line_trimmed = line.trim();
    if (line_trimmed.startsWith("[")) {
      const is_local_header = line_trimmed.startsWith("[projects.");
      current = is_local_header ? local : common;
    }

    current.push(line);
  }

  return {
    common: normalizeNewlines(common.join("")),
    local: normalizeNewlines(local.join("")),
  };
}

async function mergeWithGit(
  content: { current: string; base: string; other: string },
): Promise<MergeResult> {
  const tempDir = await Deno.makeTempDir({
    dir: dirname(paths.actualConfig),
    prefix: ".config-sync-",
  });

  try {
    const currentPath = join(tempDir, "current.toml");
    const basePath = join(tempDir, "base.toml");
    const otherPath = join(tempDir, "other.toml");

    await writeText(currentPath, content.current);
    await writeText(basePath, content.base);
    await writeText(otherPath, content.other);

    const output = await new Deno.Command("git", {
      args: [
        "merge-file",
        "-p",
        currentPath,
        basePath,
        otherPath,
      ],
      stdout: "piped",
      stderr: "piped",
    }).output();

    const merged = new TextDecoder().decode(output.stdout);
    const stderr = new TextDecoder().decode(output.stderr).trim();

    if (output.code === 0) {
      return { ok: true, merged };
    }
    if (output.code === 1) {
      return { ok: false, conflicted: merged };
    }

    throw new Error(
      stderr === "" ? `git merge-file failed: ${output.code}` : stderr,
    );
  } finally {
    await Deno.remove(tempDir, { recursive: true });
  }
}

async function resolvePaths() {
  const home = Deno.env.get("HOME");
  console.log(`HOME: ${home}`);

  if (home == null || home === "") {
    throw new Error("HOME is not set.");
  }

  const scriptPath = await Deno.realPath(fromFileUrl(import.meta.url));
  const repoCodexDir = dirname(scriptPath);
  const actualCodexDir = join(home, ".codex");

  return {
    repoCommon: join(repoCodexDir, "config.common.toml"),
    actualConfig: join(actualCodexDir, "config.toml"),
    baseCommon: join(actualCodexDir, ".config.common.base.toml"),
  };
}

async function readRequired(path: string, label: string): Promise<string> {
  console.log(`Reading ${label}: ${path}`);
  const text = await readOptional(path);

  if (text == null) {
    throw new Error(`Missing ${label}: ${path}`);
  }

  return text;
}

async function readOptional(path: string): Promise<string | null> {
  try {
    return normalizeNewlines(await Deno.readTextFile(path));
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      return null;
    }
    throw error;
  }
}

async function writeText(path: string, text: string): Promise<void> {
  await Deno.mkdir(dirname(path), { recursive: true });
  await Deno.writeTextFile(path, ensureTrailingNewline(text));
}

function splitLines(text: string): string[] {
  return text.match(/[^\n]*\n|[^\n]+/g) ?? [];
}

function combineConfig(common: string, local: string): string {
  const normalizedCommon = ensureTrailingNewline(common).replace(/\n+$/, "\n");
  const normalizedLocal = normalizeNewlines(local).replace(/^\n+/, "");

  if (normalizedLocal.trim() === "") {
    return normalizedCommon;
  }
  if (normalizedCommon.trim() === "") {
    return ensureTrailingNewline(normalizedLocal);
  }

  return `${normalizedCommon}\n${ensureTrailingNewline(normalizedLocal)}`;
}

function hasConflictMarkers(text: string): boolean {
  return text.split("\n").some((line) =>
    line.startsWith("<<<<<<< ") ||
    line.startsWith("=======") ||
    line.startsWith(">>>>>>> ")
  );
}

function normalizeNewlines(text: string): string {
  return text.replace(/\r\n/g, "\n");
}

function ensureTrailingNewline(text: string): string {
  return text.endsWith("\n") ? text : `${text}\n`;
}
