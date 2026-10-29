# How it works

One Docker container, two tmux panes: the tutor (Claude Code) on the left, the student's shell on the right.

```
┌──────────────────────────┬──────────────────────────┐
│ Tutor (claude)           │ Student (bash)           │
│ /opt/tutor               │ /home/student            │
└──────────────────────────┴──────────────────────────┘
```

## Run

```
docker build -t terminal-tutor .
docker run -it --rm --hostname school --env-file .env terminal-tutor
```

`.env` holds `CLAUDE_CODE_OAUTH_TOKEN` (from `claude setup-token`). It's in `.gitignore`.

## Files

| File | Role |
|---|---|
| `Dockerfile` | Ubuntu + tmux + nano + Claude Code. Creates user `student`. Copies the files below. |
| `start.sh` | Runs when the container starts. Opens tmux, starts both panes and the 30 s watcher. |
| `student.bashrc` | Startup file of the student's shell. Removes the token and tells the tutor after each command. |
| `claude.json` | Copied to `~/.claude.json`. Skips Claude's first-run questions (onboarding, folder trust). |
| `tutor/SYSTEM.md` | System prompt: the tutor's personality and teaching rules. Replaces Claude Code's default one. |
| `tutor/CLAUDE.md` | The lesson: Lesson 1 steps and what to say first. |
| `tutor/.claude/settings.json` | Permissions, the hook, and UI settings that hide noise. |

## Flow

1. **Start:** `start.sh` runs `claude --system-prompt-file SYSTEM.md "Hola 👋"` in `/opt/tutor`. The token logs it in, so the tutor greets first and gives task 1.
2. **Student runs a command:** bash's `PROMPT_COMMAND` (in `student.bashrc`) types `[auto] Comando ejecutado` into the tutor's pane with `tmux send-keys`.
3. **Student is quiet:** the watcher in `start.sh` checks every 30 s. If neither pane changed, it sends `[auto] 30 s sin actividad`, once until the student acts again.
4. **Every message to the tutor** triggers a `UserPromptSubmit` hook that runs `tmux capture-pane` on the student's pane and attaches the screen. So the tutor always sees what the student did.
5. **The tutor decides:** task done → praise + next task. Mistake → only `👀`, let them try. Stuck → hint, then answer.

## Tutor configuration (`tutor/.claude/settings.json`)

- **Permissions:** `Bash` and `Read` allowed, web tools denied, auto mode disabled (manual mode).
- **Hook:** `UserPromptSubmit` → attach the student's screen.
- **UI:** `showTurnDuration`, `promptSuggestionEnabled`, `spinnerTipsEnabled` off.
- **Env (in `Dockerfile`):** `CLAUDE_CODE_HIDE_CWD=1`, `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1`.

## Known limits

- The Claude logo and the `manual mode on` footer can't be hidden.
- The token is removed from the student's shell, but tmux keeps a copy, so a curious student could find it.
- `[auto]` messages are visible in the tutor's pane.
