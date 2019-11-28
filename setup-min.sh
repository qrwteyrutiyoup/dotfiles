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

# install the vim bundles
echo "Installing vim bundles"
vim +BundleInstall +q +q
