<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
    header("Location: login.php");
    exit();
}
$userid = htmlspecialchars($_SESSION['user_id']);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Toyland Bistro - Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="CSS/dashboard.css">
</head>
<body>
    <div class="user-status">
        <div class="user-info">
            <i class="fa-solid fa-circle-user account-icon"></i>
            <span>Manager (<?php echo "$userid"; ?>)</span>
        </div>
        <a href="logout.php" class="logout-link">LOGOUT</a>
    </div>

    <div class="logo-container">
        <div class="logo-circle"><img src="images/logo.jpg"></div>
    </div>

    <main class="hero-section">
        <h1>WELCOME TO TOYLAND BISTRO</h1>
        <div class="button-group">
            <a href="pos.php"><button class="nav-btn">ORDER</button></a>
            <a href="sales.php"><button class="nav-btn">SALES</button></a>
            <a href="inventory.php"><button class="nav-btn">INVENTORY</button></a>
            <a href="user_records.php"><button class="nav-btn">USER RECORDS</button></a>
            <a href="online_orders.php"><button class="nav-btn">PICK-UP ORDERS</button></a>
        </div>
    </main>
</body>
</html>