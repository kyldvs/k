FROM alpine:3.19

# Install required packages for vmroot bootstrap
RUN apk add --no-cache \
    sudo \
    jq \
    bash

# Set working directory
WORKDIR /root

# Keep container running for tests
CMD ["tail", "-f", "/dev/null"]
