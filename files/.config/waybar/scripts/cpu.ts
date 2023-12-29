async function getCpuStat() {
  const text = await Deno.readTextFile("/proc/stat");
  return text
    .split("\n")
    .filter(l => l.startsWith("cpu"))
    .map(l => {
      const [_, ...rest] = l.split(/\s+/);
      const values = rest.map(v => parseInt(v));
      const total = values.reduce((acc, v) => acc + v, 0);
      return [
        total,
        ...values,
      ];
    });
}

async function output(payload: {
  text: string;
  tooltip: string;
  percentage: number;
}) {
  await Deno.stdout.write(new TextEncoder().encode(JSON.stringify(payload) + '\n'));
}

async function main() {
  let last = await getCpuStat();
  const num_cpus = last.length - 1;

  setInterval(async () => {
    const current = await getCpuStat();

    const diff = current.map((c, i) => c.map((v, j) => v - last[i][j]));
    const [diff_sum, ...diff_each] = diff;

    const cpu_usages = diff_each.map(d => (1 - d[4] / d[0]));

    const text = `${Math.round((1 - diff_sum[4] / diff_sum[0]) * num_cpus * 100)}%`;
    const percentage = Math.round((1 - diff_sum[4] / diff_sum[0]) * 100);
    const tooltip = (
      "<span face='Sparks Bar Medium' size='20pt'>{" +
      cpu_usages.map(v => Math.floor(v * 100)).join(',') +
      "}</span>\n" +
      (["user", "nice", "system", "idle", "iowait", "irq", "softirq", "steal", "guest", "guest_nice"].map((name, i) => (
        `${name}: ${Math.floor(diff_sum[i + 1] / diff_sum[0] * 100 * num_cpus)}%`
      )).join("\n"))
    );


    await output({
      text,
      tooltip,
      percentage,
    });

    last = current;
  }, 1000);
}

await main();
