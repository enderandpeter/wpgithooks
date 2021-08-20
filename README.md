# Git Hooks for WordPress

## Introduction

Welcome to Git Hooks for WordPress, a collection of scripts to help with the development and automated deployment of WordPress sites on different environments.

### About

If you've worked with WordPress sites, you have surely noted how there are surprisingly few solutions for version control of a WordPress site's content (the `uploads` folder and database), let alone a solution for multiple developers working in different environments, not to mention accomodating different site URLs for dev, stage, and production. The best approach to this so far is [VersionPress](http://versionpress.net/). Check out what they are doing. The tools here will remain free for all to use and will continue to improve over time.

These scripts provide a strategy for deploying a WordPress site in separate environments with their own site URL, addons (themes and plugins), and custom setup commands. This
is achieved through the use of [git hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) which are stored in the `.git/hooks` folder of the repo tracking the WordPress site's content. The `wp-addons.php.example` and `cleanup.sh.example` provide minimal examples which should be tracked in your `uploads` repo. They will serve as the necessary starting point for the  untracked `wp-addons.php` and `cleanup.sh`. The non-example scripts will be suited to each environment so that each server can deviate from the primary example as needed. Some environments might have plugins that aid in development, or some server may need certain commands run afterwards that others don't. The example scripts, much like [.env.example](https://github.com/vlucas/phpdotenv), are intended to be tracked with the repo to define the main setup which can be altered in the untracked non-example files for the needs of the server.


The hooks will install the site's core files and addons if they are not present, restore the DB saved in the `uploads` repo which is typically in the site's `wp-content/uploads` folder, and save the database as a SQL file in a `.db` folder in your site's `uploads`. With just the content of the `uploads`, the site's DB as a SQL file, a list of addons and an optional cleanup script, any WordPress site can be faithfully recreated. A multisite install will need a `.htaccess` and `wp-config.php` in the root site folder before running `post-checkout` for the first time. For a single site, these files can be created from configuration in `wp-addons.php`.

### Requirements

* [wp-cli](http://wp-cli.org/)
* A `wp-addons.php` file in `uploads/.setup` which defines the plugins, themes, and wp-config.
* A `cleanup.sh` script in `uploads/.setup` with commands to be ran at the end of the setup (Optional)
* A `.db` folder with a SQL file of the site's database. There should be one file within named after one of the sites defined in the git config.
* A site definition section in `uploads/.git/config` which resembles the following:

### Example
		####################################################################
		# An example git configuration for saving SQL for a site called "test":
		####################################################################
		[wp-site]
			test = local.example.com
			live = example.com
			deploy = test

This would let your hooks know which site URLs that the DB files `uploads/.db/test.sql` and `uploads/.db/live.sql` refer to. It would install the `test` site on your server at the URL `local.example.com`.
            
### Files
`get-wp-addons.php` is called by `post-checkout` to retrieve the list of plugins and themes to be installed and removed as defined by `wp-addons.php`
in the main project (uploads folder).

`functions.sh` contains functions used by the shell scripts

`install.sh` runs the commands for installing the core WordPress files, plugins, and themes. It also recreates the `.htaccess` rewrite rules if using httpd.

`remove.sh` removes the plugins and themes listed for deletion in the main project's `wp-addons.php`.

`cleanup.sh.example` is a script that should be copied to `uploads/.setup/cleanup.sh` if additional commands should be run after the end of the setup.
            
`pre-commit` will use wp-cli to save the WordPress database to a SQL file named after the value in the `deploy` key in the git config, and then add this SQL file to the index.

`post-merge` will call `post-checkout`

`post-checkout` runs the `install.sh` script that uses `get-wp-addons.php` to read plugin and theme setup configuration from the `wp-addons.php` in the repo's working directory. It also expects a single SQL file in the `.db` folder to have a filename for a key naming one of your wp-sites. It then uses wp-cli to load the database from the file and then searches for the old site URL and replaces it with the `deploy` site URL.

For multisite, the `wp-config.php` is searched for the new (`deploy`) site name and replaces it with the URL for the current SQL file's site name. Before the database search and replace runs, the SQL file needs the old URL in wp-config.php. This is because the old site will still be defined in the database and wp-cli will think that the wp-config.php with the new site name is not for the current database. After the database gets the new site name, `post-checkout` sets `wp-config.php` to the new site name, completing the setup.

`wp-addons.php.example` is an example configuration file for defining the themes and plugins to be managed for your site. `install.sh` will copy it to `wp-addons.php`
in the main project if that file does not already exist.

`wp-cli.yml.example` is an example configuration file for wp-cli that makes sure the `.htaccess` file is actually recreated. Copy this to `uploads/.setup/wp-cli.yml`.

`setup.bat` will setup the git hooks into the WordPress uploads folder on Windows. The `_WORDPRESS_DIR` environment variable can be set to the location of the WordPress
directory, or it can be entered when prompted. The script will create softlinks for the hooks and copy the example scripts to their main locations.

__Note__:  On Windows, use CMD's `mklink` to make sure the scripts are properly linked instead of msysgit's `ln`.

`setup.sh` will setup the git hooks in the WordPress upload directory on Linux. `getWPDir` from `functions.sh` will be called to set the `WORDPRESS_DIR` environment variable to the WordPress directory.

## Linking to project
You may find it useful to create symbolic links from the scripts to your project's `.git/hooks` directory, whereas some files should be copied to your project's `.setup` directory. The `setup` scripts will do this, but you can also do so with the following:

### Windows
    mklink \path\to\wp-content\uploads\.git\hooks\get-wp-addons.php \path\to\wpgithooks\get-wp-addons.php
    mklink \path\to\wp-content\uploads\.git\hooks\functions.sh \path\to\wpgithooks\functions.sh
    mklink \path\to\wp-content\uploads\.git\hooks\install.sh \path\to\wpgithooks\install.sh
    mklink \path\to\wp-content\uploads\wp-content\uploads\.git\hooks\remove.sh \path\to\wpgithooks\remove.sh
    mklink \path\to\wp-content\uploads\wp-content\uploads\.git\hooks\pre-commit \path\to\wpgithooks\pre-commit
    mklink \path\to\wp-content\uploads\wp-content\uploads\.git\hooks\post-merge \path\to\wpgithooks\post-merge
    mklink \path\to\wp-content\uploads\wp-content\uploads\.git\hooks\post-checkout \path\to\wpgithooks\post-checkout
    copy \path\to\wpgithooks\wp-addons.php.example \path\to\project\.setup\wp-addons.php
    copy \path\to\wpgithooks\wp-addons.php.example \path\to\project\.setup
    copy \path\to\wpgithooks\cleanup.sh.example \path\to\project\.setup\cleanup.sh
    copy \path\to\wpgithooks\cleanup.sh.example \path\to\project\.setup
    copy \path\to\wpgithooks\wp-cli.yml.example \path\to\project\.setup\wp-cli.yml
    copy \path\to\wpgithooks\wp-cli.yml.example \path\to\project\.setup

### Linux/OS X
    ln -s /path/to/wpgithooks/{get-wp-addons.php,p*,install.sh,functions.sh} /path/to/project/.git/hooks    
    cp /path/to/wpgithooks/wp-cli.yml.example /path/to/project/wp-cli.yml
    cp /path/to/wpgithooks/wp-cli.yml.example /path/to/project
    cp /path/to/wpgithooks/wp-addons.php.example /path/to/project/.setup/wp-addons.php
    cp /path/to/wpgithooks/wp-addons.php.example /path/to/project/.setup
    cp /path/to/wpgithooks/cleanup.sh.example /path/to/project/.setup/cleanup.sh
    cp /path/to/wpgithooks/cleanup.sh.example /path/to/project/.setup

## How to Use

After you have either copied or symlinked the above files to the required directories and setup your `wp-addons.php` and optional `cleanup.sh`, the installation of all the core files, plugins, themes, database and running of custom cleanup commands will all happen when a commit is checked out or merged into your `uploads` repo. You can work on the site, make changes to the site content, commit them, and rest assured that cloning the site content elsewhere will recreate everything that the WordPress web application requires.

You can also start the installation and DB restoration process manually by running the `post-checkout` script.

If restoring a multisite install, you will need to provide a [`wp-config.php`](https://codex.wordpress.org/Create_A_Network#Step_4:_Enabling_the_Network). The multisite [`.htaccess`](https://codex.wordpress.org/Multisite_Network_Administration#.htaccess_and_Mod_Rewrite) rules must also be present if using Apache Web Server \(httpd\).
    
## Bugs
* pre-commit hook may occassionaly error when replacing .SQL from previous site name
* Deleted plugins may not be properly disabled in the database, resulting in a message in the plugin screen reporting the completion of their removal.
* Most version trackers will more than likely not be able to do any kind of smart merging between the SQL changes in the commits, and so when a project environment is updated, the latest changes will always overwrite whatever is present.
