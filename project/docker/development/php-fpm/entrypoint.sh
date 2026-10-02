#!/bin/sh
# Entrée du conteneur PHP-FPM local.
set -eu
# Composer install est lancé depuis workspace ; vendor peut manquer au premier démarrage.
if [ -f artisan ] && [ -f vendor/autoload.php ]; then
    echo "Nettoyage des caches Laravel..."
    php artisan config:clear
    php artisan route:clear
    php artisan view:clear
else
    echo "Dépendances absentes : lance composer install dans workspace."
fi
# exec transmet les signaux d'arrêt directement à PHP-FPM.
exec "$@"
