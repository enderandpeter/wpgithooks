#!/bin/bash

CURRENT_DIR=$( cd "$(dirname "$0")" ; pwd -P )

source "$CURRENT_DIR"/functions.sh

setColors
if ! getWPDir; then
  echo "$RED"An error occured while getting the WordPress directories"$ENDCOLOR"
  exit
fi

echo -e "$YELLOW"Symlinking hook files..."$ENDCOLOR"
ln --symbolic "$CURRENT_DIR"/{get-wp-addons.php,p*,install.sh,remove.sh,functions.sh} "$WORDPRESS_UPLOADS_DIR"/.git/hooks    

echo -e "$YELLOW"Copying YML if httpd is available..."$ENDCOLOR"
if type apachectl &> /dev/null; then
    cp "$CURRENT_DIR"/wp-cli.example.yml "$WORDPRESS_SETUP_DIR"/wp-cli.yml
    cp "$CURRENT_DIR"/wp-cli.example.yml "$WORDPRESS_SETUP_DIR"
fi


if [ ! -e "$WORDPRESS_SETUP_DIR"/wp-addons.php ] ; then
    echo -e "$YELLOW"The wp-addons.php was not found in the project."$ENDCOLOR"
    if [ ! -e "$WORDPRESS_SETUP_DIR"/wp-addons.example.php ]; then
        echo -e "$YELLOW"Copying example wp-addons from hooks repo."$ENDCOLOR"
        cp "$CURRENT_DIR"/wp-addons.example.php "$WORDPRESS_SETUP_DIR"/wp-addons.php
        cp "$CURRENT_DIR"/wp-addons.example.php "$WORDPRESS_SETUP_DIR"
    else
        echo -e "$YELLOW"Copying example wp-addons from project repo."$ENDCOLOR"
        cp "$WORDPRESS_SETUP_DIR"/wp-addons.example.php "$WORDPRESS_SETUP_DIR"/wp-addons.php
    fi
    
fi

if [ ! -e "$WORDPRESS_SETUP_DIR"/cleanup.sh ] ; then
    echo -e "$YELLOW"A cleanup script was not found in the project."$ENDCOLOR"
    if [ ! -e "$WORDPRESS_SETUP_DIR"/cleanup.example.sh ]; then
        echo -e "$YELLOW"Copying example cleanup.sh from hooks repo."$ENDCOLOR"
        cp "$CURRENT_DIR"/cleanup.example.sh "$WORDPRESS_SETUP_DIR"/cleanup.sh
        cp "$CURRENT_DIR"/cleanup.example.sh "$WORDPRESS_SETUP_DIR"
    else
        echo -e "$YELLOW"Copying example cleanup.sh from project repo."$ENDCOLOR"
        cp "$WORDPRESS_SETUP_DIR"/cleanup.example.sh "$WORDPRESS_SETUP_DIR"/cleanup.sh
    fi
    
    chmod u+x "$WORDPRESS_SETUP_DIR"/cleanup.sh
fi

