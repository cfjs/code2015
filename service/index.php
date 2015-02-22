<?php
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
header("Last-Modified: ".gmdate("D, d M Y H:i:s")." GMT");
header("Cache-Control: no-cache, must-revalidate");
header("Pragma: no-cache");
header("Content-Type:application/json");

$keywords = $_GET['keywords'];
$year_start = $_GET['year_start'];
$year_end = $_GET['year_end'];

// Implement paging instead!
$limit = 5000;

if (!$keywords) {
 $keyword = "";
}

if (!$year_start) {
 $year_start = "0";
}

if (!$year_end) {
 $year_end = "9999";
}

$escaped_keywords =pg_escape_string($keywords);

$sql = "select DISTINCT (select row_to_json(row) from (select  array_agg(a.id) as ids, array_agg(a.type) as types, " 
     . "array_agg(a.name)as names, array_agg(a.award) as awards, array_agg(a.fiscal_year) as fiscal_years) row)::varchar as students, " 
     . "sum(a.award) as awards, gi.\"returned address\" as address, a.institution, "
     . "ST_AsGeoJSON(gi.geom)::varchar as geo from awards a, "
     . "geocoded_institutions gi WHERE gi.\"original address\" = a.institution AND a.fiscal_year >= {$year_start} "
     . "AND a.fiscal_year <= {$year_end}" 
     . " AND (a.keywords ilike '%{$escaped_keywords}%' OR a.title ilike '%{$escaped_keywords}%' OR a.summary ilike '%{$escaped_keywords}%') GROUP BY gi.\"returned address\", a.institution, gi.geom LIMIT {$limit}";

error_log($sql);

$dbconn = pg_connect("host=localhost port=5432 dbname=postgres user=postgres password=ClashOfClans2015");
$result = pg_query($dbconn, $sql);
if (!$result) {
  echo "An error occurred.\n";
  exit;
}

$geojson = new stdClass();
$geojson->type = "FeatureCollection";

$data = array();

while ($row = pg_fetch_assoc($result)) {
   $line = new stdClass();
   $line->type = "Feature";

   $line->geometry = json_decode($row['geo']);

   $line->properties = new stdClass();
   $line->properties->name = $row['institution'];
   $line->properties->address = $row['address'];
   $line->properties->awards = $row['awards'];
   $students = json_decode($row['students']);
   //var_dump($students);

   $student_ids = array_values($students->ids);
   $student_types = array_values($students->types);
   $student_names = array_values($students->names);
   $student_awards = array_values($students->awards);   
   $student_years = array_values($students->fiscal_years);

   $records = array();
   foreach($student_ids as $key=>$value) {

     $rec = new stdClass(); 
     $rec->id = $student_ids[$key];
     $rec->type = $student_types[$key];
     $rec->name = $student_names[$key];
     $rec->award = $student_awards[$key];
     $rec->fiscal_year = $student_years[$key];
 
     $records[] = $rec;
   }
   $line->properties->students = $records;

   $data[] = $line;
}

$geojson->features = $data;
die(json_encode($geojson));

?>
