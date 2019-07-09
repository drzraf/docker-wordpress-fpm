#!/bin/bash

# see
# https://github.com/wp-cli/scaffold-command/blob/master/templates/install-wp-tests.sh

[[ -n "$VERBOSE" ]] && set -vx

# GitLab.com workaround for
# https://gitlab.com/gitlab-org/gitlab-runner/issues/1042#note_61788095
if [[ -n "$CI_PROJECT_DIR" ]]; then
    while ! ping -c 1 "$DB_HOST"; do
	if [[ -e "$CI_PROJECT_DIR/hosts" ]]; then
	    cat "$CI_PROJECT_DIR/hosts" > /etc/hosts
	    break;
	fi
	sleep 1
    done
fi

while ! mysqladmin --host="$DB_HOST" ping; do
    sleep 3
done

mysqladmin create "$DB_NAME" --host="$DB_HOST" --user=root --password="$MYSQL_ROOT_PASSWORD" || true

shopt -s expand_aliases

if getent passwd www-data; then
    if type -P su-exec; then
	alias wp='su-exec www-data wp'
    elif type -P sudo; then
	alias wp='sudo -u www-data wp'
    fi
else
    alias wp='wp --allow-root'
fi

let ret=0
if ! wp core is-installed && [[ -n $ADMIN_USER && -n $ADMIN_PASS && -n $ADMIN_EMAIL ]]; then
    echo >&2 "Installing WordPress..."
    cd "${WP_CORE_DIR:-/var/www/wordpress}"
    sync # see: https://github.com/docker/docker/issues/9547
    wp core install \
       --title="${SITE_TITLE:-dockerwp}" \
       --admin_user=${ADMIN_USER} \
       --admin_password="${ADMIN_PASS}" \
       --admin_email=${ADMIN_EMAIL} \
       --url=${WP_HOME} \
       --skip-email
    ret=$?
fi


# If this image is used as a service in GitLab CI then we have a no way to
# finely tweak provisioning. We already provide WP_SCRIPTS
# But let's be bold and bind an open socket to a root-shell so
# that the main container run whatever it wants to using:
# apk add socat && socat - TCP:phpfpm:9666 <<<hostname
#
# GitlLab `wait-for-service` wait for EXPOSEd port to be available before
# starting running main image scripts.
# But we don't want running socat to give a false sense that container is initialized.
# And we don't want that `wait-for-service` depends on us to setup other services because:
# 1. We may need main container `before_script` to mount $CI_PROJECT_DIR
# 2. We may need the mysql connection from another mariadb service.
#
# A manual wait-for-socket can be implemented as:
# while ! < /dev/tcp/phpfpm/9666; do sleep 1; done

if [[ -n "$SOCAT" ]]; then
    socat TCP-LISTEN:9666,reuseaddr,fork EXEC:bash,stderr,setsid,sigint &
fi

exit $ret
