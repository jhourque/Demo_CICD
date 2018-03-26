FROM php:7.1-apache

RUN docker-php-ext-install mysqli
COPY site/ /var/www/html/
RUN apt-get update
RUN apt-get install -y git unzip
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install
