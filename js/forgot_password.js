document.addEventListener("DOMContentLoaded", function() {
    const resetContainer = document.querySelector('#resetContainer');
    const toLogin = document.querySelector('#toLogin');
    
    const newPassword = document.querySelector('#new_password');
    const confirmPassword = document.querySelector('#confirm_password');
    const toggleNewPassword = document.querySelector('#toggleNewPassword');
    const toggleConfirmPassword = document.querySelector('#toggleConfirmPassword');
    
    const matchIcon = document.querySelector('#matchIcon');
    const errorMsg = document.querySelector('#errorMsg');
    const resetForm = document.querySelector('#resetForm');

    if (toLogin) {
        toLogin.addEventListener('click', function(e) {
            e.preventDefault();
            resetContainer.classList.add('fade-out');
            setTimeout(() => {
                window.location.href = this.href;
            }, 300);
        });
    }

    newPassword.addEventListener('input', function() {
        this.value.length > 0 ? toggleNewPassword.classList.add('active') : toggleNewPassword.classList.remove('active');
        checkPasswords();
    });

    confirmPassword.addEventListener('input', function() {
        this.value.length > 0 ? toggleConfirmPassword.classList.add('active') : toggleConfirmPassword.classList.remove('active');
        checkPasswords();
    });

    toggleNewPassword.addEventListener('click', function() {
        const type = newPassword.getAttribute('type') === 'password' ? 'text' : 'password';
        newPassword.setAttribute('type', type);
        this.classList.toggle('fa-eye');
        this.classList.toggle('fa-eye-slash');
    });

    toggleConfirmPassword.addEventListener('click', function() {
        const type = confirmPassword.getAttribute('type') === 'password' ? 'text' : 'password';
        confirmPassword.setAttribute('type', type);
        this.classList.toggle('fa-eye');
        this.classList.toggle('fa-eye-slash');
    });

    function checkPasswords() {
        if (confirmPassword.value.length === 0) {
            matchIcon.style.visibility = "hidden";
            errorMsg.style.display = "none";
            return;
        }

        if (newPassword.value === confirmPassword.value) {
            matchIcon.style.visibility = "visible";
            matchIcon.style.color = "#28a745";
            matchIcon.className = "fa-solid fa-circle-check";
            errorMsg.style.display = "none";
        } else {
            matchIcon.style.visibility = "visible";
            matchIcon.style.color = "#ff4d4d";
            matchIcon.className = "fa-solid fa-circle-xmark";
            errorMsg.style.display = "block";
        }
    }

    resetForm.addEventListener('submit', function(e) {
        if (newPassword.value !== confirmPassword.value) {
            e.preventDefault();
            errorMsg.style.display = "block";
            confirmPassword.focus();
        }
    });
});