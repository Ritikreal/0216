import QtQuick
import QtQuick.Controls
import ".." as Al

AlPanel {
    id: root

    property string summary: ""
    property string safetyTier: "SAFE"
    property string status: "READY"
    property bool canUndo: false
    signal undoRequested()

    implicitHeight: ribbonRow.implicitHeight + 20
    implicitWidth: 360

    Row {
        id: ribbonRow
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Column {
            width: Math.max(0, ribbonRow.width - undoButton.width - 20)
            spacing: 5

            Text {
                text: root.safetyTier + " / " + root.status
                color: root.safetyTier === "BLOCKED" || root.status === "ERROR"
                    ? Al.Theme.red : Al.Theme.amber
                font.family: Al.Theme.displayFont
                font.pixelSize: Al.Theme.labelSize
            }

            Text {
                width: parent.width
                text: root.summary
                color: Al.Theme.text
                font.family: Al.Theme.bodyFont
                font.pixelSize: Al.Theme.bodySize
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
            }
        }

        Button {
            id: undoButton
            visible: root.canUndo
            enabled: root.canUndo
            text: "Undo"
            onClicked: root.undoRequested()
        }
    }
}