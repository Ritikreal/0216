import QtQuick
import QtQuick.Controls
import ".." as Al

Button {
    id: root

    property bool critical: false
    property bool quiet: false

    implicitHeight: 38
    implicitWidth: Math.max(88, contentItem.implicitWidth + leftPadding + rightPadding)
    leftPadding: 14
    rightPadding: 14
    topPadding: 8
    bottomPadding: 8

    font.family: Al.Theme.bodyFont
    font.pixelSize: Al.Theme.bodySize
    font.weight: Font.Medium
    hoverEnabled: true

    background: Rectangle {
        radius: Al.Theme.radiusSmall
        color: root.down
            ? Al.Theme.surfaceInset
            : root.hovered && !root.quiet
                ? Al.Theme.surfaceRaised
                : "transparent"
        border.width: root.quiet ? 0 : 1
        border.color: root.critical ? Al.Theme.red : Al.Theme.border
    }

    contentItem: Text {
        text: root.text
        color: !root.enabled
            ? Al.Theme.textDim
            : root.critical ? Al.Theme.red : Al.Theme.text
        font: root.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    focusPolicy: Qt.StrongFocus

    Rectangle {
        anchors.fill: parent
        radius: Al.Theme.radiusSmall
        color: "transparent"
        border.width: root.activeFocus ? 2 : 0
        border.color: Al.Theme.focus
    }
}