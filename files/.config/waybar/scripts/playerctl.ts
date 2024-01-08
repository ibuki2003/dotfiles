import { TextLineStream } from "https://deno.land/std@0.136.0/streams/mod.ts";
import { escape } from "https://deno.land/x/html_escape/escape.ts";

async function println(s: string) {
  return await Deno.stdout.write(new TextEncoder().encode(s + "\n"));
}

function ellipsis(s: string, n: number) {
  if (s.length <= n) {
    return s;
  }
  return s.slice(0, n - 1) + "…";
}

interface PlayerctlStatus {
  status: 'Playing' | 'Paused' | 'Stopped';
  album: string;
  artist: string;
  title: string;
  position: number;
  length: number;
}


async function* playerctlStream(): AsyncGenerator<PlayerctlStatus> {
  // start with empty status
  yield {
    status: 'Stopped',
    album: '',
    artist: '',
    title: '',
    position: 0,
    length: 0,
  };

  const p = new Deno.Command("playerctl", {
    args: [
      '-p', 'playerctld',
      '-F', 'metadata',
      '--format',
      [
        'status',
        'album',
        'artist',
        'title',
        'position',
        'mpris:length',
      ]
        .map((x) => `{{ ${x} }}`)
        .join('\t')
    ],
    stdout: 'piped',
  }).spawn();
  for await (const a of p.stdout.pipeThrough(new TextDecoderStream()).pipeThrough(new TextLineStream())) {
    const [
      status,
      album,
      artist,
      title,
      position,
      length,
    ] = a ? a.split('\t') : ['Stopped', '', '', '', '0']
    yield {
      status: status as PlayerctlStatus['status'],
      album,
      artist,
      title,
      position: parseInt(position),
      length: parseInt(length),
    };
  }
}

function format_duration(t: number) {
  if (isNaN(t)) return '--:--';

  t /= 1000000;
  const h = Math.floor(t / 60 / 60);
  const m = Math.floor(t / 60 % 60);
  const s = Math.floor(t % 60);

  if (h == 0) {
    return `${m}:${s.toString().padStart(2, '0')}`;
  }
  return `${h}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
}

async function main() {
  for await (const a of playerctlStream()) {
    const status_icon = {
      Playing: '󰏤',
      Paused:  '󰐊',
      Stopped: '󰓛',
    }[a.status] ?? '󰓛'

    const text = (
      `${status_icon} ${ellipsis(a.title, 30)}`
    );

    const tooltip = (
      `${a.album} - ${a.artist}\n` +
      `${a.title}\n` +
      `${a.status}\n` +
      `${format_duration(a.position)} / ${format_duration(a.length)}`
    );

    println(JSON.stringify({
      text: escape(text),
      tooltip: escape(tooltip),
    }));

  }
}

main();
