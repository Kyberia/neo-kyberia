<?php

//loading smarty template engine and setting main parameters
require_once(SMARTY_DIR.'Smarty.class.php');
$smarty = new Smarty;

$smarty->default_resource_type=SMARTY_RESOURCE;
//$smarty->default_resource_type='file';

$smarty->settemplate_dir(SMARTY_TEMPLATE_DIR);
$smarty->setcompile_dir(SMARTY_TEMPLATEC_DIR);
$smarty->setcache_dir(SMARTY_DIR.'cache/');
$smarty->setplugins_dir(SMARTY_PLUGIN_DIR);
//$smarty->config_dir = SMARTY_DIR.'configs/'; //XXX neexistuje

$smarty->debugging = true; // XXX tmp


?>
