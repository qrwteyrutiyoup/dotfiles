#!/usr/bin/env sh

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Killing stale processes.
user=$(whoami)
for p in ibus-daemon dbus-daemon ycmd urxvt tmux vi vim dwm-statusbar random-wallpaper dzen2 foobar; do
  for pid in $(ps aux | grep ${p} | grep ${user} | awk '{ print $2 }'); do
    kill -9 ${pid} 2>/dev/null
  done
done

xcompmgr &
nohup foobar 2>&1 | tee /tmp/foobar.log &

setxkbmap us intl
#dropbox &
nm-applet &
dwm-theme-manager -d arch &

#valgrind --tool=massif --massif-out-file=i3.massif.out i3
#valgrind --tool=massif --massif-out-file=dwm.massif.out dwm
exec dwm 2>/tmp/dwmlog

# vim:set ts=2 sw=2 et:

