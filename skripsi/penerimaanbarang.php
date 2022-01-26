<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $user_number = $_POST['user_number'];

    $checkdata = "SELECT * FROM outlet_a .purchase_log WHERE user_number = '$user_number'
        ORDER BY purchase_status_id, purchase_order_date DESC";
    $result = mysqli_query($db, $checkdata);
    $count = mysqli_num_rows($result);

    while($row = mysqli_fetch_assoc($result)){
        $response[] = $row;
    }
    echo json_encode($response);
}

?>