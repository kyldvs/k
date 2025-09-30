FROM alpine:3.19

# Install SSH server and dependencies
RUN apk add --no-cache \
    openssh-server \
    bash \
    && ssh-keygen -A

# Create testuser
RUN adduser -D -s /bin/bash testuser \
    && mkdir -p /home/testuser/.ssh \
    && chown -R testuser:testuser /home/testuser/.ssh \
    && chmod 700 /home/testuser/.ssh

# SSH server configuration
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && sed -i 's/#LogLevel INFO/LogLevel VERBOSE/' /etc/ssh/sshd_config

# Copy test SSH public key to authorized_keys
COPY src/tests/fixtures/test-ssh-key.pub /home/testuser/.ssh/authorized_keys
RUN chown testuser:testuser /home/testuser/.ssh/authorized_keys \
    && chmod 600 /home/testuser/.ssh/authorized_keys

# Copy entrypoint script
COPY src/tests/images/mock-vm/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
