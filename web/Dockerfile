FROM php:7.1-apache

MAINTAINER Matthieu CONTET <matt.contet@icloud.com>
LABEL maintainer="Matthieu CONTET <matt.contet@icloud.com>"

# Install basic requirements
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        autoconf \
        git \
        jq \
        libicu-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libmcrypt-dev \
        libpng-dev \
        libssl-dev \
        libxml2-dev \
        libxml2-utils \
        mailutils \
        ssh-client \
        ssmtp \
        make \
        mysql-client \
        openssl \
        cron \
        nano \
        jpegoptim \
        nodejs \
        npm \
        uglifyjs \
        openjdk-7-jdk && \
    docker-php-ext-install -j$(nproc) \
        bcmath \
        calendar \
        hash \
        intl \
        mcrypt \
        opcache \
        pdo_mysql \
        soap \
        sockets \
        zip \
    && yes | pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && perl -pi -e "s/mailhub=mail/mailhub=maildev/" /etc/ssmtp/ssmtp.conf \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# Install PHP CS Fixer
ADD http://get.sensiolabs.org/php-cs-fixer.phar /usr/local/bin/php-cs-fixer
RUN chmod a+x /usr/local/bin/php-cs-fixer

# Install Composer globally
RUN \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Install gulp-cli globally
RUN \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" && \
    nvm install node && \
    nvm use node && \
    npm install -g gulp-cli

# Install and activate SSL
RUN \
    a2enmod ssl; \
    mkdir -p /etc/ssl/private/ /etc/ssl/certs/ && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/localhost.key -out /etc/ssl/certs/localhost.crt \
        -subj "/CN=localhost"

# Install custom virtual hosts
COPY vhosts /etc/apache2/sites-available
RUN \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    a2ensite $(find /etc/apache2/sites-available/ -type f -name "*.conf" -not -name "*default*" -printf "%f\n") && \
    a2enmod headers rewrite && \
    ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

# Install custom PHP configuration
COPY custom.ini /usr/local/etc/php/conf.d/

ADD bash_aliases /root/.bashrc
ENV TERM xterm

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

# Add crontab file in the cron directory
COPY crontab /tmp/crontab

# Install custom entrypoint
COPY ./entrypoint.sh /usr/local/bin/docker-custom-entrypoint
RUN chmod 777 /usr/local/bin/docker-custom-entrypoint
ENTRYPOINT ["docker-custom-entrypoint"]