<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $user_number = $_POST['user_number'];
    $prod_number = $_POST['prod_number'];
    $order_number = $_POST['order_number'];
    $review = $_POST['review'];

    $checkdata = "SELECT * FROM outlet_a .product_review WHERE order_number = '$order_number' 
        AND prod_number = '$prod_number'";
    $result = mysqli_query($db, $checkdata);
    $count = mysqli_num_rows($result);

    $insert = "INSERT INTO outlet_a .product_review VALUES('', '$user_number', '$order_number',
         '$prod_number', '$review')";

    
    if ($count == 0){
        mysqli_query($db, $insert);
        $response['value'] = '1';
        $response['message'] = 'Berhasil Review Produk!';
        echo json_encode($response);
    }else{
        $response['value'] = '0';
        $response['message'] = 'Produk telah direview!';
        echo json_encode($response);
    }
}

?>