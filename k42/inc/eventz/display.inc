<?php
/* 
   display event

   Most frequently used event, so make it as fast as possible.

*/

$node_content='';
$content2=nodes::get_node_content($node_id);
$node=nodes::get_node_by_id($node_id,0);

print_r($node);

foreach ($content2 as $row) { $node_content.="$row[0]\n"; }
//print_r($node_content);
$smarty->assign('node_content',$node_content);

$content .= $smarty->fetch($template_id . '.tpl');


// $node_content= ($_SESSION['header_id'].".tpl")
//$node_content=  $node_content
//foreach (($node_content) as $row) { print "$row[0]\n"; }


?>
