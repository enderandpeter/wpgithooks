#!/bin/bash
OLD_IFS="$IFS"

source .git/hooks/functions.sh

setColors
getWPDir

commandlist=('plugin uninstall' 'theme delete')

# Run each command for every plugin and theme returned
# from get-wp-addons.php, if the addon is 
echo -e "$YELLOW"Removing plugins and themes"$ENDCOLOR"
for command in "${commandlist[@]}"; do
    plugins=$(IFS=$' \n\t';php -f .git/hooks/get-wp-addons.php $command)        
    IFS=$'\n'
    for plugin in $plugins; do        
        ADDON_TYPE=$(echo $command | cut -d ' ' -f 1)
        ADDON_NAME=$(echo $plugin | cut -d ' ' -f 1)
        COMMAND_TYPE=$(echo $command | cut -d ' ' -f 2)
        
		ADDON_COMMAND="wp $command $plugin $WP_CLI_PATH_OPTION"
        IS_INSTALLED_COMMAND="wp $ADDON_TYPE is-installed $ADDON_NAME $WP_CLI_PATH_OPTION"
        DEACTIVATE_COMMAND="wp $ADDON_TYPE deactivate $ADDON_NAME $WP_CLI_PATH_OPTION"
        
        echo -e $PURPLE$ADDON_COMMAND$ENDCOLOR
        IFS=$' '
        if [ "$COMMAND_TYPE" == "install" ] && ! $IS_INSTALLED_COMMAND; then
            if ! $ADDON_COMMAND; then
                echo -e "$PURPLE"There was an error running:"$ENDCOLOR" $command $plugin
            fi        
        else
            if [ "$COMMAND_TYPE" == "install" ]; then
                echo $ADDON_NAME is already installed
            fi
        fi
        
        if [ "$COMMAND_TYPE" != "install" ] && $IS_INSTALLED_COMMAND; then
            if ! $ADDON_COMMAND; then
                echo -e "$PURPLE"There was an error running:"$ENDCOLOR" $command $plugin
            fi 
        else
            if [ "$COMMAND_TYPE" != "install" ] && $ADDON_COMMAND; then
                echo $ADDON_NAME has been removed
            fi
        fi
    done
done
IFS=$OLD_IFS