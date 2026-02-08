#!/bin/bash

set -e

echo "=========================================="
echo "Vim LSP Setup for Python, Go, Rust, Bash, C/C++"
echo "=========================================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."
if ! command -v vim &> /dev/null; then
    echo "Error: vim not found"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "Error: Node.js not found. Install with: sudo pacman -S nodejs npm"
    exit 1
fi

echo "✓ Vim $(vim --version | head -1 | awk '{print $5}')"
echo "✓ Node.js $(node --version)"
echo ""

# Install vim-plug if needed
echo "Installing vim-plug..."
if [ ! -f ~/.vim/autoload/plug.vim ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    echo "✓ vim-plug installed"
else
    echo "✓ vim-plug already installed"
fi
echo ""

# Install vim plugins
echo "Installing vim plugins..."
vim +PlugInstall +qall
echo "✓ Vim plugins installed"
echo ""

# Install coc.nvim language servers
echo "Installing coc.nvim language servers..."
vim -c 'CocInstall -sync coc-sh coc-pyright coc-clangd coc-go coc-rust-analyzer | qall' 2>&1 || true
echo "✓ Language servers installed"
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
    echo "  ✓ coc-pyright will provide LSP support (already installed via CocInstall)"
else
    echo "⚠ Python not found. Install with: sudo pacman -S python"
fi
echo ""

# Bash
echo "Checking Bash tooling..."
if command -v bash-language-server &> /dev/null; then
    echo "✓ bash-language-server already installed"
else
    echo "Installing bash-language-server..."
    npm install -g bash-language-server
fi
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
echo "LSP features available:"
echo "  gd          - Go to definition"
echo "  gr          - Find references"
echo "  K           - Show documentation"
echo "  <leader>rn  - Rename symbol"
echo "  <space>a    - Show diagnostics"
echo "  <Tab>       - Next completion"
echo "  <C-Space>   - Trigger completion"
echo ""
echo "Other features:"
echo "  <C-n>       - Toggle NERDTree"
echo "  <F8>        - Toggle Tagbar"
echo "  :Strip      - Remove trailing whitespace"
echo ""
echo "Next steps:"
echo "1. Open vim and test LSP: vim test.go"
echo "2. Press 'K' on a function to see docs"
echo "3. Press 'gd' on a symbol to go to definition"
echo ""
