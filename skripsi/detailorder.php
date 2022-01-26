<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $ordernum = $_POST['order_number'];

    $checkdata = "SELECT a .*, b .image, c .prod_name 
                    FROM outlet_a .product_cart a
                    INNER JOIN sgs_konsolidasi .fotoproduk b ON a .prod_number = b .prod_number
                    INNER JOIN sgs_konsolidasi .product_info c ON a .prod_number = c .prod_number
                    WHERE order_number ='$ordernum'";
    $result = mysqli_query($db, $checkdata);
    $count = mysqli_num_rows($result);

    while($row = mysqli_fetch_assoc($result)){
        $response[] = $row;
    }
    echo json_encode($response);
}

?>