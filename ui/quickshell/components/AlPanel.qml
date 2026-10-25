import QtQuick
import ".." as Al

Rectangle {
    id: root

    property bool inset: false
    property bool stitched: false
    property int panelRadius: Al.Theme.radiusPanel

    color: inset ? Al.Theme.surfaceInset : Al.Theme.surface
    radius: panelRadius
    border.width: 1
    border.color: stitched ? Al.Theme.border : Al.Theme.borderSoft
    antialiasing: true

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: Math.max(0, root.panelRadius - 3)
        color: "transparent"
        border.width: root.stitched ? 1 : 0
        border.color: Al.Theme.border
        opacity: 0.62
        visible: root.stitched
    }

    Rectangle {
        width: 14
        height: 3
        x: 12
        y: 0
        color: Al.Theme.amber
        opacity: 0.9
        visible: root.stitched
    }
}