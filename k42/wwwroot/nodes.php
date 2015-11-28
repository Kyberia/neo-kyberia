<?php

// starting timer for benchmarking purposes
$timer_start = Time() + SubStr(MicroTime(), 0, 8);

session_start();

// main config file with constants
require_once('../config/config.inc');
// error messges
require_once(INCLUDE_DIR.'error.inc');
// create a global PDO object $db
require_once(INCLUDE_DIR.'database.inc');
// database specific code ( all the SQL/whatever queries )
require_once(BACKEND_DIR.'/'.DB_TYPE.'/backend.inc');


// set default node id if not specified
if (!empty($_GET['node_id'])) {
	$node_id=$_GET['node_id'];
	if (!is_numeric($node_id)) {
		$node_id=DEFAULT_NODE_ID;
	}
} else {
	$node_id=DEFAULT_NODE_ID;
}

if (!empty($_GET['template_id'])) {
	$template_id=$_GET['template_id'];
	if (!is_numeric($template_id)) {
		$template_id=false;
	}
} else {
	// get template_id from node settings later
	$template_id=false;
}

// /search, /name, /id and others to be done.


// default event is display
if (empty($_POST['event'])) {
	// sec. check bypass, display is too common and available to everyone
	$event='display';
} else {
	// preg_replace prevents LFI (whitelist)
	$event= preg_replace( "![^a-zA-Z0-9_]+!", "", $_POST['event']);
	// check permissions for calling event itself
	if (eventz_perm_check() != 0)  {
		// XXX TODO 
		// errr, exit
		//return E_PERM;
	}
}

$user_id = isset($_SESSION['user_id'])?$_SESSION['user_id']:false;

$template_id=4; //XXX

//initializing node
//$node = nodes::getNodeById($_GET['node_id'],(isset($_SESSION['user_id']))?$_SESSION['user_id']:'');


// perform event itself
// permission are checked inside each event

////checking permissions
//include_once(BACKEND_DIR.'/'.DB_TYPE.'/permissions.inc');
//$permissions=permissions::checkPerms($node);
//if (!empty($_SESSION['debugging']) && $_SESSION['debugging']) {
//        print_r($permissions);
//}

$content='';

// smarty init XXX tu?
require_once(INCLUDE_DIR.'smarty.inc');

//XXX ktore z toho su nutne?
// assigning user data to smarty if user logged in (user_id not 0)
if ($user_id) {
	$smarty->assign('user_id',	$user_id);
	$smarty->assign('book',		isset($_SESSION['book'])	? $_SESSION['book']		:'');
	$smarty->assign('bookmarks',	isset($_SESSION['book'])	? $_SESSION['book']		:'');
	$smarty->assign('ignore',	isset($_SESSION['ignore'])	? $_SESSION['ignore']		:'');
	$smarty->assign('ignore_mail',	isset($_SESSION['ignore_mail'])	? $_SESSION['ignore_mail']	:'');
//	$smarty->assign('bookstyl',	isset($_SESSION['bookstyl'])	? $_SESSION['bookstyl']		:'');
	$smarty->assign('fook',		isset($_SESSION['fook'])	? $_SESSION['fook']		:'');
	$smarty->assign('mail_notify',	isset($_SESSION['mail_notify'])	? $_SESSION['mail_notify']	:'');
	$smarty->assign('friend',	isset($_SESSION['friend'])	? $_SESSION['friend']		:'');
	$smarty->assign('friends',	isset($_SESSION['friend'])	? $_SESSION['friend']		:'');
	$smarty->assign('anticsrf',	isset($_SESSION['anticsrf'])	? $_SESSION['anticsrf']		:NULL);

	$smarty->assign('_POST',	isset($_POST)			? $_POST			:''); //XXX
        $smarty->assign('cube_vector',	$_SESSION['cube_vector']);

//    $new_mail = $newmailset->getInt('user_mail');
//    if ($new_mail > 0)
//        $smarty->assign('new_mail',  $new_mail);
//    $smarty->assign('new_mail_name', $newmailset->getString('mail_sender'));
//    $smarty->assign('user_k',        $newmailset->getInt('user_k'));
//    $smarty->assign('k_wallet',      $newmailset->getInt('k_wallet'));
}


error_log("LOG: event: $event, node_id: $node_id, template_id: $template_id");
require_once(INCLUDE_DIR."eventz/$event.inc");


// Event is executed, now get $referer_id 
$referer_id="";
if (preg_match('/id\/(\d+)/',isset($_SERVER['HTTP_REFERER'])? $_SERVER['HTTP_REFERER'] : "",$match)) {
	$referer_id=$match[1];
} elseif (preg_match('/name\/(.*?)\/?$/',isset($_SERVER['HTTP_REFERER'])? $_SERVER['HTTP_REFERER'] : "",$match)) {
	$referer_id  = nodes::getNodeIdByName($match[1]);
}
// creating neural network + updating node counters
nodes::update_nodes(isset($_SESSION['user_id'])? $_SESSION['user_id'] : "",$node_id,$referer_id);


$time = substr((Time() + substr(MicroTime(), 0, 8) - $timer_start), 0, 7);
$smarty->assign('generation_time', $time);

echo $content;
// end of displaying

?>
