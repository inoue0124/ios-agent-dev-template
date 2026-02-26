#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

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
        brew install "$formula"
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
xcodebuild -version | head -1

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
    info "Mintfile から CLI ツールをインストールしています..."
    mint bootstrap
    success "Mint bootstrap 完了"
fi

install_with_brew fastlane
install_with_brew gh

# Optional: Node.js
info "=== オプションツールの確認 ==="
if check_command node; then
    node --version
else
    warn "Node.js が見つかりません。XcodeBuildMCP を利用する場合は brew install node でインストールしてください。"
fi

# Optional: Docker
if check_command docker; then
    docker --version
else
    warn "Docker が見つかりません。xcodeproj-mcp-server を利用する場合はインストールしてください。"
fi

# ============================================================
# 3. ios-claude-plugins installation
# ============================================================
info "=== ios-claude-plugins ==="
if check_command claude; then
    info "ios-claude-plugins のインストールは Claude Code 内で以下を実行してください:"
    echo ""
    echo "  /plugin marketplace add inoue0124/ios-claude-plugins"
    echo ""
else
    warn "Claude Code が見つかりません。npm install -g @anthropic-ai/claude-code でインストールしてください。"
fi

# ============================================================
# 4. MCP server setup guidance
# ============================================================
info "=== MCP サーバー ==="
echo ""
echo "  以下のコマンドで MCP サーバーを追加できます（推奨）:"
echo ""
echo "  claude mcp add XcodeBuildMCP -- npx -y xcodebuildmcp@latest mcp"
echo "  claude mcp add xcodeproj -- docker run --pull=always --rm -i -v \$PWD:/workspace ghcr.io/giginet/xcodeproj-mcp-server:latest /workspace"
echo ""

# ============================================================
# 5. Project generation
# ============================================================
info "=== プロジェクト生成 ==="
cd "$PROJECT_DIR"

if [ -f "project.yml" ]; then
    info "XcodeGen でプロジェクトを生成しています..."
    xcodegen generate
    success "Xcode プロジェクトを生成しました"
else
    warn "project.yml が見つかりません。プロジェクト生成をスキップします。"
fi

info "SPM パッケージを解決しています..."
xcodebuild -resolvePackageDependencies 2>/dev/null || warn "SPM パッケージ解決をスキップしました"

# ============================================================
# 6. Git hooks installation
# ============================================================
info "=== Git hooks ==="
if [ -d "$PROJECT_DIR/hooks" ]; then
    git config core.hooksPath hooks
    success "Git hooks を有効化しました（hooks/）"
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
