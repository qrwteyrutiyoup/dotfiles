#!/bin/bash

git submodule update --init
git submodule foreach git checkout master
git submodule foreach git pull

for file in .vim .*.min; do
    dfile=${file/%.min/}
    fqfile=$PWD/$file
    if [ "$fqfile" == $(readlink -f ~/$file) ]; then
        echo "Skipping "$file
        continue
    elif [ -e ~/${dfile} ]; then
        bkpfile=$dfile-$(date +%Y%m%d%H%M%S)
        echo "Backup'ing "${dfile}" as ~/.dotfiles-backup/"$bkpfile
        mkdir -p ~/.dotfiles-backup
        mv -f ~/${dfile} ~/.dotfiles-backup/$bkpfile
    fi

    echo "Linking "$fqfile" as ~/"$dfile
    ln -sf $fqfile ~/${dfile}
done

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
echo "Minimal vim setup complete!"
echo "==========================================="
echo ""
echo "Installed plugins:"
echo "  - vim-sensible (sensible defaults)"
echo "  - vim-surround (surround text objects)"
echo "  - vim-commentary (easy commenting)"
echo "  - vim-fugitive (git integration)"
echo "  - awesome-vim-colorschemes"
echo ""
