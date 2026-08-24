document.addEventListener('DOMContentLoaded', () => {
    const searchInput = document.getElementById("salesSearch");
    if (searchInput) {
        searchInput.addEventListener('keyup', searchSales);
    }
});

function searchSales() {
    const input = document.getElementById("salesSearch");
    const filter = input.value.toUpperCase();
    const table = document.getElementById("salesTable");
    const tbody = table.getElementsByTagName("tbody")[0];
    const tr = tbody.getElementsByTagName("tr");

    for (let i = 0; i < tr.length; i++) {
        if (tr[i].cells.length < 5) continue;

        const tdId = tr[i].cells[0];
        const tdTrans = tr[i].cells[1];
        const tdName = tr[i].cells[2];
        const tdProd = tr[i].cells[4];

        if (tdId && tdTrans && tdName && tdProd) {
            const textValue = [
                tdId.textContent,
                tdTrans.textContent,
                tdName.textContent,
                tdProd.textContent
            ].join(" ").toUpperCase();

            if (textValue.indexOf(filter) > -1) {
                tr[i].style.display = "";
            } else {
                tr[i].style.display = "none";
            }
        }
    }
}

function viewItems(button) {
    const itemsText = button.getAttribute('data-items');
    const items = itemsText.split(/,\s*(?=\d+x\s)/);
    const formatted = items.map(item => item.replace(/^(\d+)x\s/, '$1× ').trim()).join('\n');
    document.getElementById('modalItemsText').style.whiteSpace = 'pre-line';
    document.getElementById('modalItemsText').textContent = formatted;
    document.getElementById('itemsModal').style.display = 'flex';
}

function closeItemsModal() {
    document.getElementById('itemsModal').style.display = 'none';
}