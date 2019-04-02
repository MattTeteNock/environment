# Docker Environment
This repository allows the creation of a Docker environment to work locally, based on Apache

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Architecture
* `web`: [PHP 7.2 version](https://github.com/mattcontet/environment/blob/master/web/Dockerfile) with Apache.
* `mysql`: [percona:5.6](https://hub.docker.com/_/percona/) image.
* `redis`: [redis:latest](https://hub.docker.com/_/redis/) image.
* `maildev`: [djfarrelly/maildev:latest](https://hub.docker.com/r/djfarrelly/maildev/) image.

## Additional Features
* **HTTPS** : assumes the support of https locally. Please check the [tips section](#tips) to know how to use it

### Apache/PHP
The `web` container has a mount point used to share source files.
By default, the `~/www/` directory is mounted from the host. It's possible to change this path by editing the `docker-compose.yml` file.

And the `./web/x-custom.ini` file is used to customize the PHP configuration during the image build process. 

### Percona
The `./mysql/custom.cnf` file is used to customize the MySQL configuration during the image build process.

## Installation
This process assumes that [Docker Engine](https://www.docker.com/docker-engine) and [Docker Compose](https://docs.docker.com/compose/) are installed.
Otherwise, you should have a look to [Install Docker Engine](https://docs.docker.com/engine/installation/) before proceeding further.

:bangbang: You also need the `make` linux package.

### Clone the repository
```bash
$ git clone git@github.com:mattcontet/environment.git environment
```
It's also possible to download it as a [ZIP archive](https://github.com/mattcontet/environment/archive/master.zip).

### Set up the environment
```bash
$ make setup
```
#### OR
```bash
$ make env
$ make aliases
$ make cron
```
> Let's see in the [tips section](#tips) all what you can do

### Build the environment
```bash
$ make install
```

### Check the containers
```bash
$ docker-compose ps
        Name                      Command               State                      Ports
------------------------------------------------------------------------------------------------------------
environment_maildev_1     bin/maildev --web 80 --smtp 25   Up      25/tcp, 0.0.0.0:1080->80/tcp
environment_mysql_1       docker-entrypoint.sh mysqld      Up      0.0.0.0:3306->3306/tcp
environment_redis_1       docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp
environment_web_1         docker-custom-entrypoint         Up      0.0.0.0:443->443/tcp, 0.0.0.0:80->80/tcp
```
Note: You will see something slightly different if you do not clone the repository in a `environment` directory.
The container prefix depends on your directory name.

## Tips
1. **Getting started** :
Launch the command below and see all what you can do :
```bash
$ make help
```

2. **General informations** :
    - To plug your database to your application (if you didn't change the information in `docker-env` file) :
        - host : `'mysql'`
        - database : `yourdatabasename`
        - user : `'root'`
        - pass : `null`

3. You can add custom virtual hosts: all `./web/vhosts/*.conf` files are copied in the Apache directory during the image build process.

4. The HTTPS can be used easily. Check `./web/vhosts/environment.conf` as a model to get it on all your websites. You don't need to change the cert and key files.

5. **Aliases** :
    - _Symfony_ : 
        - `sfbin` alias for `php bin/console`
        - `sf-clear-cache`  : `>2.8` clear cache for all environments
        - `sf-schema-dump`  : dump the SQL needed to update the database schema to match the current mapping metadata.
        - `sf-schema-force` : execute the SQL needed to update the database schema to match the current mapping metadata.
        - `sf-assets`       : install bundles web assets under a public web directory in symlink
        - `sf-fixtures`     : launch the doctrine fixtures
    - _Others_ :
        - `ll`              : list the folder in a nice view

6. **PHP CS Fixer** :
    - Use it via the shell :
        - You have a script in `Tools/PHP_CS_Fixer/script_php_cs.sh`
        - It can take as argument any relative or full path in the volume of the web container.
    - Use it with PHPStorm : 
        - There also is a tools file in `Tools/PHP_CS_Fixer/PHP_CS_Fixer.xml`.
        - It can be added as an external tool which allow you to use it on any files of a project.
        - Just place the file in the folder :
            - For Unix : `~/.<PRODUCT><VERSION>/tools`
            - For Windows : `<SYSTEM DRIVE>\Users\<USER ACCOUNT NAME>\.<PRODUCT><VERSION>\tools`
            - For Mac : `~/Library/Preferences/<PRODUCT><VERSION>/tools`
        - Change the path to the script.
