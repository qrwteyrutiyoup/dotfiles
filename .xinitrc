# Statusbar loop

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

while true; do
   xsetroot -name "$(date)"
   sleep 1    # Update time every minute
done &

setxkbmap us intl
exec dwm
