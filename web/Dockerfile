FROM php:7.3-apache

LABEL maintainer="Matthieu CONTET <matt.contet@icloud.com>"

# Install basic requirements
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        autoconf \
        bzip2 \
        cron \
        curl \
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
        libssh2-1-dev \
        libssl-dev \
        libwebp-dev \
        libxml2-dev \
        libxml2-utils \
        libxslt-dev \
        libzip-dev \
        logrotate \
        mailutils \
        mariadb-client \
        msmtp \
        moreutils \
        nano \
        net-tools \
        netcat \
        npm \
        openssl \
        p7zip-full \
        procps \
        ssh-client \
        unzip \
        vim \
        wget \
        zip && \
    docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-gd \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-webp-dir=/usr/include/ && \
    docker-php-ext-configure zip \
        --with-libzip && \
    curl -sS -o /tmp/icu.tar.gz -L http://download.icu-project.org/files/icu4c/62.1/icu4c-62_1-src.tgz && tar -zxf /tmp/icu.tar.gz -C /tmp && cd /tmp/icu/source && ./configure --prefix=/usr/local && make && make install && \
    docker-php-ext-install -j$(nproc) \
        bcmath \
        calendar \
        exif \
        gd \
        hash \
        iconv \
        intl \
        mbstring \
        mysqli \
        opcache \
        pdo_mysql \
        soap \
        sockets \
        xml \
        xsl \
        zip && \
    apt-get clean && \
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
#RUN pecl install redis && \
#    docker-php-ext-enable redis

# Install Xdebug
#RUN pecl install xdebug && \
#    docker-php-ext-enable xdebug

# Install Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash && \
    mv /root/.symfony/bin/symfony /usr/local/bin/symfony

# Install Symfony Upgrade Fixer
RUN wget https://github.com/umpirsky/Symfony-Upgrade-Fixer/releases/download/v0.1.6/symfony-upgrade-fixer.phar -O /usr/local/bin/symfony-upgrade-fixer && \
	chmod a+x /usr/local/bin/symfony-upgrade-fixer

# Install Composer globally
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer config --global repos.packagist composer https://repo.packagist.org && \
    composer global config minimum-stability alpha && \
    composer global require "hirak/prestissimo" "sensiolabs-de/deprecation-detector" --no-suggest --optimize-autoloader --classmap-authoritative
ENV PATH "${PATH}:/root/.composer/vendor/bin"

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
