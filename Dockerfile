FROM wordpress:php5.6-fpm-alpine
LABEL maintainer "Raphaël Droz <raphael.droz@gmail.com>"

# perl-xml-xpath currently absent
RUN apk add --no-cache git unzip subversion jq libxslt wget make mysql-client less bash su-exec

ENV WP_CLI_VERSION 1.3.0
ENV COMPOSER_VERSION 1.5.1
ENV PHPUNIT_VERSION 6.3.0

# composer/behat/phpunit/phpcs part
RUN    curl -sSLo /usr/local/bin/composer https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar \
    && chmod 755 /usr/local/bin/composer \
    && curl -sSLo /usr/local/bin/wp https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar \
    && chmod 755 /usr/local/bin/wp \
    && curl -sSLo /usr/local/bin/phpunit https://phar.phpunit.de/phpunit-${PHPUNIT_VERSION}.phar \
    && chmod 755 /usr/local/bin/phpunit

# RUN mkdir /tmp/wordpress && curl -s https://wordpress.org/latest.tar.gz | tar --strip-components=1 -C /tmp/wordpress/ -zxm
RUN ln -s /usr/src/wordpress /tmp/wordpress

ADD 00-wp-reinstall-if-needed.sh /usr/local/bin/wordpress-reinstall-if-needed
ADD 05-wp-provision.sh /usr/local/bin/wordpress-provision
RUN chmod +x /usr/local/bin/*

COPY wp-config.php /usr/src/wordpress/

CMD wordpress-reinstall-if-needed.sh && wordpress-provision && exec php-fpm
