<?php
include 'db.php';
session_start();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $customer_name  = mysqli_real_escape_string($conn, $_POST['customer_name']);
    $payment_method = mysqli_real_escape_string($conn, $_POST['payment_method']);
    $amount_paid    = floatval($_POST['amount_paid']);
    $total_bill     = floatval($_POST['total_bill']);
    
    $amount_change = $amount_paid - $total_bill;

    if ($amount_paid < $total_bill) {
        header("Location: pos_order.php?error=insufficient_funds");
        exit();
    }

    $sales_sql = "INSERT INTO sales (
                    customer_name, 
                    total_amount, 
                    cash_amount, 
                    change_amount, 
                    payment_method, 
                    order_date
                ) VALUES (
                    '$customer_name', 
                    '$total_bill', 
                    '$amount_paid', 
                    '$amount_change', 
                    '$payment_method', 
                    NOW()
                )";
    
    if (mysqli_query($conn, $sales_sql)) {
        $order_id = mysqli_insert_id($conn);

        if (isset($_SESSION['cart']) && !empty($_SESSION['cart'])) {
            foreach ($_SESSION['cart'] as $item) {
                $p_name = mysqli_real_escape_string($conn, $item['name']);
                $p_qty  = intval($item['quantity']);

                $update_inventory = "UPDATE inventory 
                                     SET quantity = quantity - $p_qty 
                                     WHERE product_name = '$p_name'";
                
                mysqli_query($conn, $update_inventory);

                $check_stock = "UPDATE inventory 
                                SET stock_status = 'Out of Stock' 
                                WHERE product_name = '$p_name' AND quantity <= 0";
                mysqli_query($conn, $check_stock);
            }
        }

        unset($_SESSION['cart']); 
        header("Location: pos_order.php?success=1&change=" . number_format($amount_change, 2));
        exit();

    } else {
        echo "Error Processing Sale: " . mysqli_error($conn);
    }
} else {
    header("Location: pos_order.php");
    exit();
}
?>