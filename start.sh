#!/bin/bash
# Open the school: tutor (claude) on the left, student shell on the right.

# Pick the class: CLASE=basico uses tutor/clases/basico.md. No CLASE = rutas (Sofía's practice).
# Claude Code reads /opt/tutor/CLAUDE.md automatically, so the chosen class is copied there.
CLASE=${CLASE:-rutas}
if ! cp "/opt/tutor/clases/$CLASE.md" /opt/tutor/CLAUDE.md; then
  echo "Unknown class '$CLASE'. Available: $(ls /opt/tutor/clases | sed 's/\.md$//' | tr '\n' ' ')"
  exit 1
fi

tmux new-session -d -s school -c /opt/tutor \
  'claude --disable-slash-commands --system-prompt-file /opt/tutor/SYSTEM.md "Bienvenid@ 🫡"'  # left pane: tutor, no slash commands
tmux split-window -h -t school -c /home/student \
  'bash --rcfile /opt/student.bashrc'                                           # right pane: student

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
