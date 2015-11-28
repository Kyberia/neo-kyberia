<?php
	/* Database init.
	   Include to use.
	*/

	$dsn = DB_TYPE.':dbname='.DB_NAME.';host='.DB_HOST.';port='.DB_PORT;
	$user = DB_USER;
	$password = DB_PASS;
	$db = null;	

	try {
		$db = new PDO($dsn, $user, $password);
	} catch (PDOException $e) {
		die( 'Connection to backend failed: ' . $e->getMessage());
	}
?>
