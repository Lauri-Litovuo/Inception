FROM alpine:3.20

RUN apk update && apk add --no-cache \
    nginx \
    openssl \
    bash

RUN mkdir -p /etc/nginx/ssl

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/nginx-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/nginx-entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/nginx-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
