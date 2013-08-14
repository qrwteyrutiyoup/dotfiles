# If not running interactively, do not do anything.
[[ $- != *i* ]] && return

_set_dircolors()
{
    local DIRCOLORS=~/.dircolors
    if [ -f "$DIRCOLORS" ]; then
        eval $(dircolors "$DIRCOLORS")
    else
        echo "Please install a dircolors file at [$DIRCOLORS]; e.g: https://raw.github.com/seebi/dircolors-solarized/master/dircolors.256dark"
    fi
}
_package_installed()
{
    local pkg=$1
    if [ -z "$pkg" ]; then
        echo "Please provide a package name to check whether it's installed."
        return
    fi

    pacman -Q "$pkg" 2>/dev/null >/dev/null
    return $?
}

_enable_ubuntu_fonts()
{
    # nicer-looking font rendering
    gsettings "set" "org.gnome.settings-daemon.plugins.xsettings" "hinting" "slight"
    gsettings "set" "org.gnome.settings-daemon.plugins.xsettings" "antialiasing" "rgba"

    for p in freetype2-ubuntu fontconfig-ubuntu cairo-ubuntu; do
        if ! _package_installed "$p"; then
            echo "-> Please install package '"$p"' from the AUR"
        fi
    done
}

# adapted from https://github.com/sigurdga/gnome-terminal-colors-solarized
_gnome_terminal_solarized_dark()
{
    local force=$1
    local SOLARIZED_TERMINAL=~/.config/.solarized
    if [[ -f "$SOLARIZED_TERMINAL" ]] && [[ -z $force ]]; then
        return
    fi

    local dconfdir=/org/gnome/terminal/legacy/profiles:
    local profiles=($(dconf list $dconfdir/ | grep ^: | sed 's/\///g'))
    local profile_id="b1dcc9dd-5262-4d8d-a863-c897e6d979b9"
    local profile_path=$dconfdir/:$profile_id

    # create new profile if it doesn't yet exist
    if [ $(dconf list $dconfdir/:$profile_id/ | wc -l) -eq 0 ]; then
        dconf write $dconfdir/default "'$profile_id'"
        dconf write $dconfdir/list "['$profile_id']"
        profile_dir="$dconfdir/:$profile_id"
        dconf write $profile_dir/visible-name "'qrwteyrutiyoup'"
    fi

    # solarized dark
    local bg_color="#00002B2B3636"
    local fg_color="#838394949696"
    local bd_color="#9393a1a1a1a1"

    # set color palette
    dconf write $profile_path/palette "['#070736364242', '#DCDC32322F2F', '#858599990000', '#B5B589890000', '#26268B8BD2D2', '#D3D336368282', '#2A2AA1A19898', '#EEEEE8E8D5D5', '#00002B2B3636', '#CBCB4B4B1616', '#58586E6E7575', '#65657B7B8383', '#838394949696', '#6C6C7171C4C4', '#9393A1A1A1A1', '#FDFDF6F6E3E3']"

    # set foreground, background and highlight color
    dconf write $profile_path/bold-color "'$bd_color'"
    dconf write $profile_path/background-color "'$bg_color'"
    dconf write $profile_path/foreground-color "'$fg_color'"

    # make sure the profile is set to not use theme colors
    dconf write $profile_path/use-theme-colors "false"

    # set highlighted color to be different from foreground color
    dconf write $profile_path/bold-color-same-as-fg "false"

    touch $SOLARIZED_TERMINAL
}

# from https://gist.github.com/nirbheek/5589105
_set_gnome_terminal_transparency()
{
    if [[ -z ${DISPLAY} ]] || [[ -z ${TMUX} ]]; then
        return
    fi

    : ${XWININFO:=$(type -P xwininfo)}
    [[ -z ${XWININFO} ]] && { echo "You need to install xorg-xwininfo: pacman -S xorg-xwininfo"; return; }
    : ${XPROP:=$(type -P xprop)}
    [[ -z ${XPROP} ]] && { echo "You need to install xorg-xprop: pacman -S xorg-xprop"; return; }

    TRANSPARENCY_PERCENT=93

    # This is very fragile
    TERMINAL_WINDOW_XID=$("$XWININFO" -root -tree | grep -v "Terminal" | sed -n 's/^[[:space:]]\+\([0-9a-fx]\+\).*gnome-terminal.*/\1/p')

    if [[ ${TRANSPARENCY_PERCENT} = 100 ]]; then
        TRANSPARENCY_HEX="0xffffffff"
    elif [[ ${TRANSPARENCY_PERCENT} = 0 ]]; then
        TRANSPARENCY_HEX="0x00000000"
    else
        TRANSPARENCY_HEX=$(printf "0x%x" $((4294967295/100 * $TRANSPARENCY_PERCENT)))
    fi

    for each in $TERMINAL_WINDOW_XID; do
        "$XPROP" -id $each -f _NET_WM_WINDOW_OPACITY 32c -set _NET_WM_WINDOW_OPACITY $TRANSPARENCY_HEX
    done
}

__git_ps1()
{
    local b="$(git symbolic-ref HEAD 2>/dev/null)";
    if [ -n "$b" ]; then
        printf " (%s)" "${b##refs/heads/}";
    fi
}

_set_ps1()
{
    if [ $TERM != linux ] && tput setaf 1 &> /dev/null; then
        tput sgr0
        if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
            # heavily based on https://gist.github.com/SeanPONeil/3717199
            BASE03=$(tput setaf 234)
            BASE02=$(tput setaf 235)
            BASE01=$(tput setaf 240)
            BASE00=$(tput setaf 241)
            BASE0=$(tput setaf 244)
            BASE1=$(tput setaf 245)
            BASE2=$(tput setaf 254)
            BASE3=$(tput setaf 230)
            YELLOW=$(tput setaf 136)
            ORANGE=$(tput setaf 166)
            RED=$(tput setaf 160)
            MAGENTA=$(tput setaf 125)
            VIOLET=$(tput setaf 61)
            BLUE=$(tput setaf 33)
            CYAN=$(tput setaf 37)
            GREEN=$(tput setaf 64)
            BOLD=$(tput bold)
            RESET=$(tput sgr0)
        else
            BASE03=$(tput setaf 8)
            BASE02=$(tput setaf 0)
            BASE01=$(tput setaf 10)
            BASE00=$(tput setaf 11)
            BASE0=$(tput setaf 12)
            BASE1=$(tput setaf 14)
            BASE2=$(tput setaf 7)
            BASE3=$(tput setaf 15)
            YELLOW=$(tput setaf 3)
            ORANGE=$(tput setaf 9)
            RED=$(tput setaf 1)
            MAGENTA=$(tput setaf 5)
            VIOLET=$(tput setaf 13)
            BLUE=$(tput setaf 4)
            CYAN=$(tput setaf 6)
            GREEN=$(tput setaf 2)
        fi
        BOLD=$(tput bold)
        RESET=$(tput sgr0)
        export PS1="\[${BOLD}${CYAN}\]\u\[$BASE0\]@\[$CYAN\]\h\[$BASE0\]:\[$BLUE\]\w\[$BASE0\]\[$YELLOW\]\$(__git_ps1)\[$BASE0\]\$ \[$RESET\]"
    else
        # good and old slackware-like PS1
        export PS1="\u@\h:\w$(__git_ps1)\$ "
    fi
}

_set_default_aliases_and_exports()
{
    # custom silly and colorful ls aliases
    alias ls="ls --color"
    alias l="ls -laFh --color"
    alias ll=l

    # it's better to be safer than sorry
    alias cp="cp -i"
    alias mv="mv -i"
    alias rm="rm -i"

    # making sure we have something usable when needed
    export VISUAL=vim
    export EDITOR=$VISUAL

    # user-defined bin path to drop custom executables
    export PATH=~/bin:$PATH

    # nicer terminal colors, if available
    if infocmp xterm-256color >/dev/null 2>&1; then export TERM=xterm-256color; fi
}

_set_odd_aliases()
{
    # mplayer having problems with hdmi + audio / check out $ aplay -l
    # alias mplayer-hdmi="mplayer -ao alsa:device=hw=1.7"

    # phabricator
    alias sendpatch="arc diff --reviewers hugopl,lmoura,tullio,luck,dakerfp,lacerda,setanta,nick HEAD~1"
}

_enable_icecc()
{
    export ICECC_VERSION=~/.icecc/gcc48-x86_64-sergio-9b3f2094b14ce6119124d8ccadeff1a1.tar.gz
    mkdir -p ~/bin
    for c in gcc g++ cc c++; do
        # ln -sf /usr/bin/ccache ~/bin/${c}
        ln -sf /usr/lib/icecream/bin/icecc ~/bin/${c}
    done

    # gold linker - may be problematic in some cases. used mostly for webkit
    # ln -sf /usr/bin/ld.gold ~/bin/ld
}

_compile_ycm_extension()
{
    local YCM_SANDBOX=~/.sandbox/ycm
    rm -rf $YCM_SANDBOX
    mkdir -p $YCM_SANDBOX
    pushd $YCM_SANDBOX

    # try to use ccache
    local OLDPATH=$PATH
    local CCACHE_PATH=/usr/lib/ccache/bin
    if [ -d $CCACHE_PATH ]; then
        export PATH=$CCACHE_PATH:$PATH
    fi

    cmake -G "Unix Makefiles" -DUSE_SYSTEM_LIBCLANG=ON . ~/.vim/bundle/YouCompleteMe/cpp
    time make ycm_core -j$(nproc)

    # restore PATH
    if [ -d $CCACHE_PATH ]; then
        export PATH=$OLDPATH
    fi

    popd
}

_set_tmux()
{
    # if running X or inside an SSH session
    if [[ -n "$DISPLAY" ]] || [[ -n "$SSH_TTY" ]]; then
        # TMUX
        if _package_installed "tmux"; then
            test -f ~/.notmux && return

            # gnome_terminal_solarized_dark
            _set_gnome_terminal_transparency

            # if no session is started, start a new session
            test -z ${TMUX} && exec tmux -2
        else
            echo "Please install tmux: pacman -S tmux"
            echo "Remember to also install powerline and its fonts from the AUR: python[2]-powerline-git / powerline-fonts"
        fi
    fi
}

_set_tmux
_set_default_aliases_and_exports
_set_odd_aliases
_set_ps1
_set_dircolors
# _enable_icecc
