const decode = (s: Uint8Array) => new TextDecoder().decode(s);

const NmAvailable = new Deno.Command("nmcli", {
  args: ["-v"],
  stdout: "null",
  stderr: "null",
}).outputSync().success;

async function get_ifs() {
  let fields = [];

  if (NmAvailable) {
    const p = decode(
      (await new Deno.Command("nmcli", {
        stdout: "piped",
      }).output()).stdout,
    )
      .replaceAll(/^\troute.*\n/gm, "")
      .replaceAll("\t", "  ");

    fields = p.split("\n\n")
      .filter((l) => l.match(/^\w+: connected/));
  } else {
    const p = decode(
      (await new Deno.Command("ifconfig", {
        stdout: "piped",
      }).output()).stdout,
    )
      .replaceAll(/^.+packets.*\n/gm, "")
      .replaceAll(/^ {8}/gm, "  ");

    fields = p.split("\n\n").filter(Boolean);
  }

  return Object.fromEntries(fields.map((f) => {
    const name = f.split(":", 1)[0];
    return [name, f];
  }));
}

async function get_primary_if(): Promise<string | null> {
  const p = await new Deno.Command("ip", {
    args: ["route", "show", "default"],
    stdout: "piped",
  }).output();
  const o = decode(p.stdout).split("\n");
  if (o.length < 1) return null;

  const m = / dev (\w+)/.exec(o[0]);
  return m ? m[1] : null;
}

type Rec = Record<string, string>;

function unquote(s: string): string {
  const r = /^"(.*)"$/.exec(s);
  return r ? r[1] : s;
}

async function get_iwconfig(): Promise<Record<string, Rec>> {
  let p;
  try {
    p = await new Deno.Command("iwconfig", { stdout: "piped" }).output();
  } catch (_) {
    return {};
  }
  if (!p.success) return {};
  const o = decode(p.stdout);

  const entries = o.split("\n\n").filter(Boolean)
    .map((e) => {
      const [name, protocol, ...fields] = e.split(/ {2,}|\n/).filter(Boolean);
      const f = Object.fromEntries(fields.map((l) => {
        const i = /[:=]/.exec(l)?.index;
        if (!i) return [];
        return [
          l.slice(0, i).trim().toLowerCase().replace(/[ -]/g, "_"),
          unquote(l.slice(i + 1).trim()),
        ];
      }));
      f.protocol = protocol;
      return [name, f];
    });

  return Object.fromEntries(entries);
}

async function get_usage(): Promise<Speeds> {
  const t = decode(await Deno.readFile("/proc/net/dev"));
  return Object.fromEntries(
    t.split("\n")
      .map((l) => l.trim().split(":"))
      .filter((l) => l.length == 2)
      .map(([name, s]) => {
        const f = s.split(/\s+/).filter(Boolean);
        return [
          name,
          [
            parseInt(f[0]) as number,
            parseInt(f[8]) as number,
          ],
        ];
      }),
  );
}

const LABELS = ["B", "K", "M", "G", "T"];
function format_size(size: number): string {
  size = Math.round(size / 1024);
  let i = 1;
  while (size > 512) {
    size = Math.round(size / 1024);
    ++i;
  }
  return `${size}${LABELS[i]}`;
}

function has<X, Y extends PropertyKey>(
  x: X,
  y: Y,
): x is X & Record<Y, unknown> {
  if (typeof x !== "object" || x === null) return false;
  return Object.prototype.hasOwnProperty.call(x, y);
}

type Speeds = Record<string, [number, number]>;

async function update(
  ifs: Record<string, string>,
  iw_info: Record<string, Rec>,
  primary_if: string | null,
  speeds: Speeds,
) {
  const tooltip = Object.keys(ifs).map((i) => {
    let text = ifs[i] + "\n";
    const speed = (has(speeds, i) ? speeds[i] : null) ?? [0, 0];

    if (has(iw_info, i)) {
      const iwc = iw_info[i];

      // wifi
      text += `  ${iwc.essid} ${iwc.frequency}\n`;
      if (iwc.signal_level) {
        text += `  ${iwc.signal_level} `;
      }
      if (iwc.bit_rate) {
        text += `  ${iwc.bit_rate}\n`;
      }
    }
    text += `  ${format_size(speed[1])} / ${format_size(speed[0])}\n`;

    return text;
  })
    .join("\n\n");

  let text = "No connection";
  let mode = "nc";
  let percentage = 0;

  if (primary_if && ifs[primary_if]) {
    const p = ifs[primary_if];
    const s = speeds[primary_if] ?? [0, 0];
    const l = p.split("\n").map((l) => l.trim());

    const is_wifi = l[2].startsWith("wifi ");

    const name = (is_wifi
      ? /: connected to (.+?)$/.exec(l[0])?.[1]
      : l.filter((l) =>
        l.startsWith("inet")
      )[0].split(" ")[1]) ?? "Unknown";

    text = `${name} ${format_size(s[1])} / ${format_size(s[0])}`;

    mode = is_wifi ? "wifi" : "eth";

    const iw = has(iw_info, primary_if) ? iw_info[primary_if] : null;
    percentage = link_quality_percentage(iw?.link_quality);
  }

  await Deno.stdout.write(
    new TextEncoder().encode(
      JSON.stringify({
        text,
        alt: mode,
        tooltip,
        percentage,
      }) + "\n",
    ),
  );
}

function link_quality_percentage(quality: string | undefined): number {
  if (!quality) return 0;
  if (!quality.includes("/")) return 0;
  const f = quality.split("/");
  return Math.round(parseInt(f[0]) / parseInt(f[1]) * 100);
}

async function* watch_nmcli() {
  while (true) {
    const p = new Deno.Command("nmcli", {
      args: ["monitor"],
      stdout: "piped",
    }).spawn().stdout.getReader();

    while (true) {
      const n = await p.read();
      if (n.value) yield 1;
      if (n.done) break;
    }
    await p.cancel();
  }
}

async function* usage_speed() {
  let last_usage: Speeds = {};
  let last_t = +new Date();

  while (true) {
    const usage = await get_usage();
    const ret: Speeds = {};
    let itv = (+new Date() - last_t) / 1000;
    if (itv === 0) itv = 0.1;
    Object.keys(usage).forEach((i) => {
      if (has(last_usage, i)) {
        ret[i] = [
          (usage[i][0] - last_usage[i][0]) / itv,
          (usage[i][1] - last_usage[i][1]) / itv,
        ];
      } else {
        ret[i] = [0, 0];
      }
    });
    last_usage = usage;
    last_t = +new Date();
    yield ret;
  }
}

async function* interval(t: number) {
  while (true) {
    yield 1;
    await delay(t);
  }
}

const delay = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

async function main() {
  let infos: Record<string, string> = await get_ifs();
  let primary_if: string | null = await get_primary_if();
  let speeds: Speeds = {};
  let iw_info: Record<string, Rec> = await get_iwconfig();

  const watch = watch_nmcli();
  const watch_speed = usage_speed();

  const itv = interval(5000);

  while (true) {
    await Promise.race([
      watch.next().then(async () => {
        infos = await get_ifs();
        primary_if = await get_primary_if();
      }),
      itv.next().then(async () => {
        iw_info = await get_iwconfig();
        speeds = await watch_speed.next().then((x) => x.value) ?? {};
      }),
    ]);
    update(infos, iw_info, primary_if, speeds);
  }
}

await main();
