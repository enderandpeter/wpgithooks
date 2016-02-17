# #!/bin/bash
commandlist=('plugin install' 'plugin uninstall' 'theme install' 'theme delete')
OLD_IFS="$IFS"
purple='\e[0;35m'
endColor='\e[0m'
# # Get absolute path of WordPress directory
WORDPRESS_DIR=$(readlink -f ../..)

# echo Installing WordPress in $WORDPRESS_DIR
# wp core download --path=$WORDPRESS_DIR
# wp core install --path=$WORDPRESS_DIR

# # Run each command for every plugin and theme returned
# # from get-wp-addons.php
# echo Installing plugins and themes
for command in "${commandlist[@]}"; do
    plugins=$(IFS=$' \n\t';php -f get-wp-addons.php $command)        
    IFS=$'\n'
    for plugin in $plugins; do        
        echo -e $purple$command $plugin$endColor
        IFS=$' '
        wp $command $plugin $activate --path=$WORDPRESS_DIR
    done
done

IFS=$OLD_IFS