# iOS Agent Dev Template

iOS アプリ開発を Claude Code（AI エージェント）と共に進めるためのスターターテンプレート。

このリポジトリをクローンしてセットアップスクリプトを実行するだけで、iOS + AI エージェント開発をすぐに始められる環境が整います。

## 概要

このテンプレートは以下を提供します。

- **ビルド可能な SwiftUI + MVVM のベースアプリ** — サンプル Feature Module 付きで、セットアップ直後にビルド・実行できる
- **iOS 開発ツールの自動セットアップ** — XcodeGen、SwiftLint、SwiftFormat、Fastlane、Mint、gh CLI を一括インストール
- **[ios-claude-plugins](https://github.com/inoue0124/ios-claude-plugins) の導入** — アーキテクチャガード、コード品質チェック、テスト生成、コードレビュー支援など 9 つのプラグイン
- **MCP サーバーの設定** — XcodeBuildMCP / xcodeproj-mcp-server でビルド・テスト・プロジェクト操作を AI エージェントから直接実行可能に
- **チーム開発の基盤** — GitHub テンプレート、CI ワークフロー、pre-commit hook、コーディング規約設定

## クイックスタート

### 事前に必要なもの

以下は setup.sh では自動インストールされません。事前にインストールしてください。

| ツール | インストール方法 |
|---|---|
| macOS | — |
| Xcode | App Store からインストール |
| Homebrew | https://brew.sh |
| Claude Code | `npm install -g @anthropic-ai/claude-code`（[公式ドキュメント](https://docs.anthropic.com/en/docs/claude-code)） |

### セットアップ手順

```bash
# 1. テンプレートをクローン
git clone https://github.com/inoue0124/ios-agent-dev-template.git <your-project-name>
cd <your-project-name>

# 2. セットアップスクリプトを実行（ツールインストール・プロジェクト生成）
./scripts/setup.sh

# 3. Xcode でプロジェクトを開く
open *.xcodeproj

# 4. AI エージェントと開発スタート
claude
```

## セットアップスクリプトが行うこと

`scripts/setup.sh` は以下を順に実行します。

1. **開発ツールのインストール**（未インストールのもののみ）
   - XcodeGen（project.yml から .xcodeproj を生成）
   - Mint（Swift 製 CLI ツールのバージョン管理）
   - SwiftLint / SwiftFormat（Mint 経由）
   - Fastlane（CI/CD 自動化・証明書管理・配信）
   - gh CLI（GitHub CLI）

2. **ios-claude-plugins のインストール**
   - プラグインストアからのプラグイン一括追加（9 種）

3. **MCP サーバーの設定**
   - XcodeBuildMCP — ビルド・テスト実行・シミュレータ操作
   - xcodeproj-mcp-server — Xcode プロジェクトファイル操作

4. **プロジェクト生成**
   - XcodeGen で project.yml から .xcodeproj を生成
   - SPM パッケージの解決
   - Git hooks のインストール

> Node.js（XcodeBuildMCP 用）と Docker（xcodeproj-mcp-server 用）は必須ではありませんが、インストールされていない場合は警告を表示します。

## セットアップ後の開発ワークフロー

セットアップ完了後、`claude` コマンドで AI エージェントと対話しながら開発を進められます。

### 日常の開発フロー

```
claude で新機能の実装を依頼
  ↓ アーキテクチャガード（ios-architecture）が MVVM 準拠を自動チェック
  ↓ コード品質チェック（swift-code-quality）が lint / format を実行
  ↓ テスト生成（swift-testing）がユニットテストを自動生成
  ↓ コミット時に pre-commit hook が最終チェック
  ↓ PR 作成時にレビュー支援（code-review-assist）が差分を分析
```

### よく使うコマンド例

| やりたいこと | Claude への指示例 |
|---|---|
| 新しい Feature Module を追加 | 「ログイン画面の Feature Module を作って」 |
| テストを書く | 「LoginViewModel のユニットテストを生成して」 |
| コードレビュー | `/pr-review` |
| PR を作成 | `/pr-create` |
| アーキテクチャ監査 | `/arch-audit` |

## ディレクトリ構成

```
<your-project-name>/
├── Sources/
│   ├── App/
│   │   ├── App.swift                  # SwiftUI エントリポイント
│   │   ├── ContentView.swift          # 初期画面
│   │   └── Info.plist
│   └── Features/
│       └── Sample/                    # MVVM サンプル Feature Module
│           ├── View/
│           ├── ViewModel/
│           ├── Model/
│           └── Repository/
├── Tests/
│   └── SampleFeatureTests/
├── scripts/
│   ├── setup.sh                       # 初回セットアップ
│   ├── clean.sh                       # キャッシュクリア
│   ├── bootstrap.sh                   # 依存解決・プロジェクト再生成
│   └── lint.sh                        # SwiftFormat + SwiftLint 一括実行
├── fastlane/
│   ├── Fastfile                       # レーン定義（build, test, beta）
│   └── Appfile                        # App ID / Apple ID 設定
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   ├── feature_request.md
│   │   └── task.md
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── workflows/
│   │   └── ci.yml                     # PR 時の自動ビルド・テスト・lint
│   └── dependabot.yml                 # SPM 依存の自動アップデート
├── project.yml                        # XcodeGen プロジェクト定義
├── Mintfile                           # SwiftLint / SwiftFormat バージョン固定
├── CLAUDE.md                          # AI エージェントへの指示書
├── .swiftlint.yml
├── .swiftformat
├── .editorconfig
└── .gitignore
```

> サンプル Feature Module（`Sources/Features/Sample/`）は MVVM パターンの実装例です。新機能追加時の参考にしてください。

## ユーティリティスクリプト

`scripts/` ディレクトリに開発中に使うユーティリティスクリプトを用意しています。

| スクリプト | 用途 | 実行タイミング |
|---|---|---|
| `scripts/setup.sh` | 初回環境セットアップ | リポジトリクローン直後 |
| `scripts/clean.sh` | キャッシュクリア + プロジェクト再生成 | ビルドがおかしい時 |
| `scripts/bootstrap.sh` | Mint bootstrap → XcodeGen → SPM resolve | ブランチ切替後・依存更新時 |
| `scripts/lint.sh` | SwiftFormat + SwiftLint 一括実行 | コミット前・CI |

### scripts/clean.sh の対象

- `~/Library/Developer/Xcode/DerivedData` — ビルドキャッシュ
- `.build/` — SPM ローカルキャッシュ
- `~/Library/Caches/org.swift.swiftpm` — SPM グローバルキャッシュ
- `Package.resolved` の削除 + 再解決
- `.xcodeproj` の再生成（XcodeGen）

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

## Git hooks

| フック | 内容 |
|---|---|
| `pre-commit` | SwiftFormat + SwiftLint を自動実行（`scripts/lint.sh` を呼び出し） |
| `commit-msg` | コミットメッセージのフォーマットチェック（Conventional Commits） |

> **ios-claude-plugins との役割分担について**
>
> ios-claude-plugins の `swift-code-quality` プラグインも SwiftLint / SwiftFormat を実行しますが、それは **Claude がコード編集中に品質を担保する**ためのものです。一方、pre-commit hook は **人間が手動でコミットする際のセーフティネット**として機能します。同じツールを使いますが実行タイミングと目的が異なるため、両方を併用する設計としています。

## ライセンス

MIT
