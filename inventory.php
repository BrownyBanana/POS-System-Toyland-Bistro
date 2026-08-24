<?php 
include 'db.php'; 
session_start(); 

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['delete_id'])) {
    $delete_id = mysqli_real_escape_string($conn, $_POST['delete_id']);
    
    $deleteSql = "DELETE FROM inventory WHERE product_id = '$delete_id'";
    if (mysqli_query($conn, $deleteSql)) {
        header("Location: inventory.php?success=deleted");
        exit();
    } else {
        echo "<script>alert('Error deleting product from inventory: " . mysqli_error($conn) . "');</script>";
    }
}

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['submit_ingredient'])) {
    $product_name = mysqli_real_escape_string($conn, $_POST['product_name']);
    $category = mysqli_real_escape_string($conn, $_POST['category']); 
    $ingredients_json = isset($_POST['ingredients_json']) ? mysqli_real_escape_string($conn, $_POST['ingredients_json']) : '[]';
    $product_price = isset($_POST['product_price']) ? mysqli_real_escape_string($conn, $_POST['product_price']) : '0';
    $product_quantity = isset($_POST['product_quantity']) ? mysqli_real_escape_string($conn, $_POST['product_quantity']) : '1';
    $publish_date = mysqli_real_escape_string($conn, $_POST['publish_date']);
    $expiration_date = mysqli_real_escape_string($conn, $_POST['expiration_date']);
    $new_product_name = isset($_POST['new_product_name']) ? mysqli_real_escape_string($conn, $_POST['new_product_name']) : '';
    
    $categoryMap = [
        "Snacks" => 1, "Pizza and Pasta" => 2, "Ramen" => 3, "Rice Meals With Drinks" => 4,
        "Rice Bowl Meals" => 5, "Frappes" => 6, "Berry Smoothies" => 7, "Non - Coffee" => 8,
        "Refreshers" => 9, "Espresso" => 10
    ];
    $cat_id = isset($categoryMap[$category]) ? $categoryMap[$category] : 0;
    
    $check_sql = "SELECT * FROM products WHERE product_name = '$product_name' AND category_id = '$cat_id'";
    $check_res = mysqli_query($conn, $check_sql);
    
    if (mysqli_num_rows($check_res) == 0) {
        echo "<script>alert('Invalid Action: The selected product does not belong to the chosen category.'); window.location.href='inventory.php';</script>";
        exit();
    }

    $final_product_name = $product_name;

    if (!empty($new_product_name) && $new_product_name !== $product_name) {
        $final_product_name = $new_product_name;
        mysqli_query($conn, "UPDATE products SET product_name = '$final_product_name' WHERE product_name = '$product_name'");
        mysqli_query($conn, "UPDATE inventory SET product_name = '$final_product_name' WHERE product_name = '$product_name'");
    }
    
    $stock_status = "Added"; 

    $insertSql = "INSERT INTO inventory (product_name, category, ingredients, product_quantity, product_price, stock_status, publish_date, expiration_date) 
            VALUES ('$final_product_name', '$category', '$ingredients_json', '$product_quantity', '$product_price', '$stock_status', '$publish_date', '$expiration_date')";
    
    if (mysqli_query($conn, $insertSql)) {
        mysqli_query($conn, "UPDATE products SET price = '$product_price' WHERE product_name = '$final_product_name'");
        header("Location: inventory.php");
        exit();
    } else {
        echo "<script>alert('Database Error: " . mysqli_error($conn) . "');</script>";
    }
}

$dashboard_link = (isset($_SESSION['role']) && $_SESSION['role'] === 'admin') ? "dashboard_admin.php" : "dashboard_staff.php";
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Toyland Bistro - Inventory Management</title>
    <link rel="stylesheet" href="css/inventory.css?v=2">
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@600;700;800&family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <main class="inventory-container">
        <div class="header-flex">
            <h1 class="sales-title">INVENTORY MANAGEMENT</h1>
            <div class="header-btns">
                <button class="maroon-btn" onclick="openStatusModal()"><i class="fas fa-sync-alt"></i> UPDATE STOCK STATUS</button>
                <button class="maroon-btn" onclick="openProductModal()"><i class="fas fa-plus"></i> ADD NEW PRODUCT</button>
                <button class="maroon-btn" onclick="openIngredientModal()"><i class="fas fa-carrot"></i> ADD INGREDIENT</button>
                <a href="<?= $dashboard_link ?>" class="maroon-btn" style="text-decoration:none;">DASHBOARD</a>
            </div>
        </div>
        
        <div class="table-wrapper">
            <table id="inventoryTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Product Name</th>
                        <th>Category</th>
                        <th>Ingredients</th>
                        <th>Qty</th>
                        <th>Price</th>
                        <th>Status</th>
                        <th>Publish Date</th>
                        <th>Expiration</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    $invSql = "SELECT * FROM inventory ORDER BY product_id DESC";
                    $invRes = $conn->query($invSql);
                    
                    if($invRes && $invRes->num_rows > 0) {
                        while($row = $invRes->fetch_assoc()) {
                            $ingredientsText = "None";
                            if (!empty($row['ingredients']) && $row['ingredients'] !== 'null' && $row['ingredients'] !== '[]') {
                                $decoded = json_decode($row['ingredients'], true);
                                $ingredientsText = is_array($decoded) ? implode(", ", $decoded) : $row['ingredients'];
                            }

                            $expirationDisplay = "-";
                            if (!empty($row['expiration_date'])) {
                                $expDate = new DateTime($row['expiration_date']);
                                $today = new DateTime();
                                $expDate->setTime(0,0,0);
                                $today->setTime(0,0,0);
                                $diff = $today->diff($expDate);
                                $days = (int)$diff->format('%R%a');
                                
                                if ($days > 0) {
                                    $expirationDisplay = $row['expiration_date'] . "<br><small style='color:#2e7d32;'>($days days left)</small>";
                                } elseif ($days === 0) {
                                    $expirationDisplay = $row['expiration_date'] . "<br><small style='color:#ff9800;'>(Expires Today!)</small>";
                                } else {
                                    $expirationDisplay = $row['expiration_date'] . "<br><small style='color:#f44336;'>(Expired " . abs($days) . " days ago)</small>";
                                }
                            }

                            $statusClass = 'status-available';
                            if ($row['stock_status'] === 'Low Stock') $statusClass = 'status-low';
                            if ($row['stock_status'] === 'Out of Stock') $statusClass = 'status-out';
                            if ($row['stock_status'] === 'Completed' || $row['stock_status'] === 'Updated') $statusClass = 'status-updated';
                            if ($row['stock_status'] === 'Added') $statusClass = 'status-added';

                            $rowData = htmlspecialchars(json_encode($row), ENT_QUOTES, 'UTF-8');
                            
                            echo "<tr>";
                            echo "<td>#{$row['product_id']}</td>";
                            echo "<td style='font-weight:600; color: #333;'>{$row['product_name']}</td>";
                            echo "<td>{$row['category']}</td>";
                            echo "<td><div style='max-width: 150px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;' title='{$ingredientsText}'>{$ingredientsText}</div></td>";
                            echo "<td>{$row['product_quantity']}</td>";
                            echo "<td>₱" . number_format($row['product_price'], 2) . "</td>";
                            echo "<td><span class='badge {$statusClass}'>{$row['stock_status']}</span></td>";
                            echo "<td>" . ($row['publish_date'] ?? '-') . "</td>";
                            echo "<td>{$expirationDisplay}</td>";
                            echo "<td>
                                    <div style='display: flex; gap: 8px; align-items: center;'>
                                        <button class='action-btn' onclick='editProduct({$rowData})' title='Edit'><i class='fas fa-edit'></i> Edit</button>
                                        <form action='inventory.php' method='POST' style='margin:0;'>
                                            <input type='hidden' name='delete_id' value='{$row['product_id']}'>
                                            <button type='submit' class='action-btn' style='background: #7a1d26; border-color: #7a1d26; color: white;' onclick='return confirm(\"Are you sure you want to delete this inventory record? The POS menu product will NOT be removed.\");' title='Delete'>Delete</button>
                                        </form>
                                    </div>
                                  </td>";
                            echo "</tr>";
                        }
                    } else {
                        echo "<tr><td colspan='10' class='empty-table-msg'>Inventory is empty. Add a product to get started.</td></tr>";
                    }
                    ?>
                </tbody>
            </table>
        </div>
    </main>

    <div id="productModal" class="modal-overlay" style="display:none;">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="modalTitle">Add New Product</h2>
                <span class="close-modal" onclick="closeProductModal()">&times;</span>
            </div>
            <form action="save_inventory.php" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="product_id" id="formId">
                <div class="form-group">
                    <label>Category</label>
                    <div class="custom-select-container">
                        <select name="category" id="formCategory" required>
                            <option value="" disabled selected>Select Category</option>
                            <option value="Snacks">Snacks</option>
                            <option value="Pizza and Pasta">Pizza and Pasta</option>
                            <option value="Ramen">Ramen</option>
                            <option value="Rice Meals With Drinks">Rice Meals With Drinks</option>
                            <option value="Rice Bowl Meals">Rice Bowl Meals</option>
                            <option value="Frappes">Frappes</option>
                            <option value="Berry Smoothies">Berry Smoothies</option>
                            <option value="Non - Coffee">Non - Coffee</option>
                            <option value="Refreshers">Refreshers</option>
                            <option value="Espresso">Espresso</option>
                        </select>
                        <i class="fas fa-chevron-down v-icon-only"></i>
                    </div>
                </div>
                <div class="form-group"><label>Product Name</label><input type="text" name="product_name" id="formName" placeholder="Enter Product Name" required></div>
                <div class="form-group"><label>Product Image (Optional)</label><input type="file" name="product_image" id="formImage" accept="image/*"></div>
                <div class="form-group">
                    <label>Price (₱)</label><input type="number" step="0.01" name="product_price" id="formPrice" placeholder="0.00" required>
                </div>
                <input type="hidden" name="product_quantity" id="formQty" value="1">
                <button type="submit" class="save-btn-maroon">SAVE PRODUCT</button>
            </form>
        </div>
    </div>

    <div id="statusModal" class="modal-overlay" style="display:none;">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Update Stock Status</h2>
                <span class="close-modal" onclick="closeStatusModal()">&times;</span>
            </div>
            <form action="update_status.php" method="POST">
                <div class="form-group">
                    <label>Select Category</label>
                    <div class="custom-select-container">
                        <select id="statusCategory" name="category" onchange="filterProductsByCat()" required>
                            <option value="" disabled selected>Select Category</option>
                            <option value="1">Snacks</option>
                            <option value="2">Pizza and Pasta</option>
                            <option value="3">Ramen</option>
                            <option value="4">Rice Meals With Drinks</option>
                            <option value="5">Rice Bowl Meals</option>
                            <option value="6">Frappes</option>
                            <option value="7">Berry Smoothies</option>
                            <option value="8">Non - Coffee</option>
                            <option value="9">Refreshers</option>
                            <option value="10">Espresso</option>
                        </select>
                        <i class="fas fa-chevron-down v-icon-only"></i>
                    </div>
                </div>
                <div class="form-group">
                    <label>Select Product</label>
                    <div class="custom-select-container">
                        <select id="statusProduct" name="product_name" required>
                            <option value="" disabled selected>Select Product</option>
                            <?php
                            $allProds = mysqli_query($conn, "SELECT category_id, product_name FROM products ORDER BY product_name");
                            if ($allProds) {
                                while($p = mysqli_fetch_assoc($allProds)) {
                                    echo "<option value='".htmlspecialchars($p['product_name'], ENT_QUOTES)."' data-cat='".$p['category_id']."' style='display:none;'>".htmlspecialchars($p['product_name'], ENT_QUOTES)."</option>";
                                }
                            }
                            ?>
                        </select>
                        <i class="fas fa-chevron-down v-icon-only"></i>
                    </div>
                </div>
                <div class="form-group">
                    <label>Select Status</label>
                    <div class="custom-select-container">
                        <select name="stock_status" required>
                            <option value="Available">Available</option>
                            <option value="Low Stock">Low Stock</option>
                            <option value="Out of Stock">Out of Stock</option>
                        </select>
                        <i class="fas fa-chevron-down v-icon-only"></i>
                    </div>
                </div>
                <button type="submit" class="save-btn-maroon">UPDATE STATUS</button>
            </form>
        </div>
    </div>

    <div id="ingredientModal" class="modal-overlay" style="display: none;">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Add Ingredients & Dates</h2>
                <span class="close-modal" onclick="closeIngredientModal()">&times;</span>
            </div>
            <form action="inventory.php" method="POST" onsubmit="prepareIngredients()">
                <input type="hidden" name="submit_ingredient" value="1">
                <input type="hidden" name="product_quantity" id="ingQty" value="1">
                <div class="form-group">
                    <label>Category</label>
                    <div class="custom-select-container">
                        <select name="category" id="ingCategory" onchange="filterIngProductByCat()" required>
                            <option value="" disabled selected>Select Category</option>
                            <option value="Snacks">Snacks</option>
                            <option value="Pizza and Pasta">Pizza and Pasta</option>
                            <option value="Ramen">Ramen</option>
                            <option value="Rice Meals With Drinks">Rice Meals With Drinks</option>
                            <option value="Rice Bowl Meals">Rice Bowl Meals</option>
                            <option value="Frappes">Frappes</option>
                            <option value="Berry Smoothies">Berry Smoothies</option>
                            <option value="Non - Coffee">Non - Coffee</option>
                            <option value="Refreshers">Refreshers</option>
                            <option value="Espresso">Espresso</option>
                        </select>
                        <i class="fas fa-chevron-down v-icon-only"></i>
                    </div>
                </div>
                <div class="form-group">
                    <label>Product Name</label>
                    <div class="custom-select-container">
                        <select name="product_name" id="ingProductName" required>
                            <option value="" disabled selected>Select Product</option>
                            <?php
                            $prodListSql2 = "SELECT product_name, category_id FROM products ORDER BY product_name";
                            $prodListRes2 = $conn->query($prodListSql2);
                            if($prodListRes2) {
                                while($pRow = $prodListRes2->fetch_assoc()) {
                                    echo "<option value='".htmlspecialchars($pRow['product_name'], ENT_QUOTES)."' data-cat='".$pRow['category_id']."' style='display:none;'>".htmlspecialchars($pRow['product_name'])."</option>";
                                }
                            }
                            ?>
                        </select>
                        <i class="fas fa-chevron-down v-icon-only"></i>
                    </div>
                </div>
                <div class="form-group">
                    <label>Rename Product</label>
                    <input type="text" name="new_product_name" id="ingNewProductName" placeholder="Enter Product Name">
                </div>
                <div class="form-group">
                    <label>Price (₱)</label>
                    <input type="number" step="0.01" name="product_price" id="ingPrice" placeholder="0.00" required>
                </div>
                <div class="form-group">
                    <label>Add Ingredient</label>
                    <div class="ingredient-input-wrapper">
                        <input type="text" id="ingredientInput" placeholder="e.g. 1kg Sugar" onkeypress="handleEnter(event)">
                        <button type="button" class="add-ingredient-btn" onclick="addIngredientTag()">ADD</button>
                    </div>
                    <div id="ingredientTagsContainer" class="tags-container"></div>
                </div>
                <div class="form-group" style="margin-top: 15px;">
                    <label>Publish Date</label><input type="date" name="publish_date" id="publishDate" required onclick="this.showPicker()">
                </div>
                <div class="form-group">
                    <label>Expiration Date</label><input type="date" name="expiration_date" id="expirationDate" required onchange="updateCountdown()" onclick="this.showPicker()">
                    <div id="countdownDisplay" class="countdown-text"></div>
                </div>
                <input type="hidden" name="ingredients_json" id="hiddenIngredientData">
                <button type="submit" class="save-btn-maroon">SAVE DETAILS</button>
            </form>
        </div>
    </div>
    
    <script src="js/inventory.js"></script>
</body>
</html>