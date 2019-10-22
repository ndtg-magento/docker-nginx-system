FROM nginx:alpine

RUN apk add --no-cache gettext

COPY ./nginx/conf.d /etc/nginx/conf.d
COPY ./nginx/shared /etc/nginx/shared
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/docker-nginx-entrypoint /usr/local/bin/docker-nginx-entrypoint

ENV DOCUMENT_ROOT=/usr/share/nginx/html

WORKDIR ${DOCUMENT_ROOT}

CMD ["/usr/local/bin/docker-nginx-entrypoint"]