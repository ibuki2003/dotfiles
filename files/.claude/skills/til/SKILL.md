---
description: 知見をノートに記録する
argument-hint: 記録するトピックの説明

disable-model-invocation: true
context: fork
---

今回の調査・作業で得られた知見を、将来活用できるように、ノートに記録してください。
記録には、Obsidian MCPツールを使用する。

destination: `/ai/${yyyymmdd}-${slug}.md`
slugには、トピックを簡潔に説明するascii文字列を使用してください。

## format

frontmatterには、

- date: !`date +"%Y-%m-%d"`
- tags: til

を含めること

以下の見出しを含める。

### 問題の調査・解決のとき

- 発生していた問題
- 調査の流れ
- 根本原因
- 解決策
- 参考 (調査中参照した、参考になるページへのリンク)

