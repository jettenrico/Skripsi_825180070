<?php

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $response = array();

    $order_number = $_POST['order_number'];
    $sales_number = $_POST['sales_number'];

    $checkdata = "SELECT * FROM outlet_a .order_log WHERE order_number = '$order_number'";
    $value = "SELECT SUM(prod_unit_price * qty) `total` FROM outlet_a .product_cart a 
            LEFT JOIN sgs_konsolidasi .product_info b ON a .prod_number = b .prod_number
            WHERE order_number ='$order_number'";

    $result = mysqli_query($db, $checkdata);
    $total = mysqli_query($db, $value);
    $count = mysqli_num_rows($result);
    
    $row = mysqli_fetch_array($result);
    $data = mysqli_fetch_array($total); 
    
    $randnum = substr($order_number,4 ,6);
    $randnum2 = rand(111111,999999);  
    $trans_number = $randnum.$randnum2;
    $trans_date = $row['order_date'];
    $user_number = $row['user_number'];
    $trans_value = $data['total'];

    $proses = "UPDATE  outlet_a .order_log SET order_status_id = '4'
        WHERE order_number = '$order_number'";
    $insert = "INSERT INTO outlet_a .transaction_log VALUES ('$trans_number', '$trans_date', '2', '1', '$user_number'
        , '$sales_number', 'MB', 0, 0, '$trans_value', '$order_number', NOW())";
    $insertstocklog = "INSERT INTO outlet_a .store_stock_log 
        SELECT '', 0, a .prod_number, '$trans_number', 2, b. stock_quantity, qty, NOW(), '', NOW()
        FROM outlet_a .product_cart a
        LEFT JOIN outlet_a .store_stock b ON a .prod_number = b .prod_number
        WHERE order_number = '$order_number'";
    $updatestock = "UPDATE outlet_a .store_stock ss, outlet_a .product_cart pc
        SET ss .stock_quantity = ss .stock_quantity - pc .qty
        WHERE ss . prod_number = pc .prod_number AND pc .order_number = '$order_number'";
    
    if ($count == 0){
        $response['value'] = '0';
        $response['message'] = 'Proses order gagal!';
        echo json_encode($response);
    }else{
        mysqli_query($db, $proses);
        mysqli_query($db, $insert);
        mysqli_query($db, $insertstocklog);
        mysqli_query($db, $updatestock);
        $response['value'] = '1';
        $response['message'] = 'Proses order sukses!';
        echo json_encode($response);
    }
}

?>
