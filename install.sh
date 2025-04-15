#!/bin/bash

clear
echo "========================================="
echo "   Auto Installer Theme Pterodactyl"
echo "       Created by ChatGPT x Request Lu"
echo "========================================="
echo ""
echo "Pilih Theme yang ingin diinstall:"
echo "1) DarkNColor"
echo "2) GreenApple"
echo "3) Dracula"
echo "4) Custom URL"
echo "0) Keluar"
echo ""

read -p "Pilih [1-4]: " pilih

# Lokasi panel
PANEL_DIR="/var/www/pterodactyl"

case $pilih in
    1)
        THEME_URL="https://raw.githubusercontent.com/WeebDev/PteroThemes/main/DarkNColor/install.sh"
        ;;
    2)
        THEME_URL="https://raw.githubusercontent.com/WeebDev/PteroThemes/main/GreenApple/install.sh"
        ;;
    3)
        THEME_URL="https://raw.githubusercontent.com/WeebDev/PteroThemes/main/Dracula/install.sh"
        ;;
    4)
        read -p "Masukkan URL tema custom: " CUSTOM_URL
        THEME_URL="$CUSTOM_URL"
        ;;
    0)
        echo "Keluar dari installer."
        exit 0
        ;;
    *)
        echo "Pilihan tidak valid."
        exit 1
        ;;
esac

echo ""
echo "Menginstall theme dari: $THEME_URL"
sleep 2

cd "$PANEL_DIR" || { echo "Gagal pindah ke direktori panel."; exit 1; }

# Download dan jalankan script theme
curl -s "$THEME_URL" | bash

echo ""
echo "========================================="
echo "Theme berhasil diinstall!"
echo "Silakan cek panel Anda."
echo "========================================="
