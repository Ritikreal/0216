import QtQuick
import QtQuick.Controls
import ".." as Al

Flickable {
    id: root

    property var entries: []
    property string provisionalText: ""
    property int entrySpacing: 12

    clip: true
    contentWidth: width
    contentHeight: transcriptColumn.implicitHeight
    boundsBehavior: Flickable.StopAtBounds

    Column {
        id: transcriptColumn
        width: root.width
        spacing: root.entrySpacing

        Repeater {
            model: root.entries

            delegate: Column {
                required property var modelData
                width: transcriptColumn.width
                spacing: 4

                Text {
                    width: parent.width
                    text: String(modelData.role || "AL").toUpperCase()
                    color: modelData.role === "user" ? Al.Theme.sage : Al.Theme.amber
                    font.family: Al.Theme.displayFont
                    font.pixelSize: Al.Theme.labelSize
                    font.letterSpacing: 0.6
                }

                Text {
                    width: parent.width
                    text: String(modelData.text || "")
                    color: Al.Theme.text
                    font.family: Al.Theme.bodyFont
                    font.pixelSize: Al.Theme.bodySize
                    wrapMode: Text.Wrap
                    textFormat: Text.PlainText
                }
            }
        }

        Text {
            width: transcriptColumn.width
            visible: root.provisionalText.length > 0
            text: root.provisionalText
            color: Al.Theme.textMuted
            opacity: 0.7
            font.family: Al.Theme.bodyFont
            font.pixelSize: Al.Theme.bodySize
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
        }
    }
}