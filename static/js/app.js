// static/js/app.js - Main application with all your existing functions

// Handle pop ups functions
async function deleteCard(cardId) {
    try {
        const response = await fetch(`${API_BASE}/cards/${cardId}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            // SILENT - just reload, no notifications
            loadCollection();
        } else {
            console.error('Error deleting card');
        }
    } catch (error) {
        console.error('Network error');
    }
}

// Search and filter functions
function toggleAdvancedSearch() {
    const advancedSearch = document.getElementById('advancedSearch');
    advancedSearch.classList.toggle('show');
}

function performSearch() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase().trim();
    
    // Get all filter values
    const certNumberFilter = document.getElementById('filterCertNumber').value.toLowerCase().trim();
    const cardNumberFilter = document.getElementById('filterCardNumber').value.toLowerCase().trim();
    const specNumberFilter = document.getElementById('filterSpecNumber').value.toLowerCase().trim();
    const gradeFilter = document.getElementById('filterGrade').value;
    const setFilter = document.getElementById('filterSet').value;
    const brandFilter = document.getElementById('filterBrand').value;
    const yearFilter = document.getElementById('filterYear').value;
    const categoryFilter = document.getElementById('filterCategory').value;
    const varietyFilter = document.getElementById('filterVariety').value;
    const minValue = parseFloat(document.getElementById('minValue').value) || 0;
    const maxValue = parseFloat(document.getElementById('maxValue').value) || Infinity;

    // Filter cards based on all criteria
    filteredCards = allCards.filter(card => {
        // Main search bar - searches across name, cert_number, set, brand, variety
        const matchesSearch = !searchTerm || 
            (card.name && card.name.toLowerCase().includes(searchTerm)) ||
            (card.cert_number && card.cert_number.toLowerCase().includes(searchTerm)) ||
            (card.set && card.set.toLowerCase().includes(searchTerm)) ||
            (card.brand && card.brand.toLowerCase().includes(searchTerm)) ||
            (card.variety && card.variety.toLowerCase().includes(searchTerm)) ||
            (card.notes && card.notes.toLowerCase().includes(searchTerm));

        // Specific field filters
        const matchesCertNumber = !certNumberFilter || 
            (card.cert_number && card.cert_number.toLowerCase().includes(certNumberFilter));
        
        const matchesCardNumber = !cardNumberFilter || 
            (card.card_number && card.card_number.toLowerCase().includes(cardNumberFilter));
        
        const matchesSpecNumber = !specNumberFilter || 
            (card.spec_number && card.spec_number.toLowerCase().includes(specNumberFilter));

        const matchesGrade = !gradeFilter || card.grade === gradeFilter;
        const matchesSet = !setFilter || card.set === setFilter;
        const matchesBrand = !brandFilter || card.brand === brandFilter;
        const matchesYear = !yearFilter || card.year === yearFilter;
        const matchesCategory = !categoryFilter || card.category === categoryFilter;
        const matchesVariety = !varietyFilter || card.variety === varietyFilter;

        // Value range filter
        const cardValue = card.current_value || 0;
        const matchesValue = cardValue >= minValue && cardValue <= maxValue;

        return matchesSearch && matchesCertNumber && matchesCardNumber && 
               matchesSpecNumber && matchesGrade && matchesSet && matchesBrand && 
               matchesYear && matchesCategory && matchesVariety && matchesValue;
    });

    // Update search results info
    updateSearchResults();

    // Display filtered cards
    displayCollection(filteredCards);

    // Update stats for filtered results
    displayFilteredStats(filteredCards);
}

function updateSearchResults() {
    const resultsDiv = document.getElementById('searchResults');
    const totalCards = allCards.length;
    const filteredCount = filteredCards.length;

    if (filteredCount === totalCards) {
        resultsDiv.innerHTML = '';
    } else {
        resultsDiv.innerHTML = `Showing ${filteredCount} of ${totalCards} cards`;
    }
}

function clearSearch() {
    document.getElementById('searchInput').value = '';
    performSearch();
}

function clearAllFilters() {
    // Clear main search
    document.getElementById('searchInput').value = '';
    
    // Clear all advanced search fields
    document.getElementById('filterCertNumber').value = '';
    document.getElementById('filterCardNumber').value = '';
    document.getElementById('filterSpecNumber').value = '';
    document.getElementById('filterGrade').value = '';
    document.getElementById('filterSet').value = '';
    document.getElementById('filterBrand').value = '';
    document.getElementById('filterYear').value = '';
    document.getElementById('filterCategory').value = '';
    document.getElementById('filterVariety').value = '';
    document.getElementById('minValue').value = '';
    document.getElementById('maxValue').value = '';
    
    // Hide advanced search
    document.getElementById('advancedSearch').classList.remove('show');
    
    // Reset to show all cards
    filteredCards = [...allCards];
    updateSearchResults();
    displayCollection(filteredCards);
    displayStats(calculateStats(allCards));
}

function populateFilterOptions() {
    // Get unique values for dropdowns from your collection data
    const grades = [...new Set(allCards.map(card => card.grade).filter(Boolean))].sort();
    const sets = [...new Set(allCards.map(card => card.set).filter(Boolean))].sort();
    const brands = [...new Set(allCards.map(card => card.brand).filter(Boolean))].sort();
    const years = [...new Set(allCards.map(card => card.year).filter(Boolean))].sort();
    const categories = [...new Set(allCards.map(card => card.category).filter(Boolean))].sort();
    const varieties = [...new Set(allCards.map(card => card.variety).filter(Boolean))].sort();

    // Populate Grade dropdown
    const gradeSelect = document.getElementById('filterGrade');
    if (gradeSelect) {
        gradeSelect.innerHTML = '<option value="">All Grades</option>';
        grades.forEach(grade => {
            gradeSelect.innerHTML += `<option value="${grade}">${grade}</option>`;
        });
    }

    // Populate Set dropdown
    const setSelect = document.getElementById('filterSet');
    if (setSelect) {
        setSelect.innerHTML = '<option value="">All Sets</option>';
        sets.forEach(set => {
            setSelect.innerHTML += `<option value="${set}">${set}</option>`;
        });
    }

    // Populate Brand dropdown
    const brandSelect = document.getElementById('filterBrand');
    if (brandSelect) {
        brandSelect.innerHTML = '<option value="">All Brands</option>';
        brands.forEach(brand => {
            brandSelect.innerHTML += `<option value="${brand}">${brand}</option>`;
        });
    }

    // Populate Year dropdown
    const yearSelect = document.getElementById('filterYear');
    if (yearSelect) {
        yearSelect.innerHTML = '<option value="">All Years</option>';
        years.forEach(year => {
            yearSelect.innerHTML += `<option value="${year}">${year}</option>`;
        });
    }

    // Populate Category dropdown
    const categorySelect = document.getElementById('filterCategory');
    if (categorySelect) {
        categorySelect.innerHTML = '<option value="">All Categories</option>';
        categories.forEach(category => {
            categorySelect.innerHTML += `<option value="${category}">${category}</option>`;
        });
    }

    // Populate Variety dropdown
    const varietySelect = document.getElementById('filterVariety');
    if (varietySelect) {
        varietySelect.innerHTML = '<option value="">All Varieties</option>';
        varieties.forEach(variety => {
            varietySelect.innerHTML += `<option value="${variety}">${variety}</option>`;
        });
    }
}

function calculateStats(cards) {
    const totalCards = cards.length;
    const totalValue = cards.reduce((sum, card) => sum + (card.current_value || 0), 0);
    const averageValue = totalCards > 0 ? totalValue / totalCards : 0;

    return {
        total_cards: totalCards,
        total_value: Math.round(totalValue * 100) / 100,
        average_value: Math.round(averageValue * 100) / 100
    };
}

function displayFilteredStats(cards) {
    const stats = calculateStats(cards);
    displayStats(stats);
}

// Look up PSA card
async function lookupCard() {
    const certNumber = document.getElementById('certInput').value.trim();
    const resultDiv = document.getElementById('lookupResult');
    
    if (!certNumber) {
        resultDiv.innerHTML = '<div class="error-message">Please enter a cert number</div>';
        return;
    }
    
    resultDiv.innerHTML = '<div class="loading">🔍 Looking up PSA card...</div>';
    
    try {
        const response = await fetch(`${API_BASE}/psa/lookup/${certNumber}`);
        const data = await response.json();
        
        console.log('API Response:', data);
        
        if (response.ok) {
            if (data.success && data.card_data) {
                currentCardData = data.card_data;
                console.log('Card Data:', currentCardData);
                displayCardResult(data.card_data);
            } else {
                resultDiv.innerHTML = `<div class="error-message">❌ ${data.error || 'No card data found'}</div>`;
            }
        } else {
            resultDiv.innerHTML = `<div class="error-message">❌ ${data.error || 'API Error'}</div>`;
        }
    } catch (error) {
        console.error('Network error:', error);
        resultDiv.innerHTML = `<div class="error-message">❌ Network error: ${error.message}</div>`;
    }
}

function displayCardResult(cardData) {
    const resultDiv = document.getElementById('lookupResult');
    
    resultDiv.innerHTML = `
        <div class="card-preview">
            <h3>✅ PSA Card Found!</h3>
            
            <div class="card-details">
                <div class="detail-item">
                    <div class="detail-label">Cert Number</div>
                    <div class="detail-value">${cardData.cert_number || 'N/A'}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Card Name</div>
                    <div class="detail-value">${cardData.name || 'N/A'}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Set/Brand</div>
                    <div class="detail-value">${cardData.set || 'N/A'}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Card Number</div>
                    <div class="detail-value">${cardData.card_number || 'N/A'}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Spec Number</div>
                    <div class="detail-value">${cardData.spec_number || 'N/A'}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Grade</div>
                    <div class="detail-value">${cardData.grade || 'N/A'}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Year</div>
                    <div class="detail-value">${cardData.year || 'N/A'}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Category</div>
                    <div class="detail-value">${cardData.category || 'N/A'}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Variety</div>
                    <div class="detail-value">${cardData.variety || 'N/A'}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Label Type</div>
                    <div class="detail-value">${cardData.label_type || 'N/A'}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Population (This Grade)</div>
                    <div class="detail-value">${cardData.total_population || 'N/A'}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Population Higher</div>
                    <div class="detail-value">${cardData.population_higher || 'N/A'}</div>
                </div>
            </div>

            ${(cardData.image_front || cardData.image_back || cardData.image_url) ? `
                <div class="card-image">
                    <h4 style="margin-bottom: 15px;">📸 Card Images</h4>
                    <div style="display: flex; gap: 20px; justify-content: center; flex-wrap: wrap;">
                        ${cardData.image_front ? `
                            <div style="text-align: center;">
                                <p style="margin-bottom: 10px; font-weight: bold;">Front</p>
                                <img src="${cardData.image_front}" alt="Card Front" style="max-width: 200px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);" onerror="this.style.display='none'">
                            </div>
                        ` : ''}
                        ${cardData.image_back ? `
                            <div style="text-align: center;">
                                <p style="margin-bottom: 10px; font-weight: bold;">Back</p>
                                <img src="${cardData.image_back}" alt="Card Back" style="max-width: 200px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);" onerror="this.style.display='none'">
                            </div>
                        ` : ''}
                        ${cardData.image_url && !cardData.image_front && !cardData.image_back ? `
                            <div style="text-align: center;">
                                <img src="${cardData.image_url}" alt="Card Image" style="max-width: 200px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);" onerror="this.style.display='none'">
                            </div>
                        ` : ''}
                    </div>
                </div>
            ` : '<p style="text-align: center; color: #6b7280; margin: 20px 0; font-style: italic;">📷 Images not available (may be rate limited)</p>'}

            <div class="add-form">
                <h4>💰 Add Purchase Information (Optional)</h4>
                <div class="form-group">
                    <input type="number" id="purchasePrice" placeholder="Purchase Price ($)" step="0.01">
                    <input type="number" id="currentValue" placeholder="Current Value ($)" step="0.01">
                </div>
                <input type="text" id="notes" placeholder="Notes (optional)" style="width: 100%; margin-bottom: 15px;">
                
                <button onclick="addToCollection()" class="btn btn-success">
                    ➕ Add to Collection
                </button>
            </div>
        </div>
    `;
}

async function addToCollection() {
    if (!currentCardData) {
        alert('No card data available');
        return;
    }

    const purchasePrice = document.getElementById('purchasePrice').value;
    const currentValue = document.getElementById('currentValue').value;
    const notes = document.getElementById('notes').value;

    const cardToAdd = {
        ...currentCardData,
        purchase_price: purchasePrice || 0,
        current_value: currentValue || 0,
        notes: notes || ''
    };

    try {
        const response = await fetch(`${API_BASE}/cards/add`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(cardToAdd)
        });

        const data = await response.json();

        if (response.ok) {
            alert('✅ Card added to collection!');
            document.getElementById('certInput').value = '';
            document.getElementById('lookupResult').innerHTML = '';
            currentCardData = null;
            loadCollection();
        } else {
            alert(`❌ Error: ${data.error}`);
        }
    } catch (error) {
        alert(`❌ Network error: ${error.message}`);
    }
}

// Modal functions
function openCardModal(cardId) {
    const card = allCards.find(c => c.id === cardId);
    if (!card) return;

    document.getElementById('modalTitle').textContent = card.name || 'Card Details';

    const modalImages = document.getElementById('modalImages');
    let imagesHTML = '';
    
    if (card.image_front || card.image_back) {
        if (card.image_front) {
            imagesHTML += `
                <div class="modal-image-container">
                    <img src="${card.image_front}" alt="Card Front">
                    <div class="modal-image-label">Front</div>
                </div>
            `;
        }
        if (card.image_back) {
            imagesHTML += `
                <div class="modal-image-container">
                    <img src="${card.image_back}" alt="Card Back">
                    <div class="modal-image-label">Back</div>
                </div>
            `;
        }
    } else {
        imagesHTML = '<p style="text-align: center; color: #6b7280;">No images available</p>';
    }
    modalImages.innerHTML = imagesHTML;

    const modalDetails = document.getElementById('modalDetails');
    modalDetails.innerHTML = `
        <div class="modal-detail-item">
            <div class="modal-detail-label">Cert Number</div>
            <div class="modal-detail-value">${card.cert_number || 'N/A'}</div>
        </div>
        <div class="modal-detail-item">
            <div class="modal-detail-label">Card Name</div>
            <div class="modal-detail-value">${card.name || 'N/A'}</div>
        </div>
        <div class="modal-detail-item">
            <div class="modal-detail-label">Set/Brand</div>
            <div class="modal-detail-value">${card.set || 'N/A'}</div>
        </div>
        <div class="modal-detail-item">
            <div class="modal-detail-label">Card Number</div>
            <div class="modal-detail-value">${card.card_number || 'N/A'}</div>
        </div>
        <div class="modal-detail-item">
            <div class="modal-detail-label">Spec Number</div>
            <div class="modal-detail-value">${card.spec_number || 'N/A'}</div>
        </div>
        <div class="modal-detail-item">
            <div class="modal-detail-label">Grade</div>
            <div class="modal-detail-value">${card.grade || 'N/A'}</div>
        </div>
        <div class="modal-detail-item">
            <div class="modal-detail-label">Grade Description</div>
            <div class="modal-detail-value">${card.grade_description || 'N/A'}</div>
        </div>
        <div class="modal-detail-item">
            <div class="modal-detail-label">Year</div>
            <div class="modal-detail-value">${card.year || 'N/A'}</div>
        </div>
        <div class="modal-detail-item">
            <div class="modal-detail-label">Category</div>
            <div class="modal-detail-value">${card.category || 'N/A'}</div>
        </div>
        <div class="modal-detail-item">
            <div class="modal-detail-label">Variety</div>
            <div class="modal-detail-value">${card.variety || 'N/A'}</div>
        </div>
        <div class="modal-detail-item">
            <div class="modal-detail-label">Label Type</div>
            <div class="modal-detail-value">${card.label_type || 'N/A'}</div>
        </div>
        <div class="modal-detail-item">
            <div class="modal-detail-label">Population (This Grade)</div>
            <div class="modal-detail-value">${card.total_population || 'N/A'}</div>
        </div>
        <div class="modal-detail-item">
            <div class="modal-detail-label">Population Higher</div>
            <div class="modal-detail-value">${card.population_higher || 'N/A'}</div>
        </div>
        <div class="modal-detail-item">
            <div class="modal-detail-label">Purchase Price</div>
            <div class="modal-detail-value">${card.purchase_price > 0 ? '$' + card.purchase_price : 'Not specified'}</div>
        </div>
        <div class="modal-detail-item">
            <div class="modal-detail-label">Current Value</div>
            <div class="modal-detail-value">${card.current_value > 0 ? '$' + card.current_value : 'Not specified'}</div>
        </div>
        ${card.notes ? `
            <div class="modal-detail-item" style="grid-column: 1 / -1;">
                <div class="modal-detail-label">Notes</div>
                <div class="modal-detail-value">${card.notes}</div>
            </div>
        ` : ''}
        <div class="modal-detail-item">
            <div class="modal-detail-label">Added to Collection</div>
            <div class="modal-detail-value">${card.added_date || 'N/A'}</div>
        </div>
    `;

    document.getElementById('cardModal').classList.add('show');
}

function closeModal() {
    document.getElementById('cardModal').classList.remove('show');
}

async function loadCollection() {
    try {
        const [cardsResponse, statsResponse] = await Promise.all([
            fetch(`${API_BASE}/cards`),
            fetch(`${API_BASE}/stats`)
        ]);

        const cards = await cardsResponse.json();
        const stats = await statsResponse.json();

        allCards = cards;
        filteredCards = [...cards]; // Initialize filtered cards with all cards
        
        // Populate filter dropdowns with available options
        populateFilterOptions();
        
        // Display initial results
        updateSearchResults();
        displayStats(stats);
        displayCollection(filteredCards);
    } catch (error) {
        console.error('Error loading collection:', error);
    }
}

function displayStats(stats) {
    const statsDiv = document.getElementById('collectionStats');
    
    if (statsDiv) {
        statsDiv.innerHTML = `
            <div class="stat-card">
                <div class="stat-value">${stats.total_cards}</div>
                <div class="stat-label">Total Cards</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">$${stats.total_value}</div>
                <div class="stat-label">Total Value</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">$${stats.average_value}</div>
                <div class="stat-label">Average Value</div>
            </div>
        `;
    }
}

function displayCollection(cards) {
    const gridDiv = document.getElementById('collectionGrid');
    
    if (!gridDiv) return;
    
    if (cards.length === 0) {
        gridDiv.innerHTML = `
            <div class="empty-state">
                <h3>No cards in collection yet</h3>
                <p>Use the lookup tool above to add your first card!</p>
            </div>
        `;
        return;
    }

    gridDiv.innerHTML = cards.map(card => `
        <div class="collection-card" onclick="openCardModal(${card.id})">
            <button onclick="deleteCard(${card.id}); event.stopPropagation();" class="btn btn-danger delete-btn">×</button>
            <div class="grade">PSA ${card.grade}</div>
            
            ${card.image_front ? `
                <div class="card-image-container">
                    <img src="${card.image_front}" alt="${card.name}" onerror="this.style.display='none'">
                </div>
            ` : ''}
            
            <div class="card-details-grid">
                <h4>${card.name}</h4>
                <p><strong>Set:</strong> ${card.set}</p>
                <p><strong>Cert:</strong> ${card.cert_number}</p>
                
                ${card.card_number ? `<p><strong>Number:</strong> ${card.card_number}</p>` : ''}
                ${card.year ? `<p><strong>Year:</strong> ${card.year}</p>` : ''}
                
                <div style="margin-top: 10px; border-top: 1px solid #e2e8f0; padding-top: 10px;">
                    ${card.purchase_price > 0 ? `<p><strong>Purchase:</strong> ${card.purchase_price}</p>` : ''}
                    ${card.current_value > 0 ? `<p><strong>Value:</strong> ${card.current_value}</p>` : ''}
                </div>
                
                ${card.notes ? `<p style="margin-top: 10px; font-style: italic; color: #6b7280;">"${card.notes}"</p>` : ''}
            </div>
        </div>
    `).join('');
}

async function deleteCard(cardId) {
    if (!confirm('Are you sure you want to remove this card?')) return;

    try {
        const response = await fetch(`${API_BASE}/cards/${cardId}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            loadCollection();
        } else {
            alert('Error deleting card');
        }
    } catch (error) {
        alert('Network error');
    }
}

// Main app initialization
class PSACardApp {
    constructor() {
        this.init();
    }

    async init() {
        await ComponentLoader.loadAllComponents();
        this.setupEventListeners();
        await loadCollection();
        console.log('PSA Card App initialized successfully');
    }

    setupEventListeners() {
        // Enter key handlers
        document.addEventListener('keypress', (e) => {
            if (e.target.id === 'certInput' && e.key === 'Enter') {
                lookupCard();
            }
            if (e.target.id === 'searchInput' && e.key === 'Enter') {
                performSearch();
            }
        });

        // Modal close handlers
        document.addEventListener('click', (e) => {
            if (e.target.id === 'cardModal') {
                closeModal();
            }
        });

        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                closeModal();
            }
        });
    }
}

// Initialize the app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new PSACardApp();
});