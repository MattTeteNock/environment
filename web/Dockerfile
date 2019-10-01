FROM php:7.2-apache

LABEL maintainer="Matthieu CONTET <matt.contet@icloud.com>"

# Install basic requirements
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        autoconf \
        bzip2 \
        cron \
        git \
        gnupg \
        jpegoptim \
        jq \
        libcurl4-openssl-dev \
        libicu-dev \
        libfreetype6-dev \
        libgpgme11-dev \
        libjpeg-dev \
        libmcrypt-dev \
        libpng-dev \
        libssl-dev \
        libxml2-dev \
        libxml2-utils \
        libxslt-dev \
        mailutils \
        mariadb-client \
        nano \
        openssl \
        ssh-client \
        msmtp \
        wget && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    curl -sS -o /tmp/icu.tar.gz -L http://download.icu-project.org/files/icu4c/62.1/icu4c-62_1-src.tgz && tar -zxf /tmp/icu.tar.gz -C /tmp && cd /tmp/icu/source && ./configure --prefix=/usr/local && make && make install && \
    docker-php-ext-install -j$(nproc) \
        bcmath \
        calendar \
        gd \
        hash \
        intl \
        mysqli \
        opcache \
        pdo_mysql \
        soap \
        sockets \
        zip && \
    apt-get clean && \
#   perl -pi -e "s/mailhub=mail/mailhub=maildev/" /etc/ssmtp/ssmtp.conf && \
    usermod -u 1000 www-data

# Install GMP
RUN apt-get update -y && \
	apt-get install -y libgmp-dev re2c libmhash-dev libmcrypt-dev file && \
	ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/ && \
	docker-php-ext-configure gmp && \
	docker-php-ext-install gmp

# Install GnuPG
RUN pecl install gnupg && \
    docker-php-ext-enable gnupg

# Install Redis
RUN pecl install redis && \
    docker-php-ext-enable redis

# Install Xdebug
RUN pecl install xdebug && \
    docker-php-ext-enable xdebug

# Install PHP CS Fixer
ADD http://get.sensiolabs.org/php-cs-fixer.phar /usr/local/bin/php-cs-fixer
RUN chmod a+x /usr/local/bin/php-cs-fixer

RUN wget https://github.com/umpirsky/Symfony-Upgrade-Fixer/releases/download/v0.1.6/symfony-upgrade-fixer.phar -O /usr/local/bin/symfony-upgrade-fixer && \
	chmod a+x /usr/local/bin/symfony-upgrade-fixer

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Install Drush globally
RUN composer global require drush/drush

# Install and activate SSL
RUN a2enmod ssl; \
    mkdir -p /etc/ssl/private/ /etc/ssl/certs/ && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/localhost.key -out /etc/ssl/certs/localhost.crt \
        -subj "/CN=localhost"

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    a2enmod headers rewrite && \
    ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

# Install yarn
RUN curl -sS https://deb.nodesource.com/setup_10.x | bash && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g grunt-cli gulp-cli && \
	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn && \
    rm -rf /var/lib/apt/lists/*

# Install custom PHP configuration
COPY x-custom.ini /usr/local/etc/php/conf.d/

ADD bash_aliases /root/.bashrc
ENV TERM xterm

# Add crontab file in the cron directory
COPY crontab /tmp/crontab

# Install custom entrypoint
COPY ./entrypoint.sh /usr/local/bin/docker-custom-entrypoint

RUN chmod 777 /usr/local/bin/docker-custom-entrypoint

ENTRYPOINT ["docker-custom-entrypoint"]
