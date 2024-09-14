#!/bin/sh

# Set up PVM
PVM_DIR="$HOME/.pvm"
if [ -d "$PVM_DIR" ]; then
    echo "PVM is already installed at $PVM_DIR"
else
    echo "Installing PVM..."
    mkdir -p "$PVM_DIR"

    # Download pvm.sh to the correct location
    curl -o "$PVM_DIR/pvm.sh" https://raw.githubusercontent.com/rishitshivesh/pvm/main/scripts/pvm.sh

    # Create a symlink so that `pvm` command works globally
    if [ -d /usr/local/bin ]; then
        ln -s "$PVM_DIR/pvm.sh" /usr/local/bin/pvm
        echo "PVM symlink created at /usr/local/bin/pvm"
    else
        echo "Warning: /usr/local/bin directory not found. Please create a symlink manually:"
        echo "ln -s \"$PVM_DIR/pvm.sh\" /usr/local/bin/pvm"
    fi

    # Suggest adding PVM to the shell profile
    echo "To complete installation, add the following to your shell profile:"
    echo 'export PVM_DIR="$HOME/.pvm"'
    echo '[ -s "$PVM_DIR/pvm.sh" ] && \. "$PVM_DIR/pvm.sh"'
fi
