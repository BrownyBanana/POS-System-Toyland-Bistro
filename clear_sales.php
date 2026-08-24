<?php
include 'db.php';
session_start();

if (!isset($_SESSION['role']) || $_SESSION['role'] !== 'admin') {
    http_response_code(403);
    echo "Unauthorized access. Administrator privileges required.";
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $sql = "TRUNCATE TABLE sales";
    
    if (mysqli_query($conn, $sql)) {
        echo "Success";
    } else {
        http_response_code(500);
        echo "Error: Could not clear records. " . mysqli_error($conn);
    }
} else {
    http_response_code(405);
    echo "Method Not Allowed. This action requires a secure POST request.";
}

mysqli_close($conn);
?>