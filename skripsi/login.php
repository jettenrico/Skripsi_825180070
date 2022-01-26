<?php 
	include_once 'config.php';

	$response = array();
	$username = $_POST["username"];
	$password = $_POST["password"];

	$sql = "SELECT * FROM user_info WHERE user_name = '".$username."' AND user_password = '".$password."'";
//	$sql = "SELECT * FROM user_info WHERE user_name = 'test_login_123' AND user_password = '123456'";
	$result = mysqli_query($db,$sql);
	$count = mysqli_num_rows($result);
	$row = mysqli_fetch_array($result);
	$value = $row['user_type_id'];

	if ($count == 1) {
		if ($value == 11){
			$response['tipeuser']="Customer";	
			$response['message']="Success";
			$response['user_fullname']=$row['user_fullname'];
			$response['user_email']=$row['user_email'];
			$response['user_phone']=$row['user_phone'];
			$response['user_number']=$row['user_number'];
			$response['user_nik']=$row['user_nik'];
			echo json_encode($response);
		}else if ($value == 3){
			$response['tipeuser']="BA";
			$response['message']="Success";
			$response['user_fullname']=$row['user_fullname'];
			$response['user_email']=$row['user_email'];
			$response['user_phone']=$row['user_phone'];
			$response['user_number']=$row['user_number'];
			$response['user_nik']=$row['user_nik'];
			echo json_encode($response);
		}else{
			$response['tipeuser']="Principle";
			$response['message']="Success";
			$response['user_fullname']=$row['user_fullname'];
			$response['user_email']=$row['user_email'];
			$response['user_phone']=$row['user_phone'];
			$response['user_number']=$row['user_number'];
			$response['user_nik']=$row['user_nik'];
			echo json_encode($response);
		}
	}else{
		$response['message']="Failed";
		echo json_encode($response);
	}

?>