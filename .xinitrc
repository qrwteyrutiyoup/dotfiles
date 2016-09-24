# Statusbar loop

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

display=$(xrandr -q | grep ' connected' | awk '{ print $1 }')

function battery_stats() {
    if [ $display = 'eDP1' ]; then
        echo "🔋$(acpi -b | cut -d ',' -f 2) "
    else
        echo ""
    fi
}

# Check if using ZenBook.
if [ $display = 'eDP1' ]; then
#    xrandr --output eDP1 --brightness 0.5
    xbacklight -set 15
    synclient TapButton1=1 TapButton2=3 TapButton3=2
fi

while true; do
   xsetroot -name "$(battery_stats)$(date +"%a %b %e %Y ⌚ %k:%M %Z")"
   sleep 15
done &

setxkbmap us intl

export GTK_IM_MODULE=cedilla

dropbox &
exec dwm
