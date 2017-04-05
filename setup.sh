{

  craft_setup() {
    _craft_get_craft
    _create_configs
    _move_templates
    _create_docker-compose
    _create_nginx_conf

    echo "Running docker-compose up -d"
    docker-compose up -d
  }

  _craft_get_craft() {
    echo "Downloading Craft CMS"
    if [ -d "tar" ]; then
      rm -rf tar
    fi
    mkdir "tar"
    curl -o tar/latest.tar.gz -L https://craftcms.com/latest.tar.gz?accept_license=yes
    echo "Finished Downloading, Extracting..."
    if [ -d "craft" ]; then
      program_abort "+  craft directory already exists, make sure you aren't overwiting something important."
    else
      # unarchive craft into ./
      tar -C ./ -xzf tar/latest.tar.gz
      # Remove Config Files, will generate these in a sec
      rm -f craft/config/db.php
      rm -f craft/config/general.php
      # Remove Templates
      rm -rf craft/templates
      # Move crafts readme file
      mv -f readme.txt craft/readme.txt
      # Create uploads Folder
      mkdir public/uploads
      # Create srcFolder
      mkdir public/src
    fi
    # Remove cache
    rm -rf tar
    echo "Finished Getting Craft"
  }

  _create_configs() {
    _create_db_config
    _create_general_config
  }

  _create_db_config() {
    echo "Creating Database Config"
    cat > craft/config/db.php <<- EOF
<?php
  /**
   * Database Configuration
   *
   * All of your system\'s database configuration settings go in here.
   * You can see a list of the default settings in craft/app/etc/config/defaults/db.php
   */

  return array(
    'server' => 'localhost',
    'database' => 'projectname',
    'user' => 'root',
    'password' => 'secret',
    'tablePrefix' => 'craft_',
  );
EOF
    echo "Finished Creating Database Config"
  }

  _create_general_config() {
    echo "Creating General Config"
    cat > craft/config/general.php <<- EOF
<?php
/**
 * General Configuration
 *
 * All of your system\'s general configuration settings go in here.
 * You can see a list of the default settings in craft/app/etc/config/defaults/general.php
 */

return array(
  'enableCsrfProtection' => true,
  'omitScriptNameInUrls' => 'auto',
  'devMode' => true,
);
EOF
    echo "Finished Creating General Config"
  }

  _move_templates() {
    mkdir "craft/templates"
    mv -f craft_templates/* craft/templates/
    rm -rf craft_templates
  }

  _create_docker-compose() {
    echo "Creating docker-compose.yml"
    cat > ./docker-compose.yml <<- 'EOF'
version: '2.1'

services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - "${PUBLIC_ROOT}:/var/www/html"
      - "${CRAFT_ROOT}:/var/www/craft"
      - ./docker/nginx/default.conf:/etc/nginx/conf.d/default.conf
    networks:
      - public-network

  php:
    image: jamescgarrett/craftcms-php:latest
    volumes:
      - "${PUBLIC_ROOT}:/var/www/html"
      - "${CRAFT_ROOT}:/var/www/craft"
    networks:
      - public-network

  mysql:
    image: mariadb:latest
    volumes:
      - data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
      MYSQL_DATABASE: "${MYSQL_DATABASE}"
      MYSQL_USER: "${MYSQL_USER}"
      MYSQL_PASSWORD: "${MYSQL_PASSWORD}"
    networks:
      - public-network

volumes:
  data:

networks:
  public-network:
    driver: bridge
EOF
    echo "Finished creating docker-compose.yml"
  }

  _create_nginx_conf() {
    echo "Creating nginx conf"
    mkdir -p docker/nginx
    cat > ./docker/nginx/default.conf <<- 'EOF'
server {
  listen 80 default_server;
  listen [::]:80 default_server ipv6only=on;

  index index.php index.html;
  server_name localhost;
  root /var/www/html;

  # reduce the data that needs to be sent over network
  gzip on;
  gzip_min_length 10240;
  gzip_proxied expired no-cache no-store private auth;
  gzip_types text/plain text/css application/javascript application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
  gzip_disable "MSIE [1-6]\.";

  # Add stdout logging
  error_log /dev/stdout info;
  access_log /dev/stdout;

  location ~ [^/]\.php(/|$) {
    fastcgi_split_path_info ^(.+?\.php)(/.*)$;
    fastcgi_intercept_errors on;
    fastcgi_pass php:9000;
    fastcgi_index index.php;

    include fastcgi_params;
    fastcgi_param HTTP_PROXY "";
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param SCRIPT_NAME $fastcgi_script_name;
    fastcgi_param PATH_INFO $fastcgi_path_info;
    fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
  }

  location ~ ^(.*)$ {
    try_files $uri $uri/ /index.php?p=$uri&$args;
  }

  location ~* \.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp4|ogg|ogv|webm|htc|ttf|ttc|otf|eot|woff)$ {
    try_files $uri /index.php?$query_string;
    expires max;
    add_header Pragma public;
    add_header Cache-Control "public, must-revalidate, proxy-revalidate";
  }

  location ~* \.(?:css|js)$ {
    try_files $uri /index.php?$query_string;
    expires 1y;
    add_header Cache-Control "public";
  }

  location = /robots.txt  { access_log off; log_not_found off; }
  location = /favicon.ico { access_log off; log_not_found off; }
  location ~ /\. { access_log off; log_not_found off; deny all; }

  location ~* (?:\.(?:bak|config|sql|fla|psd|ini|log|sh|inc|swp|dist)|~)$ {
    deny all;
    access_log off;
    log_not_found off;
  }
}
EOF
    echo "Finished creating nginx conf"
  }

  program_abort() {
    >&2 echo "[ERROR] $1"
    exit ${2:1}
  }

  craft_setup

}