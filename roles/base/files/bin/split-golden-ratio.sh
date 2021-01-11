#/bin/sh

# Manual creation
# $(echo "`tmux display -p '#{pane_height}'` * 0.38196601125" | bc -l | awk '{printf("%d\n",$1 + 0.5)}')

case "$1" in

down)
    tmux split-pane -v -l 38% -c "#{pane_current_path}"
    ;;

up) 
    tmux split-pane -v -b -l 38% -c "#{pane_current_path}"
    ;;

left) 
    tmux split-pane -h -b -l 38% -c "#{pane_current_path}"
    ;;

right)
    tmux split-pane -h -l 38% -c "#{pane_current_path}"
    ;;

*) echo "Signal number $1 is not processed"
;;
esac
