# psa_test.py - Test PSA API directly
import requests
import os
from dotenv import load_dotenv

load_dotenv()

PSA_AUTH_TOKEN = os.getenv('PSA_AUTH_TOKEN')

def test_psa_api():
    print("🧪 Testing PSA API...")
    print(f"🔑 Token exists: {'✅' if PSA_AUTH_TOKEN else '❌'}")
    
    if PSA_AUTH_TOKEN:
        print(f"🔑 Token starts with: {PSA_AUTH_TOKEN[:10]}...")
        print(f"🔑 Token length: {len(PSA_AUTH_TOKEN)}")
    
    # Test different header formats
    headers_to_test = [
        {'authorization': f'bearer {PSA_AUTH_TOKEN}'},
        {'Authorization': f'bearer {PSA_AUTH_TOKEN}'},
        {'Authorization': f'Bearer {PSA_AUTH_TOKEN}'},
        {'authorization': f'Bearer {PSA_AUTH_TOKEN}'},
    ]
    
    cert_number = "12345678"  # Test cert
    url = f"https://api.psacard.com/publicapi/cert/GetByCertNumber/{cert_number}"
    
    for i, headers in enumerate(headers_to_test):
        print(f"\n📋 Test {i+1}: {headers}")
        
        try:
            response = requests.get(url, headers=headers, timeout=10)
            print(f"📊 Status: {response.status_code}")
            print(f"📄 Response: {response.text[:200]}...")
            
            if response.status_code == 200:
                print("✅ SUCCESS! This header format works!")
                break
            elif response.status_code == 401:
                print("❌ 401 Unauthorized - Token issue")
            elif response.status_code == 400:
                print("❌ 400 Bad Request - Format issue")
            elif response.status_code == 500:
                print("❌ 500 Server Error - PSA server issue")
                
        except Exception as e:
            print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_psa_api()