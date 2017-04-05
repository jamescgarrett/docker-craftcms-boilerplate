# Docker Craft CMS Boilerplate

Basic [Craft CMS](https://craftcms.com/) boilerplate for local development using [Docker](https://www.docker.com/).

Docker Images:

 * [nginx:latest](https://hub.docker.com/_/nginx/)
 * [jamescgarrett/craftcms-php:latest](https://hub.docker.com/r/jamescgarrett/craftcms-php/) (php:7.1.3-fpm) [Dockerfile](https://github.com/jamescgarrett/docker-craftcms-php)
 * [mariadb:latest](https://hub.docker.com/_/mariadb/)

## Usage:

Command Line:

 1) ```git clone https://github.com/jamescgarrett/docker-craftcms-boilerplate.git```
 2) ```cd docker-craftcms-boilerplate```
 3) Edit the .env file if you'd like
 4) ```npm run setup```
 5) Visit localhost:8080/admin to finish Craft setup

 ##To Do:

 * Add more to README (there are a few things currently not documented)
 * Refactor bash scripts so they are more in line with "the Docker way"
 * Lots of other stuff...