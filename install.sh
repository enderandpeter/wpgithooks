# #!/bin/bash
commandlist=('plugin install' 'plugin uninstall' 'theme install' 'theme delete')
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
        echo Could not find the directory: $WORDPRESS_DIR
        exit
    fi    
fi
cd $WORDPRESS_DIR
WORDPRESS_DIR=$(pwd)
cd - >> /dev/null

# Download and install WordPress core files if they
# are missing.
WP_CLI_PATH_OPTION=--path="$WORDPRESS_DIR"
CORE="wp core"

CORE_IS_INSTALLED="$CORE is-installed $WP_CLI_PATH_OPTION"
CORE_DOWNLOAD="$CORE download $WP_CLI_PATH_OPTION"
CORE_INSTALL="$CORE install $WP_CLI_PATH_OPTION"
 
if ! $CORE_IS_INSTALLED; then # Output may not be supressed
    echo -e "$yellow"Installing WordPress in $WORDPRESS_DIR"$endColor"; exit;
    $CORE_DOWNLOAD
    $CORE_INSTALL
fi

echo -e "$green"WordPress installed in $WORDPRESS_DIR"$endColor"

if [ ! -e $WORDPRESS_DIR/wp-config.php ]; then
	echo -e "$green"Creating wp-config"$endColor"

	config=$(IFS=$' \n\t';php -f .git/hooks/get-wp-addons.php config)

	CONFIG_COMMAND="$CORE config $config $WP_CLI_PATH_OPTION"
	if ! $CONFIG_COMMAND; then
		echo -e "$red"Could not create wp-config"$endColor"
		exit
	fi
fi

# Run each command for every plugin and theme returned
# from get-wp-addons.php, if the addon is 
echo -e "$green"Installing plugins and themes"$endColor"
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

# Recreate .htaccess rules if httpd is detected
if ! type httpd; then
    wp rewrite flush
fi

IFS=$OLD_IFS