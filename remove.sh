#!/bin/bash
OLD_IFS="$IFS"

purple='\e[0;35m'
green='\e[0;32m'
yellow='\e[0;33m'
red='\e[0;31m'
endColor='\e[0m'

# Get absolute path of WordPress directory, which should
# be folders folders up: /wp-content/uploads/.git/hooks
WORDPRESS_DIR=../..
if [ ! -d "$WORDPRESS_DIR" ]; then
    echo -n Please enter the path of the WordPress directory
    read WORDPRESS_DIR
    if [ ! -d "$WORDPRESS_DIR" ]; then
        echo -e "$red"Could not find the directory: $WORDPRESS_DIR"$endColor"
        exit
    fi    
fi
cd $WORDPRESS_DIR
WORDPRESS_DIR=$(pwd)
cd - >> /dev/null
WP_CLI_PATH_OPTION=--path="$WORDPRESS_DIR"

commandlist=('plugin uninstall' 'theme delete')

# Run each command for every plugin and theme returned
# from get-wp-addons.php, if the addon is 
echo -e "$yellow"Removing plugins and themes"$endColor"
for command in "${commandlist[@]}"; do
    plugins=$(IFS=$' \n\t';php -f .git/hooks/get-wp-addons.php $command)        
    IFS=$'\n'
    for plugin in $plugins; do        
        ADDON_TYPE=$(echo $command | cut -d ' ' -f 1)
        ADDON_NAME=$(echo $plugin | cut -d ' ' -f 1)
        COMMAND_TYPE=$(echo $command | cut -d ' ' -f 2)
		ADDON_COMMAND="wp $command $plugin $WP_CLI_PATH_OPTION"
        echo -e $purple$ADDON_COMMAND$endColor
        IFS=$' '
        if [ "$COMMAND_TYPE" == "install" ] && ! wp $ADDON_TYPE is-installed $ADDON_NAME $WP_CLI_PATH_OPTION; then
            if ! $ADDON_COMMAND; then
                echo -e "$purple"There was an error running:"$endColor" $command $plugin
            fi        
        else
            if [ "$COMMAND_TYPE" == "install" ]; then
                echo $ADDON_NAME is already installed
            fi
        fi
        
        if [ "$COMMAND_TYPE" != "install" ] && wp $ADDON_TYPE is-installed $ADDON_NAME $WP_CLI_PATH_OPTION; then
            if ! $ADDON_COMMAND; then
                echo -e "$purple"There was an error running:"$endColor" $command $plugin
            fi 
        else
            if [ "$COMMAND_TYPE" != "install" ]; then
                echo $ADDON_NAME has already been removed
            fi
        fi
    done
done
IFS=$OLD_IFS