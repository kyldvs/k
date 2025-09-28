FROM termux/termux-docker:x86_64

# Create test directories as root
RUN mkdir -p /var/www/bootstrap

# Python3 will be installed at runtime when the container starts
# This is necessary because DNS only works after the container's entrypoint runs dnsmasq

WORKDIR /data/data/com.termux/files/home
