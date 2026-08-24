<?php
include 'db.php';
session_start();

date_default_timezone_set('Asia/Manila');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $order_id       = $_POST['order_id'];
    $customer_name  = $_POST['customer_name'];
    $product_sold   = $_POST['product_sold'];
    $cash_amount    = floatval($_POST['cash_amount']);
    $total_amount   = floatval($_POST['total_amount']);
    $change_amount  = floatval($_POST['change_amount']);
    
    $payment_method = strtolower($_POST['payment_method']); 
    $gcash_reference = isset($_POST['gcash_reference']) ? $_POST['gcash_reference'] : '';
    
    $transaction_id = "TRNS-" . strtoupper(substr(md5(time()), 0, 8));
    $order_date     = date('Y-m-d H:i:s');
    $status         = "Completed"; 

    $reg_order = mysqli_prepare($conn, "INSERT IGNORE INTO order_form (order_id, customer_name, order_date) VALUES (?, ?, ?)");
    mysqli_stmt_bind_param($reg_order, "sss", $order_id, $customer_name, $order_date);
    mysqli_stmt_execute($reg_order);

    $sql = "INSERT INTO sales (
                order_id, 
                transaction_id, 
                customer_name, 
                order_date, 
                product_sold, 
                total_amount, 
                change_amount, 
                payment_method, 
                cash_amount, 
                status,
                gcash_reference
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    $stmt = mysqli_prepare($conn, $sql);

    if ($stmt) {
        mysqli_stmt_bind_param($stmt, "sssssddssds", 
            $order_id, 
            $transaction_id, 
            $customer_name, 
            $order_date, 
            $product_sold, 
            $total_amount, 
            $change_amount, 
            $payment_method, 
            $cash_amount, 
            $status,
            $gcash_reference
        );

        if (mysqli_stmt_execute($stmt)) {
            echo "Success";
        } else {
            echo "Database Error: " . mysqli_error($conn);
        }
    } else {
        echo "Prepare Error: " . mysqli_error($conn);
    }
}
?>