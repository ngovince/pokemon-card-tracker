// main.go
package main

import (
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// PokemonCard represents a graded Pokemon card in the collection
type PokemonCard struct {
	ID           uint    `json:"id" gorm:"primaryKey"`
	Name         string  `json:"name" gorm:"not null"`
	Set          string  `json:"set" gorm:"not null"`
	CardNumber   string  `json:"card_number"`
	Rarity       string  `json:"rarity"`
	GradingComp  string  `json:"grading_company"` // PSA, BGS, CGC, etc.
	Grade        string  `json:"grade"`           // 10, 9.5, etc.
	PurchPrice   float64 `json:"purchase_price"`
	CurrentValue float64 `json:"current_value"`
	PurchDate    string  `json:"purchase_date"`
	ImageURL     string  `json:"image_url"`
	Notes        string  `json:"notes"`
	CreatedAt    string  `json:"created_at"`
	UpdatedAt    string  `json:"updated_at"`
}

var db *gorm.DB

func initDatabase() {
	var err error
	db, err = gorm.Open(sqlite.Open("pokemon_cards.db"), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Auto-migrate the schema
	err = db.AutoMigrate(&PokemonCard{})
	if err != nil {
		log.Fatal("Failed to migrate database:", err)
	}
}

// API Handlers

// GET /api/cards - Get all cards
func getCards(c *gin.Context) {
	var cards []PokemonCard

	// Optional query parameters for filtering
	name := c.Query("name")
	set := c.Query("set")
	gradingComp := c.Query("grading_company")

	query := db
	if name != "" {
		query = query.Where("name LIKE ?", "%"+name+"%")
	}
	if set != "" {
		query = query.Where("set LIKE ?", "%"+set+"%")
	}
	if gradingComp != "" {
		query = query.Where("grading_company = ?", gradingComp)
	}

	result := query.Find(&cards)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(http.StatusOK, cards)
}

// GET /api/cards/:id - Get a specific card
func getCard(c *gin.Context) {
	id := c.Param("id")
	var card PokemonCard

	result := db.First(&card, id)
	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Card not found"})
		return
	}

	c.JSON(http.StatusOK, card)
}

// POST /api/cards - Create a new card
func createCard(c *gin.Context) {
	var card PokemonCard

	if err := c.ShouldBindJSON(&card); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	result := db.Create(&card)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(http.StatusCreated, card)
}

// PUT /api/cards/:id - Update a card
func updateCard(c *gin.Context) {
	id := c.Param("id")
	var card PokemonCard

	// Check if card exists
	result := db.First(&card, id)
	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Card not found"})
		return
	}

	// Bind updated data
	if err := c.ShouldBindJSON(&card); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Save updates
	result = db.Save(&card)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(http.StatusOK, card)
}

// DELETE /api/cards/:id - Delete a card
func deleteCard(c *gin.Context) {
	id := c.Param("id")

	result := db.Delete(&PokemonCard{}, id)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": result.Error.Error()})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Card not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Card deleted successfully"})
}

// GET /api/stats - Get collection statistics
func getStats(c *gin.Context) {
	var totalCards int64
	var totalValue float64

	db.Model(&PokemonCard{}).Count(&totalCards)
	db.Model(&PokemonCard{}).Select("COALESCE(SUM(current_value), 0)").Scan(&totalValue)

	stats := gin.H{
		"total_cards":   totalCards,
		"total_value":   totalValue,
		"average_value": 0.0,
	}

	if totalCards > 0 {
		stats["average_value"] = totalValue / float64(totalCards)
	}

	c.JSON(http.StatusOK, stats)
}

// CORS middleware
func corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Credentials", "true")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Header("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}

func main() {
	// Initialize database
	initDatabase()

	// Create Gin router
	r := gin.Default()

	// Add CORS middleware
	r.Use(corsMiddleware())

	// API routes
	api := r.Group("/api")
	{
		api.GET("/cards", getCards)
		api.GET("/cards/:id", getCard)
		api.POST("/cards", createCard)
		api.PUT("/cards/:id", updateCard)
		api.DELETE("/cards/:id", deleteCard)
		api.GET("/stats", getStats)
	}

	// Health check endpoint
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "healthy"})
	})

	// Get port from environment or use default
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	log.Fatal(r.Run(":" + port))
}
