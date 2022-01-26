<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $user_number = $_POST['user_number'];
    $ordernum = $_POST['order_number'];
    $metodepembayaran = $_POST['metode_pembayaran'];
    $metodeorder = $_POST['metode_order'];
    $detail_alamat = $_POST['detail_alamat'];

    $checkdata = "SELECT * FROM outlet_a .order_log WHERE order_number ='$ordernum' AND 
    user_number ='$user_number'";
    $result = mysqli_query($db, $checkdata);
    $count = mysqli_num_rows($result);
    
    $update = "UPDATE outlet_a .order_log SET ispickup = '$metodeorder', metode_pembayaran = 
        '$metodepembayaran', order_status_id = '2', detail_alamat = '$detail_alamat'
        WHERE order_number = '$ordernum' AND user_number = '$user_number'";

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
