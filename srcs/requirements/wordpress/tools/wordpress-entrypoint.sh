#!/bin/bash
set -e
cd /var/www/html


timeout=120
while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
    echo "Waiting for MariaDB..."
    sleep 5
    ((timeout-=5)) || { echo "Error: Timeout"; exit 1; }
done
echo "MariaDB is up and running!"


if [ ! -f wp-config.php ]; then
    echo "Installing WordPress..."

    if [ ! -f index.php ]; then
        wp core download --allow-root
    fi

    
    wp config create \
        --dbname=$WORDPRESS_DB_NAME \
        --dbuser=$WORDPRESS_DB_USER \
        --dbpass=$WORDPRESS_DB_PASSWORD \
        --dbhost=$WORDPRESS_DB_HOST \
        --allow-root

    
    wp config set WP_REDIS_HOST redis
    wp config set WP_REDIS_PORT 6379 --raw
    wp config set WP_CACHE true --raw
    wp config set FS_METHOD direct

    
    wp core install \
        --url=$WORDPRESS_URL \
        --title=$WORDPRESS_TITLE \
        --admin_user=$WORDPRESS_ADMIN_USER \
        --admin_password=$WORDPRESS_ADMIN_PASSWORD \
        --admin_email=$WORDPRESS_ADMIN_EMAIL \
        --allow-root

    
    wp user create \
        $WORDPRESS_USER \
        $WORDPRESS_USER_EMAIL \
        --role=author \
        --user_pass=$WORDPRESS_USER_PASSWORD \
        --allow-root
    
    echo "WordPress installation completed!"
else
    echo "WordPress is already installed."
fi

chmod -R o+w /var/www/html/wp-content

echo "Starting PHP-FPM..."
exec "$@"