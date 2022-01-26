<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $order_number = $_POST['order_number'];

    $checkdata = "SELECT * FROM outlet_a .order_log WHERE order_number = '$order_number'";
    $result = mysqli_query($db, $checkdata);
    $count = mysqli_num_rows($result);

    $cancel = "UPDATE  outlet_a .order_log SET order_status_id = '99'
        WHERE order_number = '$order_number'";
    
    if ($count == 0){
        $response['value'] = '0';
        $response['message'] = 'Cancel order gagal!';
        echo json_encode($response);
    }else{
        mysqli_query($db, $cancel);
        $response['value'] = '1';
        $response['message'] = 'Cancel order sukses!';
        echo json_encode($response);
    }
}

?>
