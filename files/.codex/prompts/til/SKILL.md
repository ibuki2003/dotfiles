---
description: 知見をノートに記録する
argument-hint: 記録するトピックの説明

disable-model-invocation: true
---

今回の調査・作業で得られた知見を、将来活用できるように、ノートに記録してください。
記録にはObsidian MCPツールを使用

destination: `/ai/${yyyymmdd}-${slug}.md`
slugには、トピックを簡潔に説明するascii文字列を使用してください。

## format

frontmatterには、

- date: !`date +"%Y-%m-%d"`
- tags: til

を含めること

見出しの構成は、以下に該当するパターンがあるならそれを使用、なければいい感じに

### 問題の調査・解決のとき

備忘録、作業記録として、時系列を意識した構成

- 発生していた問題
- 調査の流れ
- 根本原因
- 解決策
- 参考 (調査中参照した、参考になるページへのリンク)

