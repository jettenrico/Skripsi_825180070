<?php

    include_once 'config.php';

    $result = $db->query("SELECT a .prod_name, a .prod_number, FORMAT(a. prod_base_price, 'N') AS prod_base_price, b .image, b .color, c .brand_name, d .stock_quantity `stock`,
	case when e .qty is null then 0
	else e .qty end `terjual`
        FROM sgs_konsolidasi .product_info a
        INNER JOIN sgs_konsolidasi .fotoproduk b ON a .prod_number = b .prod_number
        INNER JOIN sgs_konsolidasi .brand c ON a .brand_id = c .brand_id
        INNER JOIN outlet_a .store_stock d ON a .prod_number = d .prod_number
        left join outlet_a .product_cart e on a .prod_number = e .prod_number
        left join outlet_a .transaction_log f on e .order_number = f .purchase_number
        GROUP BY a .prod_number 
        ORDER BY brand_name, prod_name
    ");

    $list = array();

    if($result){
        while ($row = mysqli_fetch_assoc($result)){
            $list[] = $row;
        }
        echo json_encode($list);
    }
