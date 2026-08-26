export HOME="/config"
export NPM_CONFIG_PREFIX="/config/.npm-global"
export PYTHONUSERBASE="/config/.local"
export PIPX_HOME="/config/.pipx"
export PIPX_BIN_DIR="/config/.local/bin"
export PATH="/lsiopy/bin:/config/.local/bin:/config/.npm-global/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

PS1='\[\033[01;32m\]\u@antigravity\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

alias ll='ls -la'
alias agy-logs='tail -f /config/.antigravity/antigravity.log 2>/dev/null || echo "No log file yet"'
