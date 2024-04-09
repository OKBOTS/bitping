# Use an updated small linux image as a base
FROM debian:stable-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/root/.local/bin:${PATH}" \
    NODE_DB_PATH="/root/.bitpingd/node.db" \
    BITPING_EMAIL="lykcloud@proton.me" \
    BITPING_PASSWD="L@bin123"

# Install necessary packages then clean up to reduce image size
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -qqy \
    bash \
    tini \
    supervisor \
    curl \
    wget \
    unzip \
    expect \
    python3 \
    python3-pip && \
    apt-get autoremove --purge -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /app

# Copy entrypoint script and configuration files
COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisord.conf

# Make scripts executable
RUN chmod +x /entrypoint.sh

# Download and install bitpingd
RUN curl https://bitping.com/install.sh | bash
# RUN source ~/.bashrc

# Remove the tar.gz file downloaded from the install script after installation
RUN rm -rf /app/*.tar.gz

# Set tini as the entrypoint and the custom script as the command
ENTRYPOINT ["tini", "--"]
CMD ["/entrypoint.sh"]

