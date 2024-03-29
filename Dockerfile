FROM alpine:3.18

# php:8-fpm-alpine
# + https://github.com/drzraf/ui-autotesting/blob/master/alpine-php8/Dockerfile
# + https://github.com/johnpbloch/phpfpm-images/blob/master/images/7.2/Dockerfile
# + https://raw.githubusercontent.com/10up/wp-local-docker-images/master/phpfpm/7.2/Dockerfile

ARG DIR_ACF="${WP_CORE_DIR:-/var/www/wordpress}/web/app/plugins/advanced-custom-fields-pro"
ARG DIR_GF="${WP_CORE_DIR:-/var/www/wordpress}/web/app/plugins/gravityforms"

ADD https://packages.whatwedo.ch/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub
RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories

# Note: no php-imagick
RUN apk add --no-cache less bash wget curl git make sed nano jq xz zip subversion yarn mariadb-client ssmtp patch socat su-exec sudo nginx nginx-mod-http-perl fping \
    php82 \
    php82-ctype \
    php82-curl \
    php82-dom \
    php82-fpm \
    php82-gd \
    php82-iconv \
    php82-json \
    php82-mbstring \
    php82-mysqli \
    php82-openssl \
    php82-pdo_mysql \
    php82-pdo_sqlite \
    php82-pecl-xdebug \
    php82-phar \
    php82-session \
    php82-simplexml \
    php82-soap \
    php82-tokenizer \
    php82-xml \
    php82-xmlreader \
    php82-xmlwriter \
    php82-zip \
    php8-pecl-pcov \
    && curl -sSLo /usr/local/bin/phpunit https://phar.phpunit.de/phpunit-10.1.2.phar \
    && curl -sSLo /usr/local/bin/composer https://getcomposer.org/download/2.5.5/composer.phar \
    && curl -sSLo /usr/local/bin/phpcs https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar \
    && curl -sSLo /usr/local/bin/phpcbf https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar \
    && curl -sSLo /usr/local/bin/wp https://github.com/wp-cli/wp-cli/releases/download/v2.8.1/wp-cli-2.8.1.phar \
    && curl -sSLo /usr/local/bin/behat https://github.com/Behat/Behat/releases/download/v3.13.0/behat.phar \
    && chmod 755 /usr/local/bin/*

RUN mkdir -p "${WP_CORE_DIR:-/var/www/wordpress}" \
    && composer create-project roots/bedrock "${WP_CORE_DIR:-/var/www/wordpress}" \
    && composer --working-dir="${WP_CORE_DIR:-/var/www/wordpress}" require wpackagist-plugin/timber-library \
    && mkdir -p "$DIR_ACF" "$DIR_GF" \
    && curl -sL "https://github.com/wp-premium/advanced-custom-fields-pro/archive/${VERSION:-5.8.1}.tar.gz" | tar --strip-components=1 -C "$DIR_ACF" -zxf - \
    && curl -sL "https://github.com/wp-premium/gravityforms/archive/${VERSION:-2.4.10}.tar.gz" | tar --strip-components=1 -C "$DIR_GF" -zxf - \
    && rm -rf /var/cache/apk/*

RUN sed -i -e '/include.*modules/ienv WP_BACKEND_HOSTNAME;' /etc/nginx/nginx.conf && mkdir -p /run/nginx

COPY php-fpm.conf /etc/php82/php-fpm.d/zz-docker.conf
COPY nginx-default.conf /etc/nginx/conf.d/default.conf
COPY 00-wait-for-hosts.sh /usr/local/bin/wait-for-hosts
COPY 02-remote-logger.sh /usr/local/bin/remote-logger
COPY 04-wp-reinstall-if-needed.sh /usr/local/bin/wordpress-reinstall-if-needed
COPY 05-wp-provision.sh /usr/local/bin/wordpress-provision

CMD wordpress-reinstall-if-needed && wordpress-provision && nginx && exec php-fpm7

# Don't EXPOSE port because GitLab would wait for them before setting-up other
# services that *we* need to before listening.

ENTRYPOINT ["/bin/bash", "-c"]
