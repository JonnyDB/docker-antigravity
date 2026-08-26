# `docker-antigravity` (Google Antigravity 2.0 Desktop)

A [LinuxServer.io](https://linuxserver.io) framework container for **Google Antigravity 2.0 (The Hub Desktop Application)** with in-browser Web UX (KasmVNC streaming), interactive Google OAuth sign-in flow (`agy-login`), Node.js, Python 3, and dynamic `/config` external volume installation for seamless in-place upgrades without rebuilding images.

---

## Features

- **Dynamic `/config` Installation**: Both **Google Antigravity 2.0 Desktop** (`/config/app/antigravity`) and the **Antigravity CLI** (`/config/.local/bin/agy`) are installed and maintained directly inside your mounted `/config` volume on container start.
- **Zero-Rebuild Upgrades**: Upgrade Antigravity versions in-place by setting `ANTIGRAVITY_VERSION` / `AUTO_UPDATE=true` or running `docker exec -it antigravity antigravity-update`.
- **Easy Google OAuth Sign-in**:
  1. **CLI Helper (`agy-login`)**: Run `docker exec -it antigravity agy-login` to complete the interactive OAuth flow in your host terminal.
  2. **VNC GUI Helper (`xdg-open`)**: Clicking "Sign in" inside the Antigravity Desktop interface automatically copies the Google auth URL to the clipboard and displays a visual popup dialog.
- **In-Browser Web Desktop UX**: Streams the complete Antigravity 2.0 GUI directly to your web browser over HTTP (port `3000`) and HTTPS (port `3001`) via WebRTC / WebCodecs with audio and clipboard support.
- **Google Remote Control Integration**: Seamlessly connect your instance to the [Google Antigravity Remote Control Hub](https://antigravity.google) (`https://antigravity.google/docs/remote-control/`).
- **Out-of-the-Box Toolchains**: Node.js, `npm`, `pnpm`, `yarn`, Python 3, `pip`, `pipx`, `venv`, `git`, and build tools.
- **LinuxServer.io Standards**: `PUID`/`PGID` host user permission mapping, `s6-overlay v3` process supervision, and fast `lsiown` permission management.

---

## Quickstart

### 1. Docker Compose (Recommended)

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
      - seccomp:unconfined # Required for Chrome/Electron sandboxing
    shm_size: "1gb"        # Essential for Electron / KasmVNC rendering performance
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
      - TITLE=Google Antigravity 2.0
      # Optional: Pin a specific version of Antigravity Desktop
      - ANTIGRAVITY_VERSION=2.10.0-4996573600546816
      # Optional: Auto-update on container start (true/false)
    volumes:
      - ./config:/config
      - ./workspace:/config/workspace
    ports:
      - "3000:3000"   # Web Desktop GUI (HTTP)
      - "3001:3001"   # Web Desktop GUI (HTTPS - recommended for clipboard support)
      - "4400:4400"   # Antigravity Hub Port
    restart: unless-stopped
```

Start the container:
```bash
docker compose up -d
```

---

## 🔑 Authenticating / Google OAuth Login

Google OAuth authorization is required to use Antigravity. Both the CLI and Desktop application share credentials at `/config/.gemini/jetski-standalone-oauth-token`.

### Method 1: Terminal Login (Recommended & Fastest)

Run the interactive login tool in your terminal:
```bash
docker exec -it antigravity agy-login
```
1. Open the printed authorization link in your host browser.
2. Sign in with your Google Account.
3. Paste the authorization code back into the terminal and press **Enter**.
4. The OAuth token is saved to `/config/.gemini/jetski-standalone-oauth-token`, automatically signing in both the CLI and Desktop application!

### Method 2: In-Browser Desktop GUI Sign-in

1. Navigate to **`https://<host-ip>:3001`** (or `http://<host-ip>:3000`).
2. Click **Sign in** inside the Antigravity 2.0 window.
3. A popup dialog will appear displaying the authorization link, and the URL will automatically be copied to your clipboard.
4. Paste the URL into your host browser to complete authorization.

---

## 🔄 Upgrades & Maintenance

Because binaries live in the mounted `/config` volume, you do **not** need to rebuild the Docker image to upgrade:

- **Manual Upgrade**:
  ```bash
  docker exec -it antigravity antigravity-update
  ```
- **Version Pinning**:
  Change `ANTIGRAVITY_VERSION` in your `docker-compose.yml` and restart the container.

---

## 📊 Diagnostics & Health Check

```bash
docker exec -it antigravity agy-status
```
