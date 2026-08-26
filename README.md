<p align="center">
  <img src="https://raw.githubusercontent.com/lobehub/lobe-icons/refs/heads/master/packages/static-png/dark/antigravity-color.png" width="120" alt="Google Antigravity Logo" />
</p>

# docker-antigravity

A LinuxServer.io style container for Google Antigravity 2.0 Desktop built on the modern Selkies streaming runtime on Ubuntu Resolute Raccoon (`ghcr.io/linuxserver/baseimage-selkies:ubunturesolute`). It includes in-browser WebRTC streaming, official Google Chrome for OAuth authentication, Node.js, Python, and dynamic `/config` volume installation so the application can be updated without rebuilding container images.

---

## Features

- **Selkies WebRTC Streaming**: Low-latency browser streaming using `baseimage-selkies:ubunturesolute` with native Wayland and X11 compositing.
- **Dynamic Application Storage**: Installs both Google Antigravity 2.0 Desktop (`/config/app/antigravity`) and the CLI (`/config/.local/bin/agy`) into the mounted `/config` volume on first boot.
- **Upgrades Without Rebuilding**: Update the installed versions in-place by setting `ANTIGRAVITY_VERSION` or running `docker exec -it antigravity antigravity-update`.
- **Official Google Chrome**: Ships with official Google Chrome (`google-chrome-stable`) configured for local loopback handling so Google Sign-In completes inside the container's network space.
- **Preinstalled Toolchains**: Node.js, npm, yarn, pnpm, Python 3, pip, pipx, and standard build tools.
- **Standard LinuxServer Init**: Supports `PUID` and `PGID` permission mapping with s6-overlay v3 process supervision.

---

## Quickstart

### Docker Compose

Create a `docker-compose.yml` file:

```yaml
services:
  antigravity:
    image: ghcr.io/jonnydb/antigravity:latest
    build:
      context: .
      dockerfile: Dockerfile
    container_name: antigravity
    security_opt:
      - seccomp:unconfined
    shm_size: "1gb"
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
      - TITLE=Google Antigravity 2.0
      # Optional: Pin a specific version of Antigravity Desktop
      - ANTIGRAVITY_VERSION=2.10.0-4996573600546816
      # Optional: Auto-update on startup (true/false)
      - AUTO_UPDATE=false
    volumes:
      - ./config:/config
      - ./workspace:/config/workspace
    ports:
      - "3000:3000"   # HTTP web access
      - "3001:3001"   # HTTPS web access (recommended for clipboard integration)
      - "4400:4400"   # Antigravity Hub port
    restart: unless-stopped
```

Start the service:

```bash
docker compose up -d
```

---

## Authentication

Google Antigravity requires an authorized Google account.

### Signing In via the Web Desktop

1. Open `https://localhost:3001` or `http://localhost:3000` in your web browser.
2. Click the Sign In button inside the Antigravity window.
3. Google Chrome will open inside the desktop session to handle the Google login page.
4. Sign in to your Google Account. Once approved, the callback to `127.0.0.1` completes inside the container and Antigravity connects.

### Signing In via the CLI

You can also run the interactive authentication flow from your terminal:

```bash
docker exec -it antigravity agy-login
```

Follow the URL in your host browser and paste the verification code back into the prompt.

---

## Maintenance and Updates

Because application binaries reside in `/config`, updates do not require image rebuilds:

- Run an immediate update:
  ```bash
  docker exec -it antigravity antigravity-update
  ```
- Or set `ANTIGRAVITY_VERSION` to a new release in `docker-compose.yml` and restart the container.

---

## Diagnostics

Check running services, binaries, and local ports:

```bash
docker exec -it antigravity agy-status
```
