#!/bin/bash

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo privileges."
    exit 1
fi

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create a directory called "tools" within the script's directory
TOOLS_DIR="$SCRIPT_DIR/tools"
mkdir -p "$TOOLS_DIR"

# Update the system
echo "Updating the system..."
apt update -y
apt upgrade -y
echo "System update completed."

# Install required packages
echo "Installing required packages..."
apt install -y python3-pip

# Install crackmapexec
echo "Installing crackmapexec..."
wget "https://github.com/byt3bl33d3r/CrackMapExec/releases/download/v5.4.0/cme-ubuntu-latest-3.10.zip" -O "$TOOLS_DIR/cme-ubuntu-latest-3.10.zip"
unzip "$TOOLS_DIR/cme-ubuntu-latest-3.10.zip" -d "$TOOLS_DIR"
chmod +x "$TOOLS_DIR/crackmapexec"
echo "Crackmapexec installation completed"

# Install kerbrute
echo "Installing kerbrute..."
wget "https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64" -O "$TOOLS_DIR/kerbrute_linux_amd64"
chmod +x "$TOOLS_DIR/kerbrute_linux_amd64"
echo "kerbrute installation completed."

# Install windapsearch
echo "Installing windapsearch..."
wget "https://github.com/ropnop/go-windapsearch/releases/download/v0.3.0/windapsearch-linux-amd64" -O "$TOOLS_DIR/windapsearch-linux-amd64"
chmod +x "$TOOLS_DIR/windapsearch-linux-amd64"
echo "windapsearch installation completed."

# Install impacket (if needed)
# echo "Installing impacket..."
# git clone https://github.com/SecureAuthCorp/impacket.git "$TOOLS_DIR/impacket"
# cd "$TOOLS_DIR/impacket"
# pip3 install .
# echo "impacket installation completed."

# Install netcat (if needed)
# echo "Installing netcat..."
# echo "netcat installation completed."

echo "All tools have been installed successfully."


