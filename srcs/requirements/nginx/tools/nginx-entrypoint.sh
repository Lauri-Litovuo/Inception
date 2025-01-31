#!/bin/bash
set -e

# Check if SSL certificates exist; generate them if not
if [ ! -f /etc/nginx/ssl/nginx.key ]; then
    echo "Generating self-signed SSL certificate..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/CN=${DOMAIN_NAME:-localhost}"
    echo "SSL certificate generated for ${DOMAIN_NAME:-localhost}"
fi

# Start Nginx
exec "$@"