FROM alpine:latest

# Install dependencies for bootstrap testing
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    python3

# Create non-root user to simulate termux environment
RUN adduser -D -s /bin/bash testuser

# Create directories and fix permissions
RUN mkdir -p /var/www/bootstrap \
    && chown -R testuser:testuser /var/www/bootstrap \
    && chown -R testuser:testuser /home/testuser

# Switch to test user
USER testuser
WORKDIR /home/testuser

CMD ["/bin/bash"]
