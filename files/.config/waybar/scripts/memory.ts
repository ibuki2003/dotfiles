const enc = new TextEncoder();
const dec = new TextDecoder();

interface WaybarJson {
  text?: string;
  tooltip?: string;
  percentage?: number;
}

function format_table(str: string): string {
  const lines = str.split("\n");
  const cols: number[] = [];

  let streak = 0;
  for (let i = 0; ; i++) {
    if (lines.every(l => i >= l.length)) break;
    if (lines.every(l => i >= l.length || l[i] == " ")) {
      ++streak;
      if (streak >= 3) {
        cols.push(i);
      }
    } else {
      streak = 0;
    }
  }

  return lines.map(l => (
    l.split("")
      .filter((_, i) => !cols.includes(i))
      .join("")
  )).join("\n");
}


function getMemoryStatus(): WaybarJson {
  const raw = dec.decode(new Deno.Command("free", { args: [], stdout: "piped" }).outputSync().stdout);

  const usage = raw.split("\n").slice(1).reduce((acc: {[type: string]: {total: number, used:number}}, line) => {
    if (!line.trim()) return acc;
    const [type, total, used] = line.split(/[\s:]+/).filter(Boolean);
    acc[type] = {
      total: parseInt(total),
      used: parseInt(used),
    };
    return acc;
  }, {});

  let text = "";

  text += `${Math.floor(usage["Mem"].used / usage["Mem"].total * 100)}%`;

  if (usage["Swap"].total != 0) {
    text += `+${Math.floor(usage["Swap"].used / usage["Swap"].total * 100)}%`;
  }

  const percentage = usage["Mem"].used / usage["Mem"].total * 100;

  const human_readable_raw = dec.decode(new Deno.Command("free", { args: ["-h"], stdout: "piped" }).outputSync().stdout);

  const human_readable = format_table(human_readable_raw);

  return {
    text,
    tooltip: human_readable,
    percentage,
  };
}

function write(payload: unknown) {
  Deno.stdout.write(enc.encode(JSON.stringify(payload) + '\n'));
}

write(getMemoryStatus()); // first execution
setInterval(() => write(getMemoryStatus()), 3000);
