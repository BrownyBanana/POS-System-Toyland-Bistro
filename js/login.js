const togglePassword = document.querySelector('#togglePassword');
const password = document.querySelector('#password');
const mainContainer = document.querySelector('#mainContainer');
const formTitle = document.querySelector('#formTitle');
const loginType = document.querySelector('#loginType');
const forgotPasswordDiv = document.querySelector('#forgotPasswordDiv');
const staffLinks = document.querySelector('#staffLinks');
const managerLinks = document.querySelector('#managerLinks');
const toManager = document.querySelector('#toManager');
const toStaff = document.querySelector('#toStaff');

password.addEventListener('input', function() {
    this.value.length > 0 ? togglePassword.classList.add('active') : togglePassword.classList.remove('active');
});

togglePassword.addEventListener('click', function() {
    const type = password.getAttribute('type') === 'password' ? 'text' : 'password';
    password.setAttribute('type', type);
    this.classList.toggle('fa-eye');
    this.classList.toggle('fa-eye-slash');
});

toManager.addEventListener('click', function(e) {
    e.preventDefault();
    document.getElementById('verifyId').value = '';
    document.getElementById('verifyUsername').value = '';
    document.getElementById('verifyPassword').value = '';
    document.getElementById('verifyError').style.display = 'none';
    document.getElementById('managerVerifyOverlay').style.display = 'flex';
    document.getElementById('verifyId').focus();
});

function closeManagerVerify() {
    document.getElementById('managerVerifyOverlay').style.display = 'none';
}

function submitManagerVerify() {
    const verifyId = document.getElementById('verifyId').value.trim();
    const verifyUsername = document.getElementById('verifyUsername').value.trim();
    const verifyPassword = document.getElementById('verifyPassword').value.trim();
    const verifyError = document.getElementById('verifyError');
    const verifyBtn = document.getElementById('verifyBtn');

    if (!verifyId || !verifyUsername || !verifyPassword) {
        verifyError.innerText = 'Please fill in all fields.';
        verifyError.style.display = 'block';
        return;
    }

    verifyBtn.innerText = 'Verifying...';
    verifyBtn.disabled = true;
    verifyError.style.display = 'none';

    const formData = new FormData();
    formData.append('userid', verifyId);
    formData.append('username', verifyUsername);
    formData.append('password', verifyPassword);

    fetch('verify_manager.php', { method: 'POST', body: formData })
    .then(res => res.json())
    .then(data => {
        verifyBtn.innerText = 'Verify';
        verifyBtn.disabled = false;
        if (data.success) {
            document.getElementById('managerVerifyOverlay').style.display = 'none';
            formTitle.innerText = "Manager Login";
            loginType.value = "manager";
            forgotPasswordDiv.style.display = "block";
            staffLinks.style.display = "none";
            managerLinks.style.display = "block";
            managerLinks.classList.remove('fade-transition');
            void managerLinks.offsetWidth;
            managerLinks.classList.add('fade-transition');
        } else {
            verifyError.innerText = 'Invalid credentials or not a manager account.';
            verifyError.style.display = 'block';
        }
    })
    .catch(() => {
        verifyBtn.innerText = 'Verify';
        verifyBtn.disabled = false;
        verifyError.innerText = 'Verification failed. Please try again.';
        verifyError.style.display = 'block';
    });
}

document.getElementById('verifyPassword').addEventListener('keydown', function(e) {
    if (e.key === 'Enter') submitManagerVerify();
});

toStaff.addEventListener('click', function(e) {
    e.preventDefault();
    formTitle.innerText = "Staff Login";
    loginType.value = "staff";
    
    forgotPasswordDiv.style.display = "none";
    managerLinks.style.display = "none";
    staffLinks.style.display = "block";

    staffLinks.classList.remove('fade-transition');
    void staffLinks.offsetWidth; 
    staffLinks.classList.add('fade-transition');
});