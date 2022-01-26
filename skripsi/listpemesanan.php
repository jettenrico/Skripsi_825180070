<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $purchase_number = $_POST['purchase_number'];

    $checkdata = "SELECT a .*, b .image FROM outlet_a .product_purchase a
        INNER JOIN sgs_konsolidasi .fotoproduk b ON a .prod_number = b .prod_number                    
        WHERE purchase_number ='$purchase_number'";
    $result = mysqli_query($db, $checkdata);
    $count = mysqli_num_rows($result);

    while($row = mysqli_fetch_assoc($result)){
        $response[] = $row;
    }
    echo json_encode($response);
}

?>