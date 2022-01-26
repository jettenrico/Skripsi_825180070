<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $user_number = $_POST['user_number'];

    $checkdata = "SELECT a .*, b .image, c .prod_name 
                    FROM outlet_a .product_cart a
                    INNER JOIN sgs_konsolidasi .fotoproduk b ON a .prod_number = b .prod_number
                    INNER JOIN sgs_konsolidasi .product_info c ON a .prod_number = c .prod_number
                    WHERE user_number = '$user_number' and order_number =''";
    $result = mysqli_query($db, $checkdata);
    $count = mysqli_num_rows($result);

    while($row = mysqli_fetch_assoc($result)){
        $response[] = $row;
    }
    echo json_encode($response);
}

?>