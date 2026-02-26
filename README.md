# iOS Agent Dev Template

iOS アプリ開発を Claude Code（AI エージェント）と共に進めるためのスターターテンプレート。

このリポジトリをクローンしてセットアップスクリプトを実行するだけで、iOS + AI エージェント開発をすぐに始められる環境が整います。

## 概要

このテンプレートは以下を一括でセットアップします。

- **iOS 開発の基本環境** — Xcode、XcodeGen、SwiftLint、SwiftFormat、Fastlane、Mint、gh CLI など必要なツールの検証・インストール
- **[ios-claude-plugins](https://github.com/inoue0124/ios-claude-plugins) の導入** — アーキテクチャガード、コード品質チェック、テスト生成、コードレビュー支援など、iOS チーム開発を包括的にサポートする Claude Code プラグイン群
- **MCP サーバーの設定** — XcodeBuildMCP / xcodeproj-mcp-server の導入（ビルド・テスト実行・プロジェクト構造操作を AI エージェントから直接操作可能に）
- **プロジェクト規約の初期設定** — CLAUDE.md、SwiftLint / SwiftFormat 設定ファイルなど

## クイックスタート

```bash
# 1. テンプレートをクローン
git clone https://github.com/inoue0124/ios-agent-dev-template.git <your-project-name>
cd <your-project-name>

# 2. セットアップスクリプトを実行
./scripts/setup.sh

# 3. 開発スタート
claude
```

## セットアップスクリプトが行うこと

`setup.sh` は以下を順に実行します。

1. **前提ツールの確認・インストール**
   - Xcode（xcodebuild）
   - Homebrew
   - XcodeGen（project.yml から .xcodeproj を生成）
   - Mint（Swift 製 CLI ツールのバージョン管理）
   - SwiftLint / SwiftFormat
   - Fastlane（CI/CD 自動化・証明書管理・配信）
   - gh CLI（GitHub CLI）
   - Node.js（MCP サーバー用）
   - Docker（xcodeproj-mcp-server 用、オプション）

2. **ios-claude-plugins のインストール**
   - プラグインストアからのプラグイン一括追加
   - 9 つのプラグイン（アーキテクチャガード、規約エンフォーサー、コード品質、テスト、GitHub ワークフロー、コードレビュー、オンボーディング、Feature Module 生成、配信）

3. **MCP サーバーの設定**
   - XcodeBuildMCP — ビルド・テスト実行・シミュレータ操作
   - xcodeproj-mcp-server — Xcode プロジェクトファイル操作

4. **プロジェクト初期ファイルの配置**
   - CLAUDE.md（エージェントへの指示書）
   - .swiftlint.yml / .swiftformat
   - Mintfile（SwiftLint / SwiftFormat のバージョン固定）
   - .gitignore
   - GitHub テンプレート（Issue / PR）
   - Git hooks（pre-commit）

## 前提条件

| ツール | 用途 | 必須 |
|---|---|---|
| macOS | iOS 開発環境 | 必須 |
| Xcode | ビルド・テスト実行 | 必須 |
| Claude Code | AI エージェント CLI | 必須 |
| Homebrew | パッケージ管理 | 必須 |
| XcodeGen | project.yml から .xcodeproj を生成 | 必須（setup.sh で自動インストール） |
| Mint | Swift 製 CLI ツールのバージョン管理 | 必須（setup.sh で自動インストール） |
| SwiftLint | コード品質チェック | 必須（Mint で管理） |
| SwiftFormat | コードフォーマット | 必須（Mint で管理） |
| Fastlane | CI/CD 自動化・証明書管理・TestFlight 配信 | 必須（setup.sh で自動インストール） |
| gh CLI | GitHub issue / PR 操作 | 必須（setup.sh で自動インストール） |
| Node.js 18+ | XcodeBuildMCP の実行 | 推奨 |
| Docker | xcodeproj-mcp-server の実行 | 推奨 |

## 導入されるプラグイン

[ios-claude-plugins](https://github.com/inoue0124/ios-claude-plugins) から以下のプラグインが導入されます。

| プラグイン | 説明 |
|---|---|
| ios-architecture | MVVM パターンの構造チェック・レイヤー間依存方向検査 |
| team-conventions | コーディング規約・命名規則・ブランチ運用ルールの自動検査 |
| swift-code-quality | SwiftLint / SwiftFormat による静的解析・構文チェック |
| swift-testing | テスト生成・実行・カバレッジ分析 |
| github-workflow | 構造化 issue 作成・差分解析に基づく PR 作成 |
| code-review-assist | PR 差分分析・レビューコメント生成・影響範囲特定 |
| ios-onboarding | プロジェクト構造の自動解説・用語集・変更要約 |
| feature-module-gen | SwiftUI + MVVM の Feature Module 雛形一式生成 |
| ios-distribution | TestFlight 配信・署名の自動化 |

## ユーティリティスクリプト

`scripts/` ディレクトリに開発中に使うユーティリティスクリプトを用意しています。

| スクリプト | 用途 | 実行タイミング |
|---|---|---|
| `scripts/setup.sh` | 初回環境セットアップ（ツール確認・インストール・MCP 設定） | リポジトリクローン直後 |
| `scripts/clean.sh` | キャッシュクリア + プロジェクト再生成 | ビルドがおかしい時 |
| `scripts/bootstrap.sh` | Mint bootstrap → XcodeGen → SPM resolve | ブランチ切替後・依存更新時 |
| `scripts/lint.sh` | SwiftFormat + SwiftLint 一括実行 | コミット前・CI |

### scripts/clean.sh の対象

- `~/Library/Developer/Xcode/DerivedData` — ビルドキャッシュ
- `.build/` — SPM ローカルキャッシュ
- `~/Library/Caches/org.swift.swiftpm` — SPM グローバルキャッシュ
- `Package.resolved` の削除 + 再解決
- `.xcodeproj` の再生成（XcodeGen）

## テンプレートファイル

クローン時に含まれるテンプレートファイル一覧。

### GitHub テンプレート

| ファイル | 内容 |
|---|---|
| `.github/ISSUE_TEMPLATE/bug_report.md` | バグ報告テンプレート |
| `.github/ISSUE_TEMPLATE/feature_request.md` | 機能要望テンプレート |
| `.github/ISSUE_TEMPLATE/task.md` | タスクテンプレート |
| `.github/PULL_REQUEST_TEMPLATE.md` | PR テンプレート（変更概要・テスト計画・チェックリスト） |

### Git hooks

| フック | 内容 |
|---|---|
| `pre-commit` | SwiftFormat + SwiftLint を自動実行（`scripts/lint.sh` を呼び出し） |
| `commit-msg` | コミットメッセージのフォーマットチェック（Conventional Commits） |

> **ios-claude-plugins との役割分担について**
>
> ios-claude-plugins の `swift-code-quality` プラグインも SwiftLint / SwiftFormat を実行しますが、それは **Claude がコード編集中に品質を担保する**ためのものです。一方、pre-commit hook は **人間が手動でコミットする際のセーフティネット**として機能します。同じツールを使いますが実行タイミングと目的が異なるため、両方を併用する設計としています。

### プロジェクト設定ファイル

| ファイル | 内容 |
|---|---|
| `CLAUDE.md` | AI エージェントへの指示書（アーキテクチャ方針・コーディング規約） |
| `Mintfile` | SwiftLint / SwiftFormat のバージョン固定 |
| `.swiftlint.yml` | SwiftLint ルール設定 |
| `.swiftformat` | SwiftFormat ルール設定 |
| `.gitignore` | Xcode / SPM / DerivedData / Fastlane 等の除外設定 |

## ライセンス

MIT
