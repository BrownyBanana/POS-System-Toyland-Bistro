<?php
session_start();
include 'db.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $userid = mysqli_real_escape_string($conn, $_POST['userid']);
    $new_password = $_POST['new_password'];
    $confirm_password = $_POST['confirm_password'];

    if ($new_password !== $confirm_password) {
        echo "<script>alert('Passwords do not match!'); window.location.href='forgot_password.php';</script>";
        exit();
    }

    $check_stmt = $conn->prepare("SELECT id FROM users WHERE id = ?");
    $check_stmt->bind_param("s", $userid);
    $check_stmt->execute();
    $result = $check_stmt->get_result();

    if ($result->num_rows === 1) {
        $update_stmt = $conn->prepare("UPDATE users SET password = ? WHERE id = ?");
        $update_stmt->bind_param("ss", $new_password, $userid);
        
        if ($update_stmt->execute()) {
            echo "<script>alert('Password successfully updated! You can now login.'); window.location.href='login.php';</script>";
        } else {
            echo "<script>alert('Something went wrong. Please try again.'); window.location.href='forgot_password.php';</script>";
        }
    } else {
        echo "<script>alert('Error: Admin ID not found in the system.'); window.location.href='forgot_password.php';</script>";
    }
}
?>