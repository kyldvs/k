FROM termux/termux-docker:x86_64

# Copy test fixtures (mock Doppler CLI, SSH keys, test config)
COPY src/tests/fixtures /fixtures
RUN chmod +x /fixtures/*.sh

# Bootstrap scripts are mounted via docker-compose volumes at runtime
RUN mkdir -p /var/www/bootstrap

WORKDIR /data/data/com.termux/files/home
