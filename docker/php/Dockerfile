# syntax=docker/dockerfile:1.0.0-experimental

# Usage:
# docker build -t docker-php-example .
# docker run -d -p 8080:80 docker-php-example
# open http://192.168.99.100:8080/

FROM php:8.2-cli as base

RUN docker-php-source extract \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && docker-php-source delete

RUN apt-get update && apt-get install -y git

WORKDIR /opt/

FROM base AS dev

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

VOLUME [ "/opt" ]

FROM base as runtime

CMD ["php", "-S", "0.0.0.0:8180", "/opt/app.php"]
