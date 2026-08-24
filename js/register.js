const usernameInput = document.querySelector('#reg_user');
const idInput = document.querySelector('#reg_id');
const regContainer = document.querySelector('#regContainer');
const registerForm = document.querySelector('#registerForm');
const submitBtn = document.querySelector('#submitBtn');
const toLogin = document.querySelector('#toLogin');

usernameInput.addEventListener('input', function() {
    if (this.value.trim().length > 0) {
        const randomNum = Math.floor(1000 + Math.random() * 9000);
        idInput.value = `02-${randomNum}`;
    } else {
        idInput.value = '';
    }
});

toLogin.addEventListener('click', function(e) {
    e.preventDefault();
    regContainer.classList.add('fade-out');
    setTimeout(() => {
        window.location.href = this.href;
    }, 300);
});

registerForm.addEventListener('submit', function(e) {
    e.preventDefault();

    const usernameVal = usernameInput.value;
    
    if (!/^[a-zA-Z]{3,20}$/.test(usernameVal)) {
        alert("Username must only contain letters (no numbers, spaces, or special characters) and be between 3 and 20 characters long.");
        return;
    }

    submitBtn.innerText = "Creating...";
    submitBtn.disabled = true;

    fetch('register_process.php', {
        method: 'POST',
        body: new FormData(this)
    })
    .then(response => response.text())
    .then(data => {
        if (data.trim() === 'exists') {
            alert("This username is already taken. Please choose another one.");
            submitBtn.innerText = "Create Account";
            submitBtn.disabled = false;
        } else if (data.trim() === 'invalid_format') {
            alert("Username must only contain letters (no numbers, spaces, or special characters) and be between 3 and 20 characters long.");
            submitBtn.innerText = "Create Account";
            submitBtn.disabled = false;
        } else if (data.trim() === 'success') {
            submitBtn.innerText = "Account Created!";
            submitBtn.classList.add('success');

            setTimeout(() => {
                registerForm.reset();
                idInput.value = '';
                submitBtn.innerText = "Create Account";
                submitBtn.classList.remove('success');
                submitBtn.disabled = false;
            }, 1500);
        } else {
            alert("Error creating account. Please try again.");
            submitBtn.innerText = "Create Account";
            submitBtn.disabled = false;
        }
    })
    .catch(error => {
        alert("Network error. Please check your connection.");
        submitBtn.innerText = "Create Account";
        submitBtn.disabled = false;
    });
});