FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages for VM bootstrap
RUN apt-get update && apt-get install -y \
    git \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /root

# Keep container running for tests
CMD ["tail", "-f", "/dev/null"]
