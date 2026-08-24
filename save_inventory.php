<?php
// Include db connection and start session
include 'db.php';
session_start();

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // FIXED: product_id is optional for adding new items from cohesive files. This is added code to cohesive file only.
    $product_id = isset($_POST['product_id']) ? mysqli_real_escape_string($conn, $_POST['product_id']) : '';
    $category = isset($_POST['category']) ? mysqli_real_escape_string($conn, $_POST['category']) : 'Snacks';
    $product_name = isset($_POST['product_name']) ? mysqli_real_escape_string($conn, $_POST['product_name']) : '';
    $product_price = isset($_POST['product_price']) ? mysqli_real_escape_string($conn, $_POST['product_price']) : '0';
    $product_quantity = isset($_POST['product_quantity']) ? mysqli_real_escape_string($conn, $_POST['product_quantity']) : '1';
    
    $stock_status = "Available"; // Set default status for new item or updated record. Everything from start to end.

    // ADDED: Added code for added ingredient feature in original ORDER FORM visual. Fetch added price. This is added code to cohesive files.
    // Map visual categories to database category IDs. Everything from start to finish.
    $categoryMap = [
        "Snacks" => 1,
        "Pizza and Pasta" => 2,
        "Ramen" => 3,
        "Rice Meals With Drinks" => 4,
        "Rice Bowl Meals" => 5,
        "Frappes" => 6,
        "Berry Smoothies" => 7,
        "Non - Coffee" => 8,
        "Refreshers" => 9,
        "Espresso" => 10
    ];
    $category_id = isset($categoryMap[$category]) ? $categoryMap[$category] : 1;

    $imagePath = ""; // Default empty, handle visual update only
    if (isset($_FILES["product_image"]) && $_FILES["product_image"]["error"] == 0) {
        $targetDir = "uploads/";
        if (!file_exists($targetDir)) mkdir($targetDir, 0777, true);
        $fileName = time() . "_" . basename($_FILES["product_image"]["name"]);
        $targetFilePath = $targetDir . $fileName;
        if (move_uploaded_file($_FILES["product_image"]["tmp_name"], $targetFilePath)) {
            $imagePath = $targetFilePath;
        }
    }

    // Unified update logic for both tables. Everything from start to finish.
    if (!empty($product_id)) {
        // Update inventory record
        $invUpdate = "UPDATE inventory SET category = '$category', product_name = '$product_name', product_price = '$product_price', product_quantity = '$product_quantity' WHERE product_id = '$product_id'";
        mysqli_query($conn, $invUpdate);

        // Update product record based on product_name (data mismatch fix, but architecture constraint from files)
        $imgUpdate = ($imagePath !== "") ? ", product_image = '$imagePath'" : "";
        $prodUpdate = "UPDATE products SET category_id = '$category_id', price = '$product_price' $imgUpdate WHERE product_name = '$product_name'";
        mysqli_query($conn, $prodUpdate);
    } else {
        // ADD NEW record to both tables
        // Add to inventory
        $invInsert = "INSERT INTO inventory (product_name, category, product_quantity, product_price, stock_status) VALUES ('$product_name', '$category', '$product_quantity', '$product_price', '$stock_status')";
        mysqli_query($conn, $invInsert);

        // Add to products
        if ($imagePath === "") $imagePath = "images/default.png"; // Set default for no image
        $prodInsert = "INSERT INTO products (product_name, category_id, price, product_image, status) VALUES ('$product_name', '$category_id', '$product_price', '$imagePath', 1)";
        mysqli_query($conn, $prodInsert);
    }
    
    header("Location: inventory.php?success=saved");
    exit();
}
?>