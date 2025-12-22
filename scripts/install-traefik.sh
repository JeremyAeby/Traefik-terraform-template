#!/bin/bash
# Traefik Installer Script for Debian LXC Containers
# -----------------------------
# Installs Traefik v2.11.33 from GitHub and starts it using a provided traefik.yml
# -----------------------------

set -euo pipefail

# -----------------------------
# Variables
# -----------------------------
TRAEFIK_DIR="/root/traefik"
TRAEFIK_VERSION="v2.11.33"
TRAEFIK_URL="https://github.com/traefik/traefik/releases/download/${TRAEFIK_VERSION}/traefik_${TRAEFIK_VERSION}_linux_amd64.tar.gz"
CONFIG_FILE="${TRAEFIK_DIR}/traefik.yml"
LOG_FILE="${TRAEFIK_DIR}/traefik.log"

export DEBIAN_FRONTEND=noninteractive

# -----------------------------
# Prepare Traefik directory
# -----------------------------
mkdir -p "$TRAEFIK_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file '$CONFIG_FILE' not found."
    exit 1
fi

# -----------------------------
# Install dependencies
# -----------------------------
apt-get update
apt-get install -y curl tar

# -----------------------------
# Download and extract Traefik
# -----------------------------
cd "$TRAEFIK_DIR"

# Download only if not already present
if [ ! -f traefik ]; then
    echo "Downloading Traefik $TRAEFIK_VERSION..."
    curl -4 -fSL "$TRAEFIK_URL" -o traefik.tar.gz
    tar -xzf traefik.tar.gz
    chmod +x traefik
    rm traefik.tar.gz
else
    echo "Traefik binary already exists, skipping download."
fi

# -----------------------------
# Start Traefik in background
# -----------------------------
if pgrep -x traefik >/dev/null; then
    echo "Traefik is already running, skipping start."
else
    nohup "$TRAEFIK_DIR/traefik" \
        --configFile="/root/traefik.yml" \
        > "$LOG_FILE" 2>&1 &
    echo "Traefik started."
    echo "Logs: $LOG_FILE"
fi
