<?php
// All pgsql dependent code should go here
// Split into multiple files if needed

// All injection-related security checks should be done here.

class nodes {

// Called for every node view. Updates node views, neurons, 
// DO NOT MESS WITH THIS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// creating neural network
public static function update_nodes($user_id="",$node_id="",$referer_id="") {
	global $db,$error;

	// XXX sec (parameter binding?)
	
	// update node statistics
	if (!is_numeric($node_id)) {
                $error=$error_messages['NUMERIC_NOT_NUMERIC'];
		return false;
        }
	$db->query("update nodes set node_views=node_views+1 where ".
		     "node_id='".$node_id."'");
	// XXX PDO

// XXX TODO later
// need to decide upon "neurons" format, levenstein, statistics informations, etc
	
//	// update neurons
//	if (is_numeric($referer_id) && ($referer_id)) {
//		$q="update neurons set synapse=synapse+1 where ".
//		    "dst='".$node_id."' and src='$referer_id'";
//		$result=$db->update($q);
//		if (!$result) {
//			if (!is_numeric($user_id)) {
//				$error=$error_messages['NUMERIC_NOT_NUMERIC'];
//				 return false;
//			}	
//			$q="insert into neurons set synapse_creator='".
//			   $user_id."',dst='".$node_id.
//			   "',src='$referer_id',synapse=1";
//			$db->query($q);
//		}
//	}
//
//	// LEVENSHTEIN
//	// these 4 lines are not the source of kyberia lagging problems.
//	// leave them. started on the 10.4. XXX
//	// data gained will be used for scientific purposes
//	if (is_numeric($user_id) && $user_id) {
//	        $q="insert delayed into levenshtein set user_id='".
//		    $user_id."',node_id='".$node_id."'";
//	        $db->update($q);
//	}
}


// just test to display node content
public static function get_node_content($node_id="") {
	global $db,$error;

	$state = $db->prepare("SELECT node_content FROM nodes where node_id=:node_id");
	$state->execute(array('node_id' => $node_id));
	//foreach (($state) as $row) { print "$row[0]\n"; }
	return $state;
}

public static function get_node_by_id($node_id, $user_id) {
	global $db, $error;

	$node_id = intval($node_id);
	$user_id = intval($user_id);

	$state = $db->prepare("select n.node_id
                       , n.node_name
                       , n.node_parent
                       , n.node_external_access
                       , n.node_system_access
                       , n.node_children_count
                       , n.node_creator
                       , n.node_creator as node_owner_id
                       , u.login as owner
                       , u.login as node_creator_name
                       , n.node_created
                       , n.lastchild_created
                       , n.k
                       , n.node_views
                       , n.node_descendant_count
                       , n.lastdescendant_created
                       , n.template_id
                       , n.node_updated
                       , n.external_link
                       , n.node_content
                       , n.nl2br
                       , na.node_bookmark
                       , na.node_permission
                       , na.node_user_subchild_count
                       , na.last_visit
                       , na.visits
                       , na.bookmark_category
                       , na.given_k
                       , np.node_name as node_parent_name
                  from nodes n
                  left join users u on u.user_id = n.node_creator
                  left join nodes np on np.node_id = n.node_parent
                  left join node_access na on na.node_id = n.node_id
                                          and na.user_id = :user_id
                  where n.node_id = :node_id");
	$state->execute(array(':node_id' => $node_id, ':user_id' => $user_id));

	$node = $state->fetchAll();
	return $node;
}


} // class nodes
?>
