<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Toyland Bistro | Reset Password</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="css/login.css">
    <link rel="stylesheet" href="css/forgot_password.css">
</head>
<body>
    <div class="landscape-container" id="resetContainer">
        <form action="forgot_password_process.php" method="POST" id="resetForm" style="display: contents;">
            
            <div class="side-branding">
                <div class="logo-box">
                    <img src="images/logo.jpg" alt="Logo" class="main-logo">
                </div>
                <h1>Toyland Bistro</h1>
            </div>
            
            <div class="side-form">
                <h2 class="form-title">Reset Password</h2>
                
                <div class="input-box">
                    <label>Admin ID</label>
                    <div class="field-wrapper">
                        <input type="text" name="userid" id="userid" placeholder="Enter ID (e.g., 02-9090)" required>
                        <i class="fa-solid fa-address-card"></i>
                    </div>
                </div>
                
                <div class="input-box">
                    <label>New Password</label>
                    <div class="field-wrapper">
                        <input type="password" name="new_password" id="new_password" placeholder="Enter New Password" required>
                        <i class="fa-solid fa-eye" id="toggleNewPassword"></i>
                        <i class="fa-solid fa-lock"></i>
                    </div>
                </div>
                
                <div class="input-box">
                    <label>Confirm Password</label>
                    <div class="field-wrapper">
                        <input type="password" name="confirm_password" id="confirm_password" placeholder="Confirm New Password" required>
                        <i class="fa-solid fa-eye" id="toggleConfirmPassword"></i>
                        <i class="fa-solid fa-circle-check" id="matchIcon" style="visibility: hidden;"></i>
                    </div>
                    <small id="errorMsg" style="color: #ff4d4d; font-size: 0.75rem; display: none; margin-top: 5px;">Passwords do not match!</small>
                </div>

                <button type="submit" class="submit-btn" id="submitBtn">Update Password</button>
                
                <div class="register-link" style="margin-top: 20px; text-align: center;">
                    <a href="login.php" id="toLogin" class="toggle-link" style="text-decoration: none;">
                        <i class="fa-solid fa-arrow-left"></i> Back to Login
                    </a>
                </div>
            </div>
        </form>
    </div>
    <script src="js/forgot_password.js"></script>
</body>
</html>