#!/bin/bash

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo privileges."
    exit 1
fi


# Check if Nmap is installed, and if not, install it
if ! command -v nmap &> /dev/null; then
    echo "Nmap is not installed. Installing Nmap..."
    apt install nmap -y
    echo "Nmap installation completed."
else
    echo "Nmap is already installed."
fi

# Read the IP address from the user
read -p "Enter the IP address to scan: " target_ip

# Perform an Nmap scan and save the results to a file
echo "Scanning $target_ip with Nmap..."
nmap -A -T4 -Pn -p- -oN nmap_scan_results.txt $target_ip

echo "Nmap scan completed. Results are saved in 'nmap_scan_results.txt'."

