import { TextLineStream } from "https://deno.land/std@0.136.0/streams/mod.ts";

async function println(s: string) {
  return await Deno.stdout.write(new TextEncoder().encode(s + "\n"));
}

function ellipsis(s: string, n: number) {
  if (s.length <= n) {
    return s;
  }
  return s.slice(0, n - 1) + "…";
}

async function* playerctlStream() {
  // start with empty status
  yield { status: 'Stopped', album: '', artist: '', title: '' };

  const p = new Deno.Command("playerctl", {
    args: [
      '-p', 'playerctld',
      '-F', 'metadata',
      '--format',
      ['status', 'album', 'artist', 'title']
        .map((x) => `{{ ${x} }}`)
        .join('\t')
    ],
    stdout: 'piped',
  }).spawn();
  for await (const a of p.stdout.pipeThrough(new TextDecoderStream()).pipeThrough(new TextLineStream())) {
    const [status, album, artist, title] = a ? a.split('\t') : ['Stopped', '', '', '']
    yield { status, album, artist, title };
  }
}

async function main() {
  for await (const a of playerctlStream()) {
    const status_icon = {
      Playing: '󰏤',
      Paused:  '󰐊',
      Stopped: '󰓛',
    }[a.status] ?? '󰓛'

    println(
      `%{A:playerctl -p playerctld previous:}󰒮%{A} ` +
      `%{A:playerctl -p playerctld play-pause:}${status_icon} ${ellipsis(a.album, 20)} - ${ellipsis(a.title, 30)} %{A} ` +
      `%{A:playerctl -p playerctld next:}󰒭%{A} `
    );
  }
}

main();
