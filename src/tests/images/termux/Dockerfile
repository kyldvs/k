FROM termux/termux-docker:x86_64

# Create test directories as root
RUN mkdir -p /var/www/bootstrap

# BusyBox httpd is used for HTTP server (much faster than Python)
# No additional packages needed as busybox is included in base image

WORKDIR /data/data/com.termux/files/home
