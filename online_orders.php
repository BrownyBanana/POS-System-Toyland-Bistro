<?php
session_start();
require_once 'db.php';

date_default_timezone_set('Asia/Manila');
mysqli_query($conn, "SET time_zone = '+08:00'");

if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit();
}

if (isset($_POST['update_status'])) {
    $id = mysqli_real_escape_string($conn, $_POST['order_id']);
    $new_status = mysqli_real_escape_string($conn, $_POST['new_status']);
    mysqli_query($conn, "UPDATE order_form SET status = '$new_status' WHERE order_id = '$id'");
}

$dashboard_link = ($_SESSION['role'] === 'admin') ? "dashboard_admin.php" : "dashboard_staff.php";
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Pick-Up Orders Queue</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="css/online_orders.css">
</head>
<body>
    <div class="header">
        <h1><i class="fa-solid fa-bell"></i> ACTIVE APP ORDERS</h1>
        <a href="<?= $dashboard_link ?>" class="back-btn">BACK TO DASHBOARD</a>
    </div>

    <div class="orders-grid">
        <?php
        $sql = "SELECT o.order_id, o.customer_name,
                CONVERT_TZ(o.order_date, '+00:00', '+08:00') AS order_date,
                o.total_amount, o.payment_method, s.product_sold, o.status
                FROM order_form o
                JOIN Sales s ON o.order_id = s.order_id
                WHERE o.status IN ('Pending', 'Cooking', 'Preparing') AND o.order_type = 'Pick Up'
                ORDER BY o.order_date DESC";

        $result = mysqli_query($conn, $sql);

        if ($result && mysqli_num_rows($result) > 0) {
            while ($row = mysqli_fetch_assoc($result)) {
                $current_status = $row['status'];
                $next_status = '';
                $btn_text = '';
                $btn_class = '';

                if ($current_status == 'Pending') {
                    $next_status = 'Cooking';
                    $btn_text = 'START COOKING FOOD';
                    $btn_class = 'btn-cooking';
                } elseif ($current_status == 'Cooking') {
                    $next_status = 'Preparing';
                    $btn_text = 'START PREPARING FOOD';
                    $btn_class = 'btn-preparing';
                } elseif ($current_status == 'Preparing') {
                    $next_status = 'Ready';
                    $btn_text = 'READY TO SERVE';
                    $btn_class = 'btn-ready';
                }

                $order_time = date("h:i A", strtotime($row['order_date']));
                $display_items = !empty(trim($row['product_sold'])) ? $row['product_sold'] : 'No items found';

                $status_class = strtolower($current_status);
                $total = floatval($row['total_amount']);

                $items_list = [];
                $parts = explode(', ', $display_items);
                foreach ($parts as $part) {
                    if (preg_match('/^(\d+)x\s+(.+)$/', trim($part), $matches)) {
                        $item_qty = intval($matches[1]);
                        $item_name = $matches[2];
                    } elseif (!empty(trim($part))) {
                        $item_qty = 1;
                        $item_name = trim($part);
                    } else {
                        continue;
                    }

                    $escaped_name = mysqli_real_escape_string($conn, $item_name);
                    $price_query = mysqli_query($conn, "SELECT price FROM products WHERE product_name = '$escaped_name' LIMIT 1");
                    $unit_price = 0;
                    if ($price_query && $price_row = mysqli_fetch_assoc($price_query)) {
                        $unit_price = floatval($price_row['price']);
                    }

                    $items_list[] = [
                        'qty'        => $item_qty,
                        'name'       => $item_name,
                        'unit_price' => $unit_price,
                        'line_total' => $unit_price * $item_qty,
                    ];
                }

                $item_count = array_sum(array_column($items_list, 'qty'));
                $card_id = 'card_' . $row['order_id'];
                ?>
                <div class="order-card">
                    <div class="card-status-banner status-banner-<?= $status_class ?>">
                        <?php if ($current_status == 'Pending'): ?>
                            <i class="fa-solid fa-hourglass-half"></i> PENDING
                        <?php elseif ($current_status == 'Cooking'): ?>
                            <i class="fa-solid fa-fire-burner"></i> COOKING
                        <?php elseif ($current_status == 'Preparing'): ?>
                            <i class="fa-solid fa-concierge-bell"></i> PREPARING
                        <?php endif; ?>
                    </div>

                    <div class="card-body">
                        <div class="receipt-header">
                            <h3>Order Confirmation</h3>
                            <div class="order-meta">
                                <span class="order-num">Order #<?= htmlspecialchars($row['order_id']) ?></span>
                                <span class="order-time"><i class="fa-regular fa-clock"></i> <?= $order_time ?></span>
                            </div>
                        </div>

                        <div class="items-collapsed-hint">
                            <i class="fa-solid fa-box-open"></i>
                            <span><?= $item_count ?> item<?= $item_count > 1 ? 's' : '' ?> ordered</span>
                        </div>

                        <div class="view-toggle-wrap">
                            <button class="view-toggle-btn" onclick="toggleItems('<?= $card_id ?>', this)">
                                <i class="fa-solid fa-eye"></i> View
                            </button>
                        </div>

                        <div class="items-table" id="<?= $card_id ?>" style="display:none;">
                            <div class="items-table-header">
                                <span class="col-product">Product</span>
                                <span class="col-qty">Qty</span>
                                <span class="col-price">Price</span>
                            </div>
                            <?php foreach ($items_list as $item): ?>
                            <div class="items-table-row">
                                <span class="col-product item-name"><?= htmlspecialchars($item['name']) ?></span>
                                <span class="col-qty"><?= $item['qty'] ?>x</span>
                                <span class="col-price">₱<?= number_format($item['line_total'], 2) ?></span>
                            </div>
                            <?php endforeach; ?>
                        </div>

                        <div class="amount-section">
                            <div class="amount-divider"></div>
                            <div class="amount-row total-row">
                                <span>Total</span>
                                <span class="total-amount">₱<?= number_format($total, 2) ?></span>
                            </div>
                        </div>

                        <div class="info-section">
                            <div class="info-row">
                                <span class="info-label">Ordered By</span>
                                <span class="info-value"><?= htmlspecialchars($row['customer_name']) ?></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Pickup Location</span>
                                <span class="info-value">Toyland Bistro</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Payment</span>
                                <span class="info-value"><?= htmlspecialchars($row['payment_method']) ?></span>
                            </div>
                        </div>

                        <form method="POST">
                            <input type="hidden" name="order_id" value="<?= $row['order_id'] ?>">
                            <input type="hidden" name="new_status" value="<?= $next_status ?>">
                            <button type="submit" name="update_status" class="action-btn <?= $btn_class ?>"><?= $btn_text ?></button>
                        </form>
                    </div>
                </div>
                <?php
            }
        } else {
            echo "<div class='no-orders'><i class='fa-solid fa-check-circle'></i><p>No active orders at the moment.</p></div>";
        }
        ?>
    </div>

    <script src="js/orders_refresh.js"></script>
</body>
</html>