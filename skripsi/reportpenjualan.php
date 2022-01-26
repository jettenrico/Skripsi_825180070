<?php

    include_once 'config.php';

    if ($_SERVER['REQUEST_METHOD'] == "POST") {

    $bulan = $_POST['bulan'];
    $bln = "";
    if($bulan == "Januari"){
        $bln = "1";
    }else if($bulan == "Februari"){
        $bln = "2";
    }else if($bulan == "Maret"){
        $bln = "3";
    }else if($bulan == "April"){
        $bln = "4";
    }else if($bulan == "Mei"){
        $bln = "5";
    }else if($bulan == "Juni"){
        $bln = "6";
    }else if($bulan == "Juli"){
        $bln = "7";
    }else if($bulan == "Agustus"){
        $bln = "8";
    }else if($bulan == "September"){
        $bln = "9";
    }else if($bulan == "Oktober"){
        $bln = "10";
    }else if($bulan == "November"){
        $bln = "11";
    }else {
        $bln = '12';
    }
    $tahun = $_POST['tahun'];
    $tipetrans = $_POST ['tipetrans'];
    $type = "";
    if($tipetrans == "Purchase Order"){
        $type = "1";
    }else if ($tipetrans == "Sales Order"){
        $type = "2";
    }

    $result = $db->query("SELECT trans_number, DATE(trans_date)`tanggaltransaksi`, trans_total_price, purchase_number,
    CASE WHEN
    trans_type_id = '2' THEN 'Penjualan'
    ELSE 'Pemesanan' END `transaksi`,
    CASE WHEN
    trans_type_id = '2' THEN b .user_fullname
    ELSE '-' END `customer`,
    c .user_fullname `sales`
    FROM outlet_a .transaction_log a
    LEFT JOIN sgs_konsolidasi .user_info b ON a .cust_number = b .user_number
    LEFT JOIN sgs_konsolidasi .user_info c ON a .employee_number = c .user_number
    WHERE MONTH(trans_date) = $bln AND YEAR(trans_date) = $tahun AND trans_type_id = $type
    GROUP BY trans_number ORDER BY `transaksi`, `tanggaltransaksi` DESC
    ");

    $list = array();

    if($result){
        while ($row = mysqli_fetch_assoc($result)){
            $list[] = $row;
        }
        echo json_encode($list);
    }
}
