# Terminal d'outils : Artisan, Composer et npm ; ce conteneur ne sert pas de pages web.
FROM php:8.5-cli
ARG UID=1000
ARG GID=1000
ARG NODE_VERSION=22.12.0
ENV NODE_VERSION=$NODE_VERSION
ENV PATH=/home/www/.nvm/versions/node/v$NODE_VERSION/bin:$PATH
RUN apt-get update && apt-get install -y --no-install-recommends \
    $PHPIZE_DEPS ca-certificates curl git libcurl4-openssl-dev libicu-dev \
    libonig-dev libpq-dev libsqlite3-dev libssl-dev libxml2-dev libzip-dev unzip \
    && docker-php-ext-install -j"$(nproc)" bcmath intl mbstring pcntl pdo_pgsql pdo_sqlite zip \
    && pecl install redis xdebug && docker-php-ext-enable redis xdebug \
    && rm -rf /var/lib/apt/lists/*
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
# Utilisateur avec UID/GID du poste pour limiter les problèmes de droits des fichiers montés.
RUN if ! getent group "$GID" >/dev/null; then groupadd --gid "$GID" www; fi \
    && group_name="$(getent group "$GID" | cut -d: -f1)" \
    && useradd --create-home --uid "$UID" --gid "$group_name" --shell /bin/bash www
USER www
ENV NVM_DIR=/home/www/.nvm
# NVM fournit Node et npm dans le terminal interactif.
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" && nvm install "$NODE_VERSION" && nvm alias default "$NODE_VERSION"
RUN printf '%s\n' 'export NVM_DIR="$HOME/.nvm"' '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> /home/www/.bashrc
WORKDIR /var/www
CMD ["bash"]
