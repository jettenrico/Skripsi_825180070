<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $user_number = $_POST['user_number'];
    $user_nik = $_POST['user_nik'];
    $ipuser = $_POST['ipuser'];
    $absendate = $_POST['time'];

    $image   = date('dmY') . str_replace(" ", "", basename($_FILES['file_photo']['name']));
    $imagePath = 'fotoabsen/' . $image;
    move_uploaded_file($_FILES['file_photo']['tmp_name'], $imagePath);

    $checkabsen = "select * from sgs_konsolidasi.profil_absensi where user_number='$user_number' and store_id='$store_id' and date_in='$absendate'";
    $result = mysqli_query($db, $checkabsen);
    $count = mysqli_num_rows($result);


    $insertabsen = "INSERT INTO `sgs_konsolidasi`.`profil_absensi`
    (`user_number`,`user_nik`,`store_id`,`file_photo`,`date_in`,`browser`,`modtime`, `ipuser`)
    VALUES 
    ('$user_number','$user_nik','','$image',DATE(NOW()),'',NOW(),'$ipuser')";

    $updateabsen = "UPDATE `sgs_konsolidasi`.`profil_absensi` SET                
      `file_photo`='$image' WHERE `user_number`='$user_number' and date_in='$absendate'";

    if ($count == 0) {
        mysqli_query($db, $insertabsen);
        $response['value'] = 1;
        $response['message'] = "berhasil absen";
        echo json_encode($response);
    } else {
        mysqli_query($db, $updateabsen);
        $response['value'] = 0;
        $response['message'] = "Gagal absen";
        echo json_encode($response);
    }
}

?>