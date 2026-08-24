<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Content-Type: application/json; charset=UTF-8");
require_once 'db.php';

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['order_id'])) {
    $order_id = mysqli_real_escape_string($conn, $data['order_id']);
    $status = "Completed"; 

    $sql = "UPDATE order_form SET status = '$status' WHERE order_id = '$order_id'";
    
    if (mysqli_query($conn, $sql)) {
        echo json_encode(["status" => "success", "message" => "Order updated successfully."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Database error."]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Missing order ID."]);
}
?>