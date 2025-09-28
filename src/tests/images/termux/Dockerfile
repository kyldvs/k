FROM termux/termux-docker:x86_64

# Switch to termux user for package management
USER system

# Skip package installation due to mirror issues in Docker environment
# The base termux image should have bash and curl already available
# We'll install python using a different approach if needed by the test runner
RUN echo "Skipping pkg install - using base image packages"

# Switch back to root for directory creation
USER root

# Create directories for bootstrap testing
RUN mkdir -p /var/www/bootstrap

# Ensure termux detection directory exists (should already exist in termux image)
RUN mkdir -p /data/data/com.termux

# Set final user context
USER system
WORKDIR /data/data/com.termux/files/home

CMD ["/bin/bash"]
