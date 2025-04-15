#!/bin/bash

# Warna
green="\e[32m"
red="\e[31m"
endc="\e[0m"

echo -e "${green}=== Auto Install Pterodactyl Panel ===${endc}"

# Update system
apt update && apt upgrade -y

# Install dependencies
apt install -y nginx mysql-server php php-cli php-mysql php-gd php-mbstring php-curl php-xml php-zip php-bcmath unzip curl tar git composer redis-server

# Buat user panel
useradd -m -d /var/www/pterodactyl -s /bin/bash pterodactyl
cd /var/www/pterodactyl
sudo -u pterodactyl bash << EOF
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/
composer install --no-dev --optimize-autoloader
cp .env.example .env
EOF

# Generate App Key dan Migrasi DB
cd /var/www/pterodactyl
php artisan key:generate --force
php artisan migrate --seed --force
php artisan p:environment:setup
php artisan p:environment:database
php artisan p:environment:mail
php artisan p:user:make

# Setup Permissions
chown -R www-data:www-data /var/www/pterodactyl/*

# Setup NGINX
cat <<EOL > /etc/nginx/sites-available/pterodactyl
server {
    listen 80;
    server_name yourdomain.com;

    root /var/www/pterodactyl/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

ln -s /etc/nginx/sites-available/pterodactyl /etc/nginx/sites-enabled/pterodactyl
nginx -t && systemctl reload nginx

# Install Theme (contoh: DarkNColor)
echo -e "${green}=== Installing Theme: DarkNColor ===${endc}"
cd /var/www/pterodactyl
curl -s https://raw.githubusercontent.com/WeebDev/PteroThemes/main/install.sh | bash -s -- -t darkncool

echo -e "${green}=== Done! Akses panel lo di: http://yourdomain.com ===${endc}"
