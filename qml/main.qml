import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: mainWindow
    width: 400
    height: 250
    title: "Haskell + QML"
    visible: true
    
    // KEY FIX: Use self property instead of contextObject
    property var backend: self

    Component.onCompleted: {
        console.log("QML: Text transform app starting...")
        console.log("QML: backend =", backend)
        if (backend) {
            console.log("QML: Backend connected successfully!")
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20

        // Header
        Text {
            text: "STM Text Transform"
            font.pixelSize: 20
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: backend ? "Connected to STM Backend ✓" : "Backend not connected ✗"
            color: backend ? "green" : "red"
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 12
        }

        // Input Section
        Text {
            text: "Type something (transforms to uppercase in real-time):"
            font.pixelSize: 14
        }

        TextField {
            id: inputField
            Layout.fillWidth: true
            placeholderText: "Enter text here..."
            font.pixelSize: 14
            
            // Real-time transformation via property binding
            onTextChanged: {
                if (backend) {
                    backend.inputText = text
                }
            }
        }

        // Output Section  
        Text {
            text: "Transformed text:"
            font.pixelSize: 14
            Layout.topMargin: 10
        }

        Rectangle {
            Layout.fillWidth: true
            height: 50
            color: "#f5f5f5"
            border.color: "#dddddd"
            border.width: 1
            radius: 5
            
            Text {
                anchors.centerIn: parent
                text: backend ? backend.outputText : "No output yet"
                font.pixelSize: 16
                font.bold: true
                color: "#333"
            }
        }

    }
} 
