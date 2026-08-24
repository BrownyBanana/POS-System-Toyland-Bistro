<?php
include 'db.php';
session_start();

$where_clause = "";
$filter_date = $_GET['date'] ?? '';

if (!empty($filter_date)) {
    $start_dt = date('Y-m-d 00:00:00', strtotime($filter_date));
    $end_dt = date('Y-m-d 23:59:59', strtotime($filter_date));
    $where_clause = " WHERE login_time >= '$start_dt' AND login_time <= '$end_dt'";
}

$sql = "SELECT * FROM user_records" . $where_clause . " ORDER BY login_time DESC";
$result = $conn->query($sql);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Records - Toyland Bistro</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="css/user_records.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>USER RECORDS</h1>
            <div class="header-actions">
                <form method="GET" action="user_records.php" class="date-filter-form">
                    <input type="date" name="date" value="<?= htmlspecialchars($filter_date) ?>" class="search-input date-input" required onclick="this.showPicker()">
                    <button type="submit" class="dashboard-btn"><i class="fas fa-filter"></i> Filter</button>
                    <?php if(!empty($filter_date)): ?>
                        <a href="user_records.php" class="dashboard-btn clear-btn">Clear</a>
                    <?php endif; ?>
                </form>

                <input type="text" id="searchInput" class="search-input" placeholder="Search ID, Name, or Shift...">
                <a href="dashboard_admin.php" class="dashboard-btn">DASHBOARD</a>
            </div>
        </header>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>RECORD ID</th>
                        <th>STAFF ID</th>
                        <th>STAFF USERNAME</th>
                        <th>LOGIN TIME</th>
                        <th>LOGOUT TIME</th>
                        <th>SHIFT</th>
                    </tr>
                </thead>
                <tbody id="recordTable">
                    <?php
                    if ($result && $result->num_rows > 0) {
                        while ($row = $result->fetch_assoc()) {
                            $shiftClass = strtolower($row['shift']);
                            
                            echo "<tr>";
                            echo "<td>#" . htmlspecialchars($row['record_id']) . "</td>";
                            echo "<td>" . htmlspecialchars($row['staff_id']) . "</td>";
                            echo "<td><strong>" . htmlspecialchars($row['staff_username']) . "</strong></td>";
                            echo "<td>" . date('d/m/y | h:i A', strtotime($row['login_time'])) . "</td>";
                            echo "<td>" . ($row['logout_time'] ? date('d/m/y | h:i A', strtotime($row['logout_time'])) : "--:--") . "</td>";
                            echo "<td><span class='shift-badge $shiftClass'>" . $row['shift'] . "</span></td>";
                            echo "</tr>";
                        }
                    } else {
                        echo "<tr><td colspan='6' style='text-align:center; padding: 40px; color: #666; font-style: italic;'>No records found for the selected filter.</td></tr>";
                    }
                    ?>
                </tbody>
            </table>
        </div>
    </div>
    <script src="js/user_records.js?v=3"></script>
</body>
</html>