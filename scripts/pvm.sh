#!/bin/sh

# Directory where PVM stores Python versions
PVM_DIR="${HOME}/.pvm"
mkdir -p "$PVM_DIR/versions"

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
        echo "Please specify a version" >&2
        return 1
    fi

    version_to_use="$1"

    # Fetch the latest version if only major or minor version is specified
    if echo "$1" | grep -Eq '^[0-9]+(\.[0-9]+)?$'; then
        echo "Fetching the latest version for $version_to_use..."
        version_to_use=$(fetch_latest_python_version "$version_to_use")
        if [ $? -ne 0 ]; then
            return 1
        fi
        echo "Latest version found: $version_to_use"
    fi

    if [ ! -d "$PVM_DIR/versions/$version_to_use" ]; then
        echo "Version $version_to_use not installed. Installing now..."
        pvm_install "$version_to_use"
    fi

    export PATH="$PVM_DIR/versions/$version_to_use/bin:$PATH"
    echo "Now using Python $version_to_use"
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
