FROM nginx:alpine

RUN apk add --no-cache gettext zip unzip

COPY ./nginx/conf.d /etc/nginx/conf.d
COPY ./nginx/shared /etc/nginx/shared
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/docker-nginx-entrypoint /docker-entrypoint.d/docker-nginx-entrypoint.sh

ENV DOCUMENT_ROOT=/usr/share/nginx/html

ENV ZIP_ROOT=/usr/share/nginx

# Create a user group 'xyzgroup'
RUN addgroup -S magento

# Create a user 'appuser' under 'xyzgroup'
RUN adduser -SD magento magento

RUN chown -R magento:magento ${DOCUMENT_ROOT}/

# Necessary steps to avoid permission errors
RUN touch /var/run/nginx.pid \
 && chown -R magento:magento /var/run/nginx.pid /var/cache/nginx

WORKDIR ${DOCUMENT_ROOT}

