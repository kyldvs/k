FROM ubuntu:22.04

# Install dependencies for bootstrap testing
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    jq \
    netcat-openbsd \
    sudo \
    xxd \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash testuser \
    && usermod -aG sudo testuser \
    && echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy bash server fixtures
COPY src/tests/fixtures /fixtures
RUN chmod +x /fixtures/*.sh

# Create directories and fix permissions
RUN mkdir -p /var/www/bootstrap \
    && chown -R testuser:testuser /var/www/bootstrap \
    && chown -R testuser:testuser /home/testuser

# Switch to test user
USER testuser
WORKDIR /home/testuser

CMD ["/bin/bash"]
