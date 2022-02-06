import shell_escape from 'https://deno.land/x/shell_escape/index.ts';

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
  const tree_p = Deno.run({
    cmd: ["swaymsg", "-t", "get_tree"],
    stdout: "piped",
  });

  const j = JSON.parse(new TextDecoder().decode(await tree_p.output()));
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

  if (["Alacritty"].indexOf(app_id) != -1) {
    const pos = node.name.indexOf(": ");
    if (pos == -1) return null;
    return node.name.substring(pos + 2);
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

  Deno.run({
    cmd: ["swaymsg", "exec " + shell_escape(args)],
  });
}

main();
