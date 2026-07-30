import QtQuick

QtObject {
    // Nord - Polar Night with Snow Storm, Frost, and Aurora accents.
    readonly property color nord0: "#2e3440"
    readonly property color nord1: "#3b4252"
    readonly property color nord2: "#434c5e"
    readonly property color nord3: "#4c566a"
    readonly property color nord4: "#d8dee9"
    readonly property color nord5: "#e5e9f0"
    readonly property color nord6: "#eceff4"
    readonly property color nord7: "#8fbcbb"
    readonly property color nord8: "#88c0d0"
    readonly property color nord9: "#81a1c1"
    readonly property color nord10: "#5e81ac"
    readonly property color nord11: "#bf616a"
    readonly property color nord12: "#d08770"
    readonly property color nord13: "#ebcb8b"
    readonly property color nord14: "#a3be8c"
    readonly property color nord15: "#b48ead"

    // Semantic roles used by the shell components.
    readonly property color crust: nord0
    readonly property color mantle: nord0
    readonly property color base: nord1
    readonly property color surface0: nord2
    readonly property color surface1: nord3
    readonly property color surface2: nord3
    readonly property color overlay0: nord3
    readonly property color overlay1: nord10
    readonly property color overlay2: nord9
    readonly property color subtext0: nord4
    readonly property color subtext1: nord5
    readonly property color text: nord4
    readonly property color brightText: nord6

    readonly property color green: nord14
    readonly property color greenSoft: nord7
    readonly property color greenDim: nord10
    readonly property color teal: nord7
    readonly property color cyan: nord8
    readonly property color blue: nord9
    readonly property color yellow: nord13
    readonly property color peach: nord12
    readonly property color red: nord11
    readonly property color magenta: nord15

    // Compatibility aliases for existing components.
    readonly property color rosewater: brightText
    readonly property color lavender: blue
    readonly property color mauve: magenta
    readonly property color maroon: red
    readonly property color sapphire: cyan
}
