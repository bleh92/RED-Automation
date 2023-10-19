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

# Extract the domain name from the Nmap results, preserving case
domain_name=$(grep -oP -m 1 "Domain: \K[^,]+" nmap_scan_results.txt)

echo "Nmap scan completed. Results are saved in 'nmap_scan_results.txt'."
echo "Domain name (dname): $domain_name"

echo "Using windapsearch to get usernames from LDAP"

# Run the windapsearch command with the constructed regex
# Define the path to the windapsearch executable
WINDAPSEARCH="./tools/windapsearch-linux-amd64"

# Run windapsearch based on the domain_name variable
$WINDAPSEARCH -d "$domain_name" -m users --filter | grep -o 'userPrincipalName: [^ ]*' | cut -d ' ' -f 2 > "$domain_name-Users.txt"
echo "Usernames will be saved in a text file."

# Color codes
RED='\033[0;31m'
NC='\033[0m' # No color

# Prompt the user
echo -e "${RED}Performing kerberoasting, please ensure you know the domain password policy to avoid account lockout.${NC}"
echo -e "${RED}Are you sure you want to proceed with kerberoasting? (y/n)${NC}"

# Read user input
read -r answer

# Check the user's response
if [ "$answer" == "y" ] || [ "$answer" == "Y" ]; then
    # Proceed with kerberoasting
    echo "Proceeding with kerberoasting..."
    read -p "Enter domain IP address: " domain_ip
    KERBRUTE="./tools/kerbrute_linux_amd64"
    $KERBRUTE userenum "$domain_name-Users.txt" --dc "$domain_ip" -d "$domain_name"
elif [ "$answer" == "n" ] || [ "$answer" == "N" ]; then
    # User chose not to proceed
    echo "Kerberoasting canceled."
else
    # Handle invalid input
    echo "Invalid input. Please enter 'y' to proceed or 'n' to cancel."
fi


