<?php
include 'db.php';
session_start();

if (isset($_SESSION['current_login_record_id'])) {
    $record_id = $_SESSION['current_login_record_id'];
    $stmt = $conn->prepare("UPDATE user_records SET logout_time = NOW() WHERE record_id = ?");
    $stmt->bind_param("i", $record_id);
    $stmt->execute();
    $stmt->close();
}

if (isset($_SESSION['user_id'])) {
    $cookieName = 'shift_start_' . $_SESSION['user_id'];
    if (isset($_COOKIE[$cookieName])) {
        setcookie($cookieName, '', time() - 3600, '/');
    }
}

session_unset();
session_destroy();

header("Location: login.php");
exit();
?>