<?php
$host = 'localhost';
$dbname = 'bistro';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $conn = mysqli_connect($host, $username, $password, $dbname);
} catch (PDOException $e) {
    die("Connection failed: " . $e->getMessage());
}
?>