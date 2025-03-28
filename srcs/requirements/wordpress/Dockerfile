FROM alpine:3.20

RUN apk update && apk add --no-cache bash mariadb-client openssl php82 \
    php82-fpm \
    php82-mysqli \
    php82-json \
    php82-curl \
    php82-dom \
    php82-mbstring \
    php82-openssl \
    php82-xml \
    php82-phar \
    php82-session \
    wget \
    php82-zip

RUN	mkdir -p /var/www/html && \
	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp && \
	ln -s /usr/bin/php82 /usr/bin/php

COPY conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY conf/php.ini /etc/php82/php.ini
COPY tools/wordpress-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wordpress-entrypoint.sh"]

CMD ["php-fpm82", "-F"]
