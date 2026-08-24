<?php
session_start();
include 'db.php';

date_default_timezone_set('Asia/Manila');

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $login_type = isset($_POST['login_type']) ? $_POST['login_type'] : 'staff';

    $userid = mysqli_real_escape_string($conn, $_POST['userid']);
    $username = mysqli_real_escape_string($conn, $_POST['username']);
    $password = $_POST['password'];

    $auth_stmt = $conn->prepare("SELECT role, password FROM users WHERE id = ? AND username = ?");
    $auth_stmt->bind_param("ss", $userid, $username);
    $auth_stmt->execute();
    $result = $auth_stmt->get_result();

    if ($result->num_rows === 1) {
        $row = $result->fetch_assoc();
        $storedPassword = $row['password'];
        $role = strtolower($row['role']);

        $passwordMatches = password_verify($password, $storedPassword) || ($password === $storedPassword);

        if (!$passwordMatches) {
            echo "<script>alert('Invalid ID, Username, or Password'); window.location.href='login.php';</script>";
            exit();
        }

        if ($login_type === 'manager' && $role !== 'admin') {
            echo "<script>alert('Access Denied: You do not have manager privileges.'); window.location.href='login.php';</script>";
            exit();
        }

        $hour = (int)date('H');
        if ($hour >= 5 && $hour < 12) {
            $shift = "Morning";
        } elseif ($hour >= 12 && $hour < 18) {
            $shift = "Afternoon";
        } else {
            $shift = "Evening";
        }

        $stmt = $conn->prepare("INSERT INTO user_records (staff_id, staff_username, login_time, shift) VALUES (?, ?, NOW(), ?)");
        $stmt->bind_param("sss", $userid, $username, $shift);

        if ($stmt->execute()) {
            $_SESSION['current_login_record_id'] = $conn->insert_id;
            $_SESSION['userid']   = $userid;
            $_SESSION['user_id']  = $userid;
            $_SESSION['username'] = $username;
            $_SESSION['role']     = $role;
            $_SESSION['is_logged_in'] = true;

            session_write_close();

            if ($role === 'admin') {
                header("Location: dashboard_admin.php");
            } else {
                header("Location: dashboard_staff.php");
            }
            exit();
        }
    } else {
        echo "<script>alert('Invalid ID, Username, or Password'); window.location.href='login.php';</script>";
    }
}
?>