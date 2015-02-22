<?php
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
header("Last-Modified: ".gmdate("D, d M Y H:i:s")." GMT");
header("Cache-Control: no-cache, must-revalidate");
header("Pragma: no-cache");
header("Content-Type:application/json");

$id = $_GET['id'];

if (!$id) {
  echo "No id provided.\n";
  exit;
}

$sql = "select DISTINCT a.data_type, a.title, a.summary from awards a WHERE a.id = {$id};";
error_log($sql);

$dbconn = pg_connect("host=localhost port=5432 dbname=postgres user=postgres password=ClashOfClans2015");
$result = pg_query($dbconn, $sql);
if (!$result) {
  echo "An error occurred.\n";
  exit;
}

while ($row = pg_fetch_assoc($result)) {
   
   $rec = new stdClass();
   $rec->data_type = $row['data_type'];
   $rec->title = $row['title'];
   $rec->summary = $row['summary'];
}

die(json_encode($rec));

?>
