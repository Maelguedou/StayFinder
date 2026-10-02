# Base PHP commune aux variantes Laravel ; elle contient les extensions utilisées par l'application. On installe les extensions dont laravel a besoin
FROM php:8.5-fpm AS php-base
RUN apt-get update && apt-get install -y --no-install-recommends \
    $PHPIZE_DEPS libfreetype6-dev libicu-dev libjpeg62-turbo-dev libonig-dev \
    libpng-dev libpq-dev libwebp-dev libzip-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j"$(nproc)" bcmath exif gd intl mbstring pcntl pdo_pgsql zip \
    && pecl install redis && docker-php-ext-enable redis \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /var/www

# Node compile Vite ici : Laravel doit aussi lire public/build/manifest.json côté PHP.  Installe les dependances Javascript
FROM node:22-bookworm-slim AS frontend-build
WORKDIR /var/www
COPY package.json package-lock.json ./
RUN npm ci --fetch-retries=5 --fetch-retry-mintimeout=20000 --fetch-retry-maxtimeout=120000
COPY . .
RUN npm run build

# Composer installe les dépendances Laravel dans cette étape de construction.
FROM php-base AS production-build
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
COPY --chown=www-data:www-data . /var/www
RUN composer install --no-dev --no-interaction --no-progress --prefer-dist --optimize-autoloader

# Image de production : application PHP, sans Composer ni Node.
FROM php-base AS production
WORKDIR /var/www
COPY --from=production-build --chown=www-data:www-data /var/www /var/www
COPY --from=frontend-build --chown=www-data:www-data /var/www/public/build /var/www/public/build
RUN mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache
COPY --chown=www-data:www-data ./docker/production/php-fpm/entrypoint.sh /usr/local/bin/laravel-entrypoint
RUN chmod +x /usr/local/bin/laravel-entrypoint
USER www-data
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/laravel-entrypoint"]
CMD ["php-fpm"]

# En développement, on repart de la même image et on ajoute uniquement Xdebug.
FROM production AS development
ARG XDEBUG_ENABLED=true
ARG XDEBUG_MODE=develop,debug
ARG XDEBUG_HOST=host.docker.internal
ARG XDEBUG_IDE_KEY=DOCKER
ARG XDEBUG_LOG=/dev/stdout
ARG XDEBUG_LOG_LEVEL=0
USER root
RUN if [ "$XDEBUG_ENABLED" = "true" ]; then \
    pecl install xdebug && docker-php-ext-enable xdebug \
    && printf '%s\n' "xdebug.mode=$XDEBUG_MODE" "xdebug.client_host=$XDEBUG_HOST" \
       "xdebug.idekey=$XDEBUG_IDE_KEY" "xdebug.log=$XDEBUG_LOG" \
       "xdebug.log_level=$XDEBUG_LOG_LEVEL" "xdebug.start_with_request=yes" \
       > /usr/local/etc/php/conf.d/99-xdebug.ini; \
    fi
COPY --chown=www-data:www-data ./docker/development/php-fpm/entrypoint.sh /usr/local/bin/laravel-entrypoint
RUN chmod +x /usr/local/bin/laravel-entrypoint
USER www-data
