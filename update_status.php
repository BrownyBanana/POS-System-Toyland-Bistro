<?php
include 'db.php';
session_start();

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $product_name = mysqli_real_escape_string($conn, $_POST['product_name']);
    $stock_status = mysqli_real_escape_string($conn, $_POST['stock_status']);

    $checkInv = mysqli_query($conn, "SELECT * FROM inventory WHERE product_name = '$product_name'");
    
    if (mysqli_num_rows($checkInv) > 0) {
        $updateInvSql = "UPDATE inventory SET stock_status = '$stock_status' WHERE product_name = '$product_name'";
        mysqli_query($conn, $updateInvSql);
    } else {
        $prodQ = mysqli_query($conn, "SELECT category_id, price FROM products WHERE product_name = '$product_name'");
        
        if (mysqli_num_rows($prodQ) > 0) {
            $prodData = mysqli_fetch_assoc($prodQ);
            $catId = $prodData['category_id'];
            $price = $prodData['price'];
            
            $categoryMap = [
                1 => "Snacks", 2 => "Pizza and Pasta", 3 => "Ramen", 4 => "Rice Meals With Drinks",
                5 => "Rice Bowl Meals", 6 => "Frappes", 7 => "Berry Smoothies", 8 => "Non - Coffee",
                9 => "Refreshers", 10 => "Espresso"
            ];
            
            $catName = isset($categoryMap[$catId]) ? $categoryMap[$catId] : "Snacks";

            $default_ingredients = "[]"; 
            $publish_date = date("Y-m-d");
            $expiration_date = date("Y-m-d", strtotime("+1 year"));

            $insertInvSql = "INSERT INTO inventory (product_name, category, ingredients, product_quantity, product_price, stock_status, publish_date, expiration_date) 
                             VALUES ('$product_name', '$catName', '$default_ingredients', 0, '$price', '$stock_status', '$publish_date', '$expiration_date')";
            mysqli_query($conn, $insertInvSql);
        }
    }
    
    header("Location: inventory.php?success=status_updated");
    exit();
} else {
    header("Location: inventory.php");
    exit();
}
?>