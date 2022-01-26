<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $checkdata = "SELECT * FROM sgs_konsolidasi .user_help";
    $result = mysqli_query($db, $checkdata);
    $count = mysqli_num_rows($result);

    while($row = mysqli_fetch_assoc($result)){
        $response[] = $row;
    }
    echo json_encode($response);
}

?>