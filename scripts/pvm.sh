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


# Function to fetch the latest Python version from Python.org
fetch_latest_python_version() {
    version_prefix="$1"
    # Fetch the list of available Python versions and filter based on the prefix
    latest_version=$(curl -s https://www.python.org/ftp/python/ | grep -Eo "$version_prefix\.[0-9]+/" | sort -V | tail -n 1 | tr -d '/')
    if [ -z "$latest_version" ]; then
        echo "Could not find a valid Python version for $version_prefix"
        return 1
    fi
    echo "$latest_version"
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
    mkdir -p "$PYTHON_INSTALL_DIR"

    # Check if already installed
    if [ -d "$PYTHON_INSTALL_DIR" ]; then
        echo "Python $PYTHON_VERSION is already installed."
        return 0
    fi

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

# Function to use a Python version
pvm_use() {
    if [ -z "$1" ]; then
        print_error "Please specify a version to use"
        return 1
    fi

    version_to_use="$1"

    # Fetch the latest version if only major or minor version is specified
    if echo "$1" | grep -Eq '^[0-9]+(\.[0-9]+)?$'; then
        print_info "Fetching the latest version for $version_to_use..."
        version_to_use=$(fetch_latest_python_version)
        if [ $? -ne 0 ]; then
            return 1
        fi
        print_info "Latest version found: $version_to_use"
    fi

    if [ ! -d "$PVM_DIR/versions/$version_to_use" ]; then
        print_info "Version $version_to_use not installed. Installing now..."
        pvm_install "$version_to_use"
    fi

    export PATH="$PVM_DIR/versions/$version_to_use/bin:$PATH"
    print_info "Now using Python $version_to_use"

    # Update the system-wide Python version
    if sudo ln -sf "$PVM_DIR/versions/$version_to_use/bin/python" /usr/local/bin/python; then
        print_info "System Python version updated to $version_to_use"
    else
        print_error "Failed to update system Python. You may need to run this manually:"
        print_error "sudo ln -sf \"$PVM_DIR/versions/$version_to_use/bin/python\" /usr/local/bin/python"
    fi
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

# Main entry point
case "$1" in
    install)
        pvm_install "$2"
        ;;
    use)
        pvm_use "$2"
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
    add-to-profile)
        add_pvm_to_profile
        ;;
    *)
        echo "Usage: pvm {install|use|ls|uninstall|add-to-path} [version]" >&2
        ;;
esac
