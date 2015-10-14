# Git Hooks for Developing WordPress Sites

These bash scripts are meant to be used in conjunction with [wp-cli](http://wp-cli.org/) to automate saving your WordPress database as a SQL file to a folder called `.db` in the root of your project, providing version control for the state of your database that can be checked out along with any other changes in the project. The hooks read data from the git config section named wp-site that contains keys named after sites and values for the URL of the site.

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

`post-merge` expects a single SQL file in the `.db` folder to have a filename for a key naming one of your wp-sites. It then uses wp-cli to load the database from the file and then searches for the old site URL and replaces it with the `deploy` site URL.

## Linking to project
You may find it useful to create soft links from the scripts to your project directory. You can do so with the following:

### Windows
    mklink \path\to\project\.git\hooks\post-merge \path\to\wpgithooks\post-merge
    mklink \path\to\project\.git\hooks\pre-commit \path\to\wpgithooks\pre-commit

### Linux/OS X
    ln -s /path/to/wpgithooks/p* /path/to/project/.git/hooks
