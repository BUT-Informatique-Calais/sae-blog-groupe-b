FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    git unzip zip \
    libpq-dev libicu-dev libzip-dev libonig-dev \
    curl gnupg && \
    docker-php-ext-install intl pdo pdo_pgsql zip && \
    a2enmod rewrite

RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . /var/www/html/

RUN composer install --no-interaction --prefer-dist --no-progress --optimize-autoloader

RUN if [ -f package.json ]; then npm install && npm run build; fi

RUN chown -R www-data:www-data /var/www/html

EXPOSE 80