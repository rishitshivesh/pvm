#!/bin/sh

# Set the PVM directory where Python versions will be installed
export PVM_DIR="${HOME}/.pvm"
mkdir -p "$PVM_DIR/versions"  # Ensure the versions directory exists

# Function to install a Python version
pvm_install() {
    if [ -z "$1" ]; then
        echo "Please specify a version to install" >&2
        return 1
    fi

    PYTHON_VERSION="$1"
    PYTHON_INSTALL_DIR="$PVM_DIR/versions/$PYTHON_VERSION"

    # Check if already installed
    if [ -d "$PYTHON_INSTALL_DIR" ]; then
        echo "Python $PYTHON_VERSION is already installed."
        return 0
    fi

    # Download Python source code
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

    echo "Python $PYTHON_VERSION installed successfully."
}

fetch_latest_python_version() {
    # Fetch the available Python versions from the Python website
    version_prefix="$1"
    curl -s https://www.python.org/ftp/python/ | grep -Eo "$version_prefix\.[0-9]+/" | sort -V | tail -n 1 | tr -d '/'
}

# Function to use PVM
pvm_use() {
    if [ -z "$1" ]; then
        echo "Please specify a version" >&2
        return 1
    fi

    # Check if it's a major version (e.g., 3) or minor version (e.g., 3.10)
    if echo "$1" | grep -Eq '^[0-9]+\.[0-9]+$'; then
        # It's a minor version (e.g., 3.10)
        version_to_use=$(fetch_latest_python_version "$1")
    elif echo "$1" | grep -Eq '^[0-9]+$'; then
        # It's a major version (e.g., 3)
        version_to_use=$(fetch_latest_python_version "$1")
    else
        # It's a specific version (e.g., 3.9.7)
        version_to_use="$1"
    fi

    if [ -z "$version_to_use" ]; then
        echo "Could not find a valid version for $1"
        return 1
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
    *)
        echo "Usage: pvm {install|use|ls|uninstall|add-to-path} [version]" >&2
        ;;
esac
