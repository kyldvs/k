FROM termux/termux-docker:x86_64

# Copy bash server fixtures
COPY src/tests/fixtures /fixtures
RUN chmod +x /fixtures/*.sh

# Create test directories as root
RUN mkdir -p /var/www/bootstrap

# Bash HTTP server replaces BusyBox httpd
# xxd and nc are included in termux base image

WORKDIR /data/data/com.termux/files/home
