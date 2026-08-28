# このディレクトリの構成

このディレクトリは、対話用 Zsh の設定と autoload 関数を管理する。
リポジトリ内の `files/.zshrc` は `files/.zsh/init.zsh` へのシンボリックリンクであり、`init.zsh` が起動時の入口になる。

## 読み込みの流れ

1. `init.zsh` が `make -C "$ZSHHOME" --silent` を実行する。
2. `Makefile` が `opts/*.zsh` と `lazy/*.zsh` をそれぞれファイル名順に結合し、`opts.cat.zsh`、`lazy.cat.zsh` とその `.zwc` を生成する。
3. `init.zsh` は `opts.cat.zsh` を直ちに読み込む。
4. `lazy.cat.zsh` は `zsh-defer` が利用できれば遅延して、利用できなければ直ちに読み込む。

結合ファイル、`.zwc`、`sheldon/.compiled.zsh` は生成物であり、Git では管理しない。
`*local.zsh` も個別環境用として無視されるが、`Makefile` の wildcard には含まれる。

## ディレクトリと責務

- `init.zsh`
  - 履歴、共通の初期状態、生成済み設定の読み込みを担当する。
  - 個別機能の設定はここへ増やさず、原則として `opts/` または `lazy/` に置く。
- `opts/`
  - プロンプト表示前に必要な設定を置く。
  - 数字の接頭辞が読み込み順を表す。現在は、基本オプションとパス (`00`–`01`)、プラグインのロード (`02`)、キーと ZLE (`10`)、エイリアスや表示 (`20`)、補完 (`50`)、プラグイン固有設定 (`60`) の順になっている。
  - 後続ファイルが前段の状態に依存する場合は、この順序を保つ。
- `lazy/`
  - 初回プロンプトを出す前に必須ではない初期化を置く。
  - `20-functions.zsh` が `functions/` 配下を autoload し、`30-programs.zsh` が外部コマンドに応じた環境設定を行う。`61-*` は Sheldon で読み込んだ anyframe などに依存するウィジェット設定を持つ。
- `functions/`
  - `fpath` に追加され、`lazy/20-functions.zsh` から autoload される一関数一ファイルの置き場。
  - `_` で始まるファイルは主に補完関数である。`_gpp` のように同名コマンド関数と対になるものもある。
  - `pbcopy` / `pbpaste` と `clip`、`gpp` と `_gpp` のような関連する実装は、同じ名前体系を維持する。
- `sheldon/plugins.toml`
  - Sheldon がロードする外部 Zsh プラグインを宣言する。
  - `opts/02-sheldon.zsh` がこれを基に `sheldon/.compiled.zsh` を更新して読み込む。
- `tests/completion.zsh`
  - `zpty` 上に隔離した Zsh を起動し、`functions/_mycompleter`、`functions/_fuzzy_path_prefix`、`opts/50-completion.zsh` にまたがるパス補完の挙動を検証する。
  - `tests/fixtures/carapace` を一時的な `PATH` の先頭へ配置し、carapace の初期化コードと候補プロトコルを外部バージョンに依存せず再現する。
  - `Makefile` の `test` ターゲットから実行される。

## 新しいファイルを追加する場所

- 起動直後から必要なシェルオプション、パス、キー設定、補完設定は `opts/<順序>-<役割>.zsh` に追加する。
- 外部コマンドやプラグインが存在するときだけ必要で、遅延可能な設定は `lazy/<順序>-<役割>.zsh` に追加する。
- コマンドとして呼び出す独立した処理は `functions/<関数名>` に置き、対応する補完が必要なら `functions/_<コマンド名>` を併設する。
- Sheldon 管理のプラグイン追加は `sheldon/plugins.toml` に記述し、そのプラグインを使う設定はロード順を考慮して `opts/` または `lazy/` に分離する。
- 補完ロジックを変更・追加する場合は、実装場所に加えて `tests/completion.zsh` に回帰ケースを追加する。別分野のテストが増える場合は `tests/<対象>.zsh` とし、`Makefile` の `test` から実行できるようにする。
- 補完テストの fixture は、意図を損なわない限り既存のファイルやディレクトリを再利用する。ケースごとに専用ファイルを増やさず、新しい形状が必要な場合だけ最小限追加する。
- 既存ファイルと責務が同じ小さな設定は既存ファイルへ追記する。独立した責務を持つ場合だけ新しい連番ファイルを作り、番号は依存関係を表すために使う。
- マシン固有・非公開の設定は `*local.zsh` とする。共有すべき設定を便宜上ローカルファイルへ置かない。

## 変更時の確認

- 読み込み順や通常設定を変更した場合は `make` で結合・コンパイルできることを確認する。
- 補完に関係する変更では `make test` を実行する。
- 生成された `*.cat.zsh`、`*.zwc`、`sheldon/.compiled.zsh` はコミットしない。
