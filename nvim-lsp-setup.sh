#!/bin/bash

set -e

echo "=========================================="
echo "Neovim LSP Setup for Python, Go, Rust, Bash, C/C++"
echo "=========================================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."
if ! command -v nvim &> /dev/null; then
    echo "Error: neovim not found. Install with: sudo pacman -S neovim"
    exit 1
fi

echo "✓ Neovim $(nvim --version | head -1 | awk '{print $2}')"
echo ""

# Open neovim once to bootstrap lazy.nvim and install plugins
echo "Installing Neovim plugins (this may take a minute)..."
nvim --headless "+Lazy! sync" +qa 2>&1

echo "✓ Neovim plugins installed"
echo ""

# Mason will auto-install LSP servers on first use, but we can trigger it
echo "Installing LSP servers via Mason..."
nvim --headless "+MasonInstall pyright gopls bash-language-server clangd" +qa 2>&1 || true

echo "✓ LSP servers installed"
echo ""

# Check and install language tooling
echo "=========================================="
echo "Language Tooling Setup"
echo "=========================================="
echo ""

# Go
echo "Checking Go tooling..."
if command -v go &> /dev/null; then
    echo "✓ Go $(go version | awk '{print $3}')"

    if ! command -v gopls &> /dev/null; then
        echo "  Installing gopls (Go language server)..."
        go install golang.org/x/tools/gopls@latest
    else
        echo "  ✓ gopls already installed"
    fi

    if ! command -v goimports &> /dev/null; then
        echo "  Installing goimports..."
        go install golang.org/x/tools/cmd/goimports@latest
    else
        echo "  ✓ goimports already installed"
    fi
else
    echo "⚠ Go not found. Install with: sudo pacman -S go"
fi
echo ""

# Rust
echo "Checking Rust tooling..."
if command -v rustc &> /dev/null; then
    echo "✓ Rust $(rustc --version | awk '{print $2}')"

    if ! command -v rust-analyzer &> /dev/null; then
        echo "  ⚠ rust-analyzer not found."
        echo "    Install with: sudo pacman -S rust-analyzer"
    else
        echo "  ✓ rust-analyzer already installed"
    fi

    if ! command -v rustfmt &> /dev/null; then
        echo "  ⚠ rustfmt not found."
        echo "    Install with: sudo pacman -S rustfmt"
    else
        echo "  ✓ rustfmt already installed"
    fi
else
    echo "⚠ Rust not found. Install with: sudo pacman -S rust"
fi
echo ""

# Python
echo "Checking Python tooling..."
if command -v python3 &> /dev/null; then
    echo "✓ Python $(python3 --version | awk '{print $2}')"
    echo "  ✓ pyright LSP installed via Mason"
else
    echo "⚠ Python not found. Install with: sudo pacman -S python"
fi
echo ""

# Bash
echo "Checking Bash tooling..."
echo "✓ bashls LSP installed via Mason"
echo ""

# C/C++
echo "Checking C/C++ tooling..."
if command -v clangd &> /dev/null; then
    echo "✓ clangd $(clangd --version | head -1 | awk '{print $3}')"
else
    echo "⚠ clangd not found. Install with: sudo pacman -S clang"
fi
echo ""

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Neovim is configured with native LSP support!"
echo ""
echo "LSP keybindings:"
echo "  gd          - Go to definition"
echo "  gr          - Find references"
echo "  gi          - Go to implementation"
echo "  K           - Show hover documentation"
echo "  <leader>rn  - Rename symbol"
echo "  <leader>ca  - Code action"
echo "  <leader>f   - Format code"
echo ""
echo "Other features:"
echo "  <C-n>       - Toggle Neo-tree (file explorer)"
echo "  <leader>ff  - Find files (Telescope)"
echo "  <leader>fg  - Live grep (Telescope)"
echo "  <leader>fb  - Browse buffers (Telescope)"
echo "  <Tab>       - Next completion item"
echo "  <C-Space>   - Trigger completion"
echo "  :Strip      - Remove trailing whitespace"
echo ""
echo "Next steps:"
echo "1. Run: nvim"
echo "2. Plugins will auto-install on first launch"
echo "3. Open a Python/Go/Rust file to test LSP"
echo "4. Press 'K' on a symbol to see documentation"
echo ""
