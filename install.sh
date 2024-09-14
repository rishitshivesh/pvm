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

    echo "To complete installation, add the following to your shell profile:"
    echo 'export PVM_DIR="$HOME/.pvm"'
    echo '[ -s "$PVM_DIR/pvm.sh" ] && \. "$PVM_DIR/pvm.sh"'
fi
