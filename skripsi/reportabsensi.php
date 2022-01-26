<?php

include_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {

    $bulan = $_POST['bulan'];
    $bln = "";
    if ($bulan == "Januari") {
        $bln = "1";
    } else if ($bulan == "Februari") {
        $bln = "2";
    } else if ($bulan == "Maret") {
        $bln = "3";
    } else if ($bulan == "April") {
        $bln = "4";
    } else if ($bulan == "Mei") {
        $bln = "5";
    } else if ($bulan == "Juni") {
        $bln = "6";
    } else if ($bulan == "Juli") {
        $bln = "7";
    } else if ($bulan == "Agustus") {
        $bln = "8";
    } else if ($bulan == "September") {
        $bln = "9";
    } else if ($bulan == "Oktober") {
        $bln = "10";
    } else if ($bulan == "November") {
        $bln = "11";
    } else {
        $bln = '12';
    }
    $tahun = $_POST['tahun'];

    $result = $db->query("SELECT user_fullname, file_photo, date_in, TIME(a .modtime) `jam` FROM sgs_konsolidasi 
    .profil_absensi a LEFT JOIN sgs_konsolidasi .user_info b ON a .user_number = b .user_number
    WHERE MONTH(date_in) = $bln AND YEAR(date_in) = $tahun ORDER BY date_in DESC
    ");

    $list = array();

    if ($result) {
        while ($row = mysqli_fetch_assoc($result)) {
            $list[] = $row;
        }
        echo json_encode($list);
    }
}
