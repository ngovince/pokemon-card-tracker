# app.py - PSA Card Lookup with Images (CORRECTED)
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import os
import requests
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)

# PSA API Configuration
PSA_API_BASE = "https://api.psacard.com/publicapi"
PSA_AUTH_TOKEN = os.getenv('PSA_AUTH_TOKEN')

# Simple in-memory storage
collection = []
next_id = 1

def get_psa_headers():
    """Get headers for PSA API requests"""
    if not PSA_AUTH_TOKEN:
        return None
    return {
        'authorization': f'bearer {PSA_AUTH_TOKEN}'
    }

def lookup_psa_cert(cert_number):
    """Look up a PSA cert by certificate number"""
    headers = get_psa_headers()
    if not headers:
        return {'error': 'PSA API token not configured'}
    
    try:
        # Clean cert number
        clean_cert = ''.join(filter(str.isdigit, str(cert_number)))
        if len(clean_cert) < 8:
            return {'error': 'Invalid cert number format'}
        
        clean_cert = clean_cert.zfill(8)
        url = f"{PSA_API_BASE}/cert/GetByCertNumber/{clean_cert}"
        
        print(f"🔍 Looking up PSA cert: {clean_cert}")
        response = requests.get(url, headers=headers, timeout=10)
        
        print(f"📊 Response status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"📡 Full PSA Response: {data}")
            
            # Check if PSACert exists and has CertNumber
            if data.get('PSACert') and data['PSACert'].get('CertNumber'):
                print("✅ SUCCESS: Valid PSA cert found!")
                return {'success': True, 'data': data}
            else:
                print("❌ No PSACert found in response")
                return {'error': 'No PSA cert data found'}
        else:
            print(f"❌ HTTP Error: {response.status_code}")
            return {'error': f'PSA API returned {response.status_code}'}
            
    except Exception as e:
        print(f"❌ Exception: {str(e)}")
        return {'error': f'Error: {str(e)}'}

def lookup_psa_cert_images(cert_number):
    """Look up PSA cert images - separate API call"""
    headers = get_psa_headers()
    if not headers:
        return None
    
    try:
        clean_cert = ''.join(filter(str.isdigit, str(cert_number)))
        clean_cert = clean_cert.zfill(8)
        
        # PSA Image API endpoint
        url = f"{PSA_API_BASE}/cert/GetImagesByCertNumber/{clean_cert}"
        print(f"🖼️ Getting images for cert: {clean_cert}")
        
        response = requests.get(url, headers=headers, timeout=10)
        print(f"📊 Image API status: {response.status_code}")
        
        if response.status_code == 200:
            image_data = response.json()
            print(f"✅ Got image data: {image_data}")
            return image_data
        elif response.status_code == 429:
            print("⏰ Image API rate limited")
            return None
        else:
            print(f"❌ Image API error: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"⚠️ Image lookup failed: {str(e)}")
        return None

def parse_psa_data(psa_data):
    """Parse PSA API data into card format"""
    try:
        psa_cert = psa_data.get('PSACert', {})
        
        card_info = {
            'cert_number': psa_cert.get('CertNumber'),
            'name': psa_cert.get('Subject', ''),
            'set': psa_cert.get('Brand', ''),
            'card_number': psa_cert.get('CardNumber', ''),
            'spec_number': psa_cert.get('SpecNumber', ''),
            'grade': psa_cert.get('CardGrade', ''),
            'grade_description': psa_cert.get('GradeDescription', ''),
            'year': psa_cert.get('Year', ''),
            'brand': psa_cert.get('Brand', ''),
            'category': psa_cert.get('Category', ''),
            'variety': psa_cert.get('Variety', ''),
            'label_type': psa_cert.get('LabelType', ''),
            'total_population': psa_cert.get('TotalPopulation', 0),
            'population_higher': psa_cert.get('PopulationHigher', 0),
            'is_dual_cert': psa_cert.get('IsDualCert', False),
            'reverse_bar_code': psa_cert.get('ReverseBarCode', False),
            'image_url': psa_cert.get('ImageFront', ''),
            'image_front': '',
            'image_back': '',
        }
        
        print(f"📋 Parsed card info: {card_info}")
        return card_info
        
    except Exception as e:
        print(f"❌ Parse error: {str(e)}")
        return {'error': f'Error parsing data: {str(e)}'}

# Routes
@app.route('/')
def index():
    return send_from_directory('static', 'index.html')

@app.route('/health')
def health():
    return jsonify({'status': 'ok'})

@app.route('/api/psa/lookup/<cert_number>', methods=['GET'])
def lookup_cert(cert_number):
    """Look up a PSA cert and return parsed data with images"""
    print(f"🎯 API ENDPOINT HIT for cert: {cert_number}")
    
    try:
        # Step 1: Lookup PSA cert data (your working code)
        psa_result = lookup_psa_cert(cert_number)
        print(f"🔍 PSA lookup result: {psa_result}")
        
        if 'error' in psa_result:
            print(f"❌ PSA lookup failed: {psa_result['error']}")
            return jsonify(psa_result), 400
        
        # Step 2: Parse the basic data
        card_data = parse_psa_data(psa_result['data'])
        print(f"📋 Parse result: {card_data}")
        
        if 'error' in card_data:
            print(f"❌ Parse failed: {card_data['error']}")
            return jsonify(card_data), 400
        
        # Step 3: Try to get images (separate API call)
        image_data = lookup_psa_cert_images(cert_number)
        if image_data:
            # Handle the list format from PSA image API
            try:
                if isinstance(image_data, list):
                    for img in image_data:
                        if img.get('IsFrontImage') == True:
                            card_data['image_front'] = img.get('ImageURL', '')
                            card_data['image_url'] = card_data['image_front']
                        elif img.get('IsFrontImage') == False:
                            card_data['image_back'] = img.get('ImageURL', '')
                    print(f"✅ Added images: Front={card_data['image_front']}, Back={card_data['image_back']}")
                elif isinstance(image_data, dict):
                    # Fallback for dict format
                    card_data['image_front'] = image_data.get('ImageFront', '')
                    card_data['image_back'] = image_data.get('ImageBack', '')
                    if card_data['image_front']:
                        card_data['image_url'] = card_data['image_front']
            except Exception as img_error:
                print(f"⚠️ Error processing images: {img_error}")
                # Continue without images
        
        # Step 4: Return success
        response = {
            'success': True,
            'card_data': card_data
        }
        print(f"✅ RETURNING SUCCESS with images: {response}")
        return jsonify(response)
        
    except Exception as e:
        print(f"❌ EXCEPTION in lookup_cert: {str(e)}")
        return jsonify({'error': f'Server error: {str(e)}'}), 500

@app.route('/api/cards/add', methods=['POST'])
def add_card():
    """Add a card to the collection"""
    global next_id
    
    try:
        data = request.get_json()
        print(f"📝 Adding card: {data}")
        
        # Check for duplicates
        cert_number = data.get('cert_number')
        if cert_number:
            existing = next((card for card in collection if card.get('cert_number') == cert_number), None)
            if existing:
                return jsonify({'error': 'Card already exists'}), 409
        
        # Create new card
        card = {
            'id': next_id,
            **data,  # Include all PSA data
            'purchase_price': float(data.get('purchase_price', 0) or 0),
            'current_value': float(data.get('current_value', 0) or 0),
            'notes': data.get('notes', ''),
            'added_date': str(datetime.now().date())
        }
        
        collection.append(card)
        next_id += 1
        
        print(f"✅ Card added successfully: {card['id']}")
        return jsonify({'success': True, 'card': card}), 201
        
    except Exception as e:
        print(f"❌ Error adding card: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/cards', methods=['GET'])
def get_cards():
    """Get all cards"""
    return jsonify(collection)

@app.route('/api/cards/<int:card_id>', methods=['DELETE'])
def delete_card(card_id):
    """Delete a card"""
    global collection
    collection = [card for card in collection if card['id'] != card_id]
    return jsonify({'success': True})

@app.route('/api/stats', methods=['GET'])
def get_stats():
    """Get collection statistics"""
    total_cards = len(collection)
    total_value = sum(card.get('current_value', 0) for card in collection)
    avg_value = total_value / total_cards if total_cards > 0 else 0
    
    return jsonify({
        'total_cards': total_cards,
        'total_value': round(total_value, 2),
        'average_value': round(avg_value, 2)
    })

if __name__ == '__main__':
    print("🎴 PSA Card Lookup & Collection (FIXED VERSION)")
    print("🌐 Frontend: http://localhost:8080")
    if PSA_AUTH_TOKEN:
        print("🎯 PSA API: Configured ✅")
    else:
        print("🎯 PSA API: Not configured ❌")
    print("---")
    
    app.run(debug=True, host='0.0.0.0', port=8080)