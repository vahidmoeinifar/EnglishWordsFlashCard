import QtQuick
import QtQuick.Controls
import backend 1.0

ApplicationWindow {
    id: window
    width: 800
    height: 600
    visible: true
    title: "English Words Flash Card"

    // Global color palette for dark theme
    readonly property color backgroundColor: "#1a1a2e"
    readonly property color cardBackground: "#16213e"
    readonly property color textColor: "#e6e6e6"
    readonly property color accentColor: "#0f4c75"
    readonly property color secondaryColor: "#3282b8"
    readonly property color highlightColor: "#bbe1fa"
    readonly property color successColor: "#4CAF50"
    readonly property color warningColor: "#FF9800"

    color: backgroundColor

    // WordDB instance
    WordDB {
        id: wordDB
        onDatabaseOpened: {
            if (success) {
                console.log("Database opened successfully with", getTotalWords(), "words")
                // Load first word immediately
                sendRandomRecord()
            } else {
                console.error("Failed to open database")
            }
        }

        // Add signal for when word changes
        onWordChanged: {
            console.log("Word changed to:", word)
        }

        onDefinitionChanged: {
            console.log("Definition loaded")
        }
    }

    // Header
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        color: "transparent"

        Text {
            anchors.centerIn: parent
            text: "📚 English Flash Cards"
            font.pixelSize: 32
            font.bold: true
            color: highlightColor
        }

        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            width: totalWordsLabel.width + 20
            height: 35
            radius: 17
            color: secondaryColor

            Text {
                id: totalWordsLabel
                anchors.centerIn: parent
                text: (wordDB && wordDB.getTotalWords) ? wordDB.getTotalWords() + " words" : "Loading..."
                color: textColor
                font.pixelSize: 14
            }
        }
    }

    // Flashcard Container
    Item {
        id: flashcardContainer
        width: 500
        height: 320
        anchors.centerIn: parent

        property bool flipped: false
        property bool isLoading: true

        // Initial load animation
        SequentialAnimation {
            id: initialLoadAnimation
            running: true
            PauseAnimation { duration: 100 }
            ScriptAction {
                script: {
                    // Force load first word on startup
                    if (wordDB && wordDB.getTotalWords) {
                        wordDB.sendRandomRecord()
                        flashcardContainer.isLoading = false
                    }
                }
            }
        }

        // Flip animation
        SequentialAnimation {
            id: flipAnimation
            PropertyAnimation {
                target: flashcardContainer
                property: "rotationAngle"
                to: 90
                duration: 200
                easing.type: Easing.InQuad
            }
            ScriptAction {
                script: {
                    flashcardContainer.flipped = !flashcardContainer.flipped
                }
            }
            PropertyAnimation {
                target: flashcardContainer
                property: "rotationAngle"
                from: -90
                to: 0
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        // Property for animation
        property real rotationAngle: 0

        // The flashcard
        Rectangle {
            id: flashcard
            anchors.fill: parent
            radius: 15
            color: cardBackground
            border.width: 2
            border.color: accentColor

            transform: Rotation {
                origin.x: flashcard.width / 2
                origin.y: flashcard.height / 2
                axis.x: 0; axis.y: 1; axis.z: 0
                angle: flashcardContainer.rotationAngle
            }

            // Loading overlay
            Rectangle {
                anchors.fill: parent
                color: cardBackground
                radius: 15
                visible: flashcardContainer.isLoading
                z: 10

                Column {
                    anchors.centerIn: parent
                    spacing: 20

                    Text {
                        text: "Loading words..."
                        color: highlightColor
                        font.pixelSize: 24
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 200
                        height: 4
                        radius: 2
                        color: accentColor

                        Rectangle {
                            width: parent.width
                            height: parent.height
                            radius: 2
                            color: successColor

                        }
                    }
                }
            }

            // Front side - Word
            Item {
                id: frontSide
                anchors.fill: parent
                visible: !flashcardContainer.flipped && !flashcardContainer.isLoading

                Column {
                    anchors.centerIn: parent
                    spacing: 25
                    width: parent.width * 0.85

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: wordTypeLabel.width + 24
                        height: 36
                        radius: 18
                        color: accentColor
                        border.width: 1
                        border.color: secondaryColor

                        Text {
                            id: wordTypeLabel
                            anchors.centerIn: parent
                            text: wordDB.type || "Word"
                            color: highlightColor
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }

                    Text {
                        width: parent.width
                        text: wordDB.word || "Click 'Next' to load"
                        font.pixelSize: 46
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        color: textColor
                        minimumPixelSize: 24
                        fontSizeMode: Text.Fit
                    }

                    Text {
                        text: "Click to see definition →"
                        color: secondaryColor
                        font.pixelSize: 14
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // Back side - Definition
            Item {
                id: backSide
                anchors.fill: parent
                visible: flashcardContainer.flipped && !flashcardContainer.isLoading

                Column {
                    anchors.fill: parent
                    anchors.margins: 25
                    spacing: 20

                    Row {
                        width: parent.width
                        spacing: 10

                        Text {
                            text: "Definition"
                            font.pixelSize: 20
                            font.bold: true
                            color: highlightColor
                        }

                        Rectangle {
                            width: typeLabelBack.width + 16
                            height: 28
                            radius: 14
                            color: accentColor
                            border.width: 1
                            border.color: secondaryColor

                            Text {
                                id: typeLabelBack
                                anchors.centerIn: parent
                                text: wordDB.type
                                color: highlightColor
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }

                    Flickable {
                        width: parent.width
                        height: parent.height - 80
                        contentWidth: width
                        contentHeight: definitionContent.height
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        Text {
                            id: definitionContent
                            width: parent.width
                            text: wordDB.definition || "No definition available"
                            font.pixelSize: 20
                            lineHeight: 1.4
                            wrapMode: Text.WordWrap
                            color: textColor
                        }
                    }

                    Text {
                        text: "← Click for next word"
                        color: secondaryColor
                        font.pixelSize: 14
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // Click area
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (flashcardContainer.isLoading) return;

                    if (!flashcardContainer.flipped) {
                        // First click: flip to show definition
                        flipAnimation.start()
                    } else {
                        // Second click: get new word and flip back
                        // First flip back to front
                        var flipToFront = flipAnimationToFront.createObject(flashcardContainer)
                        flipToFront.start()
                    }
                }
            }
        }

        // Animation for flipping back to front with new word
        Component {
            id: flipAnimationToFront
            SequentialAnimation {
                PropertyAnimation {
                    target: flashcardContainer
                    property: "rotationAngle"
                    to: 90
                    duration: 200
                    easing.type: Easing.InQuad
                }
                ScriptAction {
                    script: {
                        flashcardContainer.flipped = false
                        wordDB.sendRandomRecord()
                    }
                }
                PropertyAnimation {
                    target: flashcardContainer
                    property: "rotationAngle"
                    from: -90
                    to: 0
                    duration: 200
                    easing.type: Easing.OutQuad
                }
                ScriptAction {
                    script: {
                        if (this.running) {
                            this.destroy()
                        }
                    }
                }
            }
        }
    }

    // Control buttons
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20

        // Flip button
        Rectangle {
            width: 140
            height: 45
            radius: 22
            color: flipMouse.containsPress ? accentColor : secondaryColor
            opacity: flashcardContainer.isLoading ? 0.5 : 1.0

            Text {
                anchors.centerIn: parent
                text: "🔁 Flip Card"
                color: textColor
                font.pixelSize: 16
                font.bold: true
            }

            MouseArea {
                id: flipMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                enabled: !flashcardContainer.isLoading
                onClicked: {
                    if (!flashcardContainer.isLoading) {
                        flipAnimation.start()
                    }
                }
            }
        }

        // Next button
        Rectangle {
            width: 140
            height: 45
            radius: 22
            color: nextMouse.containsPress ? successColor : "#66bb6a"
            opacity: flashcardContainer.isLoading ? 0.5 : 1.0

            Text {
                anchors.centerIn: parent
                text: "⏭ Next Word"
                color: textColor
                font.pixelSize: 16
                font.bold: true
            }

            MouseArea {
                id: nextMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                enabled: !flashcardContainer.isLoading
                onClicked: {
                    if (flashcardContainer.isLoading) return;

                    if (flashcardContainer.flipped) {
                        // If showing definition, flip back first
                        var flipToFront = flipAnimationToFront.createObject(flashcardContainer)
                        flipToFront.start()
                    } else {
                        // If showing word, just get new word
                        wordDB.sendRandomRecord()
                    }
                }
            }
        }

        // Show/Hide button
        Rectangle {
            width: 140
            height: 45
            radius: 22
            color: showMouse.containsPress ? warningColor : "#FFB74D"
            visible: flashcardContainer.flipped && !flashcardContainer.isLoading
            opacity: flashcardContainer.isLoading ? 0.5 : 1.0

            Text {
                anchors.centerIn: parent
                text: "🔙 Show Word"
                color: textColor
                font.pixelSize: 16
                font.bold: true
            }

            MouseArea {
                id: showMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                enabled: !flashcardContainer.isLoading
                onClicked: {
                    if (!flashcardContainer.isLoading) {
                        flipAnimation.start()
                    }
                }
            }
        }
    }

    // Status bar
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 35
        color: accentColor

        Row {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 15

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Current: " + (wordDB.word ? wordDB.word : "Loading...")
                color: textColor
                font.pixelSize: 13
                elide: Text.ElideRight
                width: 300
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 12
                height: 12
                radius: 6
                color: {
                    if (flashcardContainer.isLoading) return warningColor;
                    return wordDB.getTotalWords() > 0 ? successColor : "#f44336";
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (flashcardContainer.isLoading) return "Loading...";
                    return "DB: " + (wordDB.getTotalWords() > 0 ? "Connected" : "Disconnected");
                }
                color: textColor
                font.pixelSize: 13
            }

            Item { width: parent.width - 450 }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (flashcardContainer.isLoading) return "Loading...";
                    return "Card: " + (flashcardContainer.flipped ? "Definition" : "Word");
                }
                color: highlightColor
                font.pixelSize: 13
                font.bold: true
            }
        }
    }

    // Instructions
    Text {
        anchors.top: flashcardContainer.bottom
        anchors.topMargin: 25
        anchors.horizontalCenter: parent.horizontalCenter
        text: "💡 SPACE: Flip • RIGHT: Next • LEFT: Previous • ESC: Exit"
        color: secondaryColor
        font.pixelSize: 14
        visible: !flashcardContainer.isLoading
    }

    // Progress indicator
    Rectangle {
        anchors.top: flashcardContainer.bottom
        anchors.topMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        width: 200
        height: 4
        radius: 2
        color: accentColor
        visible: !flashcardContainer.isLoading

        Rectangle {
            width: parent.width * (wordDB.getTotalWords() > 0 ? 1 : 0.3)
            height: parent.height
            radius: 2
            color: successColor
        }
    }

    // Keyboard shortcuts
    Shortcut {
        sequence: "Space"
        enabled: !flashcardContainer.isLoading
        onActivated: {
            if (!flashcardContainer.isLoading) {
                flipAnimation.start()
            }
        }
    }

    Shortcut {
        sequence: "Right"
        enabled: !flashcardContainer.isLoading
        onActivated: {
            if (flashcardContainer.isLoading) return;

            if (flashcardContainer.flipped) {
                var flipToFront = flipAnimationToFront.createObject(flashcardContainer)
                flipToFront.start()
            } else {
                wordDB.sendRandomRecord()
            }
        }
    }

    Shortcut {
        sequence: "Left"
        enabled: !flashcardContainer.isLoading && flashcardContainer.flipped
        onActivated: {
            if (!flashcardContainer.isLoading && flashcardContainer.flipped) {
                flipAnimation.start()
            }
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: window.close()
    }

    Shortcut {
        sequences: ["Ctrl+Q", "Ctrl+W"]
        onActivated: window.close()
    }

    // Initialize - Force load first word
    Component.onCompleted: {
        console.log("Flashcard app started")
        // Start initial load animation
        initialLoadAnimation.start()
    }
}
