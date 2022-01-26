<?php

include 'config.php';

    if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $checkdata = "SELECT * FROM outlet_a .order_log WHERE order_status_id >= 3 AND order_status_id <= 10 
        ORDER BY order_status_id, order_date DESC";
    $result = mysqli_query($db, $checkdata);
    $count = mysqli_num_rows($result);

    while($row = mysqli_fetch_assoc($result)){
        $response[] = $row;
    }
    echo json_encode($response);
}

?>