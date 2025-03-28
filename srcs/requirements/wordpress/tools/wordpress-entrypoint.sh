#!/bin/bash
set -e
cd /var/www/html


timeout=180
while ! mysqladmin ping -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    echo "Waiting for MariaDB..."
    sleep 5
    ((timeout-=5)) || { echo "Error: Timeout"; exit 1; }
done
echo "MariaDB is up and running!"


if [ ! -f wp-config.php ]; then
    echo "Installing WordPress..."

    if [ ! -f index.php ]; then
        wp --debug core download --allow-root
    fi

    
    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$MYSQL_PASSWORD \
        --dbhost=mariadb \
        --allow-root
    
    wp core install \
        --url=$DOMAIN_NAME \
        --title=$WORDPRESS_TITLE \
        --admin_user=$WORDPRESS_ADMIN_USER \
        --admin_password=$WORDPRESS_ADMIN_PASSWORD \
        --admin_email=$WORDPRESS_ADMIN_EMAIL \
        --allow-root

    
    wp user create \
        $WORDPRESS_USER \
        $WORDPRESS_EMAIL \
        --role=author \
        --user_pass=$WORDPRESS_PASSWORD \
        --allow-root

    echo "WordPress installation completed!"
else
    echo "WordPress is already installed."
fi

chmod -R o+w /var/www/html/wp-content

echo "Starting PHP-FPM..."
exec "$@"
