#!/use/bin/env bash

# If not running interactively, do not do anything.
[[ $- != *i* ]] && return


_set_ansi_dircolors()
{
  local DIRCOLORS=~/.dircolors.ansi.dark
  eval $(dircolors ${DIRCOLORS})
}

_set_dircolors()
{
  local DIRCOLORS=~/.dircolors
  eval $(dircolors ${DIRCOLORS})
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

__git_ps1()
{
  local b="$(git symbolic-ref HEAD 2>/dev/null)";
  if [ -n "$b" ]; then
    printf " (%s)" "${b##refs/heads/}";
  fi
}

_ps1_terminator_char()
{
  if [ $(whoami) == "root" ]; then
    printf '#'
  else
    printf '$'
  fi
}

_set_regular_ps1()
{
  # good and old slackware-like PS1
  export PS1="\u@\h:\w$(__git_ps1)\$(_ps1_terminator_char) "
}

function _update_ps1_powerline() {
  PS1="$(powerline-go -error $?)"
}

_set_ps1()
{
  # Let's check if powerline-go is available, and use it, if so.
  which powerline-go >/dev/null 2>/dev/null
  if [[ "${?}" -eq 0 ]] && [[  "$TERM" != "linux" ]]; then
    PROMPT_COMMAND="_update_ps1_powerline; $PROMPT_COMMAND"
    return
  fi

  if tput setaf 1 &> /dev/null; then
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
    export PS1="\[${BOLD}${CYAN}\]\u\[$BASE0\]@\[$CYAN\]\h\[$BASE0\]:\[$BLUE\]\w\[$BASE0\]\[$YELLOW\]\$(__git_ps1)\[$BASE0\]\$(_ps1_terminator_char) \[$RESET\]"
  else
    _set_regular_ps1
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

  export GOPATH=~/go
  export PATH=${PATH}:${GOPATH}/bin
}

_compile_mplayer_screensaver_workaround()
{
  pushd ~/.mplayer
  make
  popd
}

_set_keychain()
{
  if [[ -n "$TERM" ]]; then
    eval $(keychain -q --nogui --ignore-missing --eval id_rsa)
  fi

  export GPG_TTY="$(tty)"
  if [[ $(ps -U "$USER" -o ucomm | grep gpg-agent | wc -l) -eq 0 ]]; then
    eval "$(gpg-agent --daemon | tee $gpg_agent_env} 2> /dev/null)"
  fi
}

_set_extra_exports()
{
  export PATH=/usr/lib/sumo/tools:${PATH}
  export SUMO_HOME=/usr/lib/sumo
  export VDPAU_DRIVER=nvidia
}

_set_default_aliases_and_exports
_set_extra_exports
_set_ps1
_set_dircolors
_set_keychain

# vim:set ts=2 sw=2 et:
