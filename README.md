# Docker Environment
This repository allows the creation of a Docker environment that allow you to work locally.

## Architecture
* `web`: [PHP 7.1 version](https://github.com/mcoemakinafr/environment/blob/master/web/Dockerfile) with Apache.
* `mysql`: [percona:5.6](https://hub.docker.com/_/percona/) image.
* `maildev`: [djfarrelly/maildev:latest](https://hub.docker.com/r/djfarrelly/maildev/) image.

## Additional Features
* **HTTPS** : the `vX.x.1` tag assumes the support of https locally, on the two version of PHP (`5.6` and `7.1`). Please check the [tips section](#tips) to know how to use it

### Apache/PHP
The `web` container has a mount point used to share source files.
By default, the `~/www/` directory is mounted from the host. It's possible to change this path by editing the `docker-compose.yml` file.

And the `./web/custom.ini` file is used to customize the PHP configuration during the image build process. 

### Percona
The `./mysql/custom.cnf` file is used to customize the MySQL configuration during the image build process.

## Installation
This process assumes that [Docker Engine](https://www.docker.com/docker-engine) and [Docker Compose](https://docs.docker.com/compose/) are installed.
Otherwise, you should have a look to [Install Docker Engine](https://docs.docker.com/engine/installation/) before proceeding further.

### Clone the repository
```bash
$ git clone git@github.com:mcoemakinafr/environment.git environment
```
It's also possible to download it as a [ZIP archive](https://github.com/mcoemakinafr/environment/archive/master.zip).

### Define the environment variables
```bash
$ cp docker-env.dist docker-env
$ nano docker-env
```

### Get the bash aliases toolkit
```bash
$ cp web/bash_aliases.dist web/bash_aliases
$ nano web/bash_aliases
```
> Let's see in the [tips section](#tips) all what you can do

### Define the crontab
```bash
$ cp web/crontab.dist web/crontab
$ nano crontab
```

### Build the environment
```bash
$ docker-compose up -d
```

### Check the containers
```bash
$ docker-compose ps
        Name                      Command               State                      Ports
------------------------------------------------------------------------------------------------------------
environment_maildev_1     bin/maildev --web 80 --smtp 25   Up      25/tcp, 0.0.0.0:1080->80/tcp
environment_mysql_1       docker-entrypoint.sh mysqld      Up      0.0.0.0:3306->3306/tcp
environment_web_1         docker-custom-entrypoint         Up      0.0.0.0:443->443/tcp, 0.0.0.0:80->80/tcp
```
Note: You will see something slightly different if you do not clone the repository in a `environment` directory.
The container prefix depends on your directory name.

### Access to the containers
#### Database
In your docker folder, type :
```bash
docker exec -it environment_web_1 bash
```
Then type : 
```bash
mysql -uroot -hmysql
```
#### Debian
In your docker folder, type :
```bash
docker exec -it environment_web_1 bash
```

## Tips
1. You can add custom virtual hosts: all `./web/vhosts/*.conf` files are copied in the Apache directory during the image build process.
2. The HTTPS can be used easily. Check `./web/vhosts/environment.conf` as a model to get it on all your websites. You don't need to change the cert and key files.
3. **Bash aliases** :
    - _Docker_ :
        - `docker-go $1`        : connects to your container `environment_$1_1`
        - `docker-logs $1`      : displays the logs of your container `environment_$1_1`
        - `docker-rebuild [$1]` : combined of `build` and `up -d` commands from `docker-compose`. `$1` is optional
        - `docker-start [$1]`   : starts your container(s). `$1` is optional
        - `docker-stop [$1]`    : stops your container(s). `$1` is optional
    - _Symfony_ : 
        - `sfapp` alias for `php app/console`
        - `sfbin` alias for `php bin/console`
        - `schema-dump`     : dump the SQL needed to update the database schema to match the current mapping metadata.
        - `schema-force`    : execute the SQL needed to update the database schema to match the current mapping metadata.
        - `assets-install`  : install bundles web assets under a public web directory in symlink
    - _Others_ :
        - `ll`              : list the folder in a nice view
        - `goenvironment`   : go to your docker folder
        - `gosites $1`      : go to `~/www/$1` the default websites folder. `$1` is optional
        
## Notes for Drupal
This below settings can be use in `sites/default/settings.php` for a drupal 7 :
```bash
$databases = array (
  'default' => 
  array (
    'default' => 
    array (
      'database' => 'yourdatabase',
      'username' => 'root',
      'password' => '',
      'host' => 'mysql',
      'port' => '',
      'driver' => 'mysql',
      'prefix' => '',
    ),
  ),
);
```