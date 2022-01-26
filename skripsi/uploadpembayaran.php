<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $ordernum = $_POST['order_num'];

    $image   = str_replace(" ", "", basename($_FILES['buktibayar']['name']));
    $imagePath = 'fotopembayaran/' . $image;
    move_uploaded_file($_FILES['buktibayar']['tmp_name'], $imagePath);

    $checkpayment = "SELECT * FROM outlet_a .order_log WHERE order_number = '$ordernum'";
    $result = mysqli_query($db, $checkpayment);
    $count = mysqli_num_rows($result);

    $insertbukti = "UPDATE `outlet_a`.`order_log` SET `buktibayar`='$image' 
    , `order_status_id` = 3 WHERE `order_number`='$ordernum'";

    if ($count == 0) {
        $response['value'] = 0;
        $response['message'] = "Nomor Order Salah!";
        echo json_encode($response);
    } else {
        mysqli_query($db, $insertbukti);
        $response['value'] = 1;
        $response['message'] = "Berhasil Simpan";
        echo json_encode($response);
    }
}

?>