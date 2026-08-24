<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Toyland Bistro | Login</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="css/login.css">
</head>
<body>
    <div class="landscape-container" id="mainContainer">
        <form action="login_process.php" method="POST" style="display: contents;">
            <input type="hidden" name="login_type" id="loginType" value="staff">
            
            <div class="side-branding">
                <div class="logo-box">
                    <img src="images/logo.jpg" alt="Logo" class="main-logo">
                </div>
                <h1>Toyland Bistro</h1>
            </div>
            
            <div class="side-form">
                <h2 class="form-title" id="formTitle">Login</h2>
                
                <div class="input-box">
                    <label>ID</label>
                    <div class="field-wrapper">
                        <input type="text" name="userid" placeholder="Enter ID (e.g., 02-9090)" required>
                        <i class="fa-solid fa-address-card"></i>
                    </div>
                </div>
                
                <div class="input-box">
                    <label>Username</label>
                    <div class="field-wrapper">
                        <input type="text" name="username" placeholder="Enter Username" required>
                        <i class="fa-solid fa-user"></i>
                    </div>
                </div>
                
                <div class="input-box">
                    <label>Password</label>
                    <div class="field-wrapper">
                        <input type="password" name="password" id="password" placeholder="Enter Password" required>
                        <i class="fa-solid fa-eye" id="togglePassword"></i>
                        <i class="fa-solid fa-lock"></i>
                    </div>
                </div>

                <div id="forgotPasswordDiv" style="display: none; text-align: right; margin-bottom: 15px; margin-top: -5px;">
                    <a href="forgot_password.php" id="forgotPwdLink">Forgot Password?</a>
                </div>

                <button type="submit" class="submit-btn">Login</button>
                
                <div class="register-link" style="margin-top: 15px; text-align: center;">
                    
                    <div id="staffLinks" class="fade-transition">
                        <button type="button" id="toManager" class="switch-btn">Login as Manager</button>
                    </div>

                    <div id="managerLinks" class="fade-transition" style="display: none;">
                        <div style="display: flex; justify-content: space-between; align-items: center; width: 100%; padding-top: 5px; gap: 10px;">
                            <button type="button" id="toRegister" class="switch-btn switch-btn-outline" onclick="window.location.href='register.php'">Add Employee</button>
                            <button type="button" id="toStaff" class="switch-btn">Login as Staff</button>
                        </div>
                    </div>

                </div>
            </div>
        </form>
    </div>

    <div id="managerVerifyOverlay" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.6); z-index:9999; justify-content:center; align-items:center;">
        <div style="background:#ffffff; border-radius:16px; padding:32px 28px; width:90%; max-width:360px; box-shadow:0 20px 50px rgba(0,0,0,0.25);">
            <div style="text-align:center; margin-bottom:22px;">
                <i class="fa-solid fa-shield-halved" style="font-size:2rem; color:#7a1b28; margin-bottom:10px; display:block;"></i>
                <h3 style="color:#333; font-family:'Poppins',sans-serif; font-size:1.1rem; margin:0;">Manager Verification</h3>
                <p style="color:#888; font-size:0.8rem; margin-top:6px; font-family:'Poppins',sans-serif;">Enter your manager credentials to continue</p>
            </div>

            <div style="margin-bottom:14px;">
                <label style="color:#555; font-size:0.78rem; display:block; margin-bottom:5px; font-family:'Poppins',sans-serif;">Manager ID</label>
                <div style="position:relative;">
                    <input type="text" id="verifyId" placeholder="Enter Manager ID" style="width:100%; padding:11px 40px 11px 12px; border-radius:8px; border:1px solid #ddd; background:#fff; color:#333; font-family:'Poppins',sans-serif; font-size:0.88rem; outline:none; box-sizing:border-box;">
                    <i class="fa-solid fa-address-card" style="position:absolute; right:12px; top:50%; transform:translateY(-50%); color:#7a1b28;"></i>
                </div>
            </div>

            <div style="margin-bottom:14px;">
                <label style="color:#555; font-size:0.78rem; display:block; margin-bottom:5px; font-family:'Poppins',sans-serif;">Username</label>
                <div style="position:relative;">
                    <input type="text" id="verifyUsername" placeholder="Enter Username" style="width:100%; padding:11px 40px 11px 12px; border-radius:8px; border:1px solid #ddd; background:#fff; color:#333; font-family:'Poppins',sans-serif; font-size:0.88rem; outline:none; box-sizing:border-box;">
                    <i class="fa-solid fa-user" style="position:absolute; right:12px; top:50%; transform:translateY(-50%); color:#7a1b28;"></i>
                </div>
            </div>

            <div style="margin-bottom:20px;">
                <label style="color:#555; font-size:0.78rem; display:block; margin-bottom:5px; font-family:'Poppins',sans-serif;">Password</label>
                <div style="position:relative;">
                    <input type="password" id="verifyPassword" placeholder="Enter Password" style="width:100%; padding:11px 40px 11px 12px; border-radius:8px; border:1px solid #ddd; background:#fff; color:#333; font-family:'Poppins',sans-serif; font-size:0.88rem; outline:none; box-sizing:border-box;">
                    <i class="fa-solid fa-lock" style="position:absolute; right:12px; top:50%; transform:translateY(-50%); color:#7a1b28;"></i>
                </div>
            </div>

            <p id="verifyError" style="color:#e74c3c; font-size:0.78rem; text-align:center; margin-bottom:14px; display:none; font-family:'Poppins',sans-serif;">Invalid credentials or not a manager account.</p>

            <div style="display:flex; gap:10px;">
                <button type="button" onclick="closeManagerVerify()" style="flex:1; padding:11px; background:#fff; border:1px solid #ddd; color:#555; border-radius:8px; cursor:pointer; font-family:'Poppins',sans-serif; font-size:0.85rem; transition:0.2s;">Cancel</button>
                <button type="button" onclick="submitManagerVerify()" id="verifyBtn" style="flex:1; padding:11px; background:#7a1b28; border:none; color:#fff; border-radius:8px; cursor:pointer; font-family:'Poppins',sans-serif; font-size:0.85rem; font-weight:600; transition:0.2s;">Verify</button>
            </div>
        </div>
    </div>

    <script src="js/login.js"></script>
</body>
</html>