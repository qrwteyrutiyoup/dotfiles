export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

. ~/bin/laptop-check

if [ ${PC} = 'laptop' ]; then
  brightness-set 20
  set-touchpad
fi

while true; do
  dwm-statusbar
  sleep 15
done &

setxkbmap us intl

export GTK_IM_MODULE=cedilla

dropbox &
nm-applet &
random-wallpaper &
exec dwm

