<?php
include_once 'config.php';


$response = array();
$user_email = $_POST["user_email"];
$num_str = sprintf("%06d", mt_rand(1, 999999));
$defaultpass = md5($num_str);


$sql = "SELECT * FROM user_info WHERE user_email = '".$user_email."'";
$update = "UPDATE user_info SET user_password = '".$defaultpass."' WHERE user_email = '".$user_email."'";
$result = mysqli_query($db, $sql);
$count = mysqli_num_rows($result);
$row = mysqli_fetch_array($result);

    
$to       = $user_email;
$subject  = 'Forgot Password';
$message  = "Hi, your new password is <b>".$num_str."</b>!";
$headers  = 'From: sgsapplicationtester@gmail.com' . "\r\n" .
            'MIME-Version: 1.0' . "\r\n" .
            'Content-type: text/html; charset=utf-8';

if ($count == 1) {
    $response['message'] = "Success";
    $response['value'] = '1';
    mail($to, $subject, $message, $headers);
    mysqli_query($db, $update);
    echo json_encode($response);
} else {
    $response['message'] = "Email tidak terdaftar di sistem";
    $response['value'] = '0';
    echo json_encode($response);
}
