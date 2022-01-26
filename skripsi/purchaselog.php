<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $user_number = $_POST['user_number'];

    $checkdata = "SELECT * FROM outlet_a .product_purchase WHERE user_number = '$user_number'
        AND purchase_number = ''";
    $result = mysqli_query($db, $checkdata);
    $count = mysqli_num_rows($result);

    $ordernum1 = substr($user_number, -2);
    $ordernum2 = date('my');
    $ordernum3 = rand(11,99);  
    $ordernum = 'PO/'.$ordernum1.$ordernum3.'-'.$ordernum2;

    $update = "UPDATE outlet_a .product_purchase SET purchase_number = '$ordernum' 
        WHERE purchase_number = '' AND user_number = '$user_number'";

    $insert = "INSERT INTO outlet_a .purchase_log VALUE('$ordernum', DATE(NOW()), '', '', '', 
        '$user_number','', 'MB', 2, 1, NOW(), 'Y')";
    
    if ($count == 0){
        $response['value'] = '0';
        $response['message'] = 'Tidak Ada Produk!';
        echo json_encode($response);
    }else{
        mysqli_query($db, $update);
        mysqli_query($db, $insert);
        $response['value'] = '1';
        $response['message'] = 'Berhasil Pesan!';
        echo json_encode($response);
    }
}

?>
