# ~/.profile: executed by Bourne-compatible login shells.
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

mesg n 2> /dev/null || true
