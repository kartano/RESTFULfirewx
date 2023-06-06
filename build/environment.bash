#!/usr/bin/env bash

# Anything failing in the shell will die with an exit code 1
set -e

if [ $# -ne 2 ];
then
  printf "Expected 2 arguments\n"
  exit 1
fi

case "$1" in
  "local")
    cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
    ;;
  "development")
    cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
    ;;
  "production")
    cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
    ;;
  *)
    echo "Invalid environment"
    exit 1
    ;;
esac

sed -i.bak 's/memory_limit = .*/memory_limit = '"$2"'/' /usr/local/etc/php/php.ini

printf error_log="/var/log/apache2/php.log\n" >> /usr/local/etc/php/php.ini

exit 0