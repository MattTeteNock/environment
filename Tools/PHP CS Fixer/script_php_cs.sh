#!/usr/bin/env bash
# This script can be used in a shell without arguments
if [ "$#" -gt 0 ]
then
	path=$1
else
	path=$(pwd)
fi

# Format the argument to match the path in the docker container
var=$(echo $path | sed 's/.*www\///')

# Launch php cs fixer
docker exec docker-apache_web_1 php-cs-fixer fix /var/www/html/$var --verbose
