# Image Nginx locale ; Compose montera le code du projet au démarrage.
FROM nginx:1.28-alpine
# Nginx sert les fichiers publics et relaie les scripts PHP à PHP-FPM.
COPY ./docker/development/nginx/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
