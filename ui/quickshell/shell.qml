import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    implicitWidth: 920
    implicitHeight: expanded ? 690 : 82
    anchors { top: true; left: true; right: true }
    screen: Quickshell.screens[0]
    margins { top: 12; left: 0; right: 0 }
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "al-hud"
    WlrLayershell.keyboardFocus: expanded ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand

    property bool expanded: true
    property string mode: "IDLE"
    property string page: "Overview"
    property string draft: ""
    property string notice: ""
    property string noticeKind: "info"
    property var messages: [
        { who: "AL", text: "All quiet. I'm ready when you are.", time: "NOW" }
    ]
    property var activity: [
        { time: "JUST NOW", title: "Local runtime", detail: "HUD preview loaded. Voice bridge is not connected.", state: "INFO" },
        { time: "SESSION", title: "Privacy boundary", detail: "No cloud calls or shell commands are made by this preview.", state: "SAFE" }
    ]
    property var quickActions: [
        { title: "Start a conversation", detail: "Open the local chat workspace", icon: "↗", target: "Chat" },
        { title: "Inspect capabilities", detail: "See what is connected and what is planned", icon: "⌘", target: "Capabilities" },
        { title: "Open activity stream", detail: "Review recent events and notices", icon: "≋", target: "Activity" },
        { title: "System overview", detail: "Runtime state and interface controls", icon: "◈", target: "Overview" }
    ]

    readonly property color ink: "#05090D"
    readonly property color panel: "#09131B"
    readonly property color panelRaised: "#0D1B25"
    readonly property color cyan: "#62F5DF"
    readonly property color teal: "#2CAFA9"
    readonly property color dim: "#7C98A5"
    readonly property color muted: "#4D6875"
    readonly property color line: "#203744"
    readonly property color amber: "#F1C27A"
    readonly property color red: "#F17D8A"

    function notify(message, kind) {
        notice = message
        noticeKind = kind || "info"
    }
    function addActivity(title, detail, state) {
        activity = [{ time: "JUST NOW", title: title, detail: detail, state: state || "INFO" }].concat(activity).slice(0, 12)
    }
    function setPage(target) {
        page = target
        notice = ""
        if (target === "Chat") input.forceActiveFocus()
    }
    function submitMessage(value) {
        var clean = value.trim()
        if (clean.length === 0) {
            notify("Type a message first.", "error")
            return
        }
        messages = messages.concat([{ who: "YOU", text: clean, time: "NOW" }])
        messages = messages.concat([{ who: "AL", text: "This is the interface preview. The local AI runtime is not connected yet, so I have not sent this message anywhere.", time: "PREVIEW" }])
        addActivity("Preview message", "A local demo message was added to the conversation.", "INFO")
        draft = ""
        input.text = ""
        notify("Message added to the local preview. AI is not connected yet.", "success")
        chat.positionViewAtEnd()
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: Math.max(12, (parent.width - 940) / 2)
            anchors.rightMargin: Math.max(12, (parent.width - 940) / 2)
            radius: 24
            color: "#F0060C12"
            border.color: "#6638D9D0"
            border.width: 1
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Math.max(20, (root.width - 900) / 2)
        anchors.rightMargin: Math.max(20, (root.width - 900) / 2)
        anchors.topMargin: 14
        anchors.bottomMargin: 14
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            spacing: 12

            Rectangle {
                id: core
                width: 42; height: 42; radius: 14
                color: "#0B2228"; border.color: "#735FF5DF"; border.width: 1
                clip: true
                Rectangle {
                    anchors.centerIn: parent
                    width: root.mode === "LISTENING" ? 37 : 32; height: width; radius: width / 2
                    color: "transparent"; border.color: "#8B62F5DF"; border.width: root.mode === "THINKING" ? 2 : 1
                    Behavior on width { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
                    RotationAnimation on rotation { from: 0; to: 360; duration: root.mode === "THINKING" ? 1800 : 8500; loops: Animation.Infinite }
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: root.mode === "SPEAKING" ? 25 : 21; height: width; radius: width / 2
                    color: "transparent"; border.color: "#B562F5DF"; border.width: 1
                    Behavior on width { NumberAnimation { duration: 180 } }
                    RotationAnimation on rotation { from: 360; to: 0; duration: 4200; loops: Animation.Infinite }
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: 7; height: 7; radius: 4
                    color: root.mode === "ERROR" ? root.red : root.mode === "ACTION" ? root.amber : root.cyan
                    SequentialAnimation on scale {
                        running: root.visible; loops: Animation.Infinite
                        NumberAnimation { to: 1.4; duration: 900; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.8; duration: 900; easing.type: Easing.InOutSine }
                    }
                }
                Rectangle {
                    width: 4; height: 4; radius: 2; color: "#E9FFFB"
                    x: 19 + Math.cos(orbitDot.rotation * Math.PI / 180) * 15
                    y: 19 + Math.sin(orbitDot.rotation * Math.PI / 180) * 15
                    RotationAnimation { id: orbit; target: orbitDot; property: "rotation"; from: 0; to: 360; duration: 3300; loops: Animation.Infinite }
                }
            }
            ColumnLayout {
                spacing: 1
                Text { text: "AL"; color: "#F2FCFD"; font.pixelSize: 19; font.weight: Font.DemiBold; font.letterSpacing: 3 }
                Text { text: "PERSONAL INTELLIGENCE  /  LOCAL"; color: root.dim; font.pixelSize: 8; font.letterSpacing: 1.35 }
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                radius: 9; color: "#0C201F"; border.color: "#28544F"
                Layout.preferredWidth: 112; Layout.preferredHeight: 28
                RowLayout {
                    anchors.centerIn: parent; spacing: 7
                    Rectangle { width: 5; height: 5; radius: 3; color: root.cyan }
                    Text { text: root.mode; color: root.mode === "ERROR" ? root.red : root.mode === "ACTION" ? root.amber : root.cyan; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1 }
                }
            }
            Rectangle {
                width: 34; height: 34; radius: 10; color: "#111F29"; border.color: root.line
                Text { anchors.centerIn: parent; text: root.expanded ? "⌃" : "⌄"; color: "#D9ECEF"; font.pixelSize: 18 }
                MouseArea { anchors.fill: parent; onClicked: root.expanded = !root.expanded }
            }
        }

        Rectangle {
            Layout.fillWidth: true; height: 1
            color: root.line; Layout.topMargin: 9; Layout.bottomMargin: 12
            Rectangle {
                width: 68; height: 1; color: root.cyan; opacity: 0.8
                SequentialAnimation on x {
                    running: root.visible; loops: Animation.Infinite
                    NumberAnimation { from: 0; to: Math.max(0, parent.width - 68); duration: 4600; easing.type: Easing.InOutSine }
                    NumberAnimation { from: Math.max(0, parent.width - 68); to: 0; duration: 4600; easing.type: Easing.InOutSine }
                }
            }
        }

        RowLayout {
            visible: root.expanded
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 0

            Rectangle {
                Layout.preferredWidth: 174; Layout.fillHeight: true
                color: "transparent"
                ColumnLayout {
                    anchors.fill: parent; anchors.rightMargin: 12; spacing: 5
                    Text { text: "WORKSPACE"; color: root.muted; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.7; Layout.leftMargin: 10; Layout.bottomMargin: 7 }
                    Repeater {
                        model: [
                            { label: "Overview", glyph: "◈" },
                            { label: "Chat", glyph: "↗" },
                            { label: "Capabilities", glyph: "⌘" },
                            { label: "Activity", glyph: "≋" },
                            { label: "Settings", glyph: "⚙" }
                        ]
                        delegate: Rectangle {
                            Layout.fillWidth: true; height: 39; radius: 11
                            color: root.page === modelData.label ? "#14302F" : navMouse.containsMouse ? "#101F28" : "transparent"
                            border.color: root.page === modelData.label ? "#356B63" : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 11; anchors.rightMargin: 9; spacing: 10
                                Text { text: modelData.glyph; color: root.page === modelData.label ? root.cyan : root.dim; font.pixelSize: 16; Layout.preferredWidth: 17; horizontalAlignment: Text.AlignHCenter }
                                Text { text: modelData.label; color: root.page === modelData.label ? "#E4F7F4" : "#8BA2AC"; font.pixelSize: 11; font.weight: root.page === modelData.label ? Font.DemiBold : Font.Normal; Layout.fillWidth: true }
                                Rectangle { visible: root.page === modelData.label; width: 4; height: 4; radius: 2; color: root.cyan }
                            }
                            MouseArea { id: navMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.setPage(modelData.label) }
                        }
                    }
                    Item { Layout.fillHeight: true }
                    Rectangle {
                        Layout.fillWidth: true; implicitHeight: 102; radius: 13
                        color: "#0A171E"; border.color: "#1B333D"
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 12; spacing: 7
                            RowLayout {
                                Text { text: "LOCAL FIRST"; color: root.cyan; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1 }
                                Item { Layout.fillWidth: true }
                                Rectangle { width: 5; height: 5; radius: 3; color: root.cyan }
                            }
                            Text { text: "Private by default.\nYour machine, your data."; color: "#89A3AC"; font.pixelSize: 10; lineHeight: 1.2; Layout.fillWidth: true }
                            Text { text: "NO CLOUD FALLBACK"; color: "#4F707B"; font.pixelSize: 8; font.letterSpacing: 0.7 }
                        }
                    }
                    Text { text: "AL  /  PHASE 02"; color: "#3E5A65"; font.pixelSize: 8; font.letterSpacing: 1; Layout.leftMargin: 5; Layout.topMargin: 5 }
                }
            }

            Rectangle { Layout.fillHeight: true; width: 1; color: root.line; Layout.leftMargin: 1; Layout.rightMargin: 17 }

            Item {
                Layout.fillWidth: true; Layout.fillHeight: true
                StackLayout {
                    anchors.fill: parent
                    currentIndex: ["Overview", "Chat", "Capabilities", "Activity", "Settings"].indexOf(root.page)

                    // OVERVIEW
                    Flickable {
                        clip: true; contentWidth: width; contentHeight: overviewColumn.implicitHeight
                        boundsBehavior: Flickable.StopAtBounds
                        ColumnLayout {
                            id: overviewColumn
                            width: parent.width; spacing: 13
                            RowLayout {
                                Layout.fillWidth: true
                                ColumnLayout {
                                    spacing: 4
                                    Text { text: "Your lab, at a glance."; color: "#EDF8F8"; font.pixelSize: 22; font.weight: Font.Medium }
                                    Text { text: "A personal workspace for thinking, building, and doing."; color: root.dim; font.pixelSize: 10; wrapMode: Text.Wrap }
                                }
                                Item { Layout.fillWidth: true }
                                Text { text: "LOCAL SESSION"; color: "#53717D"; font.pixelSize: 8; font.letterSpacing: 1 }
                            }

                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 154; radius: 17; clip: true
                                color: "#0B1B24"; border.color: "#25464F"
                                Rectangle {
                                    width: 220; height: 220; radius: 110
                                    anchors.right: parent.right; anchors.rightMargin: 26; anchors.verticalCenter: parent.verticalCenter
                                    color: "transparent"; border.color: "#173C43"; border.width: 1
                                    Rectangle { anchors.centerIn: parent; width: 170; height: 170; radius: 85; color: "transparent"; border.color: "#20534F"; border.width: 1 }
                                    Rectangle { anchors.centerIn: parent; width: 118; height: 118; radius: 59; color: "#0B252A"; border.color: "#3B8980"; border.width: 1 }
                                    Rectangle { anchors.centerIn: parent; width: 78; height: 78; radius: 39; color: "#102E32"; border.color: "#4FCFBC"; border.width: 1 }
                                    Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; color: root.cyan
                                        SequentialAnimation on opacity { running: root.visible; loops: Animation.Infinite; NumberAnimation { to: 0.45; duration: 900 }; NumberAnimation { to: 1; duration: 900 } }
                                    }
                                    RotationAnimation on rotation { from: 0; to: 360; duration: 18000; loops: Animation.Infinite }
                                }
                                ColumnLayout {
                                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 20 }
                                    spacing: 9
                                    Text { text: "SYSTEM ONLINE"; color: root.cyan; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.5 }
                                    Text { text: "Build something\nremarkable."; color: "#F1FAFA"; font.pixelSize: 23; font.weight: Font.Medium; lineHeight: 1.0 }
                                    Text { text: "The interface is ready. Intelligence integration is next."; color: "#8AA7AF"; font.pixelSize: 9; wrapMode: Text.Wrap; Layout.maximumWidth: 275 }
                                }
                            }

                            Text { text: "QUICK ACCESS"; color: root.muted; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.5; Layout.topMargin: 1 }
                            GridLayout {
                                Layout.fillWidth: true; columns: 2; columnSpacing: 9; rowSpacing: 9
                                Repeater {
                                    model: root.quickActions
                                    delegate: Rectangle {
                                        Layout.fillWidth: true; Layout.preferredHeight: 78; radius: 13
                                        color: quickMouse.containsMouse ? "#11272D" : "#0A171F"; border.color: quickMouse.containsMouse ? "#3D827A" : "#203944"
                                        Behavior on color { ColorAnimation { duration: 130 } }
                                        ColumnLayout {
                                            anchors.fill: parent; anchors.margins: 12; spacing: 5
                                            RowLayout {
                                                Text { text: modelData.icon; color: root.cyan; font.pixelSize: 16 }
                                                Item { Layout.fillWidth: true }
                                                Text { text: "↗"; color: "#587985"; font.pixelSize: 12 }
                                            }
                                            Text { text: modelData.title; color: "#DDECEF"; font.pixelSize: 11; font.weight: Font.DemiBold }
                                            Text { text: modelData.detail; color: root.dim; font.pixelSize: 9; wrapMode: Text.Wrap; Layout.fillWidth: true }
                                        }
                                        MouseArea { id: quickMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.setPage(modelData.target) }
                                    }
                                }
                            }

                            Text { text: "RUNTIME SNAPSHOT"; color: root.muted; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.5; Layout.topMargin: 2 }
                            GridLayout {
                                Layout.fillWidth: true; columns: 3; columnSpacing: 8
                                Repeater {
                                    model: [
                                        { value: "LOCAL", label: "INFERENCE", tint: "#62F5DF" },
                                        { value: "READY", label: "VOICE LOOP", tint: "#62F5DF" },
                                        { value: "PREVIEW", label: "HUD BRIDGE", tint: "#F1C27A" }
                                    ]
                                    delegate: Rectangle {
                                        Layout.fillWidth: true; Layout.preferredHeight: 66; radius: 11; color: "#0A151D"; border.color: "#1D343E"
                                        ColumnLayout {
                                            anchors.fill: parent; anchors.margins: 10; spacing: 6
                                            Text { text: modelData.value; color: modelData.tint; font.pixelSize: 12; font.bold: true; font.letterSpacing: 0.6 }
                                            Text { text: modelData.label; color: "#617E89"; font.pixelSize: 8; font.letterSpacing: 0.8 }
                                        }
                                    }
                                }
                            }
                            Item { Layout.preferredHeight: 4 }
                        }
                    }

                    // CHAT
                    ColumnLayout {
                        spacing: 10
                        RowLayout {
                            Layout.fillWidth: true
                            ColumnLayout {
                                spacing: 3
                                Text { text: "Conversation"; color: "#EDF8F8"; font.pixelSize: 21; font.weight: Font.Medium }
                                Text { text: "A private space for your thoughts and tasks."; color: root.dim; font.pixelSize: 10 }
                            }
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                radius: 8; color: "#10221F"; border.color: "#2C5148"; width: 85; height: 26
                                Text { anchors.centerIn: parent; text: "LOCAL PREVIEW"; color: root.cyan; font.pixelSize: 8; font.bold: true }
                            }
                        }
                        ListView {
                            id: chat
                            Layout.fillWidth: true; Layout.fillHeight: true
                            clip: true; spacing: 9; model: root.messages
                            boundsBehavior: Flickable.StopAtBounds
                            delegate: Rectangle {
                                width: chat.width; height: bubble.implicitHeight + 25; radius: 13
                                color: modelData.who === "AL" ? "#0D2027" : "#111A23"
                                border.color: modelData.who === "AL" ? "#28515A" : "#263B46"
                                ColumnLayout {
                                    id: bubble
                                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                                    spacing: 6
                                    RowLayout {
                                        Text { text: modelData.who; color: modelData.who === "AL" ? root.cyan : "#B3C7CE"; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.2 }
                                        Item { Layout.fillWidth: true }
                                        Text { text: modelData.time; color: "#58727C"; font.pixelSize: 8 }
                                    }
                                    Text { text: modelData.text; color: "#D3E4E8"; font.pixelSize: 12; wrapMode: Text.Wrap; Layout.fillWidth: true }
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true; height: 49; radius: 13
                            color: "#080F15"; border.color: input.activeFocus ? root.cyan : "#263E48"
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 13; anchors.rightMargin: 7; spacing: 8
                                Text { text: "›"; color: root.cyan; font.pixelSize: 22 }
                                TextField {
                                    id: input; Layout.fillWidth: true
                                    placeholderText: "Write a thought or command…"
                                    color: "#E0F0F2"; placeholderTextColor: "#59737D"
                                    background: Item {}
                                    onTextChanged: root.draft = text
                                    onAccepted: root.submitMessage(text)
                                }
                                Rectangle {
                                    width: 35; height: 35; radius: 10; color: root.cyan
                                    Text { anchors.centerIn: parent; text: "↗"; color: "#061116"; font.pixelSize: 18; font.bold: true }
                                    MouseArea { anchors.fill: parent; onClicked: root.submitMessage(input.text) }
                                }
                            }
                        }
                        Text { text: "DEMO ONLY  /  MESSAGES STAY IN THIS UI"; color: "#4E6972"; font.pixelSize: 8; font.letterSpacing: 0.7 }
                    }

                    // CAPABILITIES
                    Flickable {
                        clip: true; contentWidth: width; contentHeight: capabilityColumn.implicitHeight
                        boundsBehavior: Flickable.StopAtBounds
                        ColumnLayout {
                            id: capabilityColumn; width: parent.width; spacing: 12
                            Text { text: "Capabilities"; color: "#EDF8F8"; font.pixelSize: 22; font.weight: Font.Medium }
                            Text { text: "A transparent view of what is real today and what still needs integration."; color: root.dim; font.pixelSize: 10; wrapMode: Text.Wrap; Layout.fillWidth: true }
                            Repeater {
                                model: [
                                    { number: "01", title: "Local speech recognition", state: "IMPLEMENTED IN CLI", detail: "faster-whisper runs locally using the configured model." , tone: "#62F5DF" },
                                    { number: "02", title: "Spoken responses", state: "IMPLEMENTED IN CLI", detail: "Kokoro ONNX generates speech locally; runtime is not wired to this HUD.", tone: "#62F5DF" },
                                    { number: "03", title: "General local AI", state: "NOT CONNECTED", detail: "A conversation model and safe request routing still need to be integrated.", tone: "#F1C27A" },
                                    { number: "04", title: "Desktop skills", state: "NOT CONNECTED", detail: "Actions should use explicit skills with SAFE, CONFIRM, and BLOCKED policies.", tone: "#F1C27A" },
                                    { number: "05", title: "Live system telemetry", state: "PLANNED", detail: "CPU, memory, model and service health require a real metrics provider.", tone: "#8DA7B1" },
                                    { number: "06", title: "HUD and voice bridge", state: "PREVIEW ONLY", detail: "UI state chips are previews; they do not start microphone capture.", tone: "#F1C27A" }
                                ]
                                delegate: Rectangle {
                                    Layout.fillWidth: true; implicitHeight: 91; radius: 13; color: "#0A171F"; border.color: "#203943"
                                    RowLayout {
                                        anchors.fill: parent; anchors.margins: 13; spacing: 12
                                        Rectangle {
                                            Layout.preferredWidth: 35; Layout.preferredHeight: 35; radius: 11; color: "#10262B"; border.color: "#244B4D"
                                            Text { anchors.centerIn: parent; text: modelData.number; color: root.cyan; font.pixelSize: 10; font.family: "monospace" }
                                        }
                                        ColumnLayout {
                                            Layout.fillWidth: true; spacing: 5
                                            RowLayout {
                                                Text { text: modelData.title; color: "#DCECEF"; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true; wrapMode: Text.Wrap }
                                                Text { text: modelData.state; color: modelData.tone; font.pixelSize: 8; font.bold: true; horizontalAlignment: Text.AlignRight }
                                            }
                                            Text { text: modelData.detail; color: root.dim; font.pixelSize: 10; wrapMode: Text.Wrap; Layout.fillWidth: true }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ACTIVITY
                    ColumnLayout {
                        spacing: 11
                        RowLayout {
                            Layout.fillWidth: true
                            ColumnLayout {
                                spacing: 3
                                Text { text: "Activity stream"; color: "#EDF8F8"; font.pixelSize: 22; font.weight: Font.Medium }
                                Text { text: "Recent events and interface notices for this session."; color: root.dim; font.pixelSize: 10 }
                            }
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                width: 76; height: 28; radius: 9; color: "#101D26"; border.color: root.line
                                Text { anchors.centerIn: parent; text: "CLEAR LOG"; color: "#A0B8C0"; font.pixelSize: 8; font.bold: true }
                                MouseArea { anchors.fill: parent; onClicked: { root.activity = []; root.notify("Activity log cleared.", "success") } }
                            }
                        }
                        ListView {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            clip: true; spacing: 8; model: root.activity
                            boundsBehavior: Flickable.StopAtBounds
                            delegate: Rectangle {
                                width: parent ? parent.width : 0; height: 80; radius: 12; color: "#0A171F"; border.color: "#203943"
                                RowLayout {
                                    anchors.fill: parent; anchors.margins: 13; spacing: 11
                                    Rectangle { Layout.preferredWidth: 6; Layout.fillHeight: true; radius: 3; color: modelData.state === "SAFE" ? root.cyan : modelData.state === "ERROR" ? root.red : root.amber; opacity: 0.8 }
                                    ColumnLayout {
                                        Layout.fillWidth: true; spacing: 5
                                        RowLayout {
                                            Text { text: modelData.title; color: "#DCECEF"; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true }
                                            Text { text: modelData.time; color: "#557580"; font.pixelSize: 8 }
                                        }
                                        Text { text: modelData.detail; color: root.dim; font.pixelSize: 10; wrapMode: Text.Wrap; Layout.fillWidth: true }
                                    }
                                }
                            }
                        }
                        Text { text: "Only events generated by this preview appear here."; color: "#4E6972"; font.pixelSize: 9 }
                    }

                    // SETTINGS
                    Flickable {
                        clip: true; contentWidth: width; contentHeight: settingsColumn.implicitHeight
                        boundsBehavior: Flickable.StopAtBounds
                        ColumnLayout {
                            id: settingsColumn; width: parent.width; spacing: 12
                            Text { text: "Interface settings"; color: "#EDF8F8"; font.pixelSize: 22; font.weight: Font.Medium }
                            Text { text: "Controls in this panel affect the HUD preview only."; color: root.dim; font.pixelSize: 10; wrapMode: Text.Wrap; Layout.fillWidth: true }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 78; radius: 13; color: "#0A171F"; border.color: "#203943"
                                RowLayout {
                                    anchors.fill: parent; anchors.margins: 13; spacing: 10
                                    ColumnLayout {
                                        Layout.fillWidth: true; spacing: 4
                                        Text { text: "Expanded workspace"; color: "#DCECEF"; font.pixelSize: 11; font.bold: true }
                                        Text { text: "Show the full HUD instead of the compact island."; color: root.dim; font.pixelSize: 9; wrapMode: Text.Wrap }
                                    }
                                    Switch { checked: root.expanded; onToggled: root.expanded = checked }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 78; radius: 13; color: "#0A171F"; border.color: "#203943"
                                RowLayout {
                                    anchors.fill: parent; anchors.margins: 13; spacing: 10
                                    ColumnLayout {
                                        Layout.fillWidth: true; spacing: 4
                                        Text { text: "Reduced motion"; color: "#DCECEF"; font.pixelSize: 11; font.bold: true }
                                        Text { text: "Motion preference is planned; core animation is currently active."; color: root.dim; font.pixelSize: 9; wrapMode: Text.Wrap }
                                    }
                                    Text { text: "PLANNED"; color: root.amber; font.pixelSize: 8; font.bold: true }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 96; radius: 13; color: "#0A171F"; border.color: "#203943"
                                ColumnLayout {
                                    anchors.fill: parent; anchors.margins: 13; spacing: 6
                                    Text { text: "Keyboard shortcuts"; color: "#DCECEF"; font.pixelSize: 11; font.bold: true }
                                    Text { text: "Ctrl + Space    Expand / preview listening state\nEscape             Collapse workspace\nCtrl + 1–6         Preview assistant states"; color: root.dim; font.pixelSize: 10; lineHeight: 1.3; font.family: "monospace" }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 78; radius: 13; color: "#0A171F"; border.color: "#203943"
                                ColumnLayout {
                                    anchors.fill: parent; anchors.margins: 13; spacing: 4
                                    Text { text: "Safety boundary"; color: root.cyan; font.pixelSize: 10; font.bold: true; font.letterSpacing: 0.8 }
                                    Text { text: "No arbitrary shell execution, microphone capture, or desktop control is triggered by this UI.", color: root.dim; font.pixelSize: 10; wrapMode: Text.Wrap; Layout.fillWidth: true }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            visible: root.expanded && root.notice.length > 0
            Layout.fillWidth: true; Layout.preferredHeight: 32; Layout.topMargin: 9
            radius: 9
            color: root.noticeKind === "error" ? "#30161C" : root.noticeKind === "success" ? "#102822" : "#101F28"
            border.color: root.noticeKind === "error" ? "#7C3544" : root.noticeKind === "success" ? "#2D6856" : "#27434D"
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 11; anchors.rightMargin: 10; spacing: 8
                Rectangle { width: 5; height: 5; radius: 3; color: root.noticeKind === "error" ? root.red : root.noticeKind === "success" ? root.cyan : root.amber }
                Text { text: root.notice; color: "#C4D9DE"; font.pixelSize: 9; Layout.fillWidth: true; elide: Text.ElideRight }
                Text { text: "×"; color: "#78949D"; font.pixelSize: 15 }
                MouseArea { anchors.right: parent.right; width: 28; anchors.top: parent.top; anchors.bottom: parent.bottom; onClicked: root.notice = "" }
            }
        }

        Item { visible: root.expanded; Layout.fillWidth: true; Layout.preferredHeight: 2 }
    }

    // Compact island status text and compact expand action are always available.
    Shortcut { sequence: "Escape"; onActivated: root.expanded = false }
    Shortcut { sequence: "Ctrl+Space"; onActivated: { root.expanded = !root.expanded; root.mode = root.mode === "LISTENING" ? "IDLE" : "LISTENING" } }
    Shortcut { sequence: "Ctrl+1"; onActivated: root.mode = "IDLE" }
    Shortcut { sequence: "Ctrl+2"; onActivated: root.mode = "LISTENING" }
    Shortcut { sequence: "Ctrl+3"; onActivated: root.mode = "THINKING" }
    Shortcut { sequence: "Ctrl+4"; onActivated: root.mode = "SPEAKING" }
    Shortcut { sequence: "Ctrl+5"; onActivated: root.mode = "ACTION" }
    Shortcut { sequence: "Ctrl+6"; onActivated: root.mode = "ERROR" }
}