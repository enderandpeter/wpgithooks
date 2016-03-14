# Git Hooks for WordPress

## Introduction

Welcome to Git Hooks for WordPress, a collection of scripts to help with development and automated deployment of WordPress sites on different environments.

### About

If you've worked with WordPress sites, you have surely noted how there are surprisingly few solutions for version control, let alone a solution for multiple developers working in
different environments, not to mention accomodating different site URLs for dev, stage, and production. The best approach to this so far is [VersionPress](http://versionpress.net/). Check out what they are doing. The tools here should remain free for all to use and will continue to improve over time.

These scripts provide a strategy for deploying a WordPress site in separate environments with their own site URL, theme and plugin installations, and custom setup commands. This
is achieved through the use of [git hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) which are used with the repo which tracks the WordPress site's content. The hooks will install the site's core files and addons if they are not present, restore the DB saved in the `uploads` repo which is typically in the site's `wp-content/uploads` folder, and save the database as a SQL file in a `.db` folder in your site's `uploads`. With just the content of the `uploads`, the site's DB as a SQL file, a list of addons and an optional cleanup script, any WordPress site can be faithfully recreated. A multisite install will need a `.htaccess` and `wp-config.php` in the root site folder before running `post-checkout` for the first time. For a single site, they are created from configuration in `wp-addons.php`.

### Requirements

* [wp-cli](http://wp-cli.org/)
* A `wp-addons.php` file in `uploads/.setup` which defines the plugins, themes, and wp-config.
* A `cleanup.sh` script in `uploads/.setup` with commands to be ran at the end of the setup (Optional)
* A site definition section in `uploads/.git/config` which resembles the following:

### Example
		####################################################################
		# An example git configuration for saving SQL for a site called "test":
		####################################################################
		[wp-site]
			test = local.example.com
			live = example.com
			deploy = test

This would let your hooks know which site URLs that the DB files `test.sql` and `live.sql` refer to. It would install the `test` site on your server at the URL `local.example.com`.
            
### Files
`get-wp-addons.php` is called by `post-checkout` to retrieve the list of plugins and themes to be installed and removed as defined by `wp-addons.php`
in the main project (uploads folder).

`functions.sh` contains functions used by the shell scripts

`install.sh` runs the commands for installing the core WordPress files, plugins, and themes. It also recreates the .htaccess rewrite rules if using httpd.

`remove.sh` removes the plugins and themes listed for deletion in the main project's `wp-addons.php`.

`cleanup.example.sh` is a script that should be copied to `uploads/.setup/cleanup.sh` if additional commands should be run after the end of the setup.
            
`pre-commit` will use wp-cli to save the WordPress database to a sql file named after the value in the `deploy` key, and then add this file to the index.

`post-merge` will call `post-checkout`

`post-checkout` runs the `install.sh` script that uses `get-wp-addons.php` to read plugin and theme setup configuration from the `wp-addons.php` in the repo's working directory. It also expects a single SQL file in the `.db` folder to have a filename for a key naming one of your wp-sites. It then uses wp-cli to load the database from the file and then searches for the old site URL and replaces it with the `deploy` site URL.

`wp-addons.example.php` is an example configuration file for defining the themes and plugins to be managed for your site. `install.sh` will copy it to `wp-addons.php`
in the main project if that file does not already exist.

`wp-cli.yml` is a configuration file for WP-CLI that makes sure the .htaccess file is actually recreated.

You can also provide a `cleanup.sh` in your uploads folder that is run at the end of the hooks, after themes and plugins have been removed.

## Linking to project
You may find it useful to create soft links from the scripts to your project's hooks directory, whereas some files should be copied to your project's `.setup` directory. You can do so with the following:

### Windows
    mklink \path\to\wp-content\uploads\.git\hooks\get-wp-addons.php \path\to\wpgithooks\get-wp-addons.php
    mklink \path\to\wp-content\uploads\.git\hooks\functions.sh \path\to\wpgithooks\functions.sh
    mklink \path\to\wp-content\uploads\.git\hooks\install.sh \path\to\wpgithooks\install.sh
    mklink \path\to\wp-content\uploads\wp-content\uploads\.git\hooks\remove.sh \path\to\wpgithooks\remove.sh
    mklink \path\to\wp-content\uploads\wp-content\uploads\.git\hooks\pre-commit \path\to\wpgithooks\pre-commit
    mklink \path\to\wp-content\uploads\wp-content\uploads\.git\hooks\post-merge \path\to\wpgithooks\post-merge
    mklink \path\to\wp-content\uploads\wp-content\uploads\.git\hooks\post-checkout \path\to\wpgithooks\post-checkout
    copy \path\to\wpgithooks\wp-addons.example.php \path\to\project\.setup\wp-addons.php
    copy \path\to\wpgithooks\cleanup.example.sh \path\to\project\.setup\cleanup.sh
    copy \path\to\wpgithooks\wp-cli.yml \path\to\project\.setup

### Linux/OS X
    ln -s /path/to/wpgithooks/{get-wp-addons.php,p*,install.sh,functions.sh} /path/to/project/.git/hooks    
    cp /path/to/wpgithooks/wp-cli.yml /path/to/project
    cp /path/to/wpgithooks/wp-addons.example.php /path/to/project/.setup/wp-addons.php
    cp /path/to/wpgithooks/cleanup.example.sh /path/to/project/.setup/cleanup.sh

## How to Use

After you have either copied or symlinked the above files to the required directories and setup your `wp-addons.php` and optional `cleanup.sh`, you will be able
to install all the core, plugin and theme files for your WordPress site. The hook scripts will also restore your database from the SQL file in your `uploads` folder's
`.db` directory. This SQL file should be named after a site defined in the `wp-site` section of your local repo's `.git/config` file. The site assigned to the `deploy` key
in the git config is the one that will be setup.

If restoring a multisite install, you will need to provide a [`wp-config.php`](https://codex.wordpress.org/Create_A_Network#Step_4:_Enabling_the_Network) and the [`.htaccess`](https://codex.wordpress.org/Multisite_Network_Administration#.htaccess_and_Mod_Rewrite) rules.
    
## Bugs
* pre-commit hook may error when replacing .SQL from previous environment
* Deleted plugins may not be properly disabled in the database, resulting in a message in the plugin screen reporting the completion of their removal.
