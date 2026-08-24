<?php 
include 'db.php'; 
session_start(); 

$dashboard_link = "login.php"; 
if (isset($_SESSION['role'])) {
    $dashboard_link = ($_SESSION['role'] === 'admin') ? "dashboard_admin.php" : "dashboard_staff.php";
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>POS Order - Toyland Bistro</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="css/pos.css">
</head>
<body class="pos-body">
    <div class="pos-container">
        <div class="pos-menu-side">
            <div id="selection-status" class="selection-status-bar" style="display:none;">SELECTION MODE ACTIVE</div>
            
            <div class="menu-header-flex">
                <h1 class="orbitron-font">Menu</h1>
                
                <div class="search-wrapper">
                    <i class="fas fa-search search-icon"></i>
                    <input type="text" id="menuSearch" placeholder="Search item..." onkeyup="filterMenu()">
                </div>

                <a href="<?= $dashboard_link ?>" class="dashboard-btn">Dashboard</a>
            </div>
            
            <div class="menu-scroll-area">
                <?php
                $categoryMap = [
                    1 => "Snacks", 2 => "Pizza and Pasta", 3 => "Ramen", 4 => "Rice Meals With Drinks",
                    5 => "Rice Bowl Meals", 6 => "Frappes", 7 => "Berry Smoothies", 8 => "Non - Coffee",
                    9 => "Refreshers", 10 => "Espresso"
                ];

                foreach ($categoryMap as $page => $catName): 
                    $catID = $page; 
                    ?>
                    <div id="page-<?= $page ?>" class="menu-page <?= ($page == 1) ? 'active' : '' ?>">
                        <h2 class="category-label"><?= $catName ?></h2>
                        <div class="horizontal-menu-row">
                            <?php
                            $sql = "SELECT p.*, i.stock_status 
                                    FROM products p 
                                    LEFT JOIN inventory i ON p.product_name = i.product_name 
                                    WHERE p.category_id = $catID AND p.status = 1 
                                    ORDER BY p.product_name ASC";
                            
                            $query = mysqli_query($conn, $sql);
                            
                            if (mysqli_num_rows($query) > 0):
                                while($item = mysqli_fetch_assoc($query)): 
                                    $status = $item['stock_status'] ?? 'Available';
                                    $isOutOfStock = ($status === 'Out of Stock');
                                    $isLowStock = ($status === 'Low Stock');
                                    
                                    $cardClass = 'menu-item-card';
                                    if ($isOutOfStock) $cardClass .= ' disabled-product';
                                    elseif ($isLowStock) $cardClass .= ' low-stock-product';
                                    
                                    $pId = $item['id'];
                                    $pName = addslashes($item['product_name']);
                                    $pPrice = $item['price'];
                                    $clickAction = $isOutOfStock ? '' : "onclick=\"addToOrder('$pId', '$pName', $pPrice)\"";

                                    $ingSql = "SELECT ingredients, product_price FROM inventory WHERE product_name = '" . mysqli_real_escape_string($conn, $item['product_name']) . "' AND stock_status IN ('Updated', 'Completed', 'Added')";
                                    $ingQuery = mysqli_query($conn, $ingSql);
                                    $ingredientButtons = "";
                                    
                                    if ($ingQuery && mysqli_num_rows($ingQuery) > 0) {
                                        while($ingRow = mysqli_fetch_assoc($ingQuery)) {
                                            $ingText = "";
                                            if (!empty($ingRow['ingredients']) && $ingRow['ingredients'] !== 'null') {
                                                $decoded = json_decode($ingRow['ingredients'], true);
                                                $ingText = (is_array($decoded) && count($decoded) > 0) ? $decoded[0] : $ingRow['ingredients'];
                                            }
                                            if ($ingText !== "None" && $ingText !== "" && !$isOutOfStock) {
                                                $ingPrice = (float)($ingRow['product_price'] ?? 0);
                                                $newPrice = $pPrice + $ingPrice;
                                                $escapedIng = addslashes($ingText);
                                                $ingredientButtons .= "<button class='temp-badge' style='background-color:#4caf50; width:auto; padding:3px 8px; font-size:10px; border-radius:10px; margin-top:5px;' onclick=\"event.stopPropagation(); addToOrder('{$pId}_ing', '{$pName} w/ {$escapedIng}', {$newPrice})\">+ {$ingText} (₱{$ingPrice})</button>";
                                            }
                                        }
                                    }
                                    ?>

                                    <div class="<?= $cardClass ?>" <?= $clickAction ?>>
                                        <?php if($isOutOfStock): ?>
                                            <div class="out-of-stock-label">OUT OF STOCK</div>
                                        <?php elseif($isLowStock): ?>
                                            <div class="low-stock-label">LOW STOCK</div>
                                        <?php endif; ?>

                                        <div class="item-img-box">
                                            <img src="<?= $item['product_image'] ?>" onerror="this.src='images/default.png'">
                                        </div>
                                        <h4 class="item-name"><?= $item['product_name'] ?></h4>
                                        
                                        <?php if($catID == 8 || $catID == 10): ?>
                                            <div class="temp-options-container">
                                                <button class="temp-badge temp-c" onclick="event.stopPropagation(); addToOrder('<?= $pId ?>_C', '<?= $pName ?> (Cold)', <?= $pPrice ?>)">C</button>
                                                <button class="temp-badge temp-h" onclick="event.stopPropagation(); addToOrder('<?= $pId ?>_H', '<?= $pName ?> (Hot)', <?= $pPrice ?>)">H</button>
                                            </div>
                                        <?php endif; ?>

                                        <p class="price-text">₱<?= number_format($item['price'], 2) ?></p>

                                        <?php if($ingredientButtons != ""): ?>
                                            <div style="display:flex; flex-wrap:wrap; gap:5px; justify-content:center; margin-bottom:10px;">
                                                <?= $ingredientButtons ?>
                                            </div>
                                        <?php endif; ?>
                                    </div>

                                <?php endwhile; 
                            else:
                                echo "<p style='color:gray; padding-left:20px; font-style:italic;'>No items available.</p>";
                            endif; ?>
                        </div>
                    </div>
                <?php endforeach; ?>
            </div>

            <div class="menu-footer">
                <div class="pagination-arrow-container">
                    <button class="arrow-btn" onclick="prevPage()"><i class="fas fa-chevron-left"></i></button>
                    <span id="page-num-display" class="page-indicator">Page 1</span>
                    <button class="arrow-btn" onclick="nextPage()"><i class="fas fa-chevron-right"></i></button>
                </div>
            </div>
        </div>

        <div class="pos-order-side">
            <div id="live-clock" class="orbitron-font" style="text-align:center; color:#7a1d26; font-size: 0.9rem; margin-bottom: 10px; font-weight:bold;">--:--:--</div>
            <h1 class="order-form-title">ORDER FORM</h1>
            <div class="order-type-toggle">
                <button id="dineInBtn" class="toggle-btn active-type" onclick="setOrderType('Dine In')">DINE IN</button>
                <button id="takeOutBtn" class="toggle-btn" onclick="setOrderType('Take Out')">TAKE OUT</button>
            </div>
            <div class="order-details-meta">
                <div><strong>ID:</strong> <span id="displayId"></span></div>
                <div><strong>TYPE:</strong> <span id="displayType">Dine In</span></div>
                <div><strong>PAY:</strong> <span id="displayPay">Cash</span></div>
                <div><strong>DATE:</strong> <span id="displayDate">DD/MM/YY</span></div>
            </div>
            <input type="text" id="custName" placeholder="CUSTOMER NAME" class="customer-input" oninput="autoGenerateMeta()">
            <div class="payment-selection">
                <button id="payCash" class="pay-option active" onclick="setPaymentMethod('Cash', this)">CASH</button>
                <button id="payGCash" class="pay-option" onclick="setPaymentMethod('GCash', this)">GCASH</button>
                <button id="payCard" class="pay-option" onclick="setPaymentMethod('Card', this)">CARD</button>
            </div>

            <div id="receipt-list" class="items-display-area"></div>
            <div class="total-container"><span class="orbitron-font">TOTAL</span><span id="total-price" class="total-amount">₱0.00</span></div>
            <div class="action-buttons">
                <button class="btn-clear" onclick="clearCart()">CLEAR</button>
                <button class="btn-view" onclick="viewOrderDetails()">VIEW</button>
                <button class="btn-checkout" onclick="processCheckout()">CHECK OUT</button>
            </div>
        </div>
    </div>

    <div id="viewModal" class="modal-overlay" style="display:none;">
        <div class="modal-card">
            <div class="modal-header">
                <h2 class="orbitron-font">ORDER DETAILS</h2>
                <span class="close-modal" onclick="document.getElementById('viewModal').style.display='none'">&times;</span>
            </div>
            <div id="modalContent" class="modal-body"></div>
            <div class="modal-footer">
                <button class="btn-close-modal" onclick="document.getElementById('viewModal').style.display='none'">CLOSE</button>
            </div>
        </div>
    </div>

    <div id="receiptModal" class="modal-overlay" style="display:none;">
        <div class="modal-card receipt-card">
            <div class="modal-header">
                <h2 class="orbitron-font">RECEIPT</h2>
                <span class="close-modal" onclick="closeReceipt()">&times;</span>
            </div>
            <div id="receiptContent" class="modal-body" style="font-family: monospace; white-space: pre-wrap; font-size: 14px; color: #333; text-align: left;">
            </div>
            <div class="modal-footer">
                <button class="btn-checkout" onclick="printReceipt()">PRINT</button>
            </div>
        </div>
    </div>

    <script src="js/pos.js"></script>
</body>
</html>