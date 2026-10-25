import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    implicitWidth: 780
    implicitHeight: expanded ? 570 : 76
    anchors { top: true; left: true; right: true }
    screen: Quickshell.screens[0]
    margins { top: 14; left: 0; right: 0 }
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "al-hud"
    WlrLayershell.keyboardFocus: expanded ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand

    property bool expanded: true
    property string mode: "STANDBY"
    property string draft: ""
    property var messages: [
        { who: "AL", text: "Systems are quiet. I'm ready when you are.", time: "NOW" }
    ]

    readonly property color ink: "#05090D"
    readonly property color panel: "#0A1219"
    readonly property color cyan: "#52F4E0"
    readonly property color dim: "#6E8B98"
    readonly property color line: "#203641"

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: (parent.width - Math.min(parent.width - 28, 780)) / 2
            anchors.rightMargin: (parent.width - Math.min(parent.width - 28, 780)) / 2
            radius: 22
            color: "#F0060C12"
            border.color: "#6638D9D0"
            border.width: 1
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Math.max(14, (root.width - 748) / 2)
        anchors.rightMargin: Math.max(14, (root.width - 748) / 2)
        anchors.topMargin: 12
        anchors.bottomMargin: 12
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            spacing: 13

            Rectangle {
                width: 42; height: 42; radius: 14
                color: "#102B31"; border.color: "#6B52F4E0"; border.width: 1
                Rectangle {
                    anchors.centerIn: parent
                    width: 13; height: 13; radius: 7
                    color: root.cyan
                    SequentialAnimation on opacity {
                        running: root.visible; loops: Animation.Infinite
                        NumberAnimation { to: 0.48; duration: 900 }
                        NumberAnimation { to: 1; duration: 900 }
                    }
                    Rectangle { anchors.centerIn: parent; width: 26; height: 26; radius: 13; color: "transparent"; border.color: "#8A52F4E0"; border.width: 1 }
                }
            }
            ColumnLayout {
                spacing: 2
                Text { text: "AL"; color: "#F0FAFC"; font.pixelSize: 19; font.weight: Font.DemiBold; font.letterSpacing: 3 }
                Text { text: "PERSONAL INTELLIGENCE  /  LOCAL"; color: root.dim; font.pixelSize: 9; font.letterSpacing: 1.4 }
            }
            Item { Layout.fillWidth: true }
            RowLayout {
                spacing: 6
                Rectangle { width: 6; height: 6; radius: 3; color: root.cyan }
                Text { text: root.mode; color: root.cyan; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.2 }
            }
            Rectangle {
                width: 34; height: 34; radius: 10
                color: "#111E27"; border.color: root.line
                Text { anchors.centerIn: parent; text: root.expanded ? "⌃" : "⌄"; color: "#D6EAED"; font.pixelSize: 18 }
                MouseArea { anchors.fill: parent; onClicked: root.expanded = !root.expanded }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: root.line; Layout.topMargin: 8; Layout.bottomMargin: 14 }

        RowLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 16
            visible: root.expanded

            ColumnLayout {
                Layout.preferredWidth: 204; Layout.fillHeight: true; spacing: 10
                Text { text: "SYSTEM STATUS"; color: root.dim; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.8; Layout.bottomMargin: 3 }
                Rectangle {
                    Layout.fillWidth: true; implicitHeight: 90; radius: 14
                    color: "#0B1B22"; border.color: "#25434B"
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 13; spacing: 7
                        RowLayout {
                            Text { text: "◈"; color: root.cyan; font.pixelSize: 16 }
                            Text { text: "LOCAL CORE"; color: "#D9EEF0"; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1 }
                            Item { Layout.fillWidth: true }
                            Text { text: "READY"; color: root.cyan; font.pixelSize: 9 }
                        }
                        Text { text: "Private by design.\nYour machine, your data."; color: "#819EA7"; font.pixelSize: 11; lineHeight: 1.2 }
                    }
                }
                Text { text: "CAPABILITIES"; color: root.dim; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.8; Layout.topMargin: 8; Layout.bottomMargin: 2 }
                Repeater {
                    model: [
                        ["01", "Voice interface", "STANDBY"],
                        ["02", "Local AI", "NOT CONNECTED"],
                        ["03", "System actions", "LOCKED"]
                    ]
                    delegate: Rectangle {
                        Layout.fillWidth: true; implicitHeight: 53; radius: 12
                        color: "#0A131A"; border.color: "#1C3039"
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 10; spacing: 10
                            Text { text: modelData[0]; color: "#4E9EAA"; font.pixelSize: 10; font.family: "monospace" }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 4
                                Text { text: modelData[1]; color: "#D0E3E7"; font.pixelSize: 11 }
                                Text { text: modelData[2]; color: "#69858F"; font.pixelSize: 8; font.letterSpacing: 1 }
                            }
                            Rectangle { width: 5; height: 5; radius: 3; color: modelData[2] === "LOCKED" ? "#D7A56C" : "#3E7781" }
                        }
                    }
                }
                Item { Layout.fillHeight: true }
                Text { text: "NO CLOUD  •  NO UNGUARDED COMMANDS"; color: "#45616A"; font.pixelSize: 8; font.letterSpacing: 0.7 }
            }

            Rectangle { Layout.fillHeight: true; width: 1; color: root.line }

            ColumnLayout {
                Layout.fillWidth: true; Layout.fillHeight: true; spacing: 10
                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        spacing: 3
                        Text { text: "Command interface"; color: "#E7F5F6"; font.pixelSize: 16; font.weight: Font.Medium }
                        Text { text: "A quiet place to think, build, and get things done."; color: root.dim; font.pixelSize: 10 }
                    }
                    Item { Layout.fillWidth: true }
                    Text { text: "SESSION 01"; color: "#4D6B75"; font.pixelSize: 8; font.letterSpacing: 1 }
                }

                ListView {
                    id: chat
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; spacing: 9
                    model: root.messages
                    delegate: Rectangle {
                        width: chat.width; height: bubble.implicitHeight + 24; radius: 13
                        color: modelData.who === "AL" ? "#0D2027" : "#10171F"
                        border.color: modelData.who === "AL" ? "#28515A" : "#26313B"
                        ColumnLayout {
                            id: bubble
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                            spacing: 6
                            RowLayout {
                                Text { text: modelData.who; color: modelData.who === "AL" ? root.cyan : "#B3C7CE"; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.4 }
                                Item { Layout.fillWidth: true }
                                Text { text: modelData.time; color: "#58727C"; font.pixelSize: 8 }
                            }
                            Text { text: modelData.text; color: "#D3E4E8"; font.pixelSize: 12; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; height: 48; radius: 14
                    color: "#080F15"; border.color: input.activeFocus ? "#52F4E0" : "#263E48"
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 7; spacing: 8
                        Text { text: "›"; color: root.cyan; font.pixelSize: 22 }
                        TextField {
                            id: input
                            Layout.fillWidth: true
                            placeholderText: "Ask AL anything…"
                            color: "#E0F0F2"; placeholderTextColor: "#59737D"
                            background: Item {}
                            onAccepted: {
                                if (text.trim().length === 0) return
                                root.messages = root.messages.concat([{who:"YOU", text:text.trim(), time:"NOW"}])
                                root.messages = root.messages.concat([{who:"AL", text:"This is the visual prototype. The local AI connection is not wired up yet.", time:"PREVIEW"}])
                                text = ""
                            }
                        }
                        Rectangle {
                            width: 34; height: 34; radius: 10; color: root.cyan
                            Text { anchors.centerIn: parent; text: "↗"; color: "#061116"; font.pixelSize: 18; font.bold: true }
                            MouseArea { anchors.fill: parent; onClicked: input.accepted() }
                        }
                    }
                }
                Text { text: "PREVIEW MODE  /  MESSAGES DO NOT REACH THE AI RUNTIME YET"; color: "#4E6972"; font.pixelSize: 8; font.letterSpacing: 0.6 }
            }
        }
    }

    Shortcut { sequence: "Escape"; onActivated: root.expanded = false }
    Shortcut { sequence: "Ctrl+Space"; onActivated: { root.expanded = true; root.mode = root.mode === "LISTENING" ? "STANDBY" : "LISTENING" } }
}