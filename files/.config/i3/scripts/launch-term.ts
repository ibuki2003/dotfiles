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

  const cl_r = xprop.filter(s => s.startsWith("WM_CLASS"));
  if (!cl_r.length) return null;
  const win_class = spl2(cl_r[0], '=')
    .split(',').map(a => a.replace(/^\s*"|"\s*$/g, ''));

  const ttl_r = xprop.filter(s => s.startsWith("WM_NAME"));
  if (!ttl_r.length) return null;
  const title = spl2(ttl_r[0], '=').replace(/^"|"$/g, '');

  if (win_class.some(c => ["Alacritty"].indexOf(c) != -1)) {
    return spl2(title, ':') ?? null;
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
