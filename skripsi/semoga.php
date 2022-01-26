<?php 
  include_once 'config.php';

  //connecting to database server

  $val = isset($_POST["user_name"]) && isset($_POST["user_password"]);

  if($val){
       //checking if there is POST data
    
       $userfull_name = $_POST["user_fullname"];
       $user_email = $_POST["user_email"];
       $user_name = $_POST["user_name"]; 
       $user_password = $_POST["user_password"];
       $tgl_lahir = $_POST["tgl_lahir"];
       $user_phone = $_POST["user_phone"];

       //validation name if there is no error before
       if($return["error"] == false && strlen($user_name) < 3){
           $return["error"] = true;
           $return["message"] = "Enter name up to 3 characters.";
       }

       //add more validations here

       //if there is no any error then ready for database write
       if($return["error"] == false){
            $userfull_name = mysqli_real_escape_string($db, $userfull_name);
            $user_email = mysqli_real_escape_string($db, $user_email);
            $user_name = mysqli_real_escape_string($db, $user_name);
            $user_password = mysqli_real_escape_string($db, $user_password);
            $tgl_lahir = mysqli_real_escape_string($db, $tgl_lahir);
            $user_phone = mysqli_real_escape_string($db, $user_phone);

            //escape inverted comma query conflict from string

            $sql = "INSERT INTO user_info 
            SET
            user_nik = 'niktest1202',
            user_number = '01230123',
            user_fullname = '$user_name',
            user_email = '$user_email'
            user_phone = '$user_phone',
            user_name = '$user_name',
            user_password = '$user_password',
            user_type_id = '3',
            user_status = '1',
            store_id = '941',
            status_ba = '6',
            modtime = NOW();";
            //student_id is with AUTO_INCREMENT, so its value will increase automatically

            $res = mysqli_query($db, $sql);
            if($res){
                //write success
            }else{
                $return["error"] = true;
                $return["message"] = "Database error";
            }
       }
  }else{
      $return["error"] = true;
      $return["message"] = 'Send all parameters.';
  }

  mysqli_close($db); //close mysqli

  header('Content-Type: application/json');
  // tell browser that its a json data
  echo json_encode($return);
  //converting array to JSON string
?>