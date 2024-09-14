#!/bin/sh

# Set the PVM directory where Python versions will be installed
export PVM_DIR="${HOME}/.pvm"
mkdir -p "$PVM_DIR/versions"  # Ensure the versions directory exists

# Function to source the active version
pvm_use() {
    if [ -z "$1" ]; then
        echo "Please specify a version" >&2
        return 1
    fi
    if [ ! -d "$PVM_DIR/versions/$1" ]; then
        echo "Version $1 not installed" >&2
        return 1
    fi
    export PATH="$PVM_DIR/versions/$1/bin:$PATH"
    echo "Now using Python $1"
}

pvm_install() {
    if [ -z "$1" ]; then
        echo "Please specify a version to install" >&2
        return 1
    fi

    # Define the Python version to install
    PYTHON_VERSION="$1"
    PYTHON_INSTALL_DIR="$PVM_DIR/versions/$PYTHON_VERSION"

    # Check if already installed
    if [ -d "$PYTHON_INSTALL_DIR" ]; then
        echo "Python $PYTHON_VERSION is already installed." >&2
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

pvm_list() {
    echo "Installed Python versions:"
    ls "$PVM_DIR/versions"
}

pvm_uninstall() {
    if [ -z "$1" ]; then
        echo "Please specify a version to uninstall" >&2
        return 1
    fi

    PYTHON_VERSION="$1"
    PYTHON_INSTALL_DIR="$PVM_DIR/versions/$PYTHON_VERSION"

    # Check if installed
    if [ ! -d "$PYTHON_INSTALL_DIR" ]; then
        echo "Python $PYTHON_VERSION is not installed." >&2
        return 1
    fi

    # Remove the version
    rm -rf "$PYTHON_INSTALL_DIR"
    echo "Python $PYTHON_VERSION uninstalled successfully."
}

pvm_current() {
    PYTHON_VERSION=$(python --version 2>&1 | awk '{print $2}')
    echo "Current Python version is $PYTHON_VERSION"
}

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
    current)
        pvm_current
        ;;
    add_to_path)
        pvm_add_to_path
        ;;
    *)
        echo "Usage: pvm {install|use|ls|uninstall|current} [version]" >&2
        ;;
esac
