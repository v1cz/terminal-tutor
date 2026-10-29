#!/bin/bash
# Open the school: tutor (claude) on the left, student shell on the right.

tmux new-session -d -s school -c /opt/tutor \
  'claude --system-prompt-file /opt/tutor/SYSTEM.md "Hola 👋"'                 # left pane: tutor
tmux split-window -h -t school -c /home/student \
  'bash --rcfile /opt/student.bashrc'                                           # right pane: student
tmux set -g mouse on                                                            # click to switch panes
tmux set -g status off                                                          # hide the green bar

# Watcher: if the student is quiet for 30 seconds, nudge the tutor once.
(
  nudged=0
  while sleep 30 && tmux has-session -t school 2>/dev/null; do
    student=$(tmux capture-pane -p -t school:0.1)
    tutor=$(tmux capture-pane -p -t school:0.0)
    if [ "$student" != "$last_student" ]; then nudged=0             # student did something
    elif [ "$tutor" = "$last_tutor" ] && [ $nudged -eq 0 ]; then    # both quiet: nudge once
      tmux send-keys -t school:0.0 "[auto] 30 s sin actividad" Enter; nudged=1
    fi
    last_student=$student; last_tutor=$tutor
  done
) &

exec tmux attach -t school                                                      # show it on screen
