pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "#0A0B0A"
    readonly property color surface: "#191B18"
    readonly property color surfaceRaised: "#22251F"
    readonly property color surfaceInset: "#10120F"
    readonly property color border: "#41453B"
    readonly property color borderSoft: "#2D302A"
    readonly property color amber: "#C5A15C"
    readonly property color sage: "#8D9B83"
    readonly property color red: "#B96D62"
    readonly property color text: "#E6E5DC"
    readonly property color textMuted: "#A1A397"
    readonly property color textDim: "#73776D"
    readonly property color focus: "#E3C783"

    readonly property string displayFont: "Noto Sans Mono"
    readonly property string bodyFont: "Inter"

    readonly property int space2: 2
    readonly property int space4: 4
    readonly property int space6: 6
    readonly property int space8: 8
    readonly property int space12: 12
    readonly property int space16: 16
    readonly property int space20: 20
    readonly property int space24: 24

    readonly property int radiusSmall: 5
    readonly property int radiusPanel: 12
    readonly property int radiusPill: 999

    readonly property int labelSize: 10
    readonly property int bodySize: 14
    readonly property int titleSize: 18
    readonly property int microSize: 9

    readonly property int motionFast: 100
    readonly property int motionStandard: 180
    readonly property int motionSlow: 260

    readonly property real disabledOpacity: 0.42
    readonly property real mutedOpacity: 0.72
}