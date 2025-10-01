FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages for vmroot bootstrap
RUN apt-get update && apt-get install -y \
    sudo \
    jq \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /root

# Keep container running for tests
CMD ["tail", "-f", "/dev/null"]
