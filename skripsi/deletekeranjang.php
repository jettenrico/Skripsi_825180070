<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $user_number = $_POST['user_number'];
    $prod_number = $_POST['prod_number'];

    $checkdata = "SELECT * FROM outlet_a .product_cart WHERE prod_number = '$prod_number' 
        AND user_number = '$user_number' AND order_number = ''";
    $result = mysqli_query($db, $checkdata);
    $count = mysqli_num_rows($result);

    $delete = "DELETE from outlet_a .product_cart WHERE prod_number = 
        '$prod_number' AND user_number = '$user_number' AND order_number =''";  
    
    if ($count == 0){
        $response['value'] = '0';
        $response['message'] = 'Tidak ada Produk!';
        echo json_encode($response);
    }else{
        mysqli_query($db, $delete);
        $response['value'] = '1';
        $response['message'] = 'Berhasil Delete Keranjang!';
        echo json_encode($response);
    }
}

?>
