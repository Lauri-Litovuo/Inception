FROM alpine:3.20.0

RUN apk update && apk add mariadb mariadb-client bash
COPY tools/mariadb-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh
ENTRYPOINT ["mariadb-entrypoint.sh"]
