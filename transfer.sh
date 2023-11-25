#!/bin/bash

DOMAINS=("ali.com" "sae.com")

for DOMAIN in "${DOMAINS[@]}"
do
  # Remove "www" and "ir" from the domain name
  DB_NAME=$(echo "$DOMAIN" | sed -E 's/(\.ir)//g')
  #DOMAIN2=$(echo "$DOMAIN" | sed -E 's/(www\.)//g')
  clpctl site:add:php --domainName="$DOMAIN" --phpVersion=8.1 --vhostTemplate='WordPress' --siteUser="$DB_NAME" --siteUserPassword='!password!'
  clpctl lets-encrypt:install:certificate --domainName="$DOMAIN"
  clpctl db:add --domainName="$DOMAIN" --databaseName="$DB_NAME" --databaseUserName="$DB_NAME" --databaseUserPassword='password'
  mv /root/domains/"$DOMAIN"/public_html/* /home/"$DB_NAME"/htdocs/"$DOMAIN"/
  chown -R "$DB_NAME." /home/"$DB_NAME"/htdocs/"$DOMAIN"/
  mysql -h 127.0.0.1 -u root -pPassword "$DB_NAME" <  /root/backup/"prefix_$DB_NAME.sql"
  # Path to the directory containing all WordPress installations
  WORDPRESS_DIR="/home/"$DB_NAME"/htdocs/"
  # Remove "prefix_" from DB_NAME
  sed -i "s/define( 'DB_NAME', 'prefix_${DB_NAME}' );/define( 'DB_NAME', '${DB_NAME}' );/" "${WORDPRESS_DIR}/${DOMAIN}/wp-config.php"

  # Remove "prefix_" from DB_USER
  sed -i "s/define( 'DB_USER', 'prefix_${DB_NAME}' );/define( 'DB_USER', '${DB_NAME}' );/" "${WORDPRESS_DIR}/${DOMAIN}/wp-config.php"

done

