<?php session_start(); ?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Toyland Bistro | Create Account</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="css/login.css">
</head>
<body>
    <div class="landscape-container" id="regContainer">
        <form id="registerForm" style="display: contents;">
            <div class="side-branding">
                <div class="logo-box">
                    <img src="images/logo.jpg" alt="Logo" class="main-logo">
                </div>
                <h1>Toyland Bistro</h1>
            </div>

            <div class="side-form">
                <h2 class="form-title">Create Account</h2>
                
                <div class="input-box">
                    <label>Username</label>
                    <div class="field-wrapper">
                        <input type="text" name="username" id="reg_user" placeholder="Enter Username (e.g. John or john)" required>
                        <i class="fa-solid fa-user"></i>
                    </div>
                </div>

                <div class="input-box">
                    <label>ID</label>
                    <div class="field-wrapper">
                        <input type="text" name="userid" id="reg_id" readonly required>
                        <i class="fa-solid fa-address-card"></i>
                    </div>
                </div>

                <div class="input-box">
                    <label>Password</label>
                    <div class="field-wrapper">
                        <input type="text" name="password" value="123" readonly>
                        <i class="fa-solid fa-lock"></i>
                    </div>
                </div>

                <button type="submit" class="submit-btn" id="submitBtn">Create Account</button>
                
                <div class="register-link">
                    <p>Already Have An Account? <a href="login.php" id="toLogin">Login here</a></p>
                </div>
            </div>
        </form>
    </div>
    <script src="js/register.js"></script>
</body>
</html>