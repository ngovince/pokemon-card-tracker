// cmd/desktop/qml/CardGrid.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

ScrollView {
    id: root
    
    property alias model: gridView.model
    property string filterText: ""
    property string gradingFilter: "All Companies"
    property string setFilter: "All Sets"

    clip: true

    GridView {
        id: gridView
        anchors.fill: parent
        anchors.margins: 8
        
        cellWidth: 320
        cellHeight: 280
        
        delegate: CardItem {
            width: gridView.cellWidth - 16
            height: gridView.cellHeight - 16
            
            cardData: model
            
            onEditClicked: {
                // Open edit dialog
                console.log("Edit card:", model.id)
            }
            
            onDeleteClicked: {
                deleteConfirmDialog.cardId = model.id
                deleteConfirmDialog.cardName = model.name
                deleteConfirmDialog.open()
            }
        }
        
        // Animations
        add: Transition {
            NumberAnimation {
                properties: "opacity"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                properties: "scale"
                from: 0.8
                to: 1.0
                duration: 300
                easing.type: Easing.OutQuad
            }
        }
        
        remove: Transition {
            NumberAnimation {
                properties: "opacity"
                to: 0
                duration: 200
            }
            NumberAnimation {
                properties: "scale"
                to: 0.8
                duration: 200
            }
        }
    }

    // Delete Confirmation Dialog
    Dialog {
        id: deleteConfirmDialog
        
        property int cardId: -1
        property string cardName: ""
        
        anchors.centerIn: parent
        width: 300
        height: 150
        
        title: "Delete Card"
        modal: true
        
        Column {
            anchors.fill: parent
            spacing: 16
            
            Text {
                text: "Are you sure you want to delete \"" + deleteConfirmDialog.cardName + "\"?"
                wrapMode: Text.WordWrap
                width: parent.width
            }
        }
        
        standardButtons: Dialog.Yes | Dialog.No
        
        onAccepted: {
            root.model.deleteCard(cardId)
        }
    }

    // Card Item Component
    component CardItem: Rectangle {
        id: cardItem
        
        property var cardData: null
        signal editClicked()
        signal deleteClicked()
        
        color: "white"
        radius: 12
        border.color: Material.color(Material.Grey, Material.Shade300)
        border.width: 1
        
        // Hover effects
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
        }
        
        states: [
            State {
                name: "hovered"
                when: mouseArea.containsMouse
                PropertyChanges {
                    target: cardItem
                    scale: 1.05
                }
                PropertyChanges {
                    target: shadowEffect
                    radius: 16
                    samples: 33
                }
            }
        ]
        
        transitions: [
            Transition {
                NumberAnimation {
                    properties: "scale"
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        ]
        
        // Drop shadow effect
        Rectangle {
            id: shadowEffect
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.leftMargin: 4
            color: Material.color(Material.Grey, Material.Shade400)
            radius: parent.radius
            opacity: 0.3
            z: -1
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8
            
            // Header with name and grade
            RowLayout {
                width: parent.width
                
                Column {
                    Layout.fillWidth: true
                    
                    Text {
                        text: cardData ? cardData.name : ""
                        font.pointSize: 14
                        font.bold: true
                        color: Material.foreground
                        elide: Text.ElideRight
                        width: parent.width
                    }
                    
                    Text {
                        text: cardData ? cardData.set : ""
                        font.pointSize: 10
                        color: Material.color(Material.Grey, Material.Shade600)
                        elide: Text.ElideRight
                        width: parent.width
                    }
                }
                
                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 30
                    color: Material.accent
                    radius: 15
                    
                    Text {
                        anchors.centerIn: parent
                        text: cardData ? (cardData.gradingCompany + " " + cardData.grade) : ""
                        color: "white"
                        font.pointSize: 10
                        font.bold: true
                    }
                }
            }
            
            // Card details
            GridLayout {
                width: parent.width
                columns: 2
                columnSpacing: 8
                rowSpacing: 4
                
                Text {
                    text: "Number:"
                    font.pointSize: 9
                    color: Material.color(Material.Grey, Material.Shade600)
                    font.bold: true
                }
                Text {
                    text: cardData ? (cardData.cardNumber || "N/A") : ""
                    font.pointSize: 9
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                
                Text {
                    text: "Rarity:"
                    font.pointSize: 9
                    color: Material.color(Material.Grey, Material.Shade600)
                    font.bold: true
                }
                Text {
                    text: cardData ? (cardData.rarity || "N/A") : ""
                    font.pointSize: 9
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                
                Text {
                    text: "Purchase:"
                    font.pointSize: 9
                    color: Material.color(Material.Grey, Material.Shade600)
                    font.bold: true
                }
                Text {
                    text: cardData ? ("$" + cardData.purchasePrice.toFixed(2)) : ""
                    font.pointSize: 9
                    Layout.fillWidth: true
                }
                
                Text {
                    text: "Current:"
                    font.pointSize: 9
                    color: Material.color(Material.Grey, Material.Shade600)
                    font.bold: true
                }
                Text {
                    text: cardData ? ("$" + cardData.currentValue.toFixed(2)) : ""
                    font.pointSize: 9
                    font.bold: true
                    color: Material.color(Material.Green, Material.Shade700)
                    Layout.fillWidth: true
                }
            }
            
            // Notes (if any)
            Text {
                visible: cardData && cardData.notes && cardData.notes.length > 0
                text: cardData ? cardData.notes : ""
                font.pointSize: 8
                color: Material.color(Material.Grey, Material.Shade600)
                width: parent.width
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
            
            // Spacer
            Item {
                Layout.fillHeight: true
            }
            
            // Action buttons
            RowLayout {
                width: parent.width
                
                Button {
                    text: "Edit"
                    Material.background: Material.accent
                    Layout.fillWidth: true
                    onClicked: cardItem.editClicked()
                }
                
                Button {
                    text: "Delete"
                    Material.background: Material.color(Material.Red, Material.Shade600)
                    Layout.fillWidth: true
                    onClicked: cardItem.deleteClicked()
                }
            }
        }
    }
}