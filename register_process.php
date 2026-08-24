<?php
include 'db.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $userid = trim($_POST['userid']);
    $username = trim($_POST['username']);
    $password = "123"; 
    $role = "staff"; 

    if (!preg_match("/^[a-zA-Z]{3,20}$/", $username)) {
        echo "invalid_format";
        exit;
    }
    
    $check_stmt = $conn->prepare("SELECT id FROM users WHERE username = ?");
    $check_stmt->bind_param("s", $username);
    $check_stmt->execute();
    $check_stmt->store_result();

    if ($check_stmt->num_rows > 0) {
        echo "exists";
        $check_stmt->close();
        exit; 
    } 
    $check_stmt->close();
        
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    $stmt = $conn->prepare("INSERT INTO users (id, username, password, role) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $userid, $username, $hashed_password, $role);

    if ($stmt->execute()) {
        echo "success";
    } else {
        http_response_code(500);
        echo "error";
    }
    $stmt->close();
}
?>