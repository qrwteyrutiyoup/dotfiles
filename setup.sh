#!/bin/bash

# check if we have sudo already
if ! which sudo >/dev/null 2>/dev/null; then
    echo "Please install sudo first: # pacman -S sudo"
    exit 1
fi

echo "Installing required packages, if needed"
sudo pacman -S --needed gvim clang ctags git tmux xorg-xwininfo xorg-xprop gnome-terminal cmake ttf-ubuntu-font-family

git submodule update --init
git submodule foreach git checkout master
git submodule foreach git pull

for file in $(ls -A -I .git -I .gitignore -I .gitmodules -I README.md -I setup.sh -I .*.swp); do
    fqfile=$PWD/$file
    if [ "$fqfile" == $(readlink -f ~/$file) ]; then
        echo "Skipping "$file
        continue
    elif [ -e ~/$file ]; then
        bkpfile=$file-$(date +%Y%m%d%H%M%S)
        echo "Backup'ing "$file" as ~/.dotfiles-backup/"$bkpfile
        mkdir -p ~/.dotfiles-backup
        mv -f ~/$file ~/.dotfiles-backup/$bkpfile
    fi

    echo "Linking "$fqfile" as ~/"$file
    ln -sf $fqfile ~/
done

# install the bundles
echo "Installing vim bundles"
vim +BundleInstall +q +q
