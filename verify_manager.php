<?php
include 'db.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false]);
    exit();
}

$userid   = isset($_POST['userid'])   ? mysqli_real_escape_string($conn, $_POST['userid'])   : '';
$username = isset($_POST['username']) ? mysqli_real_escape_string($conn, $_POST['username']) : '';
$password = isset($_POST['password']) ? $_POST['password'] : '';

if (empty($userid) || empty($username) || empty($password)) {
    echo json_encode(['success' => false]);
    exit();
}

$stmt = $conn->prepare("SELECT role FROM users WHERE id = ? AND username = ? AND password = ?");
$stmt->bind_param("sss", $userid, $username, $password);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
    $row = $result->fetch_assoc();
    if (strtolower($row['role']) === 'admin') {
        echo json_encode(['success' => true]);
    } else {
        echo json_encode(['success' => false]);
    }
} else {
    echo json_encode(['success' => false]);
}

$stmt->close();
exit();
?>