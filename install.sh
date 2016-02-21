#!/bin/bash
OLD_IFS="$IFS"

source .git/hooks/functions.sh

setColors
getWPDir

commandlist=('plugin install' 'theme install')

# Download and install WordPress core files if they
# are missing.

CORE="wp core"

CORE_IS_INSTALLED="$CORE is-installed $WP_CLI_PATH_OPTION"
CORE_DOWNLOAD="$CORE download $WP_CLI_PATH_OPTION"
CORE_INSTALL="$CORE install $WP_CLI_PATH_OPTION"
 
# If WordPress core is not installed, then download and install it.
if ! $CORE_IS_INSTALLED; then
    echo -e "$YELLOW"Installing WordPress in $WORDPRESS_DIR"$ENDCOLOR";
    $CORE_DOWNLOAD
    $CORE_INSTALL
fi

echo -e "$GREEN"WordPress installed in $WORDPRESS_DIR"$ENDCOLOR"

if [ ! -e "$WORDPRESS_DIR/wp-config.php" ]; then
	echo -e "$YELLOW"Creating wp-config"$ENDCOLOR"

	config=$(IFS=$' \n\t';php -f .git/hooks/get-wp-addons.php config)

	CONFIG_COMMAND="$CORE config $config $WP_CLI_PATH_OPTION"
	if ! $CONFIG_COMMAND; then
		echo -e "$RED"Could not create wp-config"$ENDCOLOR"
		exit 1
	fi
fi

# Set the wp-addons.php file if there is not one already
if [ ! -e "$WORDPRESS_UPLOADS_DIR/wp-addons.php" ]; then
    EXAMPLE_ADDONS="$WORDPRESS_UPLOADS_DIR/wp-addons.example.php"
    if [ ! -e "$EXAMPLE_ADDONS" ]; then
        echo -e "$RED"Please add a wp-addons.example.php or wp-addons.php to your WordPress uploads repo"$ENDCOLOR"
        exit 1
    fi
    
    if ! cp "$EXAMPLE_ADDONS" "$WORDPRESS_UPLOADS_DIR"/wp-addons.php; then
        echo -e "$RED"Could not copy addons config from "$EXAMPLE_ADDONS" to "$WORDPRESS_UPLOADS_DIR"/wp-addons.php"$ENDCOLOR"
        exit 1
    fi
fi

# Run each command for every plugin and theme returned
# from get-wp-addons.php, if the addon is 
echo -e "$YELLOW"Installing plugins and themes"$ENDCOLOR"
for command in "${commandlist[@]}"; do
    plugins=$(IFS=$' \n\t';php -f .git/hooks/get-wp-addons.php $command)        
    IFS=$'\n'
    for plugin in $plugins; do        
        ADDON_TYPE=$(echo $command | cut -d ' ' -f 1)
        ADDON_NAME=$(echo $plugin | cut -d ' ' -f 1)
        COMMAND_TYPE=$(echo $command | cut -d ' ' -f 2)
		ADDON_COMMAND="wp $command $plugin $WP_CLI_PATH_OPTION"
        echo -e $PURPLE$ADDON_COMMAND$ENDCOLOR
        IFS=$' '
        if [ "$COMMAND_TYPE" == "install" ] && ! wp $ADDON_TYPE is-installed $ADDON_NAME $WP_CLI_PATH_OPTION; then
            if ! $ADDON_COMMAND; then
                echo -e "$PURPLE"There was an error running:"$ENDCOLOR" $command $plugin
            fi        
        else
            if [ "$COMMAND_TYPE" == "install" ]; then
                echo $ADDON_NAME is already installed
            fi
        fi
        
        if [ "$COMMAND_TYPE" != "install" ] && wp $ADDON_TYPE is-installed $ADDON_NAME $WP_CLI_PATH_OPTION; then
            if ! $ADDON_COMMAND; then
                echo -e "$PURPLE"There was an error running:"$ENDCOLOR" $command $plugin
            fi 
        else
            if [ "$COMMAND_TYPE" != "install" ]; then
                echo $ADDON_NAME has already been removed
            fi
        fi
    done
done
IFS=$OLD_IFS

# Recreate .htaccess rules if httpd is detected
echo -e "$YELLOW"Recreating .htaccess rewrite rules"$ENDCOLOR"
if type httpd >> /dev/null; then
    wp rewrite flush --hard $WP_CLI_PATH_OPTION
fi