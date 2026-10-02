# Étape de compilation des ressources front-end Laravel Vite.
FROM node:22-alpine AS assets
WORKDIR /var/www
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# Image finale : Nginx et les fichiers publics compilés, sans Node.js.
FROM nginx:1.28-alpine
COPY ./docker/production/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=assets /var/www/public /var/www/public
WORKDIR /var/www/public
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
