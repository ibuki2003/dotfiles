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
  speed: [number, number];

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

async function update(ifs: Record<string, IfInfo>, primary_if: string | null) {
  const tooltip = Object.keys(ifs)
    .map((i) => {
      const info = ifs[i];
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
      text += `${format_size(info.speed[1])} / ${format_size(info.speed[0])}\n`;

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

  const text = p
    ? `${
      p.iwc?.essid ?? p.ifc.ipv4_addr
    } ${
      format_size(p.speed[1] as number)
    } / ${
      format_size(p.speed[0] as number)
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

async function main() {
  const infos: Record<string, IfInfo> = {};

  let primary_if: string | null = null;

  const update_infos = async () => {
    await get_interfaces().then((interfaces) => {
      for (const i of interfaces) {
        if (!infos[i]) infos[i] = {
          speed: [0, 0],
          ifc: {
            ipv4: [],
            ipv6: [],
          },
        };
      }
      Object.keys(infos).forEach((i) => {
        if (!interfaces.includes(i)) delete infos[i];
      });
    });
    await Promise.all([
      get_primary_if().then((a) => { primary_if = a; }),
      get_iwconfig().then((w) => {
        Object.keys(infos).forEach((i) => {
          delete infos[i].iwc;
        });
        w.forEach(i => {
          if (has(infos, i.name)) {
            infos[i.name].iwc = i as IfInfo['iwc'];
          }
        });
      }),
      get_ifconfig().then((a) => {
        a.forEach((i) => {
          if (has(infos, i.name)) {
            infos[i.name].ifc = i as IfInfo['ifc'];
          }
        });
      }),
    ]);
  };

  let last_usage: Record<string, [number, number]> = {};
  const speed_interval = 3;
  const update_speed = async () => {
    await get_usage().then((a) => {
      Object.keys(a).forEach((i) => {
        if (has(infos, i) && has(last_usage, i)) {
          infos[i].speed = [
            (a[i][0] - last_usage[i][0]) / speed_interval,
            (a[i][1] - last_usage[i][1]) / speed_interval,
          ];
        }
      });
      last_usage = a;
    });
  };

  await update_infos();
  await update_speed();
  await update(infos, primary_if);

  setInterval(async () => {
    await update_infos();
    await update(infos, primary_if);
  }, 10000);

  setInterval(async () => {
    await update_speed();
    await update(infos, primary_if);
  }, speed_interval * 1000);
}

await main();
