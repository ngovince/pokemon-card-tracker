// cmd/desktop/main.go
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/therecipe/qt/core"
	"github.com/therecipe/qt/gui"
	"github.com/therecipe/qt/qml"
	"github.com/therecipe/qt/quickcontrols2"
)

// PokemonCard represents a Pokemon card (same as backend)
type PokemonCard struct {
	ID           int     `json:"id"`
	Name         string  `json:"name"`
	Set          string  `json:"set"`
	CardNumber   string  `json:"card_number"`
	Rarity       string  `json:"rarity"`
	GradingComp  string  `json:"grading_company"`
	Grade        string  `json:"grade"`
	PurchPrice   float64 `json:"purchase_price"`
	CurrentValue float64 `json:"current_value"`
	PurchDate    string  `json:"purchase_date"`
	ImageURL     string  `json:"image_url"`
	Notes        string  `json:"notes"`
}

// CardModel provides data to QML
type CardModel struct {
	core.QAbstractListModel
	_ func() `constructor:"init"`

	cards []PokemonCard

	// Define roles for QML access
	_ int `property:"count"`
	_ func(row int) *core.QVariant `slot:"get"`
	_ func()                       `slot:"refresh"`
	_ func(card *PokemonCard)      `slot:"addCard"`
	_ func(id int)                 `slot:"deleteCard"`
}

// Define QML roles
func (m *CardModel) roleNames() map[int]*core.QByteArray {
	return map[int]*core.QByteArray{
		int(core.Qt__UserRole) + 1<<iota: core.NewQByteArray2("id", len("id")),
		int(core.Qt__UserRole) + 1<<iota: core.NewQByteArray2("name", len("name")),
		int(core.Qt__UserRole) + 1<<iota: core.NewQByteArray2("set", len("set")),
		int(core.Qt__UserRole) + 1<<iota: core.NewQByteArray2("cardNumber", len("cardNumber")),
		int(core.Qt__UserRole) + 1<<iota: core.NewQByteArray2("rarity", len("rarity")),
		int(core.Qt__UserRole) + 1<<iota: core.NewQByteArray2("gradingCompany", len("gradingCompany")),
		int(core.Qt__UserRole) + 1<<iota: core.NewQByteArray2("grade", len("grade")),
		int(core.Qt__UserRole) + 1<<iota: core.NewQByteArray2("purchasePrice", len("purchasePrice")),
		int(core.Qt__UserRole) + 1<<iota: core.NewQByteArray2("currentValue", len("currentValue")),
		int(core.Qt__UserRole) + 1<<iota: core.NewQByteArray2("purchaseDate", len("purchaseDate")),
		int(core.Qt__UserRole) + 1<<iota: core.NewQByteArray2("imageUrl", len("imageUrl")),
		int(core.Qt__UserRole) + 1<<iota: core.NewQByteArray2("notes", len("notes")),
	}
}

func (m *CardModel) rowCount(parent *core.QModelIndex) int {
	return len(m.cards)
}

func (m *CardModel) data(index *core.QModelIndex, role int) *core.QVariant {
	if !index.IsValid() || index.Row() >= len(m.cards) {
		return core.NewQVariant()
	}

	card := m.cards[index.Row()]
	switch role - int(core.Qt__UserRole) {
	case 1:
		return core.NewQVariant1(card.ID)
	case 2:
		return core.NewQVariant1(card.Name)
	case 3:
		return core.NewQVariant1(card.Set)
	case 4:
		return core.NewQVariant1(card.CardNumber)
	case 5:
		return core.NewQVariant1(card.Rarity)
	case 6:
		return core.NewQVariant1(card.GradingComp)
	case 7:
		return core.NewQVariant1(card.Grade)
	case 8:
		return core.NewQVariant1(card.PurchPrice)
	case 9:
		return core.NewQVariant1(card.CurrentValue)
	case 10:
		return core.NewQVariant1(card.PurchDate)
	case 11:
		return core.NewQVariant1(card.ImageURL)
	case 12:
		return core.NewQVariant1(card.Notes)
	}

	return core.NewQVariant()
}

func (m *CardModel) init() {
	m.cards = make([]PokemonCard, 0)
	m.SetCount(0)
	
	// Connect signals
	m.ConnectRoleNames(m.roleNames)
	m.ConnectRowCount(m.rowCount)
	m.ConnectData(m.data)
	m.ConnectGet(m.get)
	m.ConnectRefresh(m.refresh)
	m.ConnectAddCard(m.addCard)
	m.ConnectDeleteCard(m.deleteCard)
}

func (m *CardModel) get(row int) *core.QVariant {
	if row < 0 || row >= len(m.cards) {
		return core.NewQVariant()
	}
	
	card := m.cards[row]
	cardMap := map[string]interface{}{
		"id":             card.ID,
		"name":           card.Name,
		"set":            card.Set,
		"cardNumber":     card.CardNumber,
		"rarity":         card.Rarity,
		"gradingCompany": card.GradingComp,
		"grade":          card.Grade,
		"purchasePrice":  card.PurchPrice,
		"currentValue":   card.CurrentValue,
		"purchaseDate":   card.PurchDate,
		"imageUrl":       card.ImageURL,
		"notes":          card.Notes,
	}
	
	return core.NewQVariant1(cardMap)
}

func (m *CardModel) refresh() {
	m.BeginResetModel()
	
	// Fetch cards from API
	resp, err := http.Get("http://localhost:8080/api/cards")
	if err != nil {
		log.Printf("Error fetching cards: %v", err)
		m.EndResetModel()
		return
	}
	defer resp.Body.Close()

	var cards []PokemonCard
	if err := json.NewDecoder(resp.Body).Decode(&cards); err != nil {
		log.Printf("Error decoding cards: %v", err)
		m.EndResetModel()
		return
	}

	m.cards = cards
	m.SetCount(len(cards))
	m.EndResetModel()
}

func (m *CardModel) addCard(card *PokemonCard) {
	// This would typically make an API call to add the card
	// For now, just refresh the model
	m.refresh()
}

func (m *CardModel) deleteCard(id int) {
	// Make API call to delete card
	req, _ := http.NewRequest("DELETE", fmt.Sprintf("http://localhost:8080/api/cards/%d", id), nil)
	client := &http.Client{}
	
	if _, err := client.Do(req); err != nil {
		log.Printf("Error deleting card: %v", err)
		return
	}
	
	// Refresh the model
	m.refresh()
}

// StatsModel provides collection statistics
type StatsModel struct {
	core.QObject
	_ func() `constructor:"init"`

	_ int     `property:"totalCards"`
	_ float64 `property:"totalValue"`
	_ float64 `property:"averageValue"`
	_ func()  `slot:"refresh"`
}

func (s *StatsModel) init() {
	s.ConnectRefresh(s.refresh)
}

func (s *StatsModel) refresh() {
	resp, err := http.Get("http://localhost:8080/api/stats")
	if err != nil {
		log.Printf("Error fetching stats: %v", err)
		return
	}
	defer resp.Body.Close()

	var stats struct {
		TotalCards   int     `json:"total_cards"`
		TotalValue   float64 `json:"total_value"`
		AverageValue float64 `json:"average_value"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&stats); err != nil {
		log.Printf("Error decoding stats: %v", err)
		return
	}

	s.SetTotalCards(stats.TotalCards)
	s.SetTotalValue(stats.TotalValue)
	s.SetAverageValue(stats.AverageValue)
}

func main() {
	core.QCoreApplication_SetAttribute(core.Qt__AA_EnableHighDpiScaling, true)

	gui.NewQGuiApplication(len(os.Args), os.Args)

	// Set up QuickControls2 style
	quickcontrols2.QQuickStyle_SetStyle("Material")

	// Create QML engine
	engine := qml.NewQQmlApplicationEngine()

	// Register our types
	qml.QmlRegisterType2("PokemonTracker", 1, 0, "CardModel", CardModel{}, "CardModel")
	qml.QmlRegisterType2("PokemonTracker", 1, 0, "StatsModel", StatsModel{}, "StatsModel")

	// Load the main QML file
	engine.Load(core.NewQUrl3("qml/main.qml", 0))

	if len(engine.RootObjects()) == 0 {
		log.Fatal("Failed to load QML")
	}

	gui.QGuiApplication_Exec()
}
