#!/bin/bash

#=================================================
# Auto Installer Pterodactyl Theme by NeoXloud
# GitHub  : https://github.com/NeoXloud
# License : MIT
#=================================================
# Contributors:
# - NeoXloud (Main Dev)
# - RezaX
# - AiXcript

# Color setup
GREEN='\033[0;32m'
NC='\033[0m'
RED='\033[0;31m'

echo -e "${GREEN}"
cat << "EOF"
 _   _                 ____  _                 _ 
| \ | | ___  _ __ ___ |  _ \| | ___   ___ __ _| |
|  \| |/ _ \| '_ ` _ \| | | | |/ _ \ / __/ _` | |
| |\  | (_) | | | | | | |_| | | (_) | (_| (_| | |
|_| \_|\___/|_| |_| |_|____/|_|\___/ \___\__,_|_|

        Pterodactyl Theme Installer by NeoXloud
EOF
echo -e "${NC}"

# Check if pterodactyl directory exists
if [ ! -d "/var/www/pterodactyl" ]; then
  echo -e "${RED}Pterodactyl not found at /var/www/pterodactyl. Exiting.${NC}"
  exit 1
fi

cd /var/www/pterodactyl || exit

# Ask for theme choice
echo ""
echo "Choose theme to install:"
echo "1) Dark Theme"
echo "2) Red Theme"
echo "3) Purple Theme"
read -rp "Enter your choice [1-3]: " theme_choice

# Define download link
case $theme_choice in
  1)
    theme_url="https://raw.githubusercontent.com/NeoXloud/Themes/main/Dark.zip"
    ;;
  2)
    theme_url="https://raw.githubusercontent.com/NeoXloud/Themes/main/Red.zip"
    ;;
  3)
    theme_url="https://raw.githubusercontent.com/NeoXloud/Themes/main/Purple.zip"
    ;;
  *)
    echo -e "${RED}Invalid choice.${NC}"
    exit 1
    ;;
esac

# Backup existing files
backup_dir="Backup-$(date +%F-%H%M)"
mkdir -p "$backup_dir"
cp -r public "$backup_dir/"
cp -r resources "$backup_dir/"
echo -e "${GREEN}Backup created at $backup_dir${NC}"

# Download and install theme
echo "Downloading theme..."
curl -L "$theme_url" -o theme.zip
unzip -o theme.zip
cp -r public/* /var/www/pterodactyl/public/
cp -r resources/* /var/www/pterodactyl/resources/
rm -rf theme.zip public resources

# Set permissions
chown -R www-data:www-data /var/www/pterodactyl/*

echo -e "${GREEN}Theme successfully installed!${NC}"
