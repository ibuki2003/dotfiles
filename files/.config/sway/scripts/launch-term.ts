import shell_escape from "https://deno.land/x/shell_escape@1.0.0/index.ts";

type Node = {
  id: number;
  type: string;
  name: string;
  focused: boolean;

  app_id?: string;

  nodes: Node[];
  floating_nodes: Node[];
};

function* get_child_nodes(node: Node): Generator<Node> {
  yield node;
  for (const child of node.nodes) {
    yield* get_child_nodes(child);
  }
  for (const child of node.floating_nodes) {
    yield* get_child_nodes(child);
  }
}

async function* get_nodes(): AsyncGenerator<Node> {
  const tree_p = new Deno.Command("swaymsg", {
    args: ["-t", "get_tree"],
    stdout: "piped",
  });

  const j = JSON.parse(await (tree_p.output().then(s => new TextDecoder().decode(s.stdout))));
  yield* get_child_nodes(j);
}

async function get_focused_node() {
  for await (const node of get_nodes()) {
    if (node.focused) {
      return node;
    }
  }
}


async function get_focused_pwd(): Promise<string | null> {
  const node = await get_focused_node();

  if (!node) return null;

  const app_id = node.app_id;
  if (!app_id) return null;

  if (["Alacritty", "kitty"].indexOf(app_id) != -1) {
    const match = node.name.match(/^\w+: (.+?)( : .+)?$/);
    if (!match) return null;
    return match[1];
  }
  return null;
}

async function main() {
  if (Deno.args.length < 1) {
    console.log("Usage: launch-term.ts [terminal-emulator]");
    Deno.exit(1);
  }

  const args: string[] = [];
  args.push(Deno.args[0]);

  const pwd = await get_focused_pwd();
  if (pwd) {
    args.push("--working-directory", pwd.replace(/^~/, Deno.env.get("HOME") || ''));
  }

  console.log("exec " + shell_escape(args));
  await (new Deno.Command("swaymsg", {
    args: ["exec " + shell_escape(args)],
  })).spawn().status;
}

main();
