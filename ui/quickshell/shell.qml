import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    implicitWidth: 760
    implicitHeight: expanded ? 520 : 88
    anchors { top: true; horizontalCenter: true }
    margins { top: 18 }
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "al-hud"
    WlrLayershell.keyboardFocus: expanded ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand

    property bool expanded: true
    property string mode: "IDLE"
    property string draft: ""
    property var messages: [
        { who: "AL", text: "Hey. I'm here. What's up?", time: "NOW" },
        { who: "SYSTEM", text: "Local runtime interface • voice bridge not connected yet", time: "INFO" }
    ]

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: "#F0091118"
        border.color: "#344CE4F2"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 14
            Rectangle {
                width: 48; height: 48; radius: 24
                color: "#142A3940"; border.color: "#5BE8F4"; border.width: 1
                Rectangle {
                    anchors.centerIn: parent
                    width: 20; height: 20; radius: 10
                    color: "#67F0F5"
                    SequentialAnimation on scale {
                        running: root.visible
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.16; duration: 1000; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.92; duration: 1000; easing.type: Easing.InOutSine }
                    }
                    Rectangle { anchors.centerIn: parent; width: 34; height: 34; radius: 17; color: "transparent"; border.color: "#5570E8F4"; border.width: 1 }
                }
            }
            ColumnLayout {
                spacing: 2
                Text { text: "A L  /  LOCAL INTELLIGENCE"; color: "#E8FAFC"; font.pixelSize: 14; font.bold: true; font.letterSpacing: 2 }
                Text { text: "PERSONAL SYSTEM  •  ARCH / HYPRLAND"; color: "#6E9DA7"; font.pixelSize: 10; font.letterSpacing: 1 }
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                radius: 10; color: "#11232C"; border.color: "#285B6875"
                implicitWidth: stateLabel.implicitWidth + 20; implicitHeight: 30
                Text { id: stateLabel; anchors.centerIn: parent; text: root.mode; color: root.mode === "LISTENING" ? "#66F4D3" : "#8CAEB8"; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1 }
            }
            ToolButton {
                text: root.expanded ? "−" : "+"
                onClicked: root.expanded = !root.expanded
                contentItem: Text { text: parent.text; color: "#A9CED5"; font.pixelSize: 22; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#203B4A52" }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14
            visible: root.expanded

            ColumnLayout {
                Layout.preferredWidth: 190
                Layout.fillHeight: true
                spacing: 10
                Text { text: "CORE SYSTEMS"; color: "#628B96"; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.5 }
                Repeater {
                    model: [
                        ["01", "Local runtime", "READY"],
                        ["02", "Voice pipeline", "STANDBY"],
                        ["03", "Tool permissions", "LOCKED"]
                    ]
                    delegate: Rectangle {
                        Layout.fillWidth: true; implicitHeight: 54; radius: 12
                        color: "#0B1720"; border.color: "#1C3641"
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 10; spacing: 9
                            Text { text: modelData[0]; color: "#4ADDE8"; font.pixelSize: 10 }
                            ColumnLayout {
                                spacing: 3
                                Text { text: modelData[1]; color: "#C9E5EA"; font.pixelSize: 11 }
                                Text { text: modelData[2]; color: "#608A96"; font.pixelSize: 9; font.letterSpacing: 1 }
                            }
                        }
                    }
                }
                Item { Layout.fillHeight: true }
                Text { text: "LOCAL-FIRST  /  NO CLOUD"; color: "#426A75"; font.pixelSize: 9; font.letterSpacing: 1 }
            }

            Rectangle { Layout.fillHeight: true; width: 1; color: "#203B4A52" }

            ColumnLayout {
                Layout.fillWidth: true; Layout.fillHeight: true; spacing: 10
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "CONVERSATION"; color: "#628B96"; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.5 }
                    Item { Layout.fillWidth: true }
                    Text { text: "SESSION 001"; color: "#426A75"; font.pixelSize: 9 }
                }
                ListView {
                    id: chat
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; spacing: 8
                    model: root.messages
                    delegate: Rectangle {
                        width: chat.width; height: bubble.implicitHeight + 22; radius: 12
                        color: modelData.who === "AL" ? "#11232C" : "#0A141B"
                        border.color: modelData.who === "AL" ? "#244A56" : "#1A3039"
                        ColumnLayout {
                            id: bubble
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 11 }
                            spacing: 4
                            RowLayout {
                                Text { text: modelData.who; color: modelData.who === "AL" ? "#5DE4F0" : "#77949D"; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1 }
                                Item { Layout.fillWidth: true }
                                Text { text: modelData.time; color: "#46626B"; font.pixelSize: 9 }
                            }
                            Text { text: modelData.text; color: "#C5DCE1"; font.pixelSize: 12; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true; spacing: 8
                    TextField {
                        id: input
                        Layout.fillWidth: true
                        placeholderText: "Message AL… (UI preview only)"
                        color: "#D9F2F5"; placeholderTextColor: "#557680"
                        leftPadding: 14; rightPadding: 14
                        background: Rectangle { radius: 12; color: "#0A151D"; border.color: input.activeFocus ? "#4CDDE9" : "#25414C" }
                        onAccepted: {
                            if (text.trim().length === 0) return
                            root.messages = root.messages.concat([{who:"YOU", text:text.trim(), time:"NOW"}])
                            root.messages = root.messages.concat([{who:"AL", text:"The UI is alive, but the AI/runtime bridge is the next integration step.", time:"LOCAL"}])
                            text = ""
                            root.mode = "IDLE"
                        }
                    }
                    Button {
                        text: "↗"
                        onClicked: input.accepted()
                        contentItem: Text { text: parent.text; color: "#061318"; font.pixelSize: 18; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        background: Rectangle { radius: 11; color: "#62E7F0" }
                    }
                }
            }
        }
    }

    Shortcut { sequence: "Escape"; onActivated: root.expanded = false }
    Shortcut { sequence: "Ctrl+Space"; onActivated: { root.expanded = true; root.mode = root.mode === "LISTENING" ? "IDLE" : "LISTENING" } }
}
