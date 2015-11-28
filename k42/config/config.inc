<?php
// Default kyberia configuration file.
// All system-dependent settings should go here

// This runs kyberia on localhost with single database.

define('DB_TYPE',		'pgsql');	// mysql of pgsql
define('DB_HOST',		'localhost');
define('DB_PORT',		'5432');
define('DB_USER',		'kyberia');
define('DB_PASS',		'vivatpicat');
define('DB_NAME',		'kyberia42');
date_default_timezone_set(	'Europe/Prague');

define('SYSTEM_URL',		'localhost:80');
define('SYSTEM_SMTP',		'127.0.0.1');
define('SYSTEM_EMAIL',		'admin@127.0.0.1');
define('SYSTEM_EMAIL_NAME',	'Ubik osobne');
define('DEFAULT_LISTING_ORDER',	'desc');


define('SYSTEM_ROOT',		'/var/www/k42/');

define('SYSTEM_DATA',		SYSTEM_ROOT . 'wwwroot/_data/');
define('SYSTEM_IMAGES',		SYSTEM_ROOT . 'wwwroot/_images/');
define('CONFIG_DIR',		SYSTEM_ROOT . 'config/');
define('INCLUDE_DIR',		SYSTEM_ROOT . 'inc/');
define('BACKEND_DIR',		SYSTEM_ROOT . 'backend/');
define('SMARTY_RESOURCE',	'file');//kyberia
define('SMARTY_DIR',		INCLUDE_DIR . 'smarty/libs/');
define('SMARTY_PLUGIN_DIR',	INCLUDE_DIR . 'smarty/node_methodz/');
define('SMARTY_TEMPLATE_DIR',	INCLUDE_DIR . 'smarty/templates/');
define('SMARTY_TEMPLATEC_DIR',	INCLUDE_DIR . 'smarty/templates_c/');

define('TMP',			SYSTEM_DATA . 'tmp/');
define('FILE_DIR',		SYSTEM_DATA . 'files/');
define('CLASS_DIR',		INCLUDE_DIR . 'class/');
define('EVENT_DIR',		INCLUDE_DIR . 'eventz/');
//define('TRANSPORT_DIR',		INCLUDE_DIR . 'transports/');

// Kyberia senate specific settings (special node numbers, ...
require_once(CONFIG_DIR.'senate.inc')
?>
