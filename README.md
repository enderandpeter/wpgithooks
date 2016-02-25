# Git Hooks for Developing WordPress Sites

These bash scripts are meant to be used in conjunction with [wp-cli](http://wp-cli.org/) and [some WordPress Git hooks](https://github.com/enderandpeter/wpgithooks) to automate saving your WordPress database as a SQL file to a folder called `.db` in the root of your project, providing version control for the state of your database that can be checked out along with any other changes in the project. The hooks read data from the git config section named wp-site that contains keys named after sites and values for the URL of the site. There is also an install.sh script that reads from a wp-addons.php configuration array in the WordPress site's uploads folder, which is where your repo should be based. The wp-addons.example.php file is an example configuration with instructions.

### Example
		####################################################################
		# An example git configuration for saving SQL for a site called "test":
		####################################################################
		[wp-site]
			test = local.example.com
			live = example.com
			deploy = test


`get-wp-addons.php` is called by `post-checkout` to retrieve the list of plugins and themes to be installed and removed as defined by `wp-addons.php`
in the main project (uploads folder).

`functions.sh` contains functions used by the shell scripts

`install.sh` runs the commands for installing the core WordPress files, plugins, and themes. It also recreates the .htaccess rewrite rules if using httpd.

`remove.sh` removes the plugins and themes listed for deletion in the main project's `wp-addons.php`.
            
`pre-commit` will use wp-cli to save the WordPress database to a sql file named after the value in the `deploy` key, and then add this file to the index.

`post-merge` will call `post-checkout`

`post-checkout` runs the `install.sh` script that uses `get-wp-addons.php` to read plugin and theme setup configuration from the `wp-addons.php` in the repo's working directory. It also expects a single SQL file in the `.db` folder to have a filename for a key naming one of your wp-sites. It then uses wp-cli to load the database from the file and then searches for the old site URL and replaces it with the `deploy` site URL.

`wp-addons.example.php` is an example configuration file for defining the themes and plugins to be managed for your site. `install.sh` will copy it to `wp-addons.php`
in the main project if that file does not already exist.

`wp-cli.yml` is a configuration file for WP-CLI that makes sure the .htaccess file is actually recreated.

## Linking to project
You may find it useful to create soft links from the scripts to your project directory. You can do so with the following:

### Windows
    mklink \path\to\wp-content\uploads\.git\hooks\get-wp-addons.php \path\to\wpgithooks\get-wp-addons.php
    mklink \path\to\wp-content\uploads\.git\hooks\functions.sh \path\to\wpgithooks\functions.sh
    mklink \path\to\wp-content\uploads\.git\hooks\install.sh \path\to\wpgithooks\install.sh
    mklink \path\to\wp-content\uploads\wp-content\uploads\.git\hooks\remove.sh \path\to\wpgithooks\remove.sh
    mklink \path\to\wp-content\uploads\wp-content\uploads\.git\hooks\pre-commit \path\to\wpgithooks\pre-commit
    mklink \path\to\wp-content\uploads\wp-content\uploads\.git\hooks\post-merge \path\to\wpgithooks\post-merge
    mklink \path\to\wp-content\uploads\wp-content\uploads\.git\hooks\post-checkout \path\to\wpgithooks\post-checkout
    copy \path\to\wpgithooks\wp-addons.example.php \path\to\project\wp-addons.php
    copy \path\to\wpgithooks\wp-cli.yml \path\to\project\

### Linux/OS X
    ln -s /path/to/wpgithooks/{get-wp-addons.php,p*,install.sh,functions.sh} /path/to/project/.git/hooks    
    cp /path/to/wpgithooks/{wp-addons.example.php,wp-cli.yml} /path/to/project
