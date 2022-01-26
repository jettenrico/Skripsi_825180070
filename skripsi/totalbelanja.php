<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $ordernum = $_POST['order_num'];

    $checkdata = "SELECT * FROM outlet_a .product_cart 
                    WHERE order_number = '$ordernum'";
    $result = mysqli_query($db, $checkdata);

    $status = "SELECT * FROM outlet_a .order_log WHERE order_number = '$ordernum'";
    $count = mysqli_num_rows($result);

    while($row = mysqli_fetch_assoc($result)){
        $response[] = $row;
    }
    echo json_encode($response);
}

?>