{

  dump_database() {
    echo "Backing up database to ./docker/database"
    mkdir ./docker/database
    docker-compose exec mysql mysqldump -uroot -psecret craft > ./docker/database/craft.sql
    echo "Finished Backing up database"
  }

  import_database() {
    echo "Importing database from ./docker/database/craft.sql"
    echo "For some reason this takes a little time, so be patient..."
    docker-compose exec mysql mysql -uroot -psecret -e "DROP DATABASE craft"
    docker-compose exec mysql mysql -uroot -psecret -e "CREATE DATABASE craft"
    docker exec -i `basename $PWD`_mysql_1 mysql -uroot -psecret craft < ./docker/database/craft.sql
    echo "Finished importing database"
  }

  pack_uploads() {
    echo "Packing uploads to your dropbox folder"
    tar -zcvf ~/Dropbox/craftCMS_uploads/`basename $PWD`/uploads.tar.gz ./public/uploads/ 
    echo "Finished pacing uploads"
  }

  unpack_uploads() {
    echo "Unpacking uploads"
    tar -C ./ -xzf ./public/uploads.tar.gz
    rm -rf ./public/uploads.tar.gz
    echo "Finished unpacking uploads"
  }

  prepare_clone() {
    echo "Preparing for clone"
    dump_database
    pack_uploads
    echo "Finished preparing for clone"
  }

  setup_clone() {
    echo "Pulling Craft CMS"
    if [ -d "tar" ]; then
      rm -rf tar
    fi
    mkdir "tar"
    curl -o tar/latest.tar.gz -L https://craftcms.com/latest.tar.gz?accept_license=yes
    # unarchive craft into ./
    tar -C ./tar -xzf tar/latest.tar.gz
    # move app
    mv -f ./tar/craft/app craft/app
    # remove tar
    rm -rf tar
    #create directories that arent stored in repo
    mkdir ./craft/plugins
    mkdir ./craft/storage
    # if uploads present unpack
    if [ -f ./public/uploads.tar.gz ]; then
      unpack_uploads
    fi
    # import the database
    import_database
    echo "Finished pulling Craft CMS, don't forget to grab any plugins you need."
  }

  craft_setup() {
    _craft_get_craft
    _create_configs
    _move_templates

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
    'server' => getenv('DB_SERVER'),
    'port' => getenv('DB_PORT'),
    'database' => getenv('DB_NAME'),
    'user' => getenv('DB_USER'),
    'password' => getenv('DB_PASS'),
    'tablePrefix' => getenv('DB_PREFIX'),
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
  'omitScriptNameInUrls' => true,
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

  program_abort() {
    >&2 echo "[ERROR] $1"
    exit ${2:1}
  }

  "$@"
}