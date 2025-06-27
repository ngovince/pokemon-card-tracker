// cmd/desktop/qml/main.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import PokemonTracker 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 1200
    height: 800
    title: "Pokemon Card Collection Tracker"

    Material.theme: Material.Light
    Material.accent: Material.Indigo

    property alias cardModel: cardModel
    property alias statsModel: statsModel

    CardModel {
        id: cardModel
        Component.onCompleted: refresh()
    }

    StatsModel {
        id: statsModel
        Component.onCompleted: refresh()
    }

    header: ToolBar {
        Material.foreground: "white"
        Material.background: Material.Indigo

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8

            Label {
                text: "🎴 Pokemon Card Tracker"
                font.pointSize: 16
                font.bold: true
                Layout.fillWidth: true
            }

            Button {
                text: "Add Card"
                Material.background: Material.accent
                onClicked: addCardDialog.open()
            }

            Button {
                text: "Refresh"
                onClicked: {
                    cardModel.refresh()
                    statsModel.refresh()
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // Statistics Panel
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: Material.color(Material.Grey, Material.Shade100)
            radius: 8

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16

                StatsCard {
                    Layout.fillWidth: true
                    title: "Total Cards"
                    value: statsModel.totalCards.toString()
                    icon: "📊"
                }

                StatsCard {
                    Layout.fillWidth: true
                    title: "Total Value"
                    value: "$" + statsModel.totalValue.toFixed(2)
                    icon: "💰"
                }

                StatsCard {
                    Layout.fillWidth: true
                    title: "Average Value"
                    value: "$" + statsModel.averageValue.toFixed(2)
                    icon: "📈"
                }
            }
        }

        // Search and Filter Controls
        RowLayout {
            Layout.fillWidth: true

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Search cards..."
                onTextChanged: cardGrid.filterText = text
            }

            ComboBox {
                id: gradingFilter
                model: ["All Companies", "PSA", "BGS", "CGC"]
                onCurrentTextChanged: cardGrid.gradingFilter = currentText
            }

            ComboBox {
                id: setFilter
                model: ["All Sets"] // Will be populated dynamically
                onCurrentTextChanged: cardGrid.setFilter = currentText
            }
        }

        // Card Grid
        CardGrid {
            id: cardGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: cardModel
        }
    }

    // Add Card Dialog
    AddCardDialog {
        id: addCardDialog
        onCardAdded: {
            cardModel.refresh()
            statsModel.refresh()
        }
    }

    // Stats Card Component
    component StatsCard: Rectangle {
        property string title: ""
        property string value: ""
        property string icon: ""

        color: "white"
        radius: 6
        border.color: Material.color(Material.Grey, Material.Shade300)
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: icon
                font.pointSize: 24
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: value
                font.pointSize: 20
                font.bold: true
                color: Material.accent
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: title
                font.pointSize: 10
                color: Material.color(Material.Grey, Material.Shade600)
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}