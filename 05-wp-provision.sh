#!/bin/bash

# This is a sample to do some WordPress provisioning
# Any extending container could put here the stuff to run at container startup,

if [[ -n "$VERBOSE" ]]; then
    set -vx
    # exec 1> >(tee /tmp/log /dev/stdout)
    # exec 2> >(tee /tmp/log /dev/stderr)
fi

WP_PLUGIN_DIR="${WP_CORE_DIR:-/var/www/wordpress}/web/app/plugins"

cd "${WP_CORE_DIR:-/var/www/wordpress}"

waitforplugin() {
    while [[ "$(wp plugin get "$1" --field=status --format=csv)" != active ]]; do
	sleep 1;
    done
}

remver() {
    WP_PLUGINS=$(sed -r "s/${1}:[^ ]*/${1}/" <<<"$WP_PLUGINS")
}

remplugin() {
    WP_PLUGINS=$(sed -r "s/${1}(:[^ ]*)?//" <<<"$WP_PLUGINS")
}

# echo "date.timezone = Europe/Paris" | tee /usr/local/etc/php/conf.d/test.ini
if [[ "$WP_PLUGINS" =~ advanced-custom-fields-pro: ]]; then
    VERSION=$(sed -r '/advanced-custom-fields-pro:/s/.*advanced-custom-fields-pro:([^ $]+).*/\1/' <<<"$WP_PLUGINS")
    DIR="$WP_PLUGIN_DIR/advanced-custom-fields-pro"

    mkdir -p "$DIR"
    curl -SL "https://github.com/wp-premium/advanced-custom-fields-pro/archive//refs/tags/v${VERSION:-6.2.0}.tar.gz" | tar --strip-components=1 -C "$DIR" -zxf -
    remver advanced-custom-fields-pro
fi

if [[ "$WP_PLUGINS" =~ gravityforms: ]]; then
    VERSION=$(sed -r '/gravityforms:/s/.*gravityforms:([^ $]+).*/\1/' <<<"$WP_PLUGINS")
    DIR="$WP_PLUGIN_DIR/gravityforms"

    mkdir -p "$DIR"
    curl -SL "https://github.com/wp-premium/gravityforms/archive/refs/tags/${VERSION:-2.4.20}.tar.gz" | tar --strip-components=1 -C "$DIR" -zxf -
    remver gravityforms
fi

if [[ "$WP_PLUGINS" =~ wordpress-importer ]]; then
    GIT_TRACE_FSMONITOR=1 GIT_TRACE=2 git clone -b upstream-sleep https://github.com/drzraf/WordPress-Importer "$WP_PLUGIN_DIR/WordPress-Importer"
    exec 1> >(tee /tmp/log /dev/stdout); exec 2> >(tee /tmp/log /dev/stderr)
    wp plugin activate WordPress-Importer
    remplugin wordpress-importer
fi

if [[ -n "$WP_PLUGINS" ]]; then
    wp plugin install $WP_PLUGINS --activate
    wp plugin activate $WP_PLUGINS
fi

# Initialize ~/.wp-cli/packages directory
wp package update

let ret=0
if [[ -n "$WP_SCRIPT" ]]; then
    bash <<<"$WP_SCRIPT"
    ret=$?
fi

exit $ret

# wp core config XXX=yyy
# wp import --authors=skip data.xml
