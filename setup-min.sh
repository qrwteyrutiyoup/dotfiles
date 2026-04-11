#!/bin/bash

# macOS: check for Homebrew and suggest missing packages
if [ "$(uname -s)" = "Darwin" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "ERROR: Homebrew not found. Install it first:"
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
  fi

  _missing=()
  for pkg in git vim tmux coreutils gnupg pinentry-mac; do
    if ! brew list "$pkg" &>/dev/null; then
      _missing+=("$pkg")
    fi
  done

  if [ ${#_missing[@]} -gt 0 ]; then
    echo "Missing recommended brew packages: ${_missing[*]}"
    read -p "Install them now? [Y/n] " _reply
    if [ -z "$_reply" ] || [ "$_reply" = "y" ] || [ "$_reply" = "Y" ]; then
      brew install "${_missing[@]}"
      # Point pinentry to the macOS-native version
      if [[ " ${_missing[*]} " =~ " pinentry-mac " ]]; then
        echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf 2>/dev/null
      fi
    else
      echo "Continuing without installing. Some features may not work fully."
    fi
  fi
fi

git submodule update --init
git submodule foreach git checkout master
git submodule foreach git pull

# Portable readlink -f (macOS doesn't have it)
_readlink_f() {
  local target="$1"
  cd "$(dirname "$target")" 2>/dev/null || return 1
  target="$(basename "$target")"
  while [ -L "$target" ]; do
    target="$(readlink "$target")"
    cd "$(dirname "$target")" 2>/dev/null || return 1
    target="$(basename "$target")"
  done
  echo "$(pwd -P)/$target"
}

_link_file() {
  local src="$1" dst="$2"
  if [ "$src" = "$(_readlink_f "$dst")" ]; then
    echo "Skipping $(basename "$dst")"
    return
  elif [ -e "$dst" ]; then
    local bkpfile="$(basename "$dst")-$(date +%Y%m%d%H%M%S)"
    echo "Backup'ing $(basename "$dst") as ~/.dotfiles-backup/$bkpfile"
    mkdir -p ~/.dotfiles-backup
    mv -f "$dst" ~/.dotfiles-backup/"$bkpfile"
  fi
  echo "Linking $src as $dst"
  ln -sf "$src" "$dst"
}

# Detect current shell and pick the right rc file
_current_shell="$(basename "$SHELL")"

for file in .vim .*.min; do
  dfile=${file/%.min/}

  # Shell-specific logic:
  # - Skip .bashrc.min on zsh-only systems
  # - Skip .zshrc.min on bash-only systems
  # - .shellrc.min is always installed
  case "$dfile" in
    .bashrc)
      [ "$_current_shell" != "bash" ] && [ "$_current_shell" != "sh" ] && continue
      ;;
    .zshrc)
      [ "$_current_shell" != "zsh" ] && continue
      ;;
    .inputrc)
      # readline is bash-specific; zsh has its own keybinding system
      [ "$_current_shell" = "zsh" ] && continue
      ;;
  esac

  _link_file "$PWD/$file" ~/"$dfile"
done

# Also install .gitconfig
_link_file "$PWD/.gitconfig" ~/.gitconfig

# Install vim-plug if not present
echo "Checking for vim-plug..."
if [ ! -f ~/.vim/autoload/plug.vim ]; then
    echo "Installing vim-plug..."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    echo "vim-plug already installed"
fi

# Install vim plugins
echo "Installing vim plugins..."
yes | vim +PlugInstall +qall

echo ""
echo "==========================================="
echo "Minimal setup complete! (shell: $_current_shell)"
echo "==========================================="
echo ""
echo "Installed plugins:"
echo "  - vim-sensible (sensible defaults)"
echo "  - vim-surround (surround text objects)"
echo "  - vim-commentary (easy commenting)"
echo "  - vim-fugitive (git integration)"
echo "  - awesome-vim-colorschemes"
echo ""
