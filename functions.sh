setColors () {
    PURPLE='\e[0;35m'
    GREEN='\e[0;32m'
    YELLOW='\e[0;33m'
    RED='\e[0;31m'
    ENDCOLOR='\e[0m'
}

getWPDir () {
    # Get absolute path of WordPress directory, which should
    # be two folders up from /wp-content/uploads/.git/hooks
    if [ ! -e "$WORDPRESS_DIR" ]; then
        if [[ "$(pwd)" =~ uploads$ ]]; then
            WORDPRESS_DIR=../..
        fi        
    fi    
    
    if [ ! -d "$WORDPRESS_DIR" ]; then
        echo $WORDPRESS_DIR
        echo -n "Please enter the path of the WordPress directory: "
        read WORDPRESS_DIR
        if [ ! -d "$WORDPRESS_DIR" ]; then
            echo -e "$RED"Could not find the directory: $WORDPRESS_DIR"$ENDCOLOR"
            exit
        fi    
    fi
    cd $WORDPRESS_DIR
    WORDPRESS_DIR=$(pwd)
    cd - >> /dev/null
    WP_CLI_PATH_OPTION=--path="$WORDPRESS_DIR"
    
    WORDPRESS_UPLOADS_DIR=$WORDPRESS_DIR/wp-content/uploads
    WORDPRESS_SETUP_DIR=$WORDPRESS_UPLOADS_DIR/.setup
}

getSiteNames() {
    # Remake the WordPress database from the .db SQL file and replace
    # the URLs from the file with the value for the wp-site being deployed
    DB_FOLDER=.db
    EXAMPLE_CONFIG=$(cat << EOF
    ####################################################################
    # An example git configuration for saving SQL for a site called "test":
    ####################################################################
    [wp-site]
        test = local.example.com
        live = example.com
        deploy = test
EOF
)
    # Confirm the existence of the database folder
    if [ ! -d "$DB_FOLDER" ]; then
        echo -e "$RED""Could not find DB folder: $(pwd)/$DB_FOLDER""$ENDCOLOR"
        exit 1
    fi

    # The name of the SQL file helps to identify the site url that will be in it
    SITENAME=$(git config --get wp-site.deploy)

    if [ -z "$SITENAME" ]; then
        cat << EOF
    Could not find name of site. Make sure there is a [wp-site] section in the
    git config that defines a "deploy" key and the available sites. 
EOF
        echo ""
        echo "$EXAMPLE_CONFIG"
        exit 1
    fi

    SAVEPATH="$(ls "$DB_FOLDER"/*.sql | head -n 1)"

    OLDSITE=$(basename "$SAVEPATH" .sql)
    NEWURL=$(git config --get wp-site."$SITENAME")
    OLDURL=$(git config --get wp-site."$OLDSITE")

    if [ -z "$NEWURL" ] || [ -z "$OLDURL" ]; then
        cat << EOF
    Could not find replacement strings in this project's git config:

    OLDSITE = $OLDURL
    SITENAME = $NEWURL

    Make sure there is a [wp-site] section in the
    git config that defines a "deploy" key and the available sites. 
EOF
        echo 
        echo "$EXAMPLE_CONFIG"
        exit 1	
    fi
}

getMultisite() {
    if [ ! -z "$(sed -n "/^define(\('\|\"\)MULTISITE/p" "$WORDPRESS_DIR"/wp-config.php)" ]; then
        IS_MULTISITE=true
    fi
}