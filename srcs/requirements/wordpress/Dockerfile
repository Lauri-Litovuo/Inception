
FROM alpine:3.21

RUN apk update && apk add --no-cache \
    bash \
    curl \
    mariadb-client \
    icu-data-full \
    openssl \
    php82 \
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
    php82-zip \
    php82-tokenizer \
    php82-simplexml \
    php82-pecl-redis

RUN curl -o /usr/local/bin/wp -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY tools/wordpress-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wordpress-entrypoint.sh"]

CMD ["php-fpm82", "-F"]