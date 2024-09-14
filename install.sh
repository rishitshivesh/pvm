#!/bin/sh

# Directory where PVM is installed
PVM_DIR="$HOME/.pvm"
PVM_SCRIPT_URL="https://raw.githubusercontent.com/rishitshivesh/pvm/main/scripts/pvm.sh"
PVM_LATEST_RELEASE_URL="https://api.github.com/repos/rishitshivesh/pvm/releases/latest"
CURRENT_VERSION=""

# Function to print colorful messages
print_info() {
    printf "\033[1;32m$1\033[0m\n"  # Green
}

print_warning() {
    printf "\033[1;33m$1\033[0m\n"  # Yellow
}

print_error() {
    printf "\033[1;31m$1\033[0m\n"  # Red
}

# Function to fetch the latest GitHub release tag
fetch_latest_version() {
    curl -s "$PVM_LATEST_RELEASE_URL" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# Function to check if PVM is installed and up-to-date
check_pvm_installed() {
    if [ -f "$PVM_DIR/pvm.sh" ]; then
        if [ -f "$PVM_DIR/VERSION" ]; then
            CURRENT_VERSION=$(cat "$PVM_DIR/VERSION")
        else
            CURRENT_VERSION="unknown"
        fi

        LATEST_VERSION=$(fetch_latest_version)

        if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
            print_warning "A new version of PVM is available: $LATEST_VERSION (installed: $CURRENT_VERSION)"
            return 1
        else
            print_info "PVM is up to date (version: $CURRENT_VERSION)."
            return 0
        fi
    else
        return 2  # Not installed
    fi
}

# Function to install or upgrade PVM
install_or_upgrade_pvm() {
    if [ "$1" = "upgrade" ]; then
        print_info "Upgrading PVM to the latest version..."
    else
        print_info "Installing PVM..."
    fi

    mkdir -p "$PVM_DIR"

    # Fetch the latest version
    LATEST_VERSION=$(fetch_latest_version)

    # Download pvm.sh for the latest version
    curl -o "$PVM_DIR/pvm.sh" "https://raw.githubusercontent.com/rishitshivesh/pvm/$LATEST_VERSION/scripts/pvm.sh"

    # Save the latest version
    echo "$LATEST_VERSION" > "$PVM_DIR/VERSION"

    # Create a symlink for the pvm command
    if [ -d /usr/local/bin ]; then
        ln -sf "$PVM_DIR/pvm.sh" /usr/local/bin/pvm
        print_info "PVM symlink created at /usr/local/bin/pvm"
    else
        print_warning "Warning: /usr/local/bin not found. Please create the symlink manually:"
        print_warning "ln -s \"$PVM_DIR/pvm.sh\" /usr/local/bin/pvm"
    fi

    # Suggest adding PVM to shell profile
    print_info "To complete installation, add the following to your shell profile:"
    echo 'export PVM_DIR="$HOME/.pvm"'
    echo '[ -s "$PVM_DIR/pvm.sh" ] && \. "$PVM_DIR/pvm.sh"'
}

# Main install/upgrade logic
if [ -d "$PVM_DIR" ]; then
    if ! check_pvm_installed; then
        install_or_upgrade_pvm "upgrade"
    else
        print_info "No upgrade needed."
    fi
else
    install_or_upgrade_pvm "install"
fi
