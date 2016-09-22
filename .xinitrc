# Statusbar loop

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

while true; do
   xsetroot -name "$(date)"
   sleep 15
done &

setxkbmap us intl
export GTK_IM_MODULE=cedilla
synclient TapButton1=1 TapButton2=3 TapButton3=2

display=$(xrandr -q | grep ' connected' | awk '{ print $1 }')

# Check if using ZenBook.
if [ $display = 'eDP1' ]; then
#    xrandr --output eDP1 --brightness 0.5
    xbacklight -set 15
fi

exec dwm


