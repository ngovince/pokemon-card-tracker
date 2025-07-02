#!/bin/bash

# setup-modular.sh - Script to create modular file structure
# Run this from your pokemon-card-tracker directory

echo "🎴 Setting up modular PSA Card Collection structure..."

# Create directories
echo "📁 Creating directories..."
mkdir -p static/css
mkdir -p static/js
mkdir -p static/components

# Create CSS files
echo "🎨 Creating CSS files..."

# Base CSS
cat > static/css/base.css << 'EOF'
/* static/css/base.css - Base styles and layout */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    padding: 20px;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
}

/* Basic button styles */
.btn {
    padding: 15px 25px;
    border: none;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
}

.btn-primary {
    background: #667eea;
    color: white;
}

.btn-primary:hover {
    background: #5a6fd8;
    transform: translateY(-2px);
}

.btn-success {
    background: #10b981;
    color: white;
}

.btn-success:hover {
    background: #059669;
}

.btn-danger {
    background: #ef4444;
    color: white;
    padding: 8px 12px;
    font-size: 14px;
}

.btn-danger:hover {
    background: #dc2626;
}

.btn-secondary {
    background: #6b7280;
    color: white;
    padding: 12px 20px;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    cursor: pointer;
    transition: all 0.3s ease;
}

.btn-secondary:hover {
    background: #4b5563;
}

.btn-small {
    padding: 8px 16px;
    font-size: 13px;
}

/* Utility classes */
.error-message {
    background: #fef2f2;
    color: #991b1b;
    padding: 15px;
    border-radius: 8px;
    border-left: 4px solid #ef4444;
}

.loading {
    text-align: center;
    padding: 20px;
    color: #6b7280;
}

.empty-state {
    text-align: center;
    padding: 40px;
    color: #6b7280;
}
EOF

# Components CSS - Extract from your current file
cat > static/css/components.css << 'EOF'
/* Header */
.header {
    text-align: center;
    color: white;
    margin-bottom: 30px;
}

.header h1 {
    font-size: 2.5rem;
    margin-bottom: 10px;
}

.header p {
    font-size: 1.1rem;
    opacity: 0.9;
}

/* Lookup Section */
.lookup-section {
    background: white;
    border-radius: 12px;
    padding: 30px;
    margin-bottom: 30px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.1);
}

.lookup-form {
    display: flex;
    gap: 15px;
    margin-bottom: 20px;
    align-items: center;
}

.lookup-form input {
    flex: 1;
    padding: 15px;
    border: 2px solid #e1e5e9;
    border-radius: 8px;
    font-size: 16px;
}

.lookup-form input:focus {
    outline: none;
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(102,126,234,0.1);
}

.result-section {
    margin-top: 20px;
}

.card-preview {
    background: #f8fafc;
    border: 2px solid #10b981;
    border-radius: 12px;
    padding: 25px;
    margin-top: 20px;
}

.card-preview h3 {
    color: #10b981;
    margin-bottom: 20px;
    font-size: 1.5rem;
}

.card-details {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 15px;
    margin-bottom: 20px;
}

.detail-item {
    background: white;
    padding: 15px;
    border-radius: 8px;
    border-left: 4px solid #667eea;
}

.detail-label {
    font-weight: 600;
    color: #6b7280;
    font-size: 12px;
    text-transform: uppercase;
    margin-bottom: 5px;
}

.detail-value {
    color: #1f2937;
    font-size: 16px;
}

.card-image {
    text-align: center;
    margin: 20px 0;
}

.card-image img {
    max-width: 200px;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.add-form {
    background: #f1f5f9;
    padding: 20px;
    border-radius: 8px;
    margin-top: 20px;
}

.add-form h4 {
    margin-bottom: 15px;
    color: #1f2937;
}

.form-group {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 15px;
    margin-bottom: 15px;
}

.form-group input {
    padding: 10px;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    font-size: 14px;
}

/* Collection Section */
.collection-section {
    background: white;
    border-radius: 12px;
    padding: 30px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.1);
}

.collection-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 25px;
    flex-wrap: wrap;
    gap: 15px;
}

.search-container {
    display: flex;
    align-items: center;
    gap: 10px;
    flex: 1;
    max-width: 600px;
}

.search-input {
    flex: 1;
    padding: 12px 15px;
    border: 2px solid #e1e5e9;
    border-radius: 8px;
    font-size: 14px;
}

.search-input:focus {
    outline: none;
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(102,126,234,0.1);
}

.search-buttons {
    display: flex;
    gap: 10px;
}

.advanced-search {
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 20px;
    display: none;
}

.advanced-search.show {
    display: block;
}

.advanced-search h4 {
    margin-bottom: 15px;
    color: #1f2937;
}

.filter-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
}

.filter-group {
    display: flex;
    flex-direction: column;
}

.filter-group label {
    font-weight: 600;
    color: #374151;
    margin-bottom: 5px;
    font-size: 13px;
}

.filter-group select,
.filter-group input {
    padding: 8px 12px;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    font-size: 14px;
}

.filter-actions {
    display: flex;
    gap: 10px;
    margin-top: 15px;
    justify-content: flex-end;
}

.search-results-info {
    margin-bottom: 15px;
    color: #6b7280;
    font-style: italic;
}

/* Stats */
.stats {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 15px;
    margin-bottom: 25px;
}

.stat-card {
    background: linear-gradient(135deg, #667eea, #764ba2);
    color: white;
    padding: 20px;
    border-radius: 8px;
    text-align: center;
}

.stat-value {
    font-size: 2rem;
    font-weight: bold;
    margin-bottom: 5px;
}

.stat-label {
    font-size: 0.9rem;
    opacity: 0.9;
}

/* Collection Grid */
.collection-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 20px;
}

.collection-card {
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    padding: 15px;
    position: relative;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    cursor: pointer;
}

.collection-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 30px rgba(0,0,0,0.15);
}

.collection-card h4 {
    color: #1f2937;
    margin-bottom: 10px;
    font-size: 14px;
}

.collection-card .grade {
    background: #667eea;
    color: white;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: bold;
    position: absolute;
    top: 10px;
    right: 10px;
    z-index: 2;
}

.card-image-container {
    text-align: center;
    margin: 10px 0 15px 0;
    background: white;
    border-radius: 8px;
    padding: 10px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.card-image-container img {
    max-width: 100%;
    max-height: 200px;
    border-radius: 6px;
    object-fit: contain;
}

.card-details-grid {
    font-size: 13px;
    line-height: 1.4;
}

.card-details-grid p {
    margin: 4px 0;
}

.delete-btn {
    position: absolute;
    top: 10px;
    left: 10px;
    padding: 4px 8px;
    font-size: 12px;
}
EOF

# Editable Fields CSS
cat > static/css/editable-fields.css << 'EOF'
/* Editable field styles - Add these for update functionality */
.editable-field {
    position: relative;
    min-height: 24px;
    padding: 6px 10px;
    border: 2px solid transparent;
    border-radius: 4px;
    background: #f8f9fa;
    transition: all 0.2s ease;
    cursor: pointer;
    display: inline-block;
    min-width: 80px;
}

.editable-field:hover {
    background: #e9ecef;
    border-color: #007bff;
}

.editable-field.editing {
    background: white;
    border-color: #007bff;
    box-shadow: 0 0 0 3px rgba(0,123,255,0.1);
    cursor: auto;
}

.edit-input,
.edit-textarea {
    width: 100%;
    padding: 4px 6px;
    border: 1px solid #ddd;
    border-radius: 3px;
    font-size: 13px;
    font-family: inherit;
    resize: vertical;
}

.edit-input:focus,
.edit-textarea:focus {
    outline: none;
    border-color: #007bff;
}

.edit-actions {
    margin-top: 6px;
    display: flex;
    gap: 6px;
}

.edit-btn {
    padding: 4px 8px;
    border: none;
    border-radius: 3px;
    font-size: 11px;
    font-weight: 500;
    cursor: pointer;
    transition: background-color 0.2s ease;
}

.save-btn {
    background: #28a745;
    color: white;
}

.save-btn:hover:not(:disabled) {
    background: #218838;
}

.cancel-btn {
    background: #6c757d;
    color: white;
}

.cancel-btn:hover:not(:disabled) {
    background: #5a6268;
}

.edit-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.update-success {
    animation: flash-success 1s ease-out;
}

@keyframes flash-success {
    0% { background-color: #d4edda; }
    100% { background-color: transparent; }
}
EOF

# Modal CSS
cat > static/css/modals.css << 'EOF'
/* Modal styles */
.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0,0,0,0.5);
    animation: fadeIn 0.3s ease;
}

.modal.show {
    display: flex;
    align-items: center;
    justify-content: center;
}

.modal-content {
    background: white;
    margin: 20px;
    padding: 30px;
    border-radius: 12px;
    width: 90%;
    max-width: 800px;
    max-height: 90vh;
    overflow-y: auto;
    position: relative;
    animation: slideIn 0.3s ease;
}

.modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    border-bottom: 2px solid #e2e8f0;
    padding-bottom: 15px;
}

.modal-title {
    color: #1f2937;
    font-size: 1.5rem;
    margin: 0;
}

.close-btn {
    background: #ef4444;
    color: white;
    border: none;
    padding: 8px 12px;
    border-radius: 6px;
    cursor: pointer;
    font-size: 18px;
    font-weight: bold;
}

.close-btn:hover {
    background: #dc2626;
}

.modal-images {
    display: flex;
    gap: 20px;
    justify-content: center;
    margin: 20px 0;
    flex-wrap: wrap;
}

.modal-image-container {
    text-align: center;
}

.modal-image-container img {
    max-width: 250px;
    max-height: 350px;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    object-fit: contain;
}

.modal-image-label {
    margin-top: 10px;
    font-weight: bold;
    color: #6b7280;
}

.modal-details {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 15px;
    margin: 20px 0;
}

.modal-detail-item {
    background: #f8fafc;
    padding: 15px;
    border-radius: 8px;
    border-left: 4px solid #667eea;
}

.modal-detail-label {
    font-weight: 600;
    color: #6b7280;
    font-size: 12px;
    text-transform: uppercase;
    margin-bottom: 5px;
}

.modal-detail-value {
    color: #1f2937;
    font-size: 16px;
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

@keyframes slideIn {
    from { transform: translateY(-50px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
}
EOF

echo "✅ CSS files created!"

# Create JavaScript files
echo "⚡ Creating JavaScript files..."

# Config
cat > static/js/config.js << 'EOF'
// Configuration and constants
const API_BASE = 'http://localhost:8080/api';

// Global state
let currentCardData = null;
let allCards = [];
let filteredCards = [];
EOF

# Component Loader
cat > static/js/component-loader.js << 'EOF'
// Component loader utility
const ComponentLoader = {
    async loadComponent(componentName, targetId) {
        try {
            const response = await fetch(`components/${componentName}.html`);
            const html = await response.text();
            document.getElementById(targetId).innerHTML = html;
        } catch (error) {
            console.error(`Failed to load component ${componentName}:`, error);
        }
    },

    async loadAllComponents() {
        const components = [
            { name: 'header', target: 'header-component' },
            { name: 'lookup-section', target: 'lookup-component' },
            { name: 'collection-section', target: 'collection-component' },
            { name: 'modal', target: 'modal-component' }
        ];

        await Promise.all(components.map(comp => 
            this.loadComponent(comp.name, comp.target)
        ));
    }
};
EOF

echo "📄 Creating HTML component files..."

# Header component
cat > static/components/header.html << 'EOF'
<div class="header">
    <h1>🎴 PSA Card Lookup & Collection</h1>
    <p>Look up PSA graded cards and build your collection</p>
</div>
EOF

# Lookup section component
cat > static/components/lookup-section.html << 'EOF'
<div class="lookup-section">
    <h2>🔍 Look Up PSA Card</h2>
    <div class="lookup-form">
        <input 
            type="text" 
            id="certInput" 
            placeholder="Enter PSA Cert Number (e.g., 12345678)"
            maxlength="10"
        >
        <button onclick="lookupCard()" class="btn btn-primary">Look Up Card</button>
    </div>
    
    <div id="lookupResult" class="result-section"></div>
</div>
EOF

echo "🎉 Modular structure created successfully!"
echo ""
echo "📋 Next Steps:"
echo "1. Replace your existing static/index.html with the new modular version"
echo "2. Copy the remaining JavaScript functions to static/js/app.js"
echo "3. Add the PUT endpoint to your backend (main.go or app.py)"
echo "4. Test your application"
echo ""
echo "🚀 Your PSA Card Collection app is now modular and maintainable!"