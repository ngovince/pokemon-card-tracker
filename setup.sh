#!/bin/bash

echo "🚀 Setting up PSA Card Collection Go Backend..."

# Initialize Go module if it doesn't exist
if [ ! -f "go.mod" ]; then
    echo "📦 Initializing Go module..."
    go mod init psa-card-collection
fi

# Install dependencies
echo "📥 Installing dependencies..."
go get github.com/gorilla/mux@v1.8.0
go get github.com/joho/godotenv@v1.4.0
go get github.com/rs/cors@v1.10.1

# Create static directory if it doesn't exist
if [ ! -d "static" ]; then
    echo "📁 Creating static directory..."
    mkdir static
    echo "⚠️  Don't forget to put your index.html in the static/ folder!"
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "🔑 Creating .env file..."
    echo "PSA_AUTH_TOKEN=your_psa_token_here" > .env
    echo "⚠️  Don't forget to add your PSA API token to .env file!"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Add your PSA API token to .env file"
echo "2. Copy your index.html to static/ folder"
echo "3. Run: go run main.go"
echo ""