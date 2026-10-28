# 1. Start from official Ubuntu
FROM ubuntu:24.04

# 2. Install the tools the lesson needs
RUN apt-get update && apt-get install -y \
    tmux nano curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Use UTF-8 so tmux shows icons instead of "_"
ENV LANG=C.UTF-8

# 3. Create a normal user (not the admin "root")
RUN useradd -m -s /bin/bash student
USER student
WORKDIR /home/student

# 4. Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/student/.local/bin:${PATH}"

# 5. The tutor's instructions, outside the student's home
COPY tutor /opt/tutor

# 6. What runs when the container starts
COPY --chmod=755 start.sh /usr/local/bin/start.sh
CMD ["start.sh"]
