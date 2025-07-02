// main.go - PSA Card Collection API in Go (Updated with working PSA API)
package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"math"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
	"github.com/rs/cors"
)

// Card represents a PSA graded card
type Card struct {
	ID             int     `json:"id"`
	CertNumber     string  `json:"cert_number"`
	Name           string  `json:"name"`
	Set            string  `json:"set"`
	CardNumber     string  `json:"card_number"`
	SpecNumber     string  `json:"spec_number"`
	Grade          string  `json:"grade"`
	GradeDesc      string  `json:"grade_description"`
	Year           string  `json:"year"`
	Brand          string  `json:"brand"`
	Category       string  `json:"category"`
	Variety        string  `json:"variety"`
	LabelType      string  `json:"label_type"`
	TotalPop       int     `json:"total_population"`
	PopHigher      int     `json:"population_higher"`
	IsDualCert     bool    `json:"is_dual_cert"`
	ReverseBarCode bool    `json:"reverse_bar_code"`
	ImageURL       string  `json:"image_url"`
	ImageFront     string  `json:"image_front"`
	ImageBack      string  `json:"image_back"`
	PurchasePrice  float64 `json:"purchase_price"`
	CurrentValue   float64 `json:"current_value"`
	Notes          string  `json:"notes"`
	AddedDate      string  `json:"added_date"`
}

// PSACert represents the PSA API response structure
type PSACert struct {
	CertNumber                   string `json:"CertNumber"`
	SpecID                       int    `json:"SpecID"`
	SpecNumber                   string `json:"SpecNumber"`
	LabelType                    string `json:"LabelType"`
	ReverseBarCode               bool   `json:"ReverseBarCode"`
	Year                         string `json:"Year"`
	Brand                        string `json:"Brand"`
	Category                     string `json:"Category"`
	CardNumber                   string `json:"CardNumber"`
	Subject                      string `json:"Subject"`
	Variety                      string `json:"Variety"`
	IsPSADNA                     bool   `json:"IsPSADNA"`
	IsDualCert                   bool   `json:"IsDualCert"`
	GradeDescription             string `json:"GradeDescription"`
	CardGrade                    string `json:"CardGrade"`
	TotalPopulation              int    `json:"TotalPopulation"`
	TotalPopulationWithQualifier int    `json:"TotalPopulationWithQualifier"`
	PopulationHigher             int    `json:"PopulationHigher"`
	ImageFront                   string `json:"ImageFront"`
}

type PSAResponse struct {
	PSACert PSACert `json:"PSACert"`
}

type PSAImageResponse struct {
	IsFrontImage bool   `json:"IsFrontImage"`
	ImageURL     string `json:"ImageURL"`
}

// Collection represents the stored collection data
type Collection struct {
	Cards      []Card `json:"cards"`
	NextID     int    `json:"next_id"`
	LastUpdate string `json:"last_updated"`
}

// Stats represents collection statistics
type Stats struct {
	TotalCards   int     `json:"total_cards"`
	TotalValue   float64 `json:"total_value"`
	AverageValue float64 `json:"average_value"`
}

// Global variables
var (
	collection   Collection
	psaAuthToken string
	dataFile     = "collection.json"
)

func main() {
	// Load environment variables
	err := godotenv.Load()
	if err != nil {
		log.Println("Warning: No .env file found")
	}

	psaAuthToken = os.Getenv("PSA_AUTH_TOKEN")

	// Load existing collection
	loadCollection()

	// Setup router
	router := mux.NewRouter()

	// API routes
	api := router.PathPrefix("/api").Subrouter()
	api.HandleFunc("/health", healthHandler).Methods("GET")
	api.HandleFunc("/psa/lookup/{certNumber}", psaLookupHandler).Methods("GET")
	api.HandleFunc("/cards", getCardsHandler).Methods("GET")
	api.HandleFunc("/cards/add", addCardHandler).Methods("POST")
	api.HandleFunc("/cards/{id}", deleteCardHandler).Methods("DELETE")
	api.HandleFunc("/cards/{id}", updateCardHandler).Methods("PUT") // Added PUT endpoint
	api.HandleFunc("/stats", getStatsHandler).Methods("GET")

	// Static file serving
	router.PathPrefix("/").Handler(http.FileServer(http.Dir("./static/")))

	// Setup CORS
	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
		AllowedMethods: []string{"GET", "POST", "DELETE", "PUT", "OPTIONS"},
		AllowedHeaders: []string{"*"},
	})

	handler := c.Handler(router)

	// Start server
	port := "8080"
	fmt.Println("🎴 PSA Card Collection API (Go Version)")
	fmt.Printf("🌐 Server running on http://localhost:%s\n", port)
	fmt.Printf("💾 Storage: %s\n", dataFile)
	fmt.Printf("📚 Loaded Collection: %d cards\n", len(collection.Cards))
	if psaAuthToken != "" {
		fmt.Println("🎯 PSA API: Configured ✅")
	} else {
		fmt.Println("🎯 PSA API: Not configured ❌")
	}
	fmt.Println("---")

	log.Fatal(http.ListenAndServe(":"+port, handler))
}

func loadCollection() {
	if _, err := os.Stat(dataFile); os.IsNotExist(err) {
		// File doesn't exist, start with empty collection
		collection = Collection{
			Cards:  []Card{},
			NextID: 1,
		}
		log.Printf("📁 No existing collection file found, starting fresh")
		return
	}

	data, err := ioutil.ReadFile(dataFile)
	if err != nil {
		log.Printf("❌ Error reading collection file: %v", err)
		collection = Collection{Cards: []Card{}, NextID: 1}
		return
	}

	err = json.Unmarshal(data, &collection)
	if err != nil {
		log.Printf("❌ Error parsing collection file: %v", err)
		collection = Collection{Cards: []Card{}, NextID: 1}
		return
	}

	log.Printf("📚 Loaded %d cards from %s", len(collection.Cards), dataFile)
}

func saveCollection() error {
	collection.LastUpdate = time.Now().Format("2006-01-02 15:04:05")

	data, err := json.MarshalIndent(collection, "", "  ")
	if err != nil {
		return err
	}

	err = ioutil.WriteFile(dataFile, data, 0644)
	if err != nil {
		return err
	}

	log.Printf("💾 Saved %d cards to %s", len(collection.Cards), dataFile)
	return nil
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

// Clean cert number - remove non-digits and pad with zeros
func cleanCertNumber(certNumber string) string {
	// Remove all non-digit characters
	clean := ""
	for _, char := range certNumber {
		if char >= '0' && char <= '9' {
			clean += string(char)
		}
	}

	// Pad with zeros to 8 digits
	for len(clean) < 8 {
		clean = "0" + clean
	}

	return clean
}

func psaLookupHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	certNumber := vars["certNumber"]

	log.Printf("🎯 PSA Lookup request for cert: %s", certNumber)

	if psaAuthToken == "" {
		http.Error(w, `{"error": "PSA API token not configured"}`, http.StatusBadRequest)
		return
	}

	// Clean cert number
	cleanCert := cleanCertNumber(certNumber)

	if len(cleanCert) < 8 {
		http.Error(w, `{"error": "Invalid cert number format"}`, http.StatusBadRequest)
		return
	}

	log.Printf("🔍 Looking up PSA cert: %s", cleanCert)

	// Step 1: Get card data
	cardData, err := lookupPSACard(cleanCert)
	if err != nil {
		log.Printf("❌ PSA card lookup failed: %v", err)
		http.Error(w, fmt.Sprintf(`{"error": "%s"}`, err.Error()), http.StatusBadRequest)
		return
	}

	// Step 2: Get images
	images, err := lookupPSAImages(cleanCert)
	if err != nil {
		log.Printf("⚠️ PSA image lookup failed: %v", err)
		// Continue without images
	} else {
		// Add images to card data
		for _, img := range images {
			if img.IsFrontImage {
				cardData.ImageFront = img.ImageURL
				cardData.ImageURL = img.ImageURL
			} else {
				cardData.ImageBack = img.ImageURL
			}
		}
		log.Printf("✅ Added images: Front=%s, Back=%s", cardData.ImageFront, cardData.ImageBack)
	}

	log.Printf("✅ PSA lookup successful for cert: %s", certNumber)

	w.Header().Set("Content-Type", "application/json")
	response := map[string]interface{}{
		"success":   true,
		"card_data": cardData,
	}
	json.NewEncoder(w).Encode(response)
}

func lookupPSACard(certNumber string) (*Card, error) {
	url := fmt.Sprintf("https://api.psacard.com/publicapi/cert/GetByCertNumber/%s", certNumber)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", "bearer "+psaAuthToken)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	log.Printf("📊 Response status: %d", resp.StatusCode)

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("PSA API returned status %d", resp.StatusCode)
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	log.Printf("📡 Full PSA Response: %s", string(body))

	var psaResp PSAResponse
	err = json.Unmarshal(body, &psaResp)
	if err != nil {
		return nil, err
	}

	// Check if PSACert exists and has CertNumber
	if psaResp.PSACert.CertNumber == "" {
		log.Printf("❌ No PSACert found in response")
		return nil, fmt.Errorf("No PSA cert data found")
	}

	log.Printf("✅ SUCCESS: Valid PSA cert found!")

	// Convert PSA response to our Card structure
	card := &Card{
		CertNumber:     psaResp.PSACert.CertNumber,
		Name:           psaResp.PSACert.Subject,
		Set:            psaResp.PSACert.Brand,
		CardNumber:     psaResp.PSACert.CardNumber,
		SpecNumber:     psaResp.PSACert.SpecNumber,
		Grade:          psaResp.PSACert.CardGrade,
		GradeDesc:      psaResp.PSACert.GradeDescription,
		Year:           psaResp.PSACert.Year,
		Brand:          psaResp.PSACert.Brand,
		Category:       psaResp.PSACert.Category,
		Variety:        psaResp.PSACert.Variety,
		LabelType:      psaResp.PSACert.LabelType,
		TotalPop:       psaResp.PSACert.TotalPopulation,
		PopHigher:      psaResp.PSACert.PopulationHigher,
		IsDualCert:     psaResp.PSACert.IsDualCert,
		ReverseBarCode: psaResp.PSACert.ReverseBarCode,
		ImageURL:       psaResp.PSACert.ImageFront,
	}

	log.Printf("📋 Parsed card info: %+v", card)

	return card, nil
}

func lookupPSAImages(certNumber string) ([]PSAImageResponse, error) {
	url := fmt.Sprintf("https://api.psacard.com/publicapi/cert/GetImagesByCertNumber/%s", certNumber)

	log.Printf("🖼️ Getting images for cert: %s", certNumber)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", "bearer "+psaAuthToken)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	log.Printf("📊 Image API status: %d", resp.StatusCode)

	if resp.StatusCode == 429 {
		log.Printf("⏰ Image API rate limited")
		return nil, fmt.Errorf("rate limited")
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("image API returned status %d", resp.StatusCode)
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var images []PSAImageResponse
	err = json.Unmarshal(body, &images)
	if err != nil {
		return nil, err
	}

	log.Printf("✅ Got image data: %+v", images)

	return images, nil
}

func getCardsHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(collection.Cards)
}

func addCardHandler(w http.ResponseWriter, r *http.Request) {
	var card Card
	err := json.NewDecoder(r.Body).Decode(&card)
	if err != nil {
		http.Error(w, `{"error": "Invalid JSON"}`, http.StatusBadRequest)
		return
	}

	log.Printf("📝 Adding card: %s", card.Name)

	// Check for duplicates
	for _, existingCard := range collection.Cards {
		if existingCard.CertNumber == card.CertNumber && card.CertNumber != "" {
			http.Error(w, `{"error": "Card already exists"}`, http.StatusConflict)
			return
		}
	}

	// Set card ID and add date
	card.ID = collection.NextID
	card.AddedDate = time.Now().Format("2006-01-02")
	collection.NextID++

	// Add to collection
	collection.Cards = append(collection.Cards, card)

	// Save to file
	err = saveCollection()
	if err != nil {
		log.Printf("⚠️ Failed to save collection: %v", err)
	}

	log.Printf("✅ Card added successfully: %d", card.ID)

	w.Header().Set("Content-Type", "application/json")
	response := map[string]interface{}{
		"success": true,
		"card":    card,
	}
	json.NewEncoder(w).Encode(response)
}

func updateCardHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]

	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, `{"error": "Invalid card ID"}`, http.StatusBadRequest)
		return
	}

	// Parse request body
	var updateData map[string]interface{}
	err = json.NewDecoder(r.Body).Decode(&updateData)
	if err != nil {
		http.Error(w, `{"error": "Invalid JSON"}`, http.StatusBadRequest)
		return
	}

	log.Printf("📝 Updating card %d with data: %+v", id, updateData)

	// Find the card to update
	cardIndex := -1
	for i, card := range collection.Cards {
		if card.ID == id {
			cardIndex = i
			break
		}
	}

	if cardIndex == -1 {
		http.Error(w, `{"error": "Card not found"}`, http.StatusNotFound)
		return
	}

	// Update the card fields
	card := &collection.Cards[cardIndex]

	// Update notes if provided
	if notes, ok := updateData["notes"]; ok {
		if notesStr, ok := notes.(string); ok {
			card.Notes = notesStr
			log.Printf("📝 Updated notes for card %d", id)
		}
	}

	// Update price if provided
	if price, ok := updateData["price"]; ok {
		switch v := price.(type) {
		case float64:
			if v >= 0 {
				card.CurrentValue = v
				log.Printf("💰 Updated price for card %d to $%.2f", id, v)
			} else {
				http.Error(w, `{"error": "Price must be a positive number"}`, http.StatusBadRequest)
				return
			}
		case string:
			if priceFloat, err := strconv.ParseFloat(v, 64); err == nil && priceFloat >= 0 {
				card.CurrentValue = priceFloat
				log.Printf("💰 Updated price for card %d to $%.2f", id, priceFloat)
			} else {
				http.Error(w, `{"error": "Invalid price format"}`, http.StatusBadRequest)
				return
			}
		default:
			http.Error(w, `{"error": "Invalid price format"}`, http.StatusBadRequest)
			return
		}
	}

	// Update current_value if provided (alternative field name)
	if currentValue, ok := updateData["current_value"]; ok {
		switch v := currentValue.(type) {
		case float64:
			if v >= 0 {
				card.CurrentValue = v
				log.Printf("💰 Updated current_value for card %d to $%.2f", id, v)
			}
		case string:
			if priceFloat, err := strconv.ParseFloat(v, 64); err == nil && priceFloat >= 0 {
				card.CurrentValue = priceFloat
				log.Printf("💰 Updated current_value for card %d to $%.2f", id, priceFloat)
			}
		}
	}

	// Save the updated collection
	err = saveCollection()
	if err != nil {
		log.Printf("⚠️ Failed to save collection after update: %v", err)
		http.Error(w, `{"error": "Failed to save changes"}`, http.StatusInternalServerError)
		return
	}

	log.Printf("✅ Card %d updated successfully", id)

	// Return the updated card
	w.Header().Set("Content-Type", "application/json")
	response := map[string]interface{}{
		"success": true,
		"card":    *card,
	}
	json.NewEncoder(w).Encode(response)
}

func deleteCardHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]

	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, `{"error": "Invalid card ID"}`, http.StatusBadRequest)
		return
	}

	// Find and remove card
	originalLength := len(collection.Cards)
	newCards := []Card{}
	for _, card := range collection.Cards {
		if card.ID != id {
			newCards = append(newCards, card)
		}
	}

	if len(newCards) == originalLength {
		http.Error(w, `{"error": "Card not found"}`, http.StatusNotFound)
		return
	}

	collection.Cards = newCards

	// Save to file
	err = saveCollection()
	if err != nil {
		log.Printf("⚠️ Failed to save collection: %v", err)
	}

	log.Printf("✅ Card %d deleted successfully", id)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]bool{"success": true})
}

func getStatsHandler(w http.ResponseWriter, r *http.Request) {
	totalCards := len(collection.Cards)
	totalValue := 0.0
	for _, card := range collection.Cards {
		totalValue += card.CurrentValue
	}

	averageValue := 0.0
	if totalCards > 0 {
		averageValue = totalValue / float64(totalCards)
	}

	stats := Stats{
		TotalCards:   totalCards,
		TotalValue:   roundFloat(totalValue, 2),
		AverageValue: roundFloat(averageValue, 2),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(stats)
}

func roundFloat(val float64, precision uint) float64 {
	ratio := math.Pow(10, float64(precision))
	return math.Round(val*ratio) / ratio
}
