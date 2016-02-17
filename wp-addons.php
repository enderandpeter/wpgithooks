<?php
return array(
    // ['name', 'activate', 'version']
    'plugin' => [
        'install' => [
            'akismet',
            'alpine-photo-tile-for-instagram',
            'jetpack',
            'wysija-newsletters',
            'regenerate-thumbnails',
            'simply-instagram',
            'woocommerce',
            'wordpress-importer',
            'wp-edit'            
        ],
        'uninstall' => [
            'hello',
            'lightbox-plus',
            'quick-setup'
        ]
    ],    
    'theme' => [
        'install' => [
            ['attitude', null, '1.2.9'],
            ['https://gitlab.com/jb-merideoux/attitude-child/repository/archive.zip?ref=master', 'activate']
        ], 
        'delete' => [
            'twentysixteen',
            'twentyfifteen',
            'twentyfourteen'
        ]
    ],
);