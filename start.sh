#!/bin/bash
# Open the school: tutor (claude) on the left, student shell on the right.

tmux new-session -d -s school -c /opt/tutor 'claude "Empieza la lección"'   # left pane: tutor
tmux split-window -h -t school -c /home/student bash                       # right pane: student shell
tmux set -g mouse on                      # click to switch panes
exec tmux attach -t school                # show it on screen
