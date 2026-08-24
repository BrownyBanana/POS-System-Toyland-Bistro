<?php
// Include db connection and start session
include 'db.php';
session_start();

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Escape user inputs to prevent SQL injection
    $product_name = mysqli_real_escape_string($conn, $_POST['product_name']);
    $publish_date = mysqli_real_escape_string($conn, $_POST['publish_date']);
    $expiration_date = mysqli_real_escape_string($conn, $_POST['expiration_date']);
    $ingredients_json = mysqli_real_escape_string($conn, $_POST['ingredients_json']);
    $product_price = mysqli_real_escape_string($conn, $_POST['product_price']);
    // stock_status is optional as per your design
    $stock_status = isset($_POST['stock_status']) ? mysqli_real_escape_string($conn, $_POST['stock_status']) : '';
    
    // Optional: for renaming the product and reflecting in the products table
    $new_product_name = isset($_POST['new_product_name']) ? mysqli_real_escape_string($conn, $_POST['new_product_name']) : '';

    $final_product_name = $product_name;

    // Check if renaming is required and modify products table
    if (!empty($new_product_name) && $new_product_name !== $product_name) {
        $final_product_name = $new_product_name;
        
        $update_products = "UPDATE products SET product_name = '$new_product_name' WHERE product_name = '$product_name'";
        mysqli_query($conn, $update_products);
        
        $update_inv_name = "UPDATE inventory SET product_name = '$new_product_name' WHERE product_name = '$product_name'";
        mysqli_query($conn, $update_inv_name);
    }

    // Prepare the update query for inventory table
    $sql = "UPDATE inventory 
            SET ingredients = '$ingredients_json', 
                publish_date = '$publish_date', 
                expiration_date = '$expiration_date',
                product_price = '$product_price',
                stock_status = '$stock_status'
            WHERE product_name = '$final_product_name'";

    // Execute query and handle redirect/error
    if (mysqli_query($conn, $sql)) {
        header("Location: inventory.php?success=updated");
        exit();
    } else {
        echo "Error: " . mysqli_error($conn);
    }
}
?>