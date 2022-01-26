<?php

    include_once 'config.php';

    $result = $db->query("SELECT b .prod_number, d .prod_name, FORMAT(d. prod_base_price, 'N')`prod_base_price`, e .brand_name, b .image, b .color, SUM(a .qty)`terjual`, f .stock_quantity `stock` 
        FROM outlet_a .product_cart a
        INNER JOIN sgs_konsolidasi .fotoproduk b ON a .prod_number = b .prod_number
        INNER JOIN sgs_konsolidasi .product_info d ON a .prod_number = d .prod_number
        INNER JOIN outlet_a .order_log c ON a .order_number = c .order_number
        INNER JOIN outlet_a .brand e ON d .brand_id = e .brand_id
        INNER JOIN outlet_a .store_stock f ON a .prod_number = f .prod_number
        WHERE c .order_status_id IN (4,5)
        GROUP BY b .prod_number ORDER BY `terjual` DESC LIMIT 10
    ");

    $list = array();

    if($result){
        while ($row = mysqli_fetch_assoc($result)){
            $list[] = $row;
        }
        echo json_encode($list);
    }

?>
