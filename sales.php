<?php 
date_default_timezone_set('Asia/Manila'); 

include 'db.php'; 
session_start(); 

$dashboard_link = "login.php"; 
$is_staff = false;
$staff_login_time = null;

if (isset($_SESSION['role'])) {
    $dashboard_link = ($_SESSION['role'] === 'admin') ? "dashboard_admin.php" : "dashboard_staff.php";
    
    if ($_SESSION['role'] === 'staff') {
        $is_staff = true;

        if (isset($_SESSION['shift_start_time'])) {
            $staff_login_time = $_SESSION['shift_start_time'];
        } else {
            $cookieName = 'shift_start_' . ($_SESSION['user_id'] ?? '');
            if (isset($_COOKIE[$cookieName])) {
                $staff_login_time = $_COOKIE[$cookieName];
                $_SESSION['shift_start_time'] = $staff_login_time;
            }
        }
    }
}

$base_where = "";
if ($is_staff) {
    if ($staff_login_time) {
        $base_where = " WHERE order_date >= '$staff_login_time'";
    } else {
        $base_where = " WHERE 1=0"; 
    }
}

$table_where = $base_where;
$filter_date = $_GET['date'] ?? '';

if (!empty($filter_date)) {
    $start_dt = date('Y-m-d 00:00:00', strtotime($filter_date));
    $end_dt = date('Y-m-d 23:59:59', strtotime($filter_date));
    
    if (empty($table_where)) {
        $table_where = " WHERE order_date >= '$start_dt' AND order_date <= '$end_dt'";
    } else {
        $table_where .= " AND order_date >= '$start_dt' AND order_date <= '$end_dt'";
    }
}

$items_per_page = 20;
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$offset = ($page - 1) * $items_per_page;

$count_sql = "SELECT COUNT(*) as total FROM sales" . $table_where;
$count_res = $conn->query($count_sql);
$total_rows = ($count_res) ? $count_res->fetch_assoc()['total'] : 0;
$total_pages = ceil($total_rows / $items_per_page);

$sql_stats = "SELECT 
    SUM(CASE WHEN YEARWEEK(order_date, 1) = YEARWEEK(CURDATE(), 1) THEN total_amount ELSE 0 END) as week_total,
    SUM(CASE WHEN MONTH(order_date) = MONTH(CURDATE()) AND YEAR(order_date) = YEAR(CURDATE()) THEN total_amount ELSE 0 END) as month_total,
    SUM(CASE WHEN YEAR(order_date) = YEAR(CURDATE()) THEN total_amount ELSE 0 END) as year_total
    FROM sales" . $base_where;

$query_stats = mysqli_query($conn, $sql_stats);
$stats = ($query_stats) ? mysqli_fetch_assoc($query_stats) : ['week_total'=>0, 'month_total'=>0, 'year_total'=>0];
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sales Records</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="css/sales.css?v=<?php echo time(); ?>">
</head>
<body>

    <div class="sales-container">
        <div class="header-flex">
            <h1 class="orbitron-font">Sales Records</h1>
            
            <div class="header-actions">
                <form method="GET" action="sales.php" class="date-filter-form">
                    <input type="date" name="date" value="<?= htmlspecialchars($filter_date) ?>" class="search-input date-input" required onclick="this.showPicker()">
                    <button type="submit" class="back-btn"><i class="fas fa-filter"></i> Filter</button>
                    <?php if(!empty($filter_date)): ?>
                        <a href="sales.php" class="back-btn" style="background:#333;">Clear</a>
                    <?php endif; ?>
                </form>

                <input type="text" id="salesSearch" class="search-input" placeholder="Search Transaction ID...">
                <a href="<?= $dashboard_link; ?>" class="back-btn">Dashboard</a>
            </div>
        </div>

        <div class="analytics-row">
            <div class="stat-card">
                <h3>Weekly Sales</h3>
                <p>₱<?= number_format($stats['week_total'] ?? 0, 2); ?></p>
            </div>
            <div class="stat-card">
                <h3>Monthly Sales</h3>
                <p>₱<?= number_format($stats['month_total'] ?? 0, 2); ?></p>
            </div>
            <div class="stat-card">
                <h3>Yearly Sales</h3>
                <p>₱<?= number_format($stats['year_total'] ?? 0, 2); ?></p>
            </div>
        </div>

        <div class="table-wrapper">
            <table id="salesTable">
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Transaction ID</th>
                        <th>Customer</th>
                        <th>Date & Time</th>
                        <th>Items Sold</th>
                        <th>Cash</th>
                        <th>Change</th>
                        <th>Total</th>
                        <th>Method / Ref No.</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <?php 
                    $table_sql = "SELECT * FROM sales" . $table_where . " ORDER BY order_date DESC LIMIT $offset, $items_per_page";
                    $result = $conn->query($table_sql);

                    if ($result && $result->num_rows > 0) {
                        $counter = 1000;
                        while($row = $result->fetch_assoc()) {
                            $db_id = $row['order_id'] ?? $row['id'] ?? $counter++;
                            $displayID = 1000 + $db_id;

                            $itemsText = "No items";
                            if (!empty($row['product_sold'])) {
                                $itemsText = $row['product_sold'];
                            } elseif (!empty($row['order_details'])) {
                                $products = json_decode($row['order_details'], true);
                                if (is_array($products)) {
                                    $temp = "";
                                    foreach($products as $name => $d) {
                                        $qty = $d['qty'] ?? 1;
                                        $temp .= "$name ($qty), ";
                                    }
                                    $itemsText = rtrim($temp, ", ");
                                }
                            }

                            $safeItemsText = htmlspecialchars($itemsText, ENT_QUOTES);

                            $itemParts = preg_split('/,\s*(?=\d+x\s)/', $itemsText);
                            $formattedParts = array_map(function($i) {
                                return preg_replace('/^(\d+)x\s/', '$1× ', trim($i));
                            }, $itemParts);

                            $displayItemsText = implode('<br>', $formattedParts);
                            $viewBtn = "";
                            if (count($formattedParts) > 3 || strlen($itemsText) > 80) {
                                $previewParts = array_slice($formattedParts, 0, 2);
                                $displayItemsText = implode('<br>', $previewParts) . '<br>...';
                                $viewBtn = "<button class='view-items-btn' data-items='{$safeItemsText}' onclick='viewItems(this)'>View</button>";
                            }

                            $transID = isset($row['transaction_id']) ? substr($row['transaction_id'], 0, 8) . '...' : 'N/A';
                            $custName = $row['customer_name'] ?? "Walk-in";
                            $dateVal = isset($row['order_date']) ? date('M d, Y | h:i A', strtotime($row['order_date'])) : '-';
                            
                            $cash = number_format($row['cash_amount'] ?? 0, 2);
                            $change = number_format($row['change_amount'] ?? 0, 2);
                            $total = number_format($row['total_amount'] ?? 0, 2);

                            $method = ucfirst($row['payment_method'] ?? 'Cash');
                            $badgeClass = strtolower($method); 
                            $gcashRef = isset($row['gcash_reference']) ? $row['gcash_reference'] : '';
                            
                            $displayMethod = $method;
                            if ($badgeClass === 'gcash') {
                                $displayMethod = !empty($gcashRef) ? $gcashRef : 'NO REF CODE';
                            }

                            echo "<tr>
                                <td>#{$displayID}</td>
                                <td>{$transID}</td>
                                <td class='customer-name-cell'>{$custName}</td>
                                <td>{$dateVal}</td>
                                <td>
                                    <div class='items-flex-container'>
                                        <span class='items-text'>{$displayItemsText}</span>
                                        {$viewBtn}
                                    </div>
                                </td>
                                <td>₱{$cash}</td>
                                <td>₱{$change}</td>
                                <td class='total-amount-cell'>₱{$total}</td>
                                <td><span class='badge {$badgeClass}'>{$displayMethod}</span></td>
                                <td><span class='badge status-completed'>Paid</span></td>
                            </tr>";
                        }
                    } else {
                        $msg = $is_staff ? "No sales in this session." : "No sales records found.";
                        echo "<tr><td colspan='10' class='empty-table-msg'>{$msg}</td></tr>";
                    }
                    ?>
                </tbody>
            </table>
        </div>

        <?php if ($total_pages > 1): ?>
        <div class="pagination">
            <?php for ($i = 1; $i <= $total_pages; $i++): ?>
                <a href="?page=<?= $i ?>&date=<?= urlencode($filter_date) ?>" class="page-link <?= ($page == $i) ? 'active' : '' ?>"><?= $i ?></a>
            <?php endfor; ?>
        </div>
        <?php endif; ?>
    </div>

    <div id="itemsModal" class="modal-overlay" style="display:none;">
        <div class="modal-card">
            <div class="modal-header">
                <h2 class="orbitron-font">Items Sold</h2>
                <span class="close-modal" onclick="closeItemsModal()">&times;</span>
            </div>
            <div class="modal-body">
                <p id="modalItemsText" style="color: #333; font-size: 1rem; line-height: 1.6;"></p>
            </div>
        </div>
    </div>

    <script src="js/sales.js"></script>
</body>
</html>