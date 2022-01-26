<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $order_number = $_POST['order_number'];

    $checkdata = "SELECT * FROM outlet_a .order_log WHERE order_number = '$order_number'";
    $result = mysqli_query($db, $checkdata);
    $count = mysqli_num_rows($result);

    $proses = "UPDATE  outlet_a .order_log SET order_status_id = '5'
        WHERE order_number = '$order_number'";
    
    if ($count == 0){
        $response['value'] = '0';
        $response['message'] = 'Proses order gagal!';
        echo json_encode($response);
    }else{
        mysqli_query($db, $proses);
        $response['value'] = '1';
        $response['message'] = 'Proses order sukses!';
        echo json_encode($response);
    }
}

?>
