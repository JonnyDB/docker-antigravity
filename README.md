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

### Docker Compose (Published Image)

Copy the example environment file and edit it to match your setup:

```bash
curl -o .env https://raw.githubusercontent.com/JonnyDB/docker-antigravity/main/.env.example
# Edit .env to set your PUID, PGID, TZ, etc.
```

Create a `docker-compose.yml`:

```yaml
services:
  antigravity:
    image: ghcr.io/jonnydb/antigravity:latest
    container_name: antigravity
    security_opt:
      - seccomp:unconfined
    shm_size: "1gb"
    env_file: .env
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

On first boot the container downloads and installs Antigravity Desktop and the `agy` CLI into the `./config` volume. Subsequent restarts use the cached install.

### Building from Source

Clone the repo and run:

```bash
git clone https://github.com/JonnyDB/docker-antigravity.git
cd docker-antigravity
docker compose up -d --build
```

---

## Authentication

Google Antigravity requires an authorized Google account.

### Option 1: Copy an Existing OAuth Token (Recommended / Headless)

If you have already authenticated with Google Antigravity on your local workstation or laptop, Antigravity stores your OAuth token in:
- **Linux / macOS**: `~/.gemini/jetski-standalone-oauth-token`
- **Windows**: `%USERPROFILE%\.gemini\jetski-standalone-oauth-token`

You can reuse your existing token without signing in again:

**Local Deployment:**
Copy the token file into your local `./config/.gemini` volume directory:
```bash
mkdir -p ./config/.gemini
cp ~/.gemini/jetski-standalone-oauth-token ./config/.gemini/
chmod 600 ./config/.gemini/jetski-standalone-oauth-token
```

**Remote Server / Cloud VPS:**
Transfer the token from your local machine to the server running Docker:
```bash
scp ~/.gemini/jetski-standalone-oauth-token user@your-server:/path/to/agy-docker/config/.gemini/
```

**Running Container:**
Copy directly into an active container:
```bash
docker cp ~/.gemini/jetski-standalone-oauth-token antigravity:/config/.gemini/
```

**Via Environment Variable (`.env`):**
Alternatively, set the token in your `.env` file (the container automatically pre-seeds it on startup):
```bash
ANTIGRAVITY_OAUTH_TOKEN=your_token_string_here
```

---

### Option 2: Signing In via the Web Desktop

1. Open `https://localhost:3001` or `http://localhost:3000` in your web browser.
2. Click the **Sign In** button inside the Antigravity desktop window.
3. Google Chrome will open inside the virtual desktop session to handle the Google login page.
4. Sign in to your Google Account. Once approved, the callback to `127.0.0.1` completes inside the container and Antigravity connects.

---

### Option 3: Signing In via the CLI

You can also run the interactive authentication flow from your terminal:

```bash
docker exec -it antigravity agy-login
```

Follow the URL displayed in your terminal on your host browser and paste the verification code back into the prompt.

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
