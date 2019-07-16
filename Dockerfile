FROM alpine:3.10

# php:7-fpm-alpine
# + https://github.com/drzraf/ui-autotesting/blob/master/alpine-php7/Dockerfile
# + https://github.com/johnpbloch/phpfpm-images/blob/master/images/7.2/Dockerfile
# + https://raw.githubusercontent.com/10up/wp-local-docker-images/master/phpfpm/7.2/Dockerfile

ARG DIR_ACF="${WP_CORE_DIR:-/var/www/wordpress}/web/app/plugins/advanced-custom-fields-pro"
ARG DIR_GF="${WP_CORE_DIR:-/var/www/wordpress}/web/app/plugins/gravityforms"

# Note: no php-imagick
RUN apk add --no-cache less bash wget curl git make sed \
               php7 php7-fpm php7-curl php7-openssl php7-iconv php7-mbstring php7-json php7-dom php7-mysqli php7-gd php7-soap \
               php7-xdebug php7-ctype php7-phar php7-simplexml php7-tokenizer php7-xml php7-xmlreader php7-xmlwriter \
               nano jq xz zip subversion yarn mariadb-client ssmtp patch socat su-exec sudo \
               nginx nginx-mod-http-perl \
    && curl -sSLo /usr/local/bin/phpunit https://phar.phpunit.de/phpunit-8.1.6.phar \
    && curl -sSLo /usr/local/bin/composer https://getcomposer.org/download/1.8.6/composer.phar \
    && curl -sSLo /usr/local/bin/phpcs https://github.com/squizlabs/PHP_CodeSniffer/releases/download/3.4.2/phpcs.phar \
    && curl -sSLo /usr/local/bin/phpcbf https://github.com/squizlabs/PHP_CodeSniffer/releases/download/3.4.2/phpcbf.phar \
    && curl -sSLo /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && curl -sSLo /usr/local/bin/behat https://github.com/Behat/Behat/releases/download/v3.3.0/behat.phar \
    && chmod 755 /usr/local/bin/*

RUN mkdir -p "${WP_CORE_DIR:-/var/www/wordpress}" \
    && composer create-project roots/bedrock "${WP_CORE_DIR:-/var/www/wordpress}" \
    && composer --working-dir="${WP_CORE_DIR:-/var/www/wordpress}" require wpackagist-plugin/timber-library \
    && mkdir -p "$DIR_ACF" "$DIR_GF" \
    && curl -sL "https://github.com/wp-premium/advanced-custom-fields-pro/archive/${VERSION:-5.8.1}.tar.gz" | tar --strip-components=1 -C "$DIR_ACF" -zxf - \
    && curl -sL "https://github.com/wp-premium/gravityforms/archive/${VERSION:-2.4.10}.tar.gz" | tar --strip-components=1 -C "$DIR_GF" -zxf - \
    && rm -rf /var/cache/apk/*

RUN apk add --no-cache php7-zip fping
RUN sed -i -e '/include.*modules/ienv WP_BACKEND_HOSTNAME;' /etc/nginx/nginx.conf && mkdir -p /run/nginx

COPY php-fpm.conf /etc/php7/php-fpm.d/zz-docker.conf
COPY nginx-default.conf /etc/nginx/conf.d/default.conf
COPY 00-wait-for-hosts.sh /usr/local/bin/wait-for-hosts
COPY 02-remote-logger.sh /usr/local/bin/remote-logger
COPY 04-wp-reinstall-if-needed.sh /usr/local/bin/wordpress-reinstall-if-needed
COPY 05-wp-provision.sh /usr/local/bin/wordpress-provision

CMD wordpress-reinstall-if-needed && wordpress-provision && nginx && exec php-fpm7

# Don't EXPOSE port because GitLab would wait for them before setting-up other
# services that *we* need to before listening.

ENTRYPOINT ["/bin/bash", "-c"]
