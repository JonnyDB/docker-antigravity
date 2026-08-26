FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute

# Metadata labels in LSIO format
LABEL maintainer="JonnyDB"
LABEL org.opencontainers.image.title="docker-antigravity"
LABEL org.opencontainers.image.description="LinuxServer.io container for Google Antigravity 2.0 Desktop using Selkies streaming on Ubuntu Resolute with Google Chrome, Node.js, Python, and dynamic config volume deployment"
LABEL org.opencontainers.image.authors="JonnyDB"
LABEL org.opencontainers.image.url="https://antigravity.google"
LABEL org.opencontainers.image.source="https://github.com/JonnyDB/docker-antigravity"

# Environment configuration - preserve /lsiopy/bin for Selkies internal runtime
ENV DEBIAN_FRONTEND="noninteractive" \
    HOME="/config" \
    TITLE="Google Antigravity 2.0" \
    NO_GAMEPAD=true \
    PIXELFLUX_WAYLAND=true \
    ANTIGRAVITY_CONFIG_DIR="/config/.gemini" \
    ANTIGRAVITY_APP_DIR="/config/.antigravity" \
    ANTIGRAVITY_VERSION="2.10.0-4996573600546816" \
    AUTO_UPDATE="false" \
    NPM_CONFIG_PREFIX="/config/.npm-global" \
    PYTHONUSERBASE="/config/.local" \
    PIPX_HOME="/config/.pipx" \
    PIPX_BIN_DIR="/config/.local/bin" \
    PATH="/lsiopy/bin:/config/.local/bin:/config/.npm-global/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Install system dependencies, desktop libraries, Node.js, Python, development tools, Google Chrome, and set Selkies logo
RUN \
    echo "**** install system dependencies and development tools ****" && \
    apt-get update && \
    apt-get install -y \
        bash \
        build-essential \
        ca-certificates \
        curl \
        emacs \
        git \
        gnupg \
        jq \
        libasound2t64 \
        libgbm1 \
        libgtk-3-0 \
        libnss3 \
        libsecret-1-0 \
        nano \
        net-tools \
        nodejs \
        openssh-client \
        pkg-config \
        procps \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
        pipx \
        sudo \
        tar \
        tmux \
        tree \
        unzip \
        vim \
        wget \
        xclip \
        xdg-utils \
        zenity && \
    npm install -g corepack yarn pnpm && \
    \
    echo "**** install Google Chrome for in-container OAuth authentication ****" && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends google-chrome-stable && \
    \
    echo "**** install Antigravity logo for Selkies web client ****" && \
    mkdir -p /usr/share/selkies/www && \
    curl -fsSL -o /usr/share/selkies/www/icon.png \
        https://raw.githubusercontent.com/lobehub/lobe-icons/refs/heads/master/packages/static-png/dark/antigravity-color.png && \
    \
    echo "**** clean up apt caches ****" && \
    apt-get clean && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

# Copy local filesystem overlay
COPY root/ /

# Ensure executable permissions
RUN chmod +x \
    /defaults/autostart \
    /defaults/autostart_wayland \
    /etc/s6-overlay/scripts/init-antigravity \
    /usr/local/bin/antigravity \
    /usr/local/bin/antigravity-update \
    /usr/local/bin/google-chrome \
    /usr/local/bin/agy-login \
    /usr/local/bin/agy-status \
    /usr/local/bin/xdg-open

# Ports: 3000 (HTTP Desktop GUI), 3001 (HTTPS Desktop GUI), 4400 (Hub Port)
EXPOSE 3000 3001 4400

# Persistent Volume
VOLUME /config
