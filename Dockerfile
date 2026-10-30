# 1. Start from official Ubuntu
FROM ubuntu:24.04

# 2. Install the tools the lesson needs
RUN apt-get update && apt-get install -y \
    tmux nano curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Use UTF-8 so tmux shows icons instead of "_"
ENV LANG=C.UTF-8

# Hide Claude Code extras the student doesn't need
ENV CLAUDE_CODE_HIDE_CWD=1 \
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# 3. Create a normal user (not the admin "root")
RUN useradd -m -s /bin/bash student
USER student
WORKDIR /home/student

# tmux settings: click to switch panes, no green bar, focus events for Claude Code
RUN printf 'set -g mouse on\nset -g status off\nset -g focus-events on\n' > ~/.tmux.conf

# The project the student practises on
COPY --chown=student:student practica/asistente-ia /home/student/proyectos/asistente-ia

# 4. Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/student/.local/bin:${PATH}"

# 5. The tutor's instructions, outside the student's home
COPY tutor /opt/tutor
COPY student.bashrc /opt/student.bashrc

# Skip Claude's first-run questions (theme, trust folder)
COPY --chown=student:student claude.json /home/student/.claude.json

# 6. What runs when the container starts
COPY --chmod=755 start.sh /usr/local/bin/start.sh
CMD ["start.sh"]
