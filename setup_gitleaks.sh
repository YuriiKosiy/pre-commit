#!/bin/bash

GITLEAKS_VERSION="8.18.4"
INSTALL_DIR="$HOME/.local/bin"  # Install on Home DIR without sudo
ARCHIVE_FILENAME=""

# Defining OS and ARCH
OS=$(uname -s)
ARCH=$(uname -m)

# Choose OS and ARCH
case "$OS" in
    Linux)
        if [ "$ARCH" == "arm64" ]; then
            ARCHIVE_FILENAME="gitleaks_${GITLEAKS_VERSION}_linux_arm64.tar.gz"
        else
            ARCHIVE_FILENAME="gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz"
        fi
        ;;
    Darwin)
        if [ "$ARCH" == "arm64" ]; then
            ARCHIVE_FILENAME="gitleaks_${GITLEAKS_VERSION}_darwin_arm64.tar.gz"
        else
            ARCHIVE_FILENAME="gitleaks_${GITLEAKS_VERSION}_darwin_x64.tar.gz"
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*|Windows_NT)
        if [ "$ARCH" == "arm64" ]; then
            ARCHIVE_FILENAME="gitleaks_${GITLEAKS_VERSION}_windows_arm64.zip"
        else
            ARCHIVE_FILENAME="gitleaks_${GITLEAKS_VERSION}_windows_x64.zip"
        fi
        INSTALL_DIR="$HOME/.local/bin"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# URL for download Gitleaks
DOWNLOAD_URL="https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/${ARCHIVE_FILENAME}"

# download Gitleaks
echo "Downloading Gitleaks from $DOWNLOAD_URL..."
curl -sSfL "$DOWNLOAD_URL" -o gitleaks_archive

# Check path
mkdir -p "$INSTALL_DIR"

# Unpack
if [[ "$ARCHIVE_FILENAME" == *.tar.gz ]]; then
    tar -xzvf gitleaks_archive -C "$INSTALL_DIR"
elif [[ "$ARCHIVE_FILENAME" == *.zip ]]; then
    unzip -d "$INSTALL_DIR" gitleaks_archive
else
    echo "Unknown archive format: $ARCHIVE_FILENAME"
    exit 1
fi

# Clean after updates
rm gitleaks_archive

# check if $HOME/.local/bin in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Adding $INSTALL_DIR to PATH..."
    export PATH="$INSTALL_DIR:$PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # or ~/.zshrc для Zsh
fi

# Check, if Gitleaks installed
if ! command -v gitleaks &> /dev/null; then
    echo "Failed to install Gitleaks. Commit rejected."
    exit 1
fi

echo "Gitleaks installed successfully."

# Check if Gitleaks enables
check_hook_enabled() {
    HOOK_ENABLED=$(git config --get hooks.gitleaks)

    if [ "$HOOK_ENABLED" != "true" ]; then
        echo "Gitleaks pre-commit hook is disabled. Enable it with 'git config hooks.gitleaks true'."
        exit 0
    fi
}

# install pre-commit hook
setup_pre_commit_hook() {
    HOOKS_DIR=".git/hooks"
    PRE_COMMIT_HOOK="$HOOKS_DIR/pre-commit"

    # copy script to .git/hooks/pre-commit
    if [ ! -f "$PRE_COMMIT_HOOK" ]; then
        cp "$0" "$PRE_COMMIT_HOOK"
        chmod +x "$PRE_COMMIT_HOOK"
        echo "Gitleaks pre-commit hook has been installed."
    else
        echo "Pre-commit hook already exists."
    fi
}

# run Gitleaks
run_gitleaks() {
    echo "Running Gitleaks..."
    gitleaks protect --staged --source . --verbose

    if [ $? -ne 0 ]; then
        echo "Gitleaks detected secrets, commit rejected."
        exit 1
    fi

    echo "No secrets detected. Proceeding with commit."
}

# main code
check_hook_enabled
setup_pre_commit_hook
run_gitleaks