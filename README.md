Building a docker base image for a provisionable WordPress ([Docker Hub](https://hub.docker.com/r/drzraf/wp-fpm/)]

* based on [wordpress:php5.6-fpm-alpine](https://github.com/docker-library/wordpress/blob/master/php5.6/fpm-alpine/Dockerfile) (WordPress + PHP 5.6 / Alpine Linux)
* composer + [wp-cli](https://wp-cli.org/) + [phpunit](https://phpunit.de/)
* xpath, xsltproc, jq, svn, git, unzip & make
* [wordpress-test-suite](https://develop.svn.wordpress.org/trunk/)