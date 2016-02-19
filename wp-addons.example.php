<?php
/*
This is an example Plugin/Theme install manifest, which is simply a returned PHP array. Feel free to use the old-school
array() function if your server does not support the newer syntax.

This script is called by get-wp-addons.php in install.sh, which are among the necessary scripts for the hooks that manage the 
installation of your WordPress site from the uploads folder and database file.

The first level in the configuration array is for the type of setting: plugin, theme, or config. The plugin and theme sections
define which plugins and themes to install or remove from the core installation. The database will have the state of activation.
*/
return [
    // ['name', 'version']
    'plugin' => [
        'install' => [
            'akismet',
            'alpine-photo-tile-for-instagram',
            'jetpack',            
            'regenerate-thumbnails',            
            'wordpress-importer',
        ],
        'uninstall' => [
            'hello',
            'quick-setup'
        ]
    ],    
    'theme' => [
        'install' => [
            ['attitude', '1.2.9'], // Theme with version
            'https://example.com/mytheme.zip' // Specify a local or remote zip file for themes not hosted on Wordpress.org
        ], 
        'delete' => [
            'twentysixteen',
            'twentyfifteen',
            'twentyfourteen'
        ]
    ],
   'config' => [
        '--dbname=mydb',
        '--dbuser=myuser',
        '--dbpass=mypass'
   ]
];