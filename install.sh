#!/bin/bash

# === Konfigurasi Awal ===
DOMAIN="panel.domainlu.com"
EMAIL="emaillu@domain.com"  # buat SSL Let's Encrypt

echo "Updating system..."
apt update && apt upgrade -y

echo "Installing dependencies..."
apt install -y curl wget sudo unzip tar nginx gnupg mariadb-server php php-cli php-mysql php-gd php-mbstring php-xml php-bcmath php-curl php-zip php-fpm php-tokenizer php-common php-mysqlnd php-memcached php-redis php-imagick php-intl php-opcache php-readline redis composer

# === Setting Database ===
DB_ROOT_PASS=$(openssl rand -base64 12)
DB_PANEL_PASS=$(openssl rand -base64 12)

echo "Securing MariaDB..."
mysql_secure_installation <<EOF

y
$DB_ROOT_PASS
$DB_ROOT_PASS
y
y
y
y
EOF

mysql -u root -p$DB_ROOT_PASS -e "CREATE DATABASE panel;"
mysql -u root -p$DB_ROOT_PASS -e "CREATE USER 'panel'@'127.0.0.1' IDENTIFIED BY '$DB_PANEL_PASS';"
mysql -u root -p$DB_ROOT_PASS -e "GRANT ALL PRIVILEGES ON panel.* TO 'panel'@'127.0.0.1';"
mysql -u root -p$DB_ROOT_PASS -e "FLUSH PRIVILEGES;"

# === Install Panel ===
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/

composer install --no-dev --optimize-autoloader

cp .env.example .env

php artisan key:generate --force
php artisan p:environment:setup --author="$EMAIL" --url="https://$DOMAIN" --timezone="Asia/Jakarta" --cache="redis" --session="redis" --queue="redis"
php artisan p:environment:database --host=127.0.0.1 --port=3306 --database=panel --username=panel --password="$DB_PANEL_PASS"
php artisan p:environment:mail --driver=smtp --host=mail.domain.com --port=587 --username=email@domain.com --password=pass --encryption=tls --from=email@domain.com

php artisan migrate --seed --force
php artisan p:user:make

chown -R www-data:www-data /var/www/pterodactyl/*

# === Install Nebula Theme ===
curl -s https://pterothemes.com/api/install/nebula.sh | bash

# === Konfigurasi Nginx ===
cat <<EOF > /etc/nginx/sites-available/pterodactyl
server {
    listen 80;
    server_name $DOMAIN;

    root /var/www/pterodactyl/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock; # sesuaikan versi PHP
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -s /etc/nginx/sites-available/pterodactyl /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# === Install SSL ===
apt install -y certbot python3-certbot-nginx
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL

# === Selesai ===
echo "Panel sudah terinstall di https://$DOMAIN"
echo "User & Password panel dibuat saat proses"
echo "Database Password ROOT: $DB_ROOT_PASS"
echo "Database Password PANEL: $DB_PANEL_PASS"
