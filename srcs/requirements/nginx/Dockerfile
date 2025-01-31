# PenUltimate version of Alpine
FROM alpine:3.21

# Installing nginx, SSL, and bash
RUN apk update && apk add --no-cache \
    nginx \
    openssl \
    bash

# Creating SSL dir
RUN mkdir -p /etc/nginx/ssl

# Copying Nginx configuration and entrypoint script to container
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /usr/local/bin/

# Making the copied entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Exposing the used HTTPS port
EXPOSE 443

# Set the entrypoint and default command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]