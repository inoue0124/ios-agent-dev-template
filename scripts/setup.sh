#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Prevent brew from running slow auto-update on every install
export HOMEBREW_NO_AUTO_UPDATE=1

# ============================================================
# Colored logging
# ============================================================
info()    { printf "\033[1;34m[INFO]\033[0m  %s\n" "$1"; }
success() { printf "\033[1;32m[OK]\033[0m    %s\n" "$1"; }
warn()    { printf "\033[1;33m[WARN]\033[0m  %s\n" "$1"; }
error()   { printf "\033[1;31m[ERROR]\033[0m %s\n" "$1"; exit 1; }

check_command() {
    if command -v "$1" &>/dev/null; then
        success "$1 が見つかりました"
        return 0
    else
        return 1
    fi
}

install_with_brew() {
    local formula="$1"
    local name="${2:-$formula}"
    if ! check_command "$name"; then
        info "$name をインストールしています..."
        if ! brew install "$formula"; then
            warn "$name のインストールに失敗しました。後で手動でインストールしてください。"
            return 0
        fi
        success "$name をインストールしました"
    fi
}

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║   iOS Agent Dev Template - Setup     ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# ============================================================
# 1. Prerequisites check
# ============================================================
info "=== 前提条件の確認 ==="

# Xcode
if ! check_command xcodebuild; then
    error "Xcode がインストールされていません。App Store からインストールしてください。"
fi
# sed -n '1p' reads all input (no SIGPIPE), unlike head -1 which closes the pipe early
xcodebuild -version 2>&1 | sed -n '1p'

# Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    info "Xcode Command Line Tools をインストールしています..."
    xcode-select --install
    warn "インストール完了後、再度このスクリプトを実行してください。"
    exit 0
fi
success "Xcode Command Line Tools が見つかりました"

# Homebrew
if ! check_command brew; then
    error "Homebrew がインストールされていません。https://brew.sh を参照してください。"
fi

# ============================================================
# 2. Install development tools
# ============================================================
info "=== 開発ツールのインストール ==="

install_with_brew xcodegen
install_with_brew mint

# SwiftLint / SwiftFormat via Mint
cd "$PROJECT_DIR"
if [ -f "Mintfile" ]; then
    info "Mintfile から CLI ツールをインストールしています（初回はビルドに時間がかかります）..."
    if mint bootstrap; then
        success "Mint bootstrap 完了"
    else
        warn "Mint bootstrap に失敗しました。後で mint bootstrap を手動で実行してください。"
    fi
fi

install_with_brew fastlane
install_with_brew gh

# ============================================================
# 3. MCP server auto-setup
# ============================================================
info "=== MCP サーバーセットアップ ==="

install_with_brew node
if ! check_command docker; then
    info "Docker をインストールしています..."
    if ! brew install --cask docker; then
        warn "Docker のインストールに失敗しました。https://www.docker.com から手動でインストールしてください。"
    else
        success "Docker をインストールしました"
    fi
fi

SETTINGS_DIR="$PROJECT_DIR/.claude"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

# Regenerate settings.json only if it is missing (e.g. deleted by user).
# The repository ships a pre-configured .claude/settings.json that includes
# mcpServers, enabledPlugins, and extraKnownMarketplaces.  When a user
# trusts this project folder, Claude Code will auto-prompt to register the
# ios-claude-plugins marketplace via extraKnownMarketplaces.
if [ -f "$SETTINGS_FILE" ]; then
    info ".claude/settings.json は既に存在します。スキップします。"
else
    mkdir -p "$SETTINGS_DIR"
    cat > "$SETTINGS_FILE" << 'SETTINGS_EOF'
{
  "extraKnownMarketplaces": {
    "ios-claude-plugins": {
      "source": {
        "source": "github",
        "repo": "inoue0124/ios-claude-plugins"
      }
    }
  },
  "enabledPlugins": {
    "ios-architecture@ios-claude-plugins": true,
    "team-conventions@ios-claude-plugins": true,
    "swift-code-quality@ios-claude-plugins": true,
    "swift-testing@ios-claude-plugins": true,
    "github-workflow@ios-claude-plugins": true,
    "code-review-assist@ios-claude-plugins": true,
    "ios-onboarding@ios-claude-plugins": true,
    "feature-module-gen@ios-claude-plugins": true,
    "ios-distribution@ios-claude-plugins": true,
    "feature-implementation@ios-claude-plugins": true
  },
  "mcpServers": {
    "XcodeBuildMCP": {
      "command": "npx",
      "args": ["-y", "xcodebuildmcp@latest", "mcp"]
    },
    "xcodeproj": {
      "command": "docker",
      "args": ["run", "--pull=always", "--rm", "-i", "-v", "$PWD:/workspace", "ghcr.io/giginet/xcodeproj-mcp-server:latest", "/workspace"]
    }
  }
}
SETTINGS_EOF
    success ".claude/settings.json を生成しました（MCP + プラグイン設定）"
fi

# ============================================================
# 4. Project generation
# ============================================================
info "=== プロジェクト生成 ==="
cd "$PROJECT_DIR"

if [ -f "project.yml" ]; then
    info "XcodeGen でプロジェクトを生成しています..."
    if xcodegen generate; then
        success "Xcode プロジェクトを生成しました"
    else
        warn "XcodeGen によるプロジェクト生成に失敗しました。project.yml を確認してください。"
    fi
else
    warn "project.yml が見つかりません。プロジェクト生成をスキップします。"
fi

# Resolve SPM packages only if a project file exists
if ls "$PROJECT_DIR"/*.xcodeproj &>/dev/null; then
    info "SPM パッケージを解決しています..."
    if xcodebuild -resolvePackageDependencies; then
        success "SPM パッケージ解決完了"
    else
        warn "SPM パッケージ解決に失敗しました。Xcode で手動解決してください。"
    fi
else
    warn ".xcodeproj が見つからないため、SPM パッケージ解決をスキップします。"
fi

# ============================================================
# 5. Git hooks installation
# ============================================================
info "=== Git hooks ==="
if [ -d "$PROJECT_DIR/scripts/hooks" ]; then
    git config core.hooksPath scripts/hooks
    success "Git hooks を有効化しました（scripts/hooks/）"
fi

# ============================================================
# Done
# ============================================================
echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║         セットアップ完了！            ║"
echo "  ╚══════════════════════════════════════╝"
echo ""
success "以下のコマンドで開発を開始できます:"
echo ""
echo "  open *.xcodeproj   # Xcode でプロジェクトを開く"
echo "  claude             # AI エージェントと開発スタート"
echo ""
