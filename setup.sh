#!/bin/bash

source .git/hooks/functions.sh

setColors
getWPDir

CURRENT_DIR=$(pwd)

echo -e "$YELLOW"Symlinking hook files..."$ENDCOLOR"
ln -s "$CURRENT_DIR"/{get-wp-addons.php,p*,install.sh,functions.sh} "$WORDPRESS_UPLOADS_DIR"/.git/hooks    

echo "$YELLOW"Copying YML if httpd is available..."$ENDCOLOR"
if type httpd; then
    cp "$CURRENT_DIR"/wp-cli.yml "$WORDPRESS_UPLOADS_DIR"
fi


if [ ! -e "$WORDPRESS_UPLOADS_DIR"/.setup/wp-addons.php ] ; then
    echo -e "$YELLOW"The wp-addons.php was not found in the project."$ENDCOLOR"
    if [ ! -e "$WORDPRESS_UPLOADS_DIR"/.setup/wp-addons.example.php ]; then
        echo -e "$YELLOW"Copying example wp-addons from hooks repo."$ENDCOLOR"
        cp "$CURRENT_DIR"/wp-addons.example.php "$WORDPRESS_UPLOADS_DIR"/.setup/wp-addons.php
    else
        echo -e "$YELLOW"Copying example wp-addons from project repo."$ENDCOLOR"
        cp "$WORDPRESS_UPLOADS_DIR"/wp-addons.example.php "$WORDPRESS_UPLOADS_DIR"/.setup/wp-addons.php
    fi
    
fi

if [ ! -e "$WORDPRESS_UPLOADS_DIR"/.setup/cleanup.sh ] ; then
    echo -e "$YELLOW"A cleanup script was not found in the project."$ENDCOLOR"
    if [ ! -e "$WORDPRESS_UPLOADS_DIR"/.setup/cleanup.example.sh ]; then
        echo -e "$YELLOW"Copying example cleanup.sh from hooks repo."$ENDCOLOR"
        cp "$CURRENT_DIR"/cleanup.example.php "$WORDPRESS_UPLOADS_DIR"/.setup/cleanup.sh
    else
        echo -e "$YELLOW"Copying example cleanup.sh from project repo."$ENDCOLOR"
        cp "$WORDPRESS_UPLOADS_DIR"/cleanup.example.sh "$WORDPRESS_UPLOADS_DIR"/.setup/cleanup.sh
    fi
    
fi

