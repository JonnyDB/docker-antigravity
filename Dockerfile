FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble

# Set metadata labels in LSIO format
LABEL maintainer="Antigravity Community"
LABEL org.opencontainers.image.title="docker-antigravity"
LABEL org.opencontainers.image.description="LinuxServer.io container for Google Antigravity 2.0 Desktop with KasmVNC Web UX, Google Chrome for in-container OAuth, Remote Control, Node.js, and Python"
LABEL org.opencontainers.image.authors="Google Antigravity Community"
LABEL org.opencontainers.image.url="https://antigravity.google"
LABEL org.opencontainers.image.source="https://github.com/JonnyDB/docker-antigravity"

# Environment configuration
ENV DEBIAN_FRONTEND="noninteractive" \
    HOME="/config" \
    TITLE="Google Antigravity 2.0" \
    ANTIGRAVITY_CONFIG_DIR="/config/.gemini" \
    ANTIGRAVITY_APP_DIR="/config/.antigravity" \
    ANTIGRAVITY_VERSION="2.10.0-4996573600546816" \
    AUTO_UPDATE="false" \
    NPM_CONFIG_PREFIX="/config/.npm-global" \
    PYTHONUSERBASE="/config/.local" \
    PIPX_HOME="/config/.pipx" \
    PIPX_BIN_DIR="/config/.local/bin" \
    PATH="/config/.local/bin:/config/.npm-global/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"

# Install core packages, Desktop libraries, utilities, Google Chrome, Node.js, Python 3, and development tools
RUN \
    echo "**** Install system dependencies, desktop libraries, Node.js, and Python ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        ca-certificates \
        curl \
        dbus-x11 \
        emacs \
        git \
        gnupg \
        jq \
        libasound2t64 \
        libatk-bridge2.0-0 \
        libatk1.0-0 \
        libc6 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libexpat1 \
        libffi-dev \
        libgbm1 \
        libglib2.0-0 \
        libgtk-3-0 \
        libnotify-bin \
        libnotify4 \
        libnss3 \
        libpango-1.0-0 \
        libsecret-1-0 \
        libssl-dev \
        libu2f-udev \
        libvulkan1 \
        libx11-6 \
        libx11-xcb1 \
        libxcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxi6 \
        libxrandr2 \
        libxrender1 \
        libxss1 \
        libxtst6 \
        locales \
        nano \
        net-tools \
        netcat-openbsd \
        nodejs \
        npm \
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
        xsel \
        xz-utils \
        zenity \
        zlib1g-dev && \
    npm install -g corepack yarn pnpm && \
    \
    echo "**** Install Google Chrome for in-container OAuth sign-in ****" && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends google-chrome-stable && \
    \
    echo "**** Clean up ****" && \
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
