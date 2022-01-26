<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $prod_number = $_POST['prod_number'];

    $checkdata = "SELECT user_fullname, review, order_date
        FROM outlet_a .product_review a 
        INNER JOIN outlet_a .user_info b ON a .user_number = b .user_number
        INNER JOIN outlet_a .order_log c ON a .order_number = c .order_number
        WHERE prod_number = '$prod_number'";
        
    $result = mysqli_query($db, $checkdata);
    $count = mysqli_num_rows($result);

    while($row = mysqli_fetch_assoc($result)){
        $response[] = $row;
    }
    echo json_encode($response);
}

?>