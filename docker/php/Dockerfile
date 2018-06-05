# Usage:
# docker build -t docker-php-example .
# docker run -d -p 8080:80 docker-php-example
# open http://192.168.99.100:8080/

FROM php:7.2

WORKDIR /opt/

RUN pecl install apcu \
    && docker-php-ext-enable apcu

CMD ["php", "-S", "0.0.0.0:8180", "/opt/app.php"]
