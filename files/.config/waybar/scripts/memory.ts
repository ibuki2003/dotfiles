interface WaybarJson {
  text?: string;
  tooltip?: string;
  percentage?: number;
}

async function getMemoryStatus(): Promise<WaybarJson> {
  const raw = new TextDecoder().decode(await Deno.run({ cmd: ["free"], stdout: "piped" }).output());

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
    text += ` (+${Math.floor(usage["Swap"].used / usage["Swap"].total * 100)}%)`;
  }

  const percentage = usage["Mem"].used / usage["Mem"].total * 100;

  const human_readable = new TextDecoder().decode(await Deno.run({ cmd: ["free", "-h"], stdout: "piped" }).output());

  return {
    text,
    tooltip: human_readable,
    percentage,
  };
}

Deno.stdout.write(new TextEncoder().encode(JSON.stringify(await getMemoryStatus())));
