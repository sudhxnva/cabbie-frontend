#!/bin/sh

# Exit script on any error
set -e

echo "🚀 Starting deployment to Vultr VPS (Alpine)..."

# 1. Update system packages
echo "📦 Updating system packages..."
sudo apk update
sudo apk upgrade

# 2. Install Node.js and npm if not installed
if ! command -v node >/dev/null 2>&1; then
    echo "⚙️ Installing Node.js and npm..."
    sudo apk add nodejs npm
fi

# 3. Install nginx if not installed
if ! command -v nginx >/dev/null 2>&1; then
    echo "🌐 Installing Nginx..."
    sudo apk add nginx
fi

# 4. Install rsync (not included by default in Alpine)
if ! command -v rsync >/dev/null 2>&1; then
    echo "📦 Installing rsync..."
    sudo apk add rsync
fi

# 5. Install project dependencies and build the Vite React app
echo "🔨 Installing project dependencies and building Vite application..."
npm install
npm run build

# 6. Set up the web directory
echo "📂 Moving build to /var/www/cabbie-frontend/dist..."
sudo mkdir -p /var/www/cabbie-frontend

sudo rsync -av --delete dist/ /var/www/cabbie-frontend/dist/

# Set permissions
sudo chown -R nginx:nginx /var/www/cabbie-frontend
sudo chmod -R 755 /var/www/cabbie-frontend

# 7. Configure Nginx
echo "⚙️ Configuring Nginx..."

sudo mkdir -p /etc/nginx/http.d
sudo cp nginx.conf /etc/nginx/http.d/cabbie-frontend.conf

# 8. Enable nginx on boot (OpenRC)
sudo rc-update add nginx default

# 9. Test nginx config
echo "🔄 Testing Nginx configuration..."
sudo nginx -t

# 10. Restart nginx
echo "🔄 Restarting nginx..."
sudo rc-service nginx restart

echo "✅ Deployment successful! Your site should now be live."
echo "If using a firewall, open ports 80 and 443."