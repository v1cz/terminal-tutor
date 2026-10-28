# School: learn the terminal with an AI teacher

## Why

Most people have a computer, but 90% have never used the terminal or a coding agent, the tools all modern software is built with. You don't need a CS degree to learn them.

- **Why not a UI?** The terminal shows you how a computer actually works.
- **Once you're there**, you understand the tools. Most modern software is *assembled*, not built from scratch.

## The idea

One environment and two panes:

```
┌─────────────────────────┬─────────────────────────┐
│ Student                 │ Teacher                 │
│ bare Linux shell        │ coding agent (Claude)   │
│ student@school:~$ _     │ "Escribe pwd..."        │
└─────────────────────────┴─────────────────────────┘
```

- **Left:** the student types real commands on a real Linux machine.
- **Right:** a coding agent teaches, helps and troubleshoots. It can see the student's screen and run commands. Students also get used to working with an agent.

## Stack

| Piece | Role |
|---|---|
| Docker (Ubuntu) | The Linux machine: the same for everyone, safe to break, easy to reset |
| tmux | The split screen |
| Claude Code | The teacher agent, stripped down to `Bash` + `Read` |
| Anthropic account | Claude subscription (`/login`) or an API key |

Students install it locally. There's no server and no backend.

## How the teacher works

- **Minimal agent:** only the shell. No web, MCP or slash commands.
- **Sees the student:** reads the left pane with `tmux capture-pane`.
- **Starts the conversation:** opens each lesson with a greeting and the first task.

## Lesson 1: Moving around Linux (MVP)

A simplified version of the course's "Linux 1" session:

1. **Where am I?** `pwd`, `ls`, the folder tree, `/` and `~`
2. **Moving around:** `cd`, `cd ..`, absolute vs. relative paths
3. **Creating and deleting:** `mkdir`, `touch`, `nano`, `cat`, `cp`, `mv`, `rm`
4. **Working with the agent:** the student asks the agent to build a project folder, then reads what it ran
5. **Wrap-up:** three quick questions

Left for later lessons: users, permissions, `apt`, environment variables, scripts.

## Build plan

Two parts. No login handling for now (type `/login` each time).

### 1. Environment: Docker + Ubuntu + tmux

```
Dockerfile   # Ubuntu + tmux + nano + Claude Code
start.sh     # tmux: one pane runs claude, the other runs bash
```

Run with `docker build -t terminal-tutor .` then `docker run -it --rm --hostname school terminal-tutor`.

### 2. Agent: Claude Code as tutor

```
tutor/
├── CLAUDE.md               # role (patient tutor, Spanish) + Lesson 1 script
└── .claude/settings.json   # block web tools, keep Bash
```

`start.sh` launches it from `tutor/` with `claude "Empieza la lección"` so the tutor speaks first.


