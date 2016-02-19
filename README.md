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

`pre-commit` will use wp-cli to save the WordPress database to a sql file named after the value in the
`deploy` key, and then add this file to the index.

`post-merge` will call `post-checkout`

`post-checkout` runs the `install.sh` script that uses `get-wp-addons.php` to read plugin and theme setup configuration from the `wp-addons.php` in the repo's working directory. It also expects a single SQL file in the `.db` folder to have a filename for a key naming one of your wp-sites. It then uses wp-cli to load the database from the file and then searches for the old site URL and replaces it with the `deploy` site URL.

## Linking to project
You may find it useful to create soft links from the scripts to your project directory. You can do so with the following:

### Windows
    mklink \path\to\project\.git\hooks\post-merge \path\to\wpgithooks\post-merge
    mklink \path\to\project\.git\hooks\pre-commit \path\to\wpgithooks\pre-commit
    mklink \path\to\project\.git\hooks\install.sh \path\to\wpgithooks\install.sh
    mklink \path\to\project\.git\hooks\get-wp-addons.php \path\to\wpgithooks\get-wp-addons.php
    copy \path\to\wpgithooks\wp-addons.example.php \path\to\project\wp-addons.php
    copy \path\to\wpgithooks\wp-cli.yml \path\to\project\

### Linux/OS X
    ln -s /path/to/wpgithooks/p* /path/to/project/.git/hooks
    ln -s /path/to/wpgithooks/install.sh /path/to/project/.git/hooks
    ln -s /path/to/wpgithooks/get-wp-addons.php /path/to/project/.git/hooks
    cp /path/to/wpgithooks/wp-addons.example.php /path/to/project/wp-addons.php
    cp /path/to/wpgithooks/wp-cli.yml /path/to/project/
