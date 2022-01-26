<?php 

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST"){
    $response = array();

    $user_fullname = $_POST['user_fullname'];
    $user_phone = $_POST['user_phone'];
    $user_email = $_POST['user_email'];
    $user_name = $_POST['user_name'];
    $user_password = md5($_POST['user_password']);
    $tgl_lahir = $_POST['tgl_lahir'];
    $usernumber = rand(1111111111,9999999999);
    $nik1 = substr($user_phone, - 4);
    $nik2 = str_replace("-", "", $tgl_lahir);

    $cekuser = "SELECT * FROM user_info WHERE user_name = '$user_name'";
    $result = mysqli_fetch_array(mysqli_query($db, $cekuser));

    if(isset($result)){
        $response['value'] = '2';
        $response['message'] = 'Username telah digunakan!';
        echo json_encode($response);
    }else{
        
        $insert = "INSERT INTO user_info VALUE(NULL, '$usernumber', '$nik1$nik2', 
        '$user_fullname', '$user_phone', '$user_email', '$user_name', '$user_password', '11', 
        '1', '0', '941', '6', '$tgl_lahir', NOW())";

        if(mysqli_query($db, $insert)){
            $response['value'] = '1';
            $response['message'] = 'Berhasil Registrasi!';
            echo json_encode($response);
        }else{
            $response['value'] = '0';
            $response['message'] = 'Register Gagal!';
            echo json_encode($response);
        }
    }
}

?>