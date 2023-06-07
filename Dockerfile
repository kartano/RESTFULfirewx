## See:  https://hub.docker.com/layers/library/php/8.2-apache/images/sha256-20569957a4cfb98307c814bb9c6074d9fa19afac21fc8186dc3a6b4678ffbdf3?context=explore
FROM php:8.2-apache as build

########################################################################################################################
# Environment variables and arguments
########################################################################################################################

ENV SSC_PROJECT=Firewx
ARG BUILD_ENVIRONMENT=local
ARG PHP_MEMORY_LIMIT=256M

RUN echo $BUILD_ENVIRONMENT

ENV LC_ALL=C.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

########################################################################################################################
# Verify environment, copy appropriate php.ini file, make other PHP.INI changes
########################################################################################################################

COPY ./build/environment.bash /tmp/environment.bash
RUN chmod u+x /tmp/environment.bash
RUN /usr/bin/env bash /tmp/environment.bash ${BUILD_ENVIRONMENT} ${PHP_MEMORY_LIMIT}
RUN rm /tmp/environment.bash

########################################################################################################################
# Set terminal defaults
########################################################################################################################

# Default to BASH in terminals.
RUN ln -sf /bin/bash /bin/sh
ENV ENV ~/.profile

########################################################################################################################
## Install the apt utils and setup our locales
########################################################################################################################

RUN apt-get update && apt install -y apt-utils locales locales-all
RUN echo "${LANG} UTF-8" >> /etc/locale.gen && locale-gen

########################################################################################################################
# Geneate a random root password on build - let the user known this code at build time
########################################################################################################################

RUN apt-get update && apt install -y figlet pwgen
COPY ./build/secureroot.bash /tmp/secureroot.bash
RUN chmod u+x /tmp/secureroot.bash
# Kludge - never allow secureroot to cache output.
ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache
RUN /usr/bin/env bash /tmp/secureroot.bash
RUN rm /tmp/secureroot.bash

########################################################################################################################
# Installers and install utils
########################################################################################################################

# Global utils
RUN apt-get update && apt-get install -y git wget openssl

# Install Composer
RUN curl -sS https://getcomposer.org/installer \
  | php -- --install-dir=/usr/local/bin --filename=composer

# Install NodeJS
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - \
    && sudo apt-get install -y nodejs

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install -y yarn

# Install Bower globally
RUN npm install -g bower

#  Install Phive
RUN wget -O /tmp/phive.phar "https://phar.io/releases/phive.phar" \
    && wget -O /tmp/phive.phar.asc "https://phar.io/releases/phive.phar.asc" \
    && gpg --keyserver hkps://keys.openpgp.org --recv-keys 0x6AF725270AB81E04D79442549D8A98B29B2D5D79 \
    && gpg --verify /tmp/phive.phar.asc /tmp/phive.phar \
    && rm /tmp/phive.phar.asc \
    && cp /tmp/phive.phar /usr/local/bin/phive \
    && chmod +x /usr/local/bin/phive \
    && rm /tmp/phive.phar

########################################################################################################################
# Other global utilities useful in terminals etc
########################################################################################################################

RUN apt-get update && apt-get install -y vim

# RAR - always handy.
RUN curl -L -o /tmp/rarlinux-x64-621.tar.gz https://www.win-rar.com/fileadmin/winrar-versions/rarlinux-x64-621.tar.gz \
    && gunzip /tmp/rarlinux-x64-621.tar.gz \
    && tar -xf /tmp/rarlinux-x64-621.tar -C /tmp/ \
    && cp /tmp/rar/rar /usr/local/bin \
    && cp /tmp/rar/unrar /usr/local/bin \
    && chmod u+x /usr/local/bin/rar /usr/local/bin/unrar \
    && rm -fr /tmp/rarlinux-x64-621.tar \
    && rm -fr /tmp/rar

########################################################################################################################
# PHP Extensisons
########################################################################################################################

# Global packages
RUN apt-get update -y && apt-get install -y libfreetype6-dev
RUN apt-get update -y && apt-get install -y libjpeg62-turbo-dev
RUN apt-get update -y && apt-get install -y libmcrypt-dev
RUN apt-get update -y && apt-get install -y libldap2-dev libxml2-dev
RUN apt-get update -y && apt-get install -y libicu-dev
RUN apt-get update -y && apt-get install -y zlib1g-dev
RUN apt-get update -y && apt-get install -y libpng-dev
RUN apt-get update -y && apt-get install -y libmemcached-dev
RUN apt-get update -y && apt-get install -y libzip-dev
RUN apt-get update -y && apt-get install -y libc-client-dev
RUN apt-get update -y && apt-get install -y libkrb5-dev
RUN apt-get update -y && apt-get install -y libxslt1-dev
RUN apt-get update -y && apt-get install -y libpspell-dev
RUN apt-get update -y && apt-get install -y libonig-dev

RUN pecl install memcached

# Install PDO
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql

# Install zip libraries and extension
RUN docker-php-ext-install zip

# Install intl library and extension
RUN docker-php-ext-configure intl && docker-php-ext-install intl

# Install Memcached
RUN docker-php-ext-enable memcached

# Install Soap
RUN docker-php-ext-install soap

# Install LDAP
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && docker-php-ext-install ldap

# Install MYSQLI
RUN docker-php-ext-install mysqli

# Install mcrypt
RUN pecl install mcrypt-1.0.6
RUN docker-php-ext-enable mcrypt

# Install XML Writer
RUN docker-php-ext-install xmlwriter

# Install DOM library support
RUN docker-php-ext-install dom

# XML library
RUN docker-php-ext-install xml

# SimpleXML support
RUN docker-php-ext-install simplexml

# FTP support
RUN docker-php-ext-install ftp

# Calendar library
RUN docker-php-ext-install calendar

# Process control library
RUN docker-php-ext-install pcntl

# PHRAR manipulation library
RUN docker-php-ext-install phar

# Session library
RUN docker-php-ext-install session

# Sockets library
RUN docker-php-ext-install sockets

# Multibyte string support
RUN docker-php-ext-install mbstring && docker-php-ext-enable mbstring

########################################################################################################################
# Create log files
########################################################################################################################

RUN mkdir -p /var/log/firewx
RUN chown www-data:www-data /var/log/firewx

########################################################################################################################
# Install symfony CLI
########################################################################################################################

RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash
RUN apt-get update -y && apt-get install -y symfony-cli

########################################################################################################################
# Copy over our Apache conf file
########################################################################################################################

# Adjust Apache settings to match what we need for a Laminas project.
RUN a2enmod rewrite \
    && sed -i 's!/var/www/html!/var/www/public!g' /etc/apache2/sites-available/000-default.conf \
    && mv /var/www/html /var/www/public

COPY ./build/docker/apache.conf /etc/apache2/conf-enabled/firewx.conf

########################################################################################################################
# Cleanups
########################################################################################################################

RUN apt-get autoremove -y && apt-get clean y
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*

########################################################################################################################
# Done
########################################################################################################################

WORKDIR /var/www