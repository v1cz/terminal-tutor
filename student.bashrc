# Student shell: normal settings, no token, and tell the tutor after each command.

source ~/.bashrc
unset CLAUDE_CODE_OAUTH_TOKEN

# Runs every time a command finishes (skips the very first prompt)
PROMPT_COMMAND='[ -n "$started" ] && tmux send-keys -t school:0.0 "[auto] Comando ejecutado" Enter; started=1'
