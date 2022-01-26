<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $user_number = $_POST['user_number'];
    $prod_number = $_POST['prod_number'];
    $prod_price = $_POST['prod_price'];
    $qty = $_POST['qty'];
    $harga = number_format($prod_price);

    $checkdata = "SELECT * FROM outlet_a .product_cart WHERE prod_number = '$prod_number' 
        AND user_number = '$user_number' AND order_number = ''";
    $result = mysqli_query($db, $checkdata);
    $count = mysqli_num_rows($result);

    $insert = "INSERT INTO outlet_a .product_cart VALUE(NULL, '', '$user_number', '', 
        '$prod_number', '$harga', '$qty', DATE(NOW()))";
    $update = "UPDATE outlet_a .product_cart SET qty = '$qty' WHERE prod_number = 
        '$prod_number' AND user_number = '$user_number'";
    
    if ($count == 0){
        mysqli_query($db, $insert);
        $response['value'] = '1';
        $response['message'] = 'Berhasil Tambah Keranjang!';
        echo json_encode($response);
    }else{
        mysqli_query($db, $update);
        $response['value'] = '0';
        $response['message'] = 'Berhasil Update Keranjang!';
        echo json_encode($response);
    }
}

?>