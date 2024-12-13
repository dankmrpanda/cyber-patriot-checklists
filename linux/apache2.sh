#!/bin/bash

# Apache Hardening Script according to CIS Benchmarks
# Tested on Mint 21 (Ubuntu 22.04 LTS base)

# Variables
APACHE_CONF_DIR="/etc/apache2"
APACHE_DIR_CONF="$APACHE_CONF_DIR/apache2.conf"
APACHE_CONF_FILE="$APACHE_CONF_DIR/conf-available/security.conf"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/root/apache_backup_$TIMESTAMP"

# Create backup of Apache configuration
echo "Creating backups of Apache configuration files..."
mkdir -p "$BACKUP_DIR"
cp -r "$APACHE_CONF_DIR" "$BACKUP_DIR"
echo "Backups saved in $BACKUP_DIR"

# Update and upgrade system packages
echo "Updating system packages..."
apt update && apt -y upgrade

# Ensure Apache is installed
echo "Installing Apache2 if not already installed..."
apt -y install apache2

# Disable unnecessary Apache modules
echo "Disabling unnecessary Apache modules..."
a2dismod -f autoindex status info cgi include negotiation userdir

# Enable necessary Apache modules
echo "Enabling necessary Apache modules..."
a2enmod headers ssl rewrite

# Configure ServerTokens and ServerSignature
echo "Configuring Apache to hide version information..."
sed -i 's/^ServerTokens .*/ServerTokens Prod/' "$APACHE_CONF_FILE"
sed -i 's/^ServerSignature .*/ServerSignature Off/' "$APACHE_CONF_FILE"

# Disable directory listing
echo "Disabling directory listing..."
sed -i 's/Options Indexes FollowSymLinks/Options FollowSymLinks/' "$APACHE_DIR_CONF"

# Set appropriate permissions and ownership for Apache directories
echo "Setting permissions and ownership for Apache directories..."
chown -R root:root "$APACHE_CONF_DIR"
find "$APACHE_CONF_DIR" -type d -exec chmod 755 {} \;
find "$APACHE_CONF_DIR" -type f -exec chmod 644 {} \;

# Configure access control
echo "Configuring access control..."
ACCESS_CONF="$APACHE_CONF_DIR/conf-available/access.conf"
echo "<Directory />
    AllowOverride None
    Require all denied
</Directory>

<Directory /usr/share>
    AllowOverride None
    Require all granted
</Directory>

<Directory /var/www/>
    AllowOverride None
    Require all granted
</Directory>" > "$ACCESS_CONF"
a2enconf access

# Limit HTTP request methods
echo "Limiting HTTP request methods..."
LIMIT_METHODS_CONF="$APACHE_CONF_DIR/conf-available/limit-methods.conf"
echo "<Location />
    <LimitExcept GET POST HEAD>
        Require all denied
    </LimitExcept>
</Location>" > "$LIMIT_METHODS_CONF"
a2enconf limit-methods

# Configure timeout and limit settings
echo "Configuring timeout and limit settings..."
sed -i 's/^Timeout .*/Timeout 60/' "$APACHE_DIR_CONF"
if ! grep -q "^KeepAlive Off" "$APACHE_DIR_CONF"; then
    echo "KeepAlive Off" >> "$APACHE_DIR_CONF"
fi
sed -i 's/^MaxRequestWorkers .*/MaxRequestWorkers 150/' "$APACHE_CONF_DIR/mods-available/mpm_prefork.conf"

# Enable SSL and configure HTTPS
echo "Enabling SSL module and configuring HTTPS..."
a2enmod ssl
a2ensite default-ssl

# Generate a self-signed SSL certificate (for testing purposes)
echo "Generating self-signed SSL certificate..."
SSL_DIR="/etc/ssl/apache2"
mkdir -p "$SSL_DIR"
openssl req -new -x509 -days 365 -nodes -out "$SSL_DIR/apache.crt" -keyout "$SSL_DIR/apache.key" -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=example.com"

# Update default-ssl.conf with the certificate paths
SSL_CONF="$APACHE_CONF_DIR/sites-available/default-ssl.conf"
sed -i "s|SSLCertificateFile.*|SSLCertificateFile $SSL_DIR/apache.crt|" "$SSL_CONF"
sed -i "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile $SSL_DIR/apache.key|" "$SSL_CONF"

# Force HTTPS by redirecting HTTP to HTTPS
echo "Forcing HTTPS connections..."
REDIRECT_CONF="$APACHE_CONF_DIR/conf-available/redirect-http-to-https.conf"
echo "<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
</IfModule>" > "$REDIRECT_CONF"
a2enconf redirect-http-to-https

# Configure logging
echo "Configuring Apache logging..."

# Remove existing LogFormat directives that define 'combined' to prevent duplication
sed -i '/^LogFormat.*combined$/d' "$APACHE_DIR_CONF"

# Add the correct LogFormat directive if not already present
if ! grep -q '^LogFormat.*combined$' "$APACHE_DIR_CONF"; then
    echo 'LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined' >> "$APACHE_DIR_CONF"
fi

# Ensure ErrorLog and CustomLog are set correctly
sed -i 's|^ErrorLog .*|ErrorLog ${APACHE_LOG_DIR}/error.log|' "$APACHE_DIR_CONF"
sed -i 's|^CustomLog .*|CustomLog ${APACHE_LOG_DIR}/access.log combined|' "$APACHE_DIR_CONF"

# Restrict access to logs
echo "Restricting access to log files..."
chown -R root:adm /var/log/apache2
chmod -R 640 /var/log/apache2

# Disable TRACE method
echo "Disabling TRACE method..."
if ! grep -q "^TraceEnable Off" "$APACHE_DIR_CONF"; then
    echo "TraceEnable Off" >> "$APACHE_DIR_CONF"
fi

# Disable ETag header
echo "Disabling ETag header..."
if ! grep -q "^FileETag None" "$APACHE_DIR_CONF"; then
    echo "FileETag None" >> "$APACHE_DIR_CONF"
fi

# Enable HTTP Strict Transport Security (HSTS)
echo "Enabling HSTS..."
if ! grep -q "Strict-Transport-Security" "$APACHE_CONF_FILE"; then
    echo 'Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"' >> "$APACHE_CONF_FILE"
fi

# Restart Apache to apply changes
echo "Restarting Apache to apply changes..."
apachectl configtest
if [ $? -eq 0 ]; then
    systemctl restart apache2
    echo "Apache hardening completed according to CIS Benchmarks."
else
    echo "Apache configuration test failed. Check the syntax and try again."
fi
