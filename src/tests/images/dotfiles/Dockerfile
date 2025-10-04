FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages for dotfiles system
RUN apt-get update && apt-get install -y \
    git \
    stow \
    sudo \
    curl \
    jq \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Install yq YAML parser (from binary)
RUN curl -fsSL \
  https://github.com/mikefarah/yq/releases/download/v4.35.2/yq_linux_amd64 \
  -o /usr/local/bin/yq && \
  chmod +x /usr/local/bin/yq

# Create test user with home directory
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/testuser && \
    chmod 440 /etc/sudoers.d/testuser

# Switch to test user
USER testuser
WORKDIR /home/testuser

# Keep container running for tests
CMD ["tail", "-f", "/dev/null"]
