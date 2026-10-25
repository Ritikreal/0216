import QtQuick
import ".." as Al

Text {
    id: root

    property bool display: false
    property bool muted: false
    property bool tape: false
    property color labelColor: display ? Al.Theme.amber : Al.Theme.text

    color: muted ? Al.Theme.textMuted : labelColor
    font.family: display ? Al.Theme.displayFont : Al.Theme.bodyFont
    font.pixelSize: display ? Al.Theme.labelSize : Al.Theme.bodySize
    font.letterSpacing: display ? 0.7 : 0
    font.weight: display ? Font.DemiBold : Font.Normal
    renderType: Text.NativeRendering
    wrapMode: Text.Wrap
    textFormat: Text.PlainText

    Rectangle {
        anchors.fill: parent
        anchors.margins: -4
        z: -1
        visible: root.tape
        color: Al.Theme.surfaceRaised
        border.color: Al.Theme.border
        radius: Al.Theme.radiusSmall
    }
}