<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $ordernum = $_POST['order_number'];
    $suratjalan = $_POST['suratjalan'];

    $checkdata = "SELECT * FROM outlet_a .purchase_log
                    WHERE purchase_number = '$ordernum'";
    $productpurchase = "SELECT SUM(prod_unit_price * prod_request_quantity) `total` FROM outlet_a .product_purchase a 
                    LEFT JOIN sgs_konsolidasi .product_info b ON a .prod_number = b .prod_number
                    WHERE purchase_number ='$ordernum'";

    $result = mysqli_query($db, $checkdata);
    $total = mysqli_query($db, $productpurchase);
    $hitungproduk = mysqli_query($db, $storestocklog);
    $count = mysqli_num_rows($result);
    $row = mysqli_fetch_array($result);
    $data = mysqli_fetch_array($total); 
	$trans_date = $row['purchase_order_date'];
    $user_number = $row['user_number'];
    $trans_value = $data['total'];
    $randnum = substr($ordernum,3 ,5);
    $randnum2 = rand(111111,999999);  
    $trans_number = $randnum.$randnum2;

    $update = "UPDATE outlet_a .purchase_log SET purchase_status_id = 3, surat_jalan = 
        '$suratjalan', purchase_delivery_date = DATE(NOW()) WHERE purchase_number = '$ordernum'";
    $insert = "INSERT INTO outlet_a .transaction_log VALUES ('$trans_number', '$trans_date', '1', '1', ''
        , '$user_number', 'MB', 0, 0, '$trans_value', '$ordernum', NOW())";
    $insertstocklog = "INSERT INTO outlet_a .store_stock_log 
        SELECT '', 0, a .prod_number, '$trans_number', 1, b. stock_quantity, prod_request_quantity, NOW(), '', NOW()
        FROM outlet_a .product_purchase a
        LEFT JOIN outlet_a .store_stock b ON a .prod_number = b .prod_number
        WHERE purchase_number = '$ordernum'";
    $updatestock = "UPDATE outlet_a .store_stock ss, outlet_a .product_purchase pp
        SET ss .stock_quantity = ss .stock_quantity + pp .prod_request_quantity
        WHERE ss . prod_number = pp .prod_number AND pp .purchase_number = '$ordernum'";

    if($count == 0){
        $response['value'] = '0';
        $response['message'] = 'Gagal!';
        echo json_encode($response);
    }else{
        mysqli_query($db, $update);
        mysqli_query($db, $insert);
        mysqli_query($db, $insertstocklog);
        mysqli_query($db, $updatestock);
        $response['value'] = '1';
        $response['message'] = 'Berhasil Terima Produk!';
        echo json_encode($response);
    }
}

?>