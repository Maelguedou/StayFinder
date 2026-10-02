#!/bin/sh
# Entrée du conteneur PHP-FPM de production.
set -eu
# Préparer le cache de configuration avec l'environnement injecté au démarrage.
php artisan config:cache
# exec transmet correctement les signaux d'arrêt à PHP-FPM.
exec "$@"
