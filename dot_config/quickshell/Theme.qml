import QtQuick

QtObject {
    // Forest Green shared palette.
    readonly property color forestBackground: "#192324"
    readonly property color forestBackgroundAlt: "#213230"
    readonly property color forestSurface: "#29463d"
    readonly property color forestSelection: "#345b4b"
    readonly property color forestBorder: "#43725d"
    readonly property color forestAccent: "#5a8e73"
    readonly property color forestForeground: "#dce8e1"
    readonly property color forestBrightForeground: "#f3f7f5"
    readonly property color forestMuted: "#a9beb3"
    readonly property color forestInfo: "#6f9a91"
    readonly property color forestWarning: "#b9a66c"
    readonly property color forestError: "#b97872"

    // Semantic roles used by the shell components.
    readonly property color crust: forestBackground
    readonly property color mantle: forestBackgroundAlt
    readonly property color base: forestSurface
    readonly property color surface0: forestSelection
    readonly property color surface1: forestBorder
    readonly property color surface2: forestAccent
    readonly property color overlay0: forestMuted
    readonly property color overlay1: forestInfo
    readonly property color overlay2: forestBrightForeground
    readonly property color subtext0: forestMuted
    readonly property color subtext1: forestInfo
    readonly property color text: forestForeground
    readonly property color brightText: forestBrightForeground

    readonly property color green: forestAccent
    readonly property color greenSoft: forestInfo
    readonly property color greenDim: forestBorder
    readonly property color teal: forestInfo
    readonly property color cyan: forestInfo
    readonly property color blue: forestInfo
    readonly property color yellow: forestWarning
    readonly property color peach: forestWarning
    readonly property color red: forestError
    readonly property color magenta: forestBorder

    // Compatibility aliases for existing components.
    readonly property color rosewater: brightText
    readonly property color lavender: blue
    readonly property color mauve: magenta
    readonly property color maroon: red
    readonly property color sapphire: cyan
}
