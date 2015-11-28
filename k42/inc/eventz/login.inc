<?php

XXX rewrite

function login() {
	global $db,$error,$node_id;

	if ((!isset($_POST['login'])) or (!isset($_POST['password'])) or (!isset($_POST['login_type']))) {
		$error="Da fuq?"
		return false;
	}

	$login = $_POST['login'];
	$password = $_POST['password'];
	$login_type = $_POST['login_type'];


	$login = db_escape_string($login);  //XXX
	//Not SQLi in $password but be carefull
	$password_hash_algos=array('sha256','sha1','md5'); 
	//List of supported algos can be obtained using: php -r 'print_r(hash_algos());'

	$hash_query='(';
	foreach($password_hash_algos as $algo) {
		$hash_query.="password='".hash($algo, $password)."' OR ";
	}
	$hash_query.='false )';

	$referer = $_SERVER['HTTP_REFERER'];

	if (!session_id()) {
		$error='asi nemas zapnute cookies alebo co';
		return false;
	}

	// XXX do backendu
	switch ($login_type) {
		case "name":
			$q = "select * from users where login='$login' and $hash_query";
			break;
		case "id":
			$login=intval($login); //HA! if it is number, escape_string is not enough
			$q="select * from users where user_id='$login' and $hash_query";
			break;
	}

	$set = $db->query($q);
	$resultat=$set->fetch(PDO::FETCH_ASSOC);
	$user_id = $resultat["user_id"];
	$user_name = $resultat["login"];
//	$xmpp = strtolower($resultat["xmpp"]);

    if (!$set) { //XXX test
        $error="Zadal si nespravne uzivatelske meno [alebo id] alebo heslo. Rob so sebou nieco";
        return false;
    }
    elseif ($resultat["hash"]) {
        $error='Tvoja registracia este nebola schvalena.';
        return false;
    }
    else {
        $now=date("Y-m-d H:i:s");
        $lockout=$resultat["acc_lockout"];
        if ($lockout >= $now ) {
            $error="Account lockout mas aktivny. Sorry ale neprihlasis sa minimalne do $lockout.
Prajem prijemnu odvykacku:-)";
            return false;
        }

//	Login sucessfull

	// prevent session fixation
	session_regenerate_id(); 

        $cube_vector=$resultat["cube_vector"];

// XXX one big (backend) SQL query, and then save one by one

        // saves friends list as an array into user session
        $q="select distinct node_parent,node_name from nodes where node_creator='$user_id' and
external_link='session://friend' order by node_parent";
        $friendset=$db->query($q);
        while ($resultat=$friendset->fetch(PDO::FETCH_ASSOC)){
            $_SESSION['friends'][$resultat["node_parent"]]=true;
        }

        // saves bookmarks as an array into user session
        $q="select nodes.node_name,nodes.node_id from node_access left join nodes on node_access.node_id=nodes.node_id
where node_access.user_id='$user_id' and node_bookmark='yes' order by node_name";
        $bookmarkset=$db->query($q);
        while ($resultat=$bookmarkset->fetch(PDO::FETCH_ASSOC)){
            $_SESSION['bookmarks'][$resultat["node_id"]]=$resultat["node_name"];
        }

// ignored + fooked => weights?

        //saves ignored users as an array into user session
        $q="select node_parent from nodes where node_creator='$user_id' and external_link='session://ignore'";
        $ignoreset=$db->query($q);
        while ($resultat=$ignoreset->fetch(PDO::FETCH_ASSOC)){
            $_SESSION['ignore'][$resultat["node_parent"]]=true;
        }

        //saves fooked forums as an array into user session
        $q="select node_parent from nodes where node_creator='$user_id' and external_link='session://fook'";
        $fookset=$db->query($q);
        while ($resultat=$fookset->fetch(PDO::FETCH_ASSOC)){
            $_SESSION['fook'][$resultat["node_parent"]]=true;
        }


        //save bookstyle into user session
//        $q="select node_content from nodes where node_parent=19 and external_link='session://bookstyl' and node_creator='$user_id'";
//        $bookstylset=$db->query($q);
//        $resultat=$bookstylset->fetch(PDO::FETCH_ASSOC);
//        $_SESSION['bookstyl'] = $resultat["node_content"];

        // mood
//        $mset = $db->query(sprintf('select moods from users where user_id = %d', $user_id));
//        $resultat=$mset->fetch(PDO::FETCH_ASSOC);
//        $moods_expl = explode(";",$resultat["moods"]);
//        if (!empty($moods_expl[count($moods_expl)-1])) {
//            $_SESSION['mood_id'] = $moods_expl[count($moods_expl)-1];
//            $mset = $db->query(sprintf('select node_name, node_content from nodes where node_id = %d', $moods_expl[count($moods_expl)-1]));
//            $resultat=$mset->fetch(PDO::FETCH_ASSOC);
//            $_SESSION['mood_name'] = $resultat["node_name"];
//            $_SESSION['mood_content'] = addslashes(substr(strip_tags($resultat["node_content"]),0,223));
//        }
        // last login

//backend
	$db->query(sprintf('update users set date_last_login = NOW() where user_id = %d', $user_id));

        $_SESSION['user_id']=$user_id;
        $_SESSION['user_name']=addslashes($user_name); // XXX addslashes?

        if (!empty($cube_vector)) $_SESSION['cube_vector']=$cube_vector;
        if (empty($_SESSION['template_set'])) $_SESSION['template_set']=$resultat["template_set"];
        if (!empty($_POST['screen_width']) && is_numeric($_POST['screen_width'])) 
		{ $_SESSION['browser']['screen_width']=$_POST['screen_width']; }
        if (!empty($_POST['screen_height']) && is_numeric($_POST['screen_height'])) 
		{ $_SESSION['browser']['screen_height']=$_POST['screen_height']; }
        $_SESSION['listing_amount']=$resultat["listing_amount"];
        $_SESSION['listing_order']=$resultat["listing_order"];
        $_SESSION['header_id']=$resultat["header_id"];
    }
//    header("Location: $referer");
    return true;
}



}
