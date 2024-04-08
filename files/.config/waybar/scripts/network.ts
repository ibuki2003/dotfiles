const decode = (s: Uint8Array) => new TextDecoder().decode(s);

async function get_interfaces(): Promise<string[]> {
  const p = await new Deno.Command("find", {
    args: [
      "/sys/class/net",
      "-mindepth", "1",
      "-maxdepth", "1",
      "-lname", "*virtual*",
      "-prune",
      "-o",
      "-printf", "%f\n",
    ],
    stdout: "piped",
  }).output();
  return decode(p.stdout).trim().split("\n");
}

type Rec = Record<string, string | number>;

async function get_ifconfig(): Promise<Rec[]> {
  const p = await new Deno.Command("jc", {
    args: ["ifconfig"],
    stdout: "piped",
  }).output();
  return JSON.parse(decode(p.stdout));
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

async function get_iwconfig(): Promise<Rec[]> {
  const p = await new Deno.Command("jc", {
    args: ["iwconfig"],
    stdout: "piped",
  }).output();
  if (!p.success) return [];

  return JSON.parse(decode(p.stdout));
}

async function get_usage(): Promise<Record<string, [number, number]>> {
  const t = decode(await Deno.readFile("/proc/net/dev"));
  return Object.fromEntries(t.split("\n")
    .map(l => l.split(':'))
    .filter(l => l.length == 2)
    .map(([name, s]) => {
      const f = s.split(/\s+/).filter(Boolean);
      return [
        name,
        [
          parseInt(f[0]) as number,
          parseInt(f[8]) as number,
        ],
      ]
    }));
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
  return Object.prototype.hasOwnProperty.call(x, y);
}

interface IfInfo {
  ifc: {
    ipv4: { address: string }[] | null;
    ipv6: { address: string }[] | null;
    [key: string]: unknown;
  };

  iwc?: {
    signal_level: number;
    [key: string]: unknown;
  };
};

type Ifs = Record<string, IfInfo>;
type Speeds = Record<string, [number, number]>;

async function update(ifs: Ifs, speeds: Speeds, primary_if: string | null) {
  const tooltip = Object.keys(ifs)
    .filter((i) => speeds[i])
    .map((i) => {
      const info = ifs[i];
      const spd = speeds[i];
      let text = i;
      if (info.iwc) {
        // wifi
        text +=
          ` ${info.iwc.essid} ${info.iwc.frequency}${info.iwc.frequency_unit}\n`;
        if (info.iwc.signal_level)
          text += `${info.iwc.signal_level}${info.iwc.signal_level_unit} `;
        if (info.iwc.bit_rate)
          text += `${info.iwc.bit_rate}${info.iwc.bit_rate_unit}\n`;
      } else {
        text += "\n";
      }
      text += `${format_size(spd[1])} / ${format_size(spd[0])}\n`;

      if (info.ifc.ipv4) {
        text += info.ifc.ipv4
          .map((ip: { address: string }) => ` ${ip.address}`)
          .join("\n");
        text += '\n';
      }
      if (info.ifc.ipv6) {
        text += info.ifc.ipv6
          .map((ip: { address: string }) => ` ${ip.address}`)
          .join("\n");
        text += '\n';
      }

      return text;
    })
    .join("\n\n");

  const p = primary_if ? ifs[primary_if] : null;
  const s = primary_if ? speeds[primary_if] ?? [0, 0] : [0, 0];

  const text = p
    ? `${
      p.iwc?.essid ?? p.ifc.ipv4_addr
    } ${
      format_size(s[1])
    } / ${
      format_size(s[0])
    }`
    : "No connection";


  const mode = primary_if
    ? has(p, "iwc")
      ? "wifi"
      : "eth"
    : "nc";

  const percentage = p?.iwc ?
    Math.round(
      Math.min(
          Math.max(1 - (-45 - p.iwc.signal_level) / 45, 0),
          1,
        ) * 100
    )
    : 0;

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

let last_usage: Record<string, [number, number]> = {};
async function get_speeds(interval: number): Promise<Speeds> {
  const ret: Speeds = {};
  const a = await get_usage();
  Object.keys(a).forEach((i) => {
    if (has(last_usage, i)) {
      ret[i] = [
        (a[i][0] - last_usage[i][0]) / interval,
        (a[i][1] - last_usage[i][1]) / interval,
      ];
    }
  });
  last_usage = a;
  return ret;
}

async function get_infos(): Promise<Ifs> {
  const ret: Ifs = {};
  await get_interfaces().then((interfaces) => {
    for (const i of interfaces) {
      ret[i] = {
        ifc: {
          ipv4: [],
          ipv6: [],
        },
      };
    }
  });
  await Promise.all([
    get_iwconfig().then((w) => {
      w.forEach(i => {
        if (has(ret, i.name)) {
          ret[i.name].iwc = i as IfInfo['iwc'];
        }
      });
    }),
    get_ifconfig().then((a) => {
      a.forEach((i) => {
        if (has(ret, i.name)) {
          ret[i.name].ifc = i as IfInfo['ifc'];
        }
      });
    }),
  ]);
  return ret;
}

function sleep(duration: number) {
  return new Promise((resolve) => setTimeout(resolve, duration));
}

const interval = 3; // seconds
const info_itv = 30; // times

async function main() {
  let infos: Ifs = {};
  let primary_if: string | null = null;
  let speeds: Speeds = {};

  let c = 0;
  while (true) {
    speeds = await get_speeds(interval);

    const need_update = Object.keys(speeds).some((i) => infos[i]);
    if (c-- <= 0 || need_update) {
      primary_if = await get_primary_if();
      infos = await get_infos();
      c = info_itv;
    }
    await update(infos, speeds, primary_if);

    await sleep(interval * 1000);
  }
}

await main();
