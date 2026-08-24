setInterval(function() {
    console.log("Checking for new orders from the app...");
    location.reload();
}, 10000);
function toggleItems(cardId, btn) {
            const table = document.getElementById(cardId);
            const isHidden = table.style.display === 'none';
            table.style.display = isHidden ? 'block' : 'none';
            btn.innerHTML = isHidden
                ? '<i class="fa-solid fa-eye-slash"></i> Hide'
                : '<i class="fa-solid fa-eye"></i> View';
            btn.classList.toggle('active', isHidden);
        }