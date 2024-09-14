#!/bin/sh

# Directory where PVM is installed
PVM_DIR="$HOME/.pvm"
PVM_SCRIPT_URL="https://raw.githubusercontent.com/rishitshivesh/pvm/main/scripts/pvm.sh"
PVM_LATEST_RELEASE_URL="https://api.github.com/repos/rishitshivesh/pvm/releases/latest"

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

#!/bin/sh

# Directory where PVM is installed
PVM_DIR="$HOME/.pvm"
PVM_SCRIPT_URL="https://raw.githubusercontent.com/rishitshivesh/pvm/main/scripts/pvm.sh"
PVM_LATEST_RELEASE_URL="https://api.github.com/repos/rishitshivesh/pvm/releases/latest"

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
    if sudo ln -sf "$PVM_DIR/pvm.sh" /usr/local/bin/pvm; then
        print_info "PVM symlink created at /usr/local/bin/pvm"
    else
        print_error "Failed to create symlink. Please run this command manually:"
        print_error "sudo ln -sf \"$PVM_DIR/pvm.sh\" /usr/local/bin/pvm"
    fi

    # Suggest adding PVM to shell profile
    print_info "To complete installation, add the following to your shell profile:"
    echo 'export PVM_DIR="$HOME/.pvm"'
    echo '[ -s "$PVM_DIR/pvm.sh" ] && \. "$PVM_DIR/pvm.sh"'
}

# Main install/upgrade logic
if [ -d "$PVM_DIR" ]; then
    install_or_upgrade_pvm "upgrade"
else
    install_or_upgrade_pvm "install"
fi


# Main install/upgrade logic
if [ -d "$PVM_DIR" ]; then
    install_or_upgrade_pvm "upgrade"
else
    install_or_upgrade_pvm "install"
fi
