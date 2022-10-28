import shell_escape from 'https://deno.land/x/shell_escape/index.ts';

function spl2(str: string, target: string) {
  const pos = str.indexOf(target);
  if (pos == -1) return '';
  return str.substring(pos + target.length).trim();
}

async function get_focused_pwd(): Promise<string | null> {
  const id = await Deno.run({
    cmd: ["xdpyinfo"],
    stdout: "piped",
  }).output()
    .then(s => new TextDecoder().decode(s))
    .then(s => s.split("\n")
          .filter(s => s.startsWith("focus:"))[0]
          .split(' ')
          .filter(s => s.startsWith('0x'))[0]
         );
  const xprop = await Deno.run({
    cmd: ["xprop", "-id", id],
    stdout: "piped",
  }).output()
    .then(s => new TextDecoder().decode(s).split('\n'));

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
    return match[1];
  }
  return null;
}

async function main() {
  const args: string[] = [];
  args.push(Deno.args.length >= 1 ? Deno.args[0] : 'alacritty');

  const pwd = await get_focused_pwd();
  if (pwd) {
    args.push("--working-directory", pwd.replace(/^~/, Deno.env.get("HOME") || ''));
  }

  const p =Deno.run({
    cmd: ["i3-msg", "exec --no-startup-id " + shell_escape(args)],
    stdout: "piped",
  });
  p.output().then(s => new TextDecoder().decode(s)).then(s => console.log(s));
}

main();
