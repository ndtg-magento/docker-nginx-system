![Docker Stars](https://img.shields.io/docker/stars/ntuangiang/magento-nginx.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/ntuangiang/magento-nginx.svg)
![Docker Automated build](https://img.shields.io/docker/automated/ntuangiang/magento-nginx.svg)

# Magento 2 Nginx
[https://www.nginx.com](https://www.nginx.com) NGINX accelerates content and application delivery, improves security, facilitates availability and scalability for the busiest web sites on the Internet.
             
[https://devdocs.magento.com](https://devdocs.magento.com) Meet the small business, mid-sized business, and enterprise-level companies who are benefiting from the power and flexibility of Magento on their web stores. We built the eCommerce platform, so you can build your business.

## Docker Repository
[ntuangiang/magento-nginx](https://hub.docker.com/r/ntuangiang/magento-nginx) 
## Usage
- Write `Dockerfile`

```Dockerfile
FROM ntuangiang/magento:2.3.3-develop as magento-php-fpm

ENV MAGENTO_UPDATE_PACKAGE=true
ENV DOCUMENT_ROOT=/yourDir

COPY --chown=magento:magento ./composer.* ${DOCUMENT_ROOT}/

RUN sh /rootfs/magento-composer-installer

COPY --chown=magento:magento ./app ${DOCUMENT_ROOT}/

RUN composer clear-cache

WORKDIR ${DOCUMENT_ROOT}

# --- Install Nginx ---

FROM ntuangiang/magento-nginx as magento-nginx

ENV NGINX_DOCUMENT_ROOT=/yourDir

COPY --from=magento-php-fpm \
    ${NGINX_DOCUMENT_ROOT}/ \
    ${NGINX_DOCUMENT_ROOT}/

WORKDIR ${NGINX_DOCUMENT_ROOT}
```

- Write `docker-compose.yml` to start services.

```yml
version: '3.7'

services:
  m2varnish:
    image: ntuangiang/magento-varnish
    environment:
      - VARNISH_BACKEND_PORT=80
      - VARNISH_PURGE_HOST=m2nginx
      - VARNISH_BACKEND_HOST=m2nginx
      - VARNISH_HEALTH_CHECK_FILE=/health_check.php
    labels:
      - traefik.port=80
      - traefik.enable=true
      - traefik.docker.network=traefik_proxy
      - traefik.frontend.entryPoints=https,http
      - traefik.frontend.rule=Host:magento2.dev.traefik;PathPrefix:/
    networks:
      - traefik

  m2nginx:
    image: ntuangiang/magento-nginx
    volumes:
      - ./:/yourDir
    environment:
      - NGINX_SERVER_NAME=default_server
      - NGINX_DOCUMENT_ROOT=/usr/share/nginx/html
      - NGINX_BACKEND_PORT=80
      - NGINX_BACKEND_LISTEN=80
      - MAGE_DEBUG_SHOW_ARGS=0
      - MAGE_RUN_CODE=
      - MAGE_RUN_TYPE=
      - MAGE_MODE=default
      - NGINX_BACKEND_HOST=m2php
      - MAGE_MODE=developer
    networks:
      - backend
      - traefik

  m2php:
    image: ntuangiang/magento:v2.3.3-develop
    env_file: docker-compose.env
    volumes:
      - ./:/yourDir
    networks:
      - backend

  m2db:
    image: mysql
    command: --default-authentication-plugin=mysql_native_password
    volumes:
      - /yourDir:/var/lib/mysql
    ports:
      - '2336:3306'
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_DATABASE=magento2
    networks:
      - backend

  m2redis:
    image: redis:alpine
    networks:
      - backend

networks:
  backend:
  traefik:
    external:
      name: traefik_proxy
```

## LICENSE

MIT License