// cmd/desktop/qml/AddCardDialog.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: dialog
    title: "Add New Pokemon Card"
    modal: true
    anchors.centerIn: parent
    width: 500
    height: 700

    signal cardAdded()

    property bool isEdit: false
    property int editCardId: -1

    Material.accent: Material.Indigo

    ScrollView {
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 16

            GridLayout {
                columns: 2
                columnSpacing: 16
                rowSpacing: 12
                Layout.fillWidth: true

                // Card Name
                Label {
                    text: "Card Name *"
                    font.bold: true
                }
                TextField {
                    id: nameField
                    Layout.fillWidth: true
                    placeholderText: "e.g., Charizard"
                    selectByMouse: true
                }

                // Set
                Label {
                    text: "Set *"
                    font.bold: true
                }
                TextField {
                    id: setField
                    Layout.fillWidth: true
                    placeholderText: "e.g., Base Set"
                    selectByMouse: true
                }

                // Card Number
                Label {
                    text: "Card Number"
                    font.bold: true
                }
                TextField {
                    id: numberField
                    Layout.fillWidth: true
                    placeholderText: "e.g., 4/102"
                    selectByMouse: true
                }

                // Rarity
                Label {
                    text: "Rarity"
                    font.bold: true
                }
                ComboBox {
                    id: rarityField
                    Layout.fillWidth: true
                    editable: true
                    model: ["", "Common", "Uncommon", "Rare", "Rare Holo", "Ultra Rare", "Secret Rare"]
                }

                // Grading Company
                Label {
                    text: "Grading Company"
                    font.bold: true
                }
                ComboBox {
                    id: gradingCompanyField
                    Layout.fillWidth: true
                    model: ["", "PSA", "BGS", "CGC", "SGC"]
                }

                // Grade
                Label {
                    text: "Grade"
                    font.bold: true
                }
                TextField {
                    id: gradeField
                    Layout.fillWidth: true
                    placeholderText: "e.g., 10, 9.5"
                    selectByMouse: true
                }

                // Purchase Price
                Label {
                    text: "Purchase Price ($)"
                    font.bold: true
                }
                SpinBox {
                    id: purchasePriceField
                    Layout.fillWidth: true
                    from: 0
                    to: 999999
                    stepSize: 100
                    
                    property real realValue: value / 100
                    
                    validator: DoubleValidator {
                        bottom: 0
                        top: 9999.99
                        decimals: 2
                    }
                    
                    textFromValue: function(value, locale) {
                        return "$" + (value / 100).toFixed(2)
                    }
                    
                    valueFromText: function(text, locale) {
                        return Math.round(parseFloat(text.replace("$", "")) * 100)
                    }
                }

                // Current Value
                Label {
                    text: "Current Value ($)"
                    font.bold: true
                }
                SpinBox {
                    id: currentValueField
                    Layout.fillWidth: true
                    from: 0
                    to: 999999
                    stepSize: 100
                    
                    property real realValue: value / 100
                    
                    validator: DoubleValidator {
                        bottom: 0
                        top: 9999.99
                        decimals: 2
                    }
                    
                    textFromValue: function(value, locale) {
                        return "$" + (value / 100).toFixed(2)
                    }
                    
                    valueFromText: function(text, locale) {
                        return Math.round(parseFloat(text.replace("$", "")) * 100)
                    }
                }

                // Purchase Date
                Label {
                    text: "Purchase Date"
                    font.bold: true
                }
                TextField {
                    id: purchaseDateField
                    Layout.fillWidth: true
                    placeholderText: "YYYY-MM-DD"
                    selectByMouse: true
                    
                    // Simple date validation
                    validator: RegularExpressionValidator {
                        regularExpression: /^\d{4}-\d{2}-\d{2}$/
                    }
                }

                // Image URL
                Label {
                    text: "Image URL"
                    font.bold: true
                }
                TextField {
                    id: imageUrlField
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    placeholderText: "https://example.com/card-image.jpg"
                    selectByMouse: true
                }

                // Notes
                Label {
                    text: "Notes"
                    font.bold: true
                    Layout.alignment: Qt.AlignTop
                }
                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    Layout.columnSpan: 2
                    
                    TextArea {
                        id: notesField
                        placeholderText: "Additional notes about the card..."
                        wrapMode: TextArea.Wrap
                        selectByMouse: true
                    }
                }
            }

            // Image Preview (if URL provided)
            Rectangle {
                id: imagePreview
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: Material.color(Material.Grey, Material.Shade100)
                radius: 8
                visible: imageUrlField.text.length > 0
                
                border.color: Material.color(Material.Grey, Material.Shade300)
                border.width: 1

                Image {
                    id: previewImage
                    anchors.fill: parent
                    anchors.margins: 8
                    source: imageUrlField.text
                    fillMode: Image.PreserveAspectFit
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "white"
                        opacity: 0.8
                        visible: previewImage.status === Image.Loading
                        
                        BusyIndicator {
                            anchors.centerIn: parent
                            running: previewImage.status === Image.Loading
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Failed to load image"
                        visible: previewImage.status === Image.Error
                        color: Material.color(Material.Red, Material.Shade600)
                    }
                }
            }
        }
    }

    standardButtons: Dialog.Save | Dialog.Cancel

    onAccepted: {
        // Validate required fields
        if (nameField.text.trim() === "" || setField.text.trim() === "") {
            validationDialog.open()
            return
        }
        
        // Create card object
        var cardData = {
            name: nameField.text.trim(),
            set: setField.text.trim(),
            card_number: numberField.text.trim(),
            rarity: rarityField.currentText,
            grading_company: gradingCompanyField.currentText,
            grade: gradeField.text.trim(),
            purchase_price: purchasePriceField.realValue,
            current_value: currentValueField.realValue,
            purchase_date: purchaseDateField.text.trim(),
            image_url: imageUrlField.text.trim(),
            notes: notesField.text.trim()
        }
        
        // Make API call to save card
        saveCard(cardData)
    }

    onRejected: {
        clearForm()
    }

    // Validation error dialog
    Dialog {
        id: validationDialog
        title: "Validation Error"
        anchors.centerIn: parent
        
        Label {
            text: "Please fill in all required fields (Card Name and Set)."
        }
        
        standardButtons: Dialog.Ok
    }

    // Success dialog
    Dialog {
        id: successDialog
        title: "Success"
        anchors.centerIn: parent
        
        Label {
            text: "Card saved successfully!"
        }
        
        standardButtons: Dialog.Ok
        
        onAccepted: {
            dialog.cardAdded()
            dialog.close()
            clearForm()
        }
    }

    // Error dialog
    Dialog {
        id: errorDialog
        title: "Error"
        anchors.centerIn: parent
        
        property string errorMessage: ""
        
        Label {
            text: "Failed to save card: " + errorDialog.errorMessage
        }
        
        standardButtons: Dialog.Ok
    }

    function clearForm() {
        nameField.text = ""
        setField.text = ""
        numberField.text = ""
        rarityField.currentIndex = 0
        gradingCompanyField.currentIndex = 0
        gradeField.text = ""
        purchasePriceField.value = 0
        currentValueField.value = 0
        purchaseDateField.text = ""
        imageUrlField.text = ""
        notesField.text = ""
        isEdit = false
        editCardId = -1
    }

    function saveCard(cardData) {
        var xhr = new XMLHttpRequest()
        var url = "http://localhost:8080/api/cards"
        var method = "POST"
        
        if (isEdit) {
            url += "/" + editCardId
            method = "PUT"
        }
        
        xhr.open(method, url, true)
        xhr.setRequestHeader("Content-Type", "application/json")
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 201) {
                    successDialog.open()
                } else {
                    errorDialog.errorMessage = xhr.responseText || "Unknown error"
                    errorDialog.open()
                }
            }
        }
        
        xhr.send(JSON.stringify(cardData))
    }

    function editCard(cardData) {
        isEdit = true
        editCardId = cardData.id
        
        nameField.text = cardData.name || ""
        setField.text = cardData.set || ""
        numberField.text = cardData.cardNumber || ""
        
        // Set combo box values
        var rarityIndex = rarityField.find(cardData.rarity || "")
        rarityField.currentIndex = rarityIndex >= 0 ? rarityIndex : 0
        
        var gradingIndex = gradingCompanyField.find(cardData.gradingCompany || "")
        gradingCompanyField.currentIndex = gradingIndex >= 0 ? gradingIndex : 0
        
        gradeField.text = cardData.grade || ""
        purchasePriceField.value = Math.round((cardData.purchasePrice || 0) * 100)
        currentValueField.value = Math.round((cardData.currentValue || 0) * 100)
        purchaseDateField.text = cardData.purchaseDate || ""
        imageUrlField.text = cardData.imageUrl || ""
        notesField.text = cardData.notes || ""
        
        title = "Edit Pokemon Card"
        open()
    }
}