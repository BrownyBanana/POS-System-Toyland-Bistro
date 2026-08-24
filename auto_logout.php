<?php
session_start();
include 'db.php';

// Check if there is an active login record for this session
if (isset($_SESSION['current_login_record_id'])) {
    $record_id = $_SESSION['current_login_record_id'];

    // Update the logout time to the exact moment the tab is closed/unloaded.
    // Notice that we DO NOT destroy the session here. This is the secret to 
    // allowing users to refresh the page without getting kicked back to login!
    $stmt = $conn->prepare("UPDATE user_records SET logout_time = NOW() WHERE record_id = ?");
    $stmt->bind_param("i", $record_id);
    $stmt->execute();
}
?>