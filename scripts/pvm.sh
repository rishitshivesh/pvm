#!/bin/sh

# Directory where PVM stores Python versions
PVM_DIR="${HOME}/.pvm"
mkdir -p "$PVM_DIR/versions"
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
fetch_latest_pvm_version() {
    curl -s "$PVM_LATEST_RELEASE_URL" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}


# Function to fetch the latest Python version for a given major/minor version
fetch_latest_python_version() {
    version_prefix="$1"
    latest_python_version=$(curl -s https://www.python.org/ftp/python/ | grep -Eo "$version_prefix\.[0-9]+/" | sort -V | tail -n 1 | tr -d '/')
    if [ -z "$latest_python_version" ]; then
        print_error "Could not find a valid Python version for $version_prefix"
        return 1
    fi
    echo "$latest_python_version"
}

# Function to install a Python version
pvm_install() {
    if [ -z "$1" ]; then
        echo "Please specify a version to install" >&2
        return 1
    fi

    PYTHON_VERSION="$1"

    # If only major or minor version is provided, fetch the latest available patch version
    if echo "$PYTHON_VERSION" | grep -Eq '^[0-9]+(\.[0-9]+)?$'; then
        echo "Fetching the latest version for $PYTHON_VERSION..."
        PYTHON_VERSION=$(fetch_latest_python_version "$PYTHON_VERSION")
        if [ $? -ne 0 ]; then
            return 1
        fi
        echo "Latest version found: $PYTHON_VERSION"
    fi

    PYTHON_INSTALL_DIR="$PVM_DIR/versions/$PYTHON_VERSION"

    # Check if already installed
    if [ -d "$PYTHON_INSTALL_DIR" ]; then
        echo "Python $PYTHON_VERSION is already installed."
        return 0
    fi

    mkdir -p "$PYTHON_INSTALL_DIR"

    # Download Python source code to PVM_DIR/versions
    cd "$PVM_DIR/versions" || return 1
    PYTHON_TAR_FILE="Python-$PYTHON_VERSION.tgz"
    PYTHON_SRC_URL="https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz"

    echo "Downloading Python $PYTHON_VERSION..."
    curl -o "$PYTHON_TAR_FILE" "$PYTHON_SRC_URL"

    # Extract and compile
    echo "Extracting..."
    tar -xzf "$PYTHON_TAR_FILE"
    cd "Python-$PYTHON_VERSION" || return 1

    echo "Configuring and installing..."
    ./configure --prefix="$PYTHON_INSTALL_DIR"
    make -j "$(nproc)"
    make install

    cd ..
    rm -rf "Python-$PYTHON_VERSION" "$PYTHON_TAR_FILE"

    echo "Python $PYTHON_VERSION installed successfully in $PYTHON_INSTALL_DIR."
}

# Function to use a Python version and override system Python
pvm_use() {
    if [ -z "$1" ]; then
        print_error "Please specify a version to use"
        return 1
    fi

    version_to_use="$1"

    # Fetch the latest Python version if only major or minor version is specified
    if echo "$1" | grep -Eq '^[0-9]+(\.[0-9]+)?$'; then
        print_info "Fetching the latest Python version for $version_to_use..."
        version_to_use=$(fetch_latest_python_version "$version_to_use")
        if [ $? -ne 0 ]; then
            return 1
        fi
        print_info "Latest Python version found: $version_to_use"
    fi

    if [ ! -d "$PVM_DIR/versions/$version_to_use" ]; then
        print_info "Version $version_to_use not installed. Installing now..."
        pvm_install "$version_to_use"
    fi

    export PATH="$PVM_DIR/versions/$version_to_use/bin:$PATH"
    print_info "Now using Python $version_to_use"

    # Track the current version being used
    echo "$version_to_use" > "$PVM_CURRENT_VERSION_FILE"

    # Update the system-wide Python version (for both python and python3)
    if sudo ln -sf "$PVM_DIR/versions/$version_to_use/bin/python" /usr/local/bin/python && \
       sudo ln -sf "$PVM_DIR/versions/$version_to_use/bin/python3" /usr/local/bin/python3; then
        print_info "System Python version updated to $version_to_use"
    else
        print_error "Failed to update system Python. You may need to run this manually:"
        print_error "sudo ln -sf \"$PVM_DIR/versions/$version_to_use/bin/python\" /usr/local/bin/python"
        print_error "sudo ln -sf \"$PVM_DIR/versions/$version_to_use/bin/python3\" /usr/local/bin/python3"
    fi

    # Compare the actual system Python version
    actual_python_version=$(python3 --version 2>&1 | awk '{print $2}')
    if [ "$actual_python_version" != "$version_to_use" ]; then
        print_warning "There is a mismatch between the PVM-managed Python version ($version_to_use) and the system Python version ($actual_python_version)."
    fi
}

# Function to show the current Python version
pvm_current() {
    if [ -f "$PVM_CURRENT_VERSION_FILE" ]; then
        current_version=$(cat "$PVM_CURRENT_VERSION_FILE")
        print_info "Current Python version in use by PVM: $current_version"
    else
        print_warning "No Python version is currently being used via PVM."
    fi

    # Also print the system's current Python version
    system_python_version=$(python3 --version 2>&1)
    print_info "System Python version: $system_python_version"
}

# List installed Python versions
pvm_list() {
    echo "Installed Python versions:"
    ls "$PVM_DIR/versions"
}

# Uninstall a Python version
pvm_uninstall() {
    if [ -z "$1" ]; then
        echo "Please specify a version to uninstall" >&2
        return 1
    fi
    PYTHON_INSTALL_DIR="$PVM_DIR/versions/$1"
    if [ ! -d "$PYTHON_INSTALL_DIR" ]; then
        echo "Python $1 is not installed."
        return 1
    fi
    rm -rf "$PYTHON_INSTALL_DIR"
    echo "Python $1 uninstalled successfully."
}

# Add PVM_HOME to PATH
pvm_add_to_path() {
    if [ -z "$PVM_HOME" ]; then
        export PVM_HOME="$PVM_DIR"
    fi
    if ! echo "$PATH" | grep -q "$PVM_HOME"; then
        export PATH="$PVM_HOME/bin:$PATH"
        echo "PVM_HOME has been added to PATH."
    else
        echo "PVM_HOME is already in PATH."
    fi
}

add_pvm_to_profile() {
    SHELL_PROFILE=""
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_PROFILE="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_PROFILE="$HOME/.bashrc"
    fi

    if [ -n "$SHELL_PROFILE" ]; then
        echo "export PVM_HOME=\"$PVM_DIR\"" >> "$SHELL_PROFILE"
        echo "[ -s \"\$PVM_HOME/pvm.sh\" ] && . \"\$PVM_HOME/pvm.sh\"" >> "$SHELL_PROFILE"
        echo "PVM has been added to your $SHELL_PROFILE. Please run 'source $SHELL_PROFILE' to use it immediately."
    else
        echo "Unable to determine shell type. Please add PVM_HOME manually to your shell profile."
    fi
}

pvm_upgrade() {
    LATEST_VERSION=$(fetch_latest_pvm_version)
    CURRENT_VERSION=$(cat "$PVM_DIR/VERSION" 2>/dev/null || echo "none")

    if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
        print_info "Upgrading PVM from version $CURRENT_VERSION to $LATEST_VERSION..."
        curl -o "$PVM_DIR/pvm.sh" "https://raw.githubusercontent.com/rishitshivesh/pvm/$LATEST_VERSION/scripts/pvm.sh"
        echo "$LATEST_VERSION" > "$PVM_DIR/VERSION"
        print_info "PVM upgraded to version $LATEST_VERSION"
    else
        print_info "PVM is already up to date (version: $CURRENT_VERSION)."
    fi
}


print_greeting() {
    # Get the PVM version
    pvm_version=$(cat "$PVM_DIR/VERSION" 2>/dev/null || echo "unknown")

    # Get the currently used Python version
    if [ -f "$PVM_CURRENT_VERSION_FILE" ]; then
        current_python_version=$(cat "$PVM_CURRENT_VERSION_FILE")
    else
        current_python_version="none"
    fi

    # Print the greeting message
    printf "\033[1;36mHello, friend! \033[1;35mUsing pvm@$pvm_version.\033[0m\n"  # Cyan and Purple
    printf "\033[1;32mPython current version at - \033[1;33m$current_python_version\033[0m\n"  # Green and Yellow
    printf "\033[1;32mSteps to use:\033[0m\n"
    printf "\033[1;32m  - To install a version: \033[1;33mpvm install <version>\033[0m\n"
    printf "\033[1;32m  - To use a version: \033[1;33mpvm use <version>\033[0m\n"
    printf "\033[1;32m  - To list installed versions: \033[1;33mpvm list\033[0m\n"
    printf "\033[1;32m  - To upgrade PVM: \033[1;33mpvm upgrade\033[0m\n"
    printf "\033[1;32m  - To check the current Python version: \033[1;33mpvm current\033[0m\n"
}

# Main entry point for PVM
case "$1" in
    upgrade)
        pvm_upgrade
        ;;
    install)
        pvm_install "$2"
        ;;
    use)
        pvm_use "$2"
        ;;
    current)
        pvm_current
        ;;
    ls | list)
        pvm_list
        ;;
    uninstall)
        pvm_uninstall "$2"
        ;;
    add-to-path)
        pvm_add_to_path
        ;;
    *)
        print_greeting
        ;;
esac