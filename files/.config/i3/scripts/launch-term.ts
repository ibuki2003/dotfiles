import shell_escape from "https://deno.land/x/shell_escape@1.0.0/index.ts";
import { exists } from "https://deno.land/std@0.190.0/fs/mod.ts";

async function get_focused_pwd(): Promise<string | null> {
  const id = await new Deno.Command("xdpyinfo", {stdout: "piped"}).output()
    .then(s => new TextDecoder().decode(s.stdout))
    .then(s => s.split("\n")
          .filter(s => s.startsWith("focus:"))[0]
          .split(' ')
          .filter(s => s.startsWith('0x'))[0]
         );
  const xprop = await new Deno.Command("xprop", {
    args: ["-id", id],
    stdout: "piped",
  }).output()
    .then(s => new TextDecoder().decode(s.stdout).split('\n'));

  const props = Object.fromEntries(
    xprop
      .flatMap(s => {
        const p = s.indexOf(' = ');
        if (p == -1) return [];

        const b = Math.min(s.indexOf('('), p);
        const key = s.substring(0, b);
        const value = s.substring(p + 3)
          .split(', ').map(s => s.replace(/^\s*"|"\s*$/g, ''));
        return [[key, value]]
      }));

  if (!Object.hasOwn(props, 'WM_CLASS')) return null;
  const win_class = props['WM_CLASS'];

  const names = props['_NET_WM_NAME'] ?? props['WM_NAME'];
  if (!names || names.length == 0) return null;

  if (win_class.some(c => ["Alacritty"].indexOf(c) != -1)) {
    const match = names[0].match(/^\w+: (.+?)( : .+)?$/);
    if (!match) return null;
    const path = match[1].replace(/^~/, Deno.env.get("HOME") || '');
    if (await exists(path, {isDirectory: true})) return path;
    return null;
  }
  return null;
}

async function main() {
  const args: string[] = [];
  args.push(Deno.args.length >= 1 ? Deno.args[0] : 'alacritty');

  const pwd = await get_focused_pwd();
  if (pwd) {
    args.push("--working-directory", pwd);
  }

  const p = new Deno.Command("i3-msg", {
    args: ["exec --no-startup-id " + shell_escape(args)],
  });
  await p.spawn().status;
}

main();
