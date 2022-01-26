<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $user_number = $_POST['user_number'];
    $user_email = $_POST['user_email'];
    $user_pass = $_POST['pass'];
    $user_phone = $_POST['phone'];

    $checkabsen = "SELECT * FROM user_info WHERE user_number = '".$user_number."'";
    $result = mysqli_query($db, $checkabsen);
    $count = mysqli_num_rows($result);

    $updateprofil = "UPDATE `sgs_konsolidasi`.`user_info` SET                
    `user_email`='$user_email', `user_phone` = '$user_phone',  
    `user_password` = '$user_pass' WHERE `user_number`='$user_number'";

    if ($count == 0) {
        $response['value'] = 0;
        $response['message'] = "data tidak ada";
        echo json_encode($response);
    } else {
        mysqli_query($db, $updateprofil);
        $response['value'] = 1;
        $response['message'] = "Berhasil update";
        echo json_encode($response);
    }
}

?>