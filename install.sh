# #!/bin/bash
commandlist=('plugin install' 'plugin uninstall' 'theme install' 'theme delete')
OLD_IFS="$IFS"
purple='\e[0;35m'
endColor='\e[0m'
# Get absolute path of WordPress directory, which should
# be two folders up
WORDPRESS_DIR=../..
if [ ! -d "$WORDPRESS_DIR" ]; then
    echo Could not find WordPress directory
    exit
fi
cd $WORDPRESS_DIR
WORDPRESS_DIR=$(pwd)
cd -

# Download and install WordPress core files if they
# are missing.
WP_CLI_PATH_OPTION=--path="$WORDPRESS_DIR"
CORE=wp core

CORE_IS_INSTALLED=$CORE is-installed $WP_CLI_PATH_OPTION
CORE_DOWNLOAD=$CORE download $WP_CLI_PATH_OPTION
CORE_INSTALL=$CORE install $WP_CLI_PATH_OPTION
 
if [ ! $CORE_IS_INSTALLED ]; then
    echo Installing WordPress in $WORDPRESS_DIR
    $CORE_DOWNLOAD
    $CORE_INSTALL    
fi

echo "$purple"WordPress installed in $WORDPRESS_DIR"$endColor"

# Run each command for every plugin and theme returned
# from get-wp-addons.php, if the addon is 
echo -e "$purple"Installing plugins and themes"$endColor"
for command in "${commandlist[@]}"; do
    plugins=$(IFS=$' \n\t';php -f get-wp-addons.php $command)        
    IFS=$'\n'
    for plugin in $plugins; do        
        ADDON_TYPE=$(echo $command | cut -d ' ' -f 1)
        ADDON_NAME=$(echo $plugin | cut -d ' ' -f 1)
        COMAND_TYPE=$(echo $command | cut -d ' ' -f 2)
        echo -e $purple$command $plugin$endColor
        IFS=$' '
        if [ $COMAND_TYPE == "install" && ! wp $ADDON_NAME is-installed $WP_CLI_PATH_OPTION ]; then
            if [ ! wp $command $ADDON_NAME $WP_CLI_PATH_OPTION ]; then
                echo -e "$purple"There was an error running:"$endColor" $command $plugin
            fi        
        fi
    done
done

# Recreate .htaccess rules if httpd is detected
if [ type httpd ]; then
    wp rewrite flush
fi

IFS=$OLD_IFS