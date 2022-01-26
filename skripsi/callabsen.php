<?php 
	include_once 'config.php';

	$response = array();
    $user_number = $_POST["user_number"];
	$tglabsen = $_POST["absenmasuk"];

	$sql = "SELECT * FROM profil_absensi WHERE user_number = '$user_number' AND date_in = '$tglabsen'";
	// $sql = "SELECT * FROM profil_absensi WHERE user_number = '1287721135' AND date_in ='2021-11-14'";
	$result = mysqli_query($db,$sql);
	$count = mysqli_num_rows($result);
	$row = mysqli_fetch_array($result);

	echo json_encode($row['file_photo']);
?>