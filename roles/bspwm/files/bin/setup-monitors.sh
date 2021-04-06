#!/bin/sh

width=1768
height=2125
refresh=120
mode="${width}x${height}_${refresh}.00"
newmode="$(gtf ${width} ${height} ${refresh} | sed -n '3p' | cut -c 12-)"

case "$1" in 
  setup)
    xrandr --newmode $mode  679.52  1768 1928 2128 2488  2125 2126 2129 2276  -HSync +Vsync
    xrandr --addmode VIRTUAL1 $mode
    xrandr --output DP1 --off --output DP1-1 --off --output DP1-8 --mode 1920x1080 --pos 0x0 --rotate normal --output DP2 --off --output HDMI1 --off --output HDMI2 --mode 1920x1080 --pos 3688x0 --rotate normal --output HDMI3 --off --output VIRTUAL1 --mode $mode --pos 1920x0 --rotate normal --output VIRTUAL2 --off
  ;;

  serve)
    x11vnc \
      -noxdamage \
      -clip ${width}x${height}+1920+0 \
      -ncache 10 \
      -ncache_cr \
      -forever
  ;;
esac
#!/bin/sh
