#!/usr/bin/env sh

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

. ~/bin/laptop-check

if [ ${PC} = 'laptop' ]; then
  brightness-set 20
  set-touchpad
fi

# Killing stale processes.
user=$(whoami)
for p in dbus-daemon ycmd urxvt tmux vi vim dwm-statusbar; do
  for pid in $(ps aux | grep ${p} | grep ${user} | awk '{ print $2 }'); do
    kill -9 ${pid} 2>/dev/null
  done
done

dwm-statusbar ~/.dwm.json &

setxkbmap us intl

export $(dbus-launch)
export GTK_IM_MODULE=cedilla

dropbox &
nm-applet &
random-wallpaper &

exec dwm

# vim:set ts=2 sw=2 et:

