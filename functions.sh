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