@ECHO off

IF NOT DEFINED _WORDPRESS_DIR (
    SET /P _WORDPRESS_DIR=Please enter full path to WordPress directory: 
)

SET _WORDPRESS_UPLOADS_DIR=%_WORDPRESS_DIR%\wp-content\uploads
SET _WORDPRESS_SETUP_DIR=%_WORDPRESS_UPLOADS_DIR%\.setup

IF NOT EXIST %_WORDPRESS_UPLOADS_DIR%\.git\hooks (
    ECHO Could not find git hooks directory in %_WORDPRESS_UPLOADS_DIR%
    EXIT /B
)

IF NOT EXIST %_WORDPRESS_SETUP_DIR% (
    MD %_WORDPRESS_SETUP_DIR%
)

ECHO Symlinking hook files...

FOR %%G IN (get-wp-addons.php,functions.sh,install.sh,remove.sh,post-checkout,post-merge,post-commit) DO (
    IF NOT EXIST %_WORDPRESS_UPLOADS_DIR%\.git\hooks\%%G (
        MKLINK %_WORDPRESS_UPLOADS_DIR%\.git\hooks\%%G %CD%\%%G || (
            ECHO Could not create symlinks 
            EXIT /B
        )
    ) ELSE (
        ECHO Found link to %_WORDPRESS_UPLOADS_DIR%\.git\hooks\%%G
    )
)

WHERE httpd > NUL && (    
    IF NOT EXIST %_WORDPRESS_SETUP_DIR%\wp-cli.yml (
        ECHO Detected httpd. Copying YML...
        COPY %0\..\wp-cli.yml %_WORDPRESS_SETUP_DIR%
    ) ELSE (
        ECHO WP-CLI configuration found at %_WORDPRESS_SETUP_DIR%\wp-cli.yml
    )
)

IF NOT EXIST %_WORDPRESS_SETUP_DIR%\wp-addons.php (
    ECHO wp-addons.php was not found in the project.
    IF NOT EXIST  %_WORDPRESS_SETUP_DIR%\wp-addons.example.php (
        ECHO Copying example wp-addons from hooks repo.
        COPY %0\..\wp-addons.example.php %_WORDPRESS_SETUP_DIR%\wp-addons.php
    ) ELSE (
        ECHO Copying example wp-addons from project repo.
        COPY %_WORDPRESS_SETUP_DIR%\wp-addons.example.php %_WORDPRESS_SETUP_DIR%\wp-addons.php
    )    
)

IF NOT EXIST %_WORDPRESS_SETUP_DIR%\cleanup.sh (
    ECHO A cleanup script was not found in the project.
    IF NOT EXIST  %_WORDPRESS_SETUP_DIR%\cleanup.example.sh (
        ECHO Copying example cleanup.sh from hooks repo.
        COPY %0\..\cleanup.example.sh %_WORDPRESS_SETUP_DIR%\cleanup.sh
    ) ELSE (
        ECHO Copying example cleanup.sh from project repo.
        COPY %_WORDPRESS_SETUP_DIR%\cleanup.example.sh %_WORDPRESS_SETUP_DIR%\cleanup.sh
    )    
)

ECHO To install the site, open an msysgit terminal and enter: cd "%_WORDPRESS_UPLOADS_DIR%" ^&^& .git/hooks/post-checkout
ECHO Be sure to set the site definitions first in .git/config
