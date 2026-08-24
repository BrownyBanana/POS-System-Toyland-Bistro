document.getElementById('searchInput').addEventListener('keyup', function() {
    let filter = this.value.toUpperCase();
    let rows = document.querySelector("#recordTable").rows;
    
    for (let i = 0; i < rows.length; i++) {
        let firstCol = rows[i].cells[0].textContent.toUpperCase();
        let secondCol = rows[i].cells[1].textContent.toUpperCase();
        let thirdCol = rows[i].cells[2].textContent.toUpperCase();
        let sixthCol = rows[i].cells[5].textContent.toUpperCase();
        
        if (firstCol.indexOf(filter) > -1 || secondCol.indexOf(filter) > -1 || 
            thirdCol.indexOf(filter) > -1 || sixthCol.indexOf(filter) > -1) {
            rows[i].style.display = "";
        } else {
            rows[i].style.display = "none";
        }      
    }
});


let isNavigating = false;


document.addEventListener('click', function(e) {
    let target = e.target.closest('a'); 
    if (target && target.href) {
        isNavigating = true;
    }
});

document.addEventListener('submit', function() {
    isNavigating = true;
});

window.addEventListener('pagehide', function() {
    if (!isNavigating) {
        navigator.sendBeacon('auto_logout.php');
    }
});