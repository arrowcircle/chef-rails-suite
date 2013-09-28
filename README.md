chef-rails-suite
================

Chef skeleton for provisioning rails servers with multiple apps per server.

# Installation
Clone rails-suite to YOUR_DIR_NAME ('redde_servers' for example):
	
	git clone https://github.com/arrowcircle/chef-rails-suite.git YOUR_DIR_NAME
	cd YOUR_DIR_NAME
	gem install chef librarian-chef knife-solo

Please use knife-solo version 0.3.0 or higher.
	
# Usage
Choose template:

	ls sample_roles
	
This directory contains skeletons for your servers named like:

	mri-2.0.0-p247_mysql_puma.json
	mri-2.0.0-p247_mysql_unicorn.json
	mri-2.0.0-p247_postgres_puma.json
	mri-2.0.0-p247_postgres_unicorn.json
	
Choose desired skeleton for your server and copy it:

	cp sample_roles/mri-2.0.0-p247_postgres_unicorn.json roles/SERVER_NAME.json
	
Open SERVER_NAME.json with favorite editor:

	{
  	  "json_class": "Chef::Role",
      "name": "mri-2.0.0-p247_postgres_unicorn",
      "description": "Rails application server testapp",
      "run_list": ["recipe[rails-stack]"],
      "default_attributes": {
        "nginx": {
          "version": "1.4.1",
          "init_style": "init"
        },
        "users": [
         {
          "user": "YOUR_APP_USER",
          "authorized_keys": ["YOUR_SSH_KEY"]
         }
        ],
        "apps":
          [
            {
              "name": "YOUR_APP_NAME",
              "user": "YOUR_APP_USER",
              "ruby_version": "2.0.0-p247",
              "domain_names": ["DOMAIN_NAME"],
              "app_server": {
                "type": "unicorn",
                "timeout": "50",
                "workers": "2"
              },
              "database": {
                "dbname": "DBNAME_production",
                "server": true,
                "type": "postgresql",
                "username": "DB_USERNAME",
                "password": "DB_PASSWORD",
                "host": "localhost"
              }
            }
          ]
      }
    }
    
Change `name` attribute to SERVER_NAME

`users` is an array containing info about users

Each user have these attributes:

* `user` username of the user
* `authorized_keys` contains array of ssh keys. Put needed keys here
* `known_hosts` contains array of known_hosts

`apps` is an array containing info about your applications

Each app have these attributes:

* `name` is the name of the app. This attribute will be used as folder for deploy
* `user` is os user name
* `ruby_version` is ruby version to install. Default is *2.0.0-p247*
* `domain_names` is domain names array used in nginx config. Use without www (eg 'redde.ru')
* `app_server` block used to describe application server to use. `type` can be `unicorn` and `puma`.

For `unicorn` you can tune `timeout` and `workers` (Used inside unicorn.rb)
For `puma` tou can set `workers`, `min_threads`, `max_threads` (Used inside puma.rb)

`database` block contains info about database, used for your app. Params:

* `type` is `postgresql` or `mysql`
* `server` is `true` or `false`. Install or not database server of the `type`
* `dbname` is database name to use (used in database.yml file, eg 'app_production')
* `username` is name of the user to connect to database
* `password` is password of the user above
* `host` is the host of the database

You are now ready to start provisioning your server

# Provisioning
If you have clean server, use bootstrap script

	knife solo bootstrap user@ip_address -r "role[SERVER_NAME]" -N "SERVER_NAME_NUMBER"
	
You can add `-p 2222` if you have custom ssh port. If you are planning to use one server, you can user `SERVER_NAME` instead of `SERVER_NAME_NUMBER`. Parameter after `-N` will be used to create node info file. Also, you can user hostname insted of `ip_address`

If you need to update some server info, you can change params in role (or node) info and then run

	knife solo cook user@ip_addres -r "role[SERVER_NAME]" -N "SERVER_NAME_NUMBER" 

This command will provision server for node and role configuration.

# Multiapp server
If you want to install multiple applications, just add another element to `apps` array. You can even install different rubies for one user.

