let orderData = {};
let currentPage = 1;
const MAX_PAGES = 10;
let selectedPayment = "Cash"; 
let metaGenerated = false;

document.addEventListener('DOMContentLoaded', () => { 
    changePage(1); 
    setInterval(updateClock, 1000);
    updateClock();
    document.getElementById('displayDate').innerText = new Date().toLocaleDateString();
});

function changePage(pageNum) {
    document.querySelectorAll('.menu-page').forEach(pg => {
        pg.classList.remove('active');
        pg.style.display = 'none';
    });
    
    const target = document.getElementById('page-' + pageNum);
    if (target) {
        target.style.display = 'block';
        setTimeout(() => {
            target.classList.add('active');
        }, 10);
        currentPage = pageNum;
        document.getElementById('page-num-display').innerText = "Page " + currentPage;
    }
}

function nextPage() { 
    if (currentPage < MAX_PAGES) {
        changePage(currentPage + 1); 
    }
}

function prevPage() { 
    if (currentPage > 1) {
        changePage(currentPage - 1); 
    }
}

function setOrderType(type) {
    document.getElementById('displayType').innerText = type;
    document.getElementById('displayDate').innerText = new Date().toLocaleDateString();
    document.querySelectorAll('.toggle-btn').forEach(btn => {
        btn.classList.remove('active-type');
    });
    
    if (type === 'Dine In') {
        document.getElementById('dineInBtn').classList.add('active-type');
    } else {
        document.getElementById('takeOutBtn').classList.add('active-type');
    }
}

function setPaymentMethod(method, element) {
    selectedPayment = method;
    document.getElementById('displayPay').innerText = method;
    document.querySelectorAll('.pay-option').forEach(btn => {
        btn.classList.remove('active');
    });
    element.classList.add('active');
}

function addToOrder(id, name, price) {
    document.getElementById('selection-status').style.display = 'block';
    
    if (orderData[id]) {
        orderData[id].qty++;
    } else {
        orderData[id] = { 
            name: name, 
            price: parseFloat(price), 
            qty: 1 
        };
    }
    renderOrder();
}

function removeFromOrder(id) {
    delete orderData[id];
    renderOrder();
}

function renderOrder() {
    const list = document.getElementById('receipt-list');
    let total = 0;
    list.innerHTML = "";
    
    const itemKeys = Object.keys(orderData);
    
    if (itemKeys.length === 0) {
        document.getElementById('selection-status').style.display = 'none';
    }

    itemKeys.forEach(id => {
        let item = orderData[id];
        let subtotal = item.qty * item.price;
        total += subtotal;
        
        list.innerHTML += `
            <div class="order-list-item">
                <span><strong>${item.qty}x</strong> ${item.name}</span>
                <span>
                    ₱${subtotal.toFixed(2)} 
                    <i class="fa-solid fa-trash" onclick="removeFromOrder('${id}')" 
                       style="cursor:pointer; color:#7a1d26; margin-left:10px;"></i>
                </span>
            </div>`;
    });
    
    document.getElementById('total-price').innerText = '₱' + total.toFixed(2);
}

function clearCart() {
    if (Object.keys(orderData).length === 0) {
        return;
    }
    if (confirm("Are you sure you want to clear the entire order?")) {
        orderData = {}; 
        renderOrder(); 
        document.getElementById('custName').value = ""; 
        autoGenerateMeta(); 
    }
}

function autoGenerateMeta() {
    const nameInput = document.getElementById('custName').value.trim();
    if (nameInput.length > 0 && !metaGenerated) {
        document.getElementById('displayId').innerText = "#" + Math.floor(1000 + Math.random() * 9000);
        metaGenerated = true;
    } else if (nameInput.length === 0) {
        metaGenerated = false;
        document.getElementById('displayId').innerText = "";
    }
}

function viewOrderDetails() {
    if (Object.keys(orderData).length === 0) {
        return alert("Cart is empty!");
    }

    let grandTotal = 0;
    let rows = '';
    for (let id in orderData) {
        let item = orderData[id];
        let subtotal = item.qty * item.price;
        grandTotal += subtotal;
        rows += `<tr>
            <td style="padding:7px 10px; color:#333; font-size:0.85rem;">${item.name}</td>
            <td style="padding:7px 10px; color:#333; text-align:center; font-size:0.85rem;">${item.qty}</td>
            <td style="padding:7px 10px; color:#333; text-align:right; font-size:0.85rem;">₱${subtotal.toFixed(2)}</td>
        </tr>`;
    }

    let html = `<div style="background:#ffffff; color:#333; padding:16px; border-radius:8px; font-family:'Poppins',sans-serif;">
        <div style="margin-bottom:10px; font-weight:600; color:#555; font-size:0.85rem;">Items:</div>
        <table style="width:100%; border-collapse:collapse;">
            <thead>
                <tr style="border-bottom:1px solid #ddd;">
                    <th style="padding:6px 10px; text-align:left; color:#666; font-weight:600; font-size:0.78rem; font-family:'Poppins',sans-serif;">Product</th>
                    <th style="padding:6px 10px; text-align:center; color:#666; font-weight:600; font-size:0.78rem; font-family:'Poppins',sans-serif;">Qty</th>
                    <th style="padding:6px 10px; text-align:right; color:#666; font-weight:600; font-size:0.78rem; font-family:'Poppins',sans-serif;">Total</th>
                </tr>
            </thead>
            <tbody>${rows}</tbody>
        </table>
        <div style="border-top:1px solid #ddd; margin-top:12px; padding-top:12px; font-size:0.85rem; line-height:1.8; color:#333;">
            <div>Total Amount: ₱${grandTotal.toFixed(2)}</div>
            <div>Payment Method: ${selectedPayment}</div>
        </div>
    </div>`;

    document.getElementById('modalContent').innerHTML = html;
    document.getElementById('viewModal').style.display = 'flex';
}

function processCheckout() {
    const nameEl = document.getElementById('custName');
    const name = nameEl ? nameEl.value.trim() : "Walk-in";
    const displayIdEl = document.getElementById('displayId');
    const orderId = displayIdEl ? displayIdEl.innerText.replace('#', '') : Math.floor(1000 + Math.random() * 9000);
    const totalText = document.getElementById('total-price').innerText.replace('₱', '').replace(',', '');
    const totalAmount = parseFloat(totalText);

    if (!name) {
        return alert("Please enter Customer Name!");
    }
    if (Object.keys(orderData).length === 0) {
        return alert("Add items first!");
    }

    let cashAmount = 0;
    let gcashRef = "";

    if (selectedPayment.toLowerCase() === 'gcash') {
        const refInput = prompt(`Total Amount: ₱${totalAmount.toFixed(2)}\nEnter GCash Reference Number:`);
        if (refInput === null) return;
        if (!refInput.trim()) return alert("Please enter a valid reference number.");
        gcashRef = refInput.trim();
        cashAmount = totalAmount;
    } else if (selectedPayment.toLowerCase() === 'card') {
        const refInput = prompt(`Total Amount: ₱${totalAmount.toFixed(2)}\nEnter Card Reference Number:`);
        if (refInput === null) return;
        if (!refInput.trim()) return alert("Please enter a valid reference number.");
        gcashRef = refInput.trim();
        cashAmount = totalAmount;
    } else {
        const cashInput = prompt(`Total Amount: ₱${totalAmount.toFixed(2)}\nEnter Cash Amount:`);
        if (cashInput === null) return;
        cashAmount = parseFloat(cashInput);
        if (isNaN(cashAmount) || cashAmount < totalAmount) {
            return alert("Error: Invalid or insufficient cash amount.");
        }
    }

    const changeAmount = cashAmount - totalAmount;
    const productsSold = Object.values(orderData).map(item => `${item.qty}x ${item.name}`).join(', ');

    const formData = new FormData();
    formData.append('order_id', orderId);
    formData.append('customer_name', name);
    formData.append('product_sold', productsSold);
    formData.append('cash_amount', cashAmount);
    formData.append('total_amount', totalAmount);
    formData.append('change_amount', changeAmount);
    formData.append('payment_method', selectedPayment);
    formData.append('gcash_reference', gcashRef);

    fetch('save_order.php', { method: 'POST', body: formData })
    .then(response => response.text())
    .then(data => {
        const now = new Date();
        const displayTypeEl = document.getElementById('displayType');
        const orderType = displayTypeEl ? displayTypeEl.innerText : "Order";

        const mm = String(now.getMonth() + 1).padStart(2, '0');
        const dd = String(now.getDate()).padStart(2, '0');
        const yyyy = now.getFullYear();
        const hours = now.getHours();
        const minutes = String(now.getMinutes()).padStart(2, '0');
        const ampm = hours >= 12 ? 'PM' : 'AM';
        const hour12 = hours % 12 || 12;
        const dateStr = `${mm}/${dd}/${yyyy}`;
        const timeStr = `${hour12}:${minutes} ${ampm}`;

        let receiptText = "         TOYLAND BISTRO         \n";
        receiptText += "--------------------------------\n";
        receiptText += `Date: ${dateStr} ${timeStr}\n`;
        receiptText += `Order #: ${orderId}\n`;
        receiptText += `Customer: ${name}\n`;
        receiptText += `Type: ${orderType}\n`;
        receiptText += `Payment Method: ${selectedPayment}\n`;
        if ((selectedPayment.toLowerCase() === 'gcash' || selectedPayment.toLowerCase() === 'card') && gcashRef) {
            receiptText += `Ref No: ${gcashRef}\n`;
        }
        receiptText += "--------------------------------\n";

        for (let id in orderData) {
            let item = orderData[id];
            let subtotal = item.qty * item.price;
            receiptText += `${item.qty}x ${item.name}\n`;
            receiptText += `   ₱${parseFloat(item.price).toFixed(2)} x ${item.qty} = ₱${subtotal.toFixed(2)}\n`;
        }

        receiptText += "--------------------------------\n";
        receiptText += `TOTAL:           ₱${totalAmount.toFixed(2)}\n`;
        receiptText += `AMOUNT PAID:     ₱${cashAmount.toFixed(2)}\n`;
        receiptText += `CHANGE:          ₱${changeAmount.toFixed(2)}\n`;
        receiptText += "--------------------------------\n";
        receiptText += "      Thank you for ordering!   \n";

        const receiptEl = document.getElementById('receiptContent');
        receiptEl.style.display = 'flex';
        receiptEl.style.justifyContent = 'center';
        receiptEl.style.textAlign = 'center';
        receiptEl.innerHTML = `<span style="display:inline-block; text-align:left; white-space:pre-wrap;">${receiptText.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')}</span>`;

        document.getElementById('receiptModal').style.display = 'flex';
    })
    .catch(error => {
        alert("An error occurred while saving the order.");
    });
}

function closeReceipt() {
    document.getElementById('receiptModal').style.display = 'none';
}

function printReceipt() {
    document.getElementById('receiptModal').style.display = 'none';
    location.reload(); 
}

function filterMenu() {
    let input = document.getElementById('menuSearch').value.toUpperCase();
    let pages = document.querySelectorAll('.menu-page');
    let allCards = document.querySelectorAll('.menu-item-card, .item-card');
    let categoryLabels = document.querySelectorAll('.category-label');

    if (input.trim() === "") {
        categoryLabels.forEach(lbl => lbl.style.display = "block");
        
        pages.forEach(pg => {
            if (pg.id === 'page-' + currentPage) {
                pg.style.display = 'block';
                pg.classList.add('active');
            } else {
                pg.style.display = 'none';
                pg.classList.remove('active');
            }
        });
        allCards.forEach(card => card.style.display = "");
    } else {
        categoryLabels.forEach(lbl => lbl.style.display = "none");

        pages.forEach(pg => {
            pg.style.display = 'block';
            pg.classList.remove('active');
        });
        
        allCards.forEach(card => {
            let title = card.querySelector('.item-name').innerText;
            if (title.toUpperCase().indexOf(input) > -1) {
                card.style.display = ""; 
            } else {
                card.style.display = "none";
            }
        });
    }
}

function updateClock() {
    const now = new Date();
    const timeString = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
    const dateString = now.toLocaleDateString([], { weekday: 'short', month: 'short', day: 'numeric' });
    const clockEl = document.getElementById('live-clock');
    const clockElStandard = document.getElementById('clock');
    if (clockEl) {
        clockEl.innerHTML = `${dateString} &bull; ${timeString}`;
    }
    if (clockElStandard) {
        clockElStandard.innerHTML = timeString;
    }
}