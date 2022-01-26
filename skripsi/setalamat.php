<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $ordernum = $_POST['order_number'];
    $lat = $_POST['lat'];
    $long = $_POST['long'];

    $checkdata = "SELECT * FROM outlet_a .order_log WHERE order_number ='$ordernum'";
    $result = mysqli_query($db, $checkdata);
    $count = mysqli_num_rows($result);
    
    $update = "UPDATE outlet_a .order_log SET latitude = '$lat', longitude = '$long'
        WHERE order_number = '$ordernum'";

    if ($count == 0){
        $response['value'] = '0';
        $response['message'] = 'GAGAL!';
        echo json_encode($response);
    }else{
        mysqli_query($db, $update);
        $response['value'] = '1';
        $response['message'] = 'Berhasil!';
        echo json_encode($response);
    }
}

?>
