#!/bin/bash

# see
# https://github.com/wp-cli/scaffold-command/blob/master/templates/install-wp-tests.sh

while ! mysqladmin ping -h"$DB_HOST" --silent; do
    sleep 3
done

mysqladmin create "$DB_NAME" --host=$DB_HOST --user=$DB_USER --password="$DB_PASSWORD"

shopt -s expand_aliases
alias wp='su-exec www-data wp --path=/usr/src/wordpress'

if ! wp core is-installed && [[ -n $ADMIN_USER && -n $ADMIN_PASS && -n $ADMIN_EMAIL ]]; then
    echo >&2 "You've given me install info. I guess I should use it. Installing..."
    sync # see: https://github.com/docker/docker/issues/9547
    wp core install \
       --title="${SITE_TITLE:-dockerwp}" \
       --admin_user=${ADMIN_USER} \
       --admin_password="${ADMIN_PASS}" \
       --admin_email=${ADMIN_EMAIL} \
       --url=${WP_HOME} \
       --skip-email
    exit $?
fi

exit 0
