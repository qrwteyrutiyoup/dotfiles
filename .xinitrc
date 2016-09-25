export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

. ~/bin/zenbook-check

if [ ${PC} = 'laptop' ]; then
    xbacklight -set 20
    synclient TapButton1=1 TapButton2=3 TapButton3=2
fi

while true; do
    dwm-statusbar
    sleep 15
done &

setxkbmap us intl

export GTK_IM_MODULE=cedilla

dropbox &
exec dwm

