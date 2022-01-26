<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $user_number = $_POST['user_number'];

    $checkdata = "SELECT * FROM outlet_a .product_cart WHERE user_number = '$user_number'
    AND order_number = ''";
    $result = mysqli_query($db, $checkdata);
    $count = mysqli_num_rows($result);

    $ordernum1 = substr($user_number, 0 , 2);
    $ordernum2 = date('my');
    $ordernum3 = rand(1111,9999);  
    $ordernum = 'ORD/'.$ordernum2.'-'.$ordernum3;

    $update = "UPDATE outlet_a .product_cart SET order_number = '$ordernum' 
        WHERE order_number = '' AND user_number = '$user_number'";

    $insert = "INSERT INTO outlet_a .order_log VALUE('$ordernum', DATE(NOW()) , '$user_number',
        '', '1','','', '', '', '', '', NOW())";
    
    if ($count == 0){
        $response['value'] = '0';
        $response['message'] = 'Tidak Ada Produk di Keranjang!';
        echo json_encode($response);
    }else{
        mysqli_query($db, $update);
        mysqli_query($db, $insert);
        $response['value'] = '1';
        $response['message'] = 'Berhasil Checkout!';
        echo json_encode($response);
    }
}

?>
