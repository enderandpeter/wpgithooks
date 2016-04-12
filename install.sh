#!/bin/bash
OLD_IFS="$IFS"

source .git/hooks/functions.sh

setColors
getWPDir
getMultisite

commandlist=('plugin install' 'theme install')

# Download and install WordPress core files if they
# are missing.

CORE="wp core"

CORE_IS_INSTALLED="$CORE is-installed $WP_CLI_PATH_OPTION"
CORE_DOWNLOAD="$CORE download $WP_CLI_PATH_OPTION"
CORE_INSTALL="$CORE install --quiet $WP_CLI_PATH_OPTION"
 
# If WordPress core is not installed, then download and install it.
if ! $CORE_IS_INSTALLED >> /dev/null; then
    echo -e "$YELLOW"Installing WordPress in $WORDPRESS_DIR"$ENDCOLOR";
    $CORE_DOWNLOAD
    $CORE_INSTALL
fi

echo -e "$GREEN"WordPress installed in $WORDPRESS_DIR"$ENDCOLOR"

if [ ! -e "$WORDPRESS_DIR"/wp-config.php ]; then
    if [ ! -z "$IS_MULTISITE" ]; then    
        echo -e "$RED"You must provide a wp-config.php if setting up multisite"$ENDCOLOR"
        exit 1
    else
        echo -e "$YELLOW"Creating wp-config"$ENDCOLOR"

        config=$(IFS=$' \n\t';php -f .git/hooks/get-wp-addons.php config)

        CONFIG_COMMAND="$CORE config $config $WP_CLI_PATH_OPTION"
        if ! $CONFIG_COMMAND; then
            echo -e "$RED"Could not create wp-config"$ENDCOLOR"
            exit 1
        fi
    fi
fi

# Set the wp-addons.php file if there is not one already
if [ ! -e "$WORDPRESS_SETUP_DIR"/wp-addons.php ]; then
    EXAMPLE_ADDONS="$WORDPRESS_SETUP_DIR"/wp-addons.example.php
    if [ ! -e "$EXAMPLE_ADDONS" ]; then
        echo -e "$RED"Please add a wp-addons.example.php to your uploads repo or a wp-addons.php to your uploads working directory"$ENDCOLOR"
        exit 1
    fi
    
    if ! cp "$EXAMPLE_ADDONS" "$WORDPRESS_SETUP_DIR"/wp-addons.php; then
        echo -e "$RED"Could not copy addons config from "$EXAMPLE_ADDONS" to "$WORDPRESS_SETUP_DIR"/wp-addons.php"$ENDCOLOR"
        exit 1
    fi
fi

getSiteNames

# Import the original DB if it is not loaded so that the addons will install
if ! wp db tables &> /dev/null; then
    if ! wp db import "$SAVEPATH" $WP_CLI_PATH_OPTION; then
        echo -e "$RED"Could not restore database"$ENDCOLOR"
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
        if [ "$COMMAND_TYPE" == "install" ]; then		
			if [ "$(echo $ADDON_NAME | awk -F . '{print $NF}')" == "git" ]; then
				addon_repo=$(basename $ADDON_NAME .git)
				
				if [ ! -d "$WORDPRESS_DIR"/wp-content/plugins/$addon_repo ]; then
					if ! git clone $ADDON_NAME "$WORDPRESS_DIR"/wp-content/${ADDON_TYPE}s/$addon_repo; then
						echo -e "$RED"Could not clone $ADDON_NAME to "$WORDPRESS_DIR"/wp-content/${ADDON_TYPE}s/$addon_repo"$ENDCOLOR"
					fi
				else
					echo $ADDON_NAME is already installed
				fi
			elif ! wp $ADDON_TYPE is-installed $ADDON_NAME $WP_CLI_PATH_OPTION; then
				if ! $ADDON_COMMAND; then
					echo -e "$PURPLE"There was an error running:"$ENDCOLOR" $command $plugin
				fi
			else            
                echo $ADDON_NAME is already installed
			fi
        fi
        
        if [ "$COMMAND_TYPE" != "install" ] && ! wp $ADDON_TYPE is-installed $ADDON_NAME $WP_CLI_PATH_OPTION; then
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
if type httpd &> /dev/null || type apachectl > /dev/null; then
    if [ ! -z "$IS_MULTISITE" ] && [ ! -e "$WORDPRESS_DIR"/.htaccess ]; then
        echo -e "$YELLOW"Remember to add multisite .htaccess rules"$ENDCOLOR"
    elif [ ! -z "$IS_MULTISITE" ]; then
        echo -e "$YELLOW"Recreating .htaccess rewrite rules"$ENDCOLOR"
        WP_CLI_CONFIG_PATH=$WORDPRESS_SETUP_DIR/wp-cli.yml wp rewrite flush --hard $WP_CLI_PATH_OPTION        
    fi
fi
