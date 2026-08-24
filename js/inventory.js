window.openProductModal = () => {
    const modal = document.getElementById('productModal');
    if (modal) {
        document.querySelector('#productModal form').reset();
        document.getElementById('modalTitle').innerText = "Add New Product";
        document.getElementById('formId').value = ""; 
        modal.style.display = 'flex';
    }
}

window.closeProductModal = () => {
    document.getElementById('productModal').style.display = 'none';
}

window.openStatusModal = () => {
    document.getElementById('statusModal').style.display = 'flex';
    document.querySelector('#statusModal form').reset();
}

window.closeStatusModal = () => {
    document.getElementById('statusModal').style.display = 'none';
}

window.openIngredientModal = () => {
    document.getElementById('ingredientModal').style.display = 'flex';
    document.querySelector('#ingredientModal h2').innerText = "Add Ingredients & Dates";
    document.querySelector('#ingredientModal form').reset();
    const tagsContainer = document.getElementById('ingredientTagsContainer');
    if (tagsContainer) tagsContainer.innerHTML = "";
    updateHiddenIngredients();
    const countdown = document.getElementById('countdownDisplay');
    if (countdown) countdown.innerText = "";
    const options = document.querySelectorAll('#ingProductName option');
    options.forEach(opt => { if (opt.value !== "") opt.style.display = "none"; });
}

window.closeIngredientModal = () => {
    document.getElementById('ingredientModal').style.display = 'none';
}

window.editProduct = (data) => {
    const modal = document.getElementById('ingredientModal');
    
    if (modal) {
        document.querySelector('#ingredientModal h2').innerText = "Edit Product Details";
        
        const catDropdown = document.getElementById('ingCategory');
        if (catDropdown) catDropdown.value = data.category;
        
        window.filterIngProductByCat();
        
        const prodDropdown = document.getElementById('ingProductName');
        if (prodDropdown) {
            let found = Array.from(prodDropdown.options).some(opt => opt.value === data.product_name);
            if (!found) {
                let newOpt = document.createElement('option');
                newOpt.value = data.product_name;
                newOpt.text = data.product_name;
                prodDropdown.add(newOpt);
            }
            prodDropdown.value = data.product_name;
        }
        
        const priceInput = document.getElementById('ingPrice');
        if (priceInput) priceInput.value = data.product_price;
        
        const qtyInput = document.getElementById('ingQty');
        if (qtyInput) qtyInput.value = data.product_quantity;

        const publishDate = document.getElementById('publishDate');
        if (publishDate) publishDate.value = data.publish_date || '';
        
        const expirationDate = document.getElementById('expirationDate');
        if (expirationDate) expirationDate.value = data.expiration_date || '';
        
        const tagsContainer = document.getElementById('ingredientTagsContainer');
        if (tagsContainer) {
            tagsContainer.innerHTML = "";
            if (data.ingredients && data.ingredients !== "null" && data.ingredients !== "[]") {
                try {
                    let parsed = JSON.parse(data.ingredients);
                    if (Array.isArray(parsed)) {
                        parsed.forEach(ing => addTagToUI(ing));
                    } else {
                        addTagToUI(data.ingredients);
                    }
                } catch(e) {
                    addTagToUI(data.ingredients);
                }
            }
        }
        
        updateHiddenIngredients();
        updateCountdown();
        
        modal.style.display = 'flex';
    }
}

window.addIngredientTag = () => {
    const input = document.getElementById('ingredientInput');
    const val = input.value.trim();
    if (val) {
        addTagToUI(val);
        input.value = "";
        updateHiddenIngredients();
    }
}

function addTagToUI(text) {
    const container = document.getElementById('ingredientTagsContainer');
    if (!container) return; 
    const tag = document.createElement('div');
    tag.className = 'ingredient-tag';
    tag.innerHTML = `${text} <span class="remove-x" onclick="this.parentElement.remove(); updateHiddenIngredients();">&times;</span>`;
    container.appendChild(tag);
}

window.updateHiddenIngredients = () => {
    const tags = document.querySelectorAll('.ingredient-tag');
    const ingredients = Array.from(tags).map(t => t.innerText.replace(' ×', '').replace(' \u00d7', '').trim());
    const hiddenInput = document.getElementById('hiddenIngredientData');
    if (hiddenInput) {
        hiddenInput.value = JSON.stringify(ingredients);
    }
}

window.prepareIngredients = () => {
    window.updateHiddenIngredients();
}

window.handleEnter = (e) => {
    if (e.key === 'Enter') {
        e.preventDefault();
        window.addIngredientTag();
    }
}

window.updateCountdown = () => {
    const expDateInput = document.getElementById('expirationDate').value;
    const display = document.getElementById('countdownDisplay');
    if (!expDateInput) {
        if(display) display.innerText = "";
        return;
    }
    
    const expDate = new Date(expDateInput), today = new Date();
    today.setHours(0,0,0,0); expDate.setHours(0,0,0,0);
    const diffDays = Math.ceil((expDate - today) / (1000 * 60 * 60 * 24)); 

    if (diffDays > 0) { 
        if(display) { display.innerText = `Expires in: ${diffDays} day(s)`; display.style.color = "#4caf50"; }
    } 
    else if (diffDays === 0) { 
        if(display) { display.innerText = "Expires TODAY!"; display.style.color = "#ff9800"; }
    } 
    else { 
        if(display) { display.innerText = `Expired ${Math.abs(diffDays)} day(s) ago`; display.style.color = "#ff4444"; }
    }
}

window.filterProductsByCat = () => {
    const catId = document.getElementById('statusCategory').value;
    const options = document.querySelectorAll('#statusProduct option');
    
    options.forEach(opt => {
        if (opt.value === "") return; 
        
        if (opt.getAttribute('data-cat') === catId) {
            opt.style.display = ""; 
        } else {
            opt.style.display = "none";
        }
    });
    
    const productDropdown = document.getElementById('statusProduct');
    if(productDropdown) {
        productDropdown.value = "";
    }
}

window.filterIngProductByCat = () => {
    const categoryMap = {
        "Snacks": "1", "Pizza and Pasta": "2", "Ramen": "3",
        "Rice Meals With Drinks": "4", "Rice Bowl Meals": "5",
        "Frappes": "6", "Berry Smoothies": "7", "Non - Coffee": "8",
        "Refreshers": "9", "Espresso": "10"
    };
    const catName = document.getElementById('ingCategory').value;
    const catId = categoryMap[catName] || "";
    const options = document.querySelectorAll('#ingProductName option');

    options.forEach(opt => {
        if (opt.value === "") return;
        if (catId && opt.getAttribute('data-cat') === catId) {
            opt.style.display = "";
        } else {
            opt.style.display = "none";
        }
    });

    const productDropdown = document.getElementById('ingProductName');
    if (productDropdown) productDropdown.value = "";
}

document.addEventListener('DOMContentLoaded', () => {
    const searchInput = document.getElementById('inventorySearch');
    if (searchInput) {
        searchInput.addEventListener('keyup', () => {
            const filter = searchInput.value.toUpperCase();
            const tr = document.querySelectorAll('#inventoryTable tbody tr');
            tr.forEach(row => {
                const text = row.innerText.toUpperCase();
                row.style.display = text.includes(filter) ? "" : "none";
            });
        });
    }
});