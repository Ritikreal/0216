import QtQuick
import ".." as Al

Item {
    id: root

    property string state: "idle"
    property real amplitude: 0
    property bool simulated: false
    property bool lowPower: false
    property int orbSize: 28

    implicitWidth: orbSize + (simulated ? 28 : 0)
    implicitHeight: orbSize

    readonly property color stateColor: {
        switch (state) {
        case "listening": return Al.Theme.amber
        case "speaking": return Al.Theme.sage
        case "error": return Al.Theme.red
        case "confirmation_required": return Al.Theme.red
        case "thinking": return Al.Theme.textMuted
        default: return Al.Theme.border
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: root.orbSize
        height: root.orbSize
        radius: width / 2
        color: Al.Theme.surfaceInset
        border.width: 1
        border.color: root.stateColor

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * (root.lowPower ? 0.32 : 0.28 + Math.max(0, Math.min(1, root.amplitude)) * 0.32)
            height: width
            radius: width / 2
            color: root.stateColor
            opacity: root.state === "idle" ? 0.55 : 0.95
        }
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: root.orbSize + 6
        anchors.verticalCenter: parent.verticalCenter
        visible: root.simulated
        text: "SIM"
        color: Al.Theme.textMuted
        font.family: Al.Theme.displayFont
        font.pixelSize: Al.Theme.microSize
    }
}