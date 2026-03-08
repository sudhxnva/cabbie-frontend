#!/bin/bash

# Exit script on any error
set -e

echo "🚀 Starting deployment to Vultr VPS..."

# 1. Update system packages
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# 2. Install Node.js (v20) and npm if they are not installed
if ! command -v node &> /dev/null; then
    echo "⚙️ Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# 3. Install Nginx if not installed
if ! command -v nginx &> /dev/null; then
    echo "🌐 Installing Nginx..."
    sudo apt install nginx -y
fi

# 4. Install project dependencies and build the Vite React app
echo "🔨 Installing project dependencies and building Vite application..."
npm install
npm run build

# 5. Set up the web directory
echo "📂 Moving build to /var/www/cabbie-frontend/dist..."
sudo mkdir -p /var/www/cabbie-frontend
# Sync the dist folder from the build to the web directory
sudo rsync -av --delete dist/ /var/www/cabbie-frontend/dist/

# Set appropriate permissions
sudo chown -R www-data:www-data /var/www/cabbie-frontend
sudo chmod -R 755 /var/www/cabbie-frontend

# 6. Configure Nginx
echo "⚙️ Configuring Nginx..."
sudo cp nginx.conf /etc/nginx/sites-available/cabbie-frontend

# Enable the site by creating a symlink (if it doesn't already exist)
if [ ! -L /etc/nginx/sites-enabled/cabbie-frontend ]; then
    sudo ln -s /etc/nginx/sites-available/cabbie-frontend /etc/nginx/sites-enabled/
fi

# Remove default nginx config to avoid conflicts
if [ -f /etc/nginx/sites-enabled/default ]; then
    sudo rm /etc/nginx/sites-enabled/default
fi

# 7. Restart Nginx to apply changes
echo "🔄 Testing Nginx configuration and restarting..."
sudo nginx -t
sudo systemctl restart nginx

echo "✅ Deployment successful! Your site should now be live."
echo "If you have a domain, you can now run 'sudo ufw allow 'Nginx Full'' and set up SSL with Certbot (Let's Encrypt)."
