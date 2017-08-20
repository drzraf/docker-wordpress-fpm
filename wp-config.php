<?php

define('WP_SITEURL', getenv('WP_SITEURL'));
define('WP_HOME', getenv('WP_HOME') ? : getenv('WP_SITEURL'));


// the following is following: https://raw.githubusercontent.com/WordPress/WordPress/master/wp-config-sample.php

define('DB_NAME', getenv('DB_NAME'));
define('DB_USER', getenv('DB_USER'));
define('DB_PASSWORD', getenv('DB_PASSWORD'));
define('DB_HOST', getenv('DB_HOST'));
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

define('AUTH_KEY',         'hieJ8yib');
define('SECURE_AUTH_KEY',  'iiZ5iel6');
define('LOGGED_IN_KEY',    'Iuvoo2si');
define('NONCE_KEY',        'Iek4uuCu');
define('AUTH_SALT',        'xei4paeN');
define('SECURE_AUTH_SALT', 'Chi5aed7');
define('LOGGED_IN_SALT',   'iJaePh2t');
define('NONCE_SALT',       'och9Eihu');

$table_prefix  = 'wp_';

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
  $_SERVER['HTTPS'] = 'on';
}

require_once(ABSPATH . 'wp-settings.php');
