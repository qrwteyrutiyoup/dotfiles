#!/usr/bin/env sh

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

. ~/bin/laptop-check

if [ ${PC} = 'laptop' ]; then
#  brightness-set 20
  set-touchpad
fi

# Killing stale processes.
user=$(whoami)
for p in ibus-daemon dbus-daemon ycmd urxvt tmux vi vim dwm-statusbar random-wallpaper dzen2 foobar; do
  for pid in $(ps aux | grep ${p} | grep ${user} | awk '{ print $2 }'); do
    kill -9 ${pid} 2>/dev/null
  done
done

xcompmgr &
#dwm-statusbar 2>&1 | tee /tmp/statusbar.log &
#valgrind --tool=massif --massif-out-file=foobar.massif.out foobar 2>&1 | tee /tmp/foobar.log &
nohup foobar 2>&1 | tee /tmp/foobar.log &

#URxvt.inputMethod: ibus
#URxvt.preeditType: OverTheSpot

setxkbmap us intl

#export $(dbus-launch)
#export GTK_IM_MODULE=cedilla
#export QM_IM_MODULE=xim
# export GTK_IM_MODULE=ibus
# export QT_IM_MODULE=ibus
# export XMODIFIERS=@im=ibus

#dropbox &
nm-applet &
#random-wallpaper &
#feh --bg-scale ~/Pictures/wallpapers/goku.jpg
#feh --bg-scale ~/Downloads/80B.jpg
#feh --bg-fill ~/Downloads/goku-freeza.jpg
#feh --bg-fill ~/Downloads/cell-wallpaper-1.jpg
#feh --bg-fill ~/Downloads/majin.jpg
#feh --bg-fill ~/Pictures/wallpapers/gohan.jpg

#dwm-theme-manager -d matrix &
#dwm-theme-manager -d arch &
dwm-theme-manager -d arch &


#exec i3
#valgrind --tool=massif --massif-out-file=i3.massif.out i3
#valgrind --tool=massif --massif-out-file=dwm.massif.out dwm
exec dwm 2>/tmp/dwmlog

# vim:set ts=2 sw=2 et:

