import QtQuick

QtObject {
    // TokyoNight Night shared palette.
    readonly property color tokyoBackground: "#1a1b26"
    readonly property color tokyoBackgroundAlt: "#16161e"
    readonly property color tokyoSurface: "#24283b"
    readonly property color tokyoSelection: "#33467c"
    readonly property color tokyoBorder: "#414868"
    readonly property color tokyoAccent: "#7aa2f7"
    readonly property color tokyoForeground: "#c0caf5"
    readonly property color tokyoBrightForeground: "#e0e6ff"
    readonly property color tokyoMuted: "#565f89"
    readonly property color tokyoInfo: "#7dcfff"
    readonly property color tokyoWarning: "#e0af68"
    readonly property color tokyoError: "#f7768e"

    // Semantic roles used by the shell components.
    readonly property color crust: tokyoBackground
    readonly property color mantle: tokyoBackgroundAlt
    readonly property color base: tokyoSurface
    readonly property color surface0: tokyoSelection
    readonly property color surface1: tokyoBorder
    readonly property color surface2: tokyoAccent
    readonly property color overlay0: tokyoMuted
    readonly property color overlay1: tokyoInfo
    readonly property color overlay2: tokyoBrightForeground
    readonly property color subtext0: tokyoMuted
    readonly property color subtext1: tokyoInfo
    readonly property color text: tokyoForeground
    readonly property color brightText: tokyoBrightForeground

    readonly property color green: "#9ece6a"
    readonly property color greenSoft: "#73daca"
    readonly property color greenDim: tokyoBorder
    readonly property color teal: "#1abc9c"
    readonly property color cyan: "#7dcfff"
    readonly property color blue: "#7aa2f7"
    readonly property color yellow: "#e0af68"
    readonly property color peach: "#ff9e64"
    readonly property color red: "#f7768e"
    readonly property color magenta: "#bb9af7"

    // Compatibility aliases for existing components.
    readonly property color rosewater: brightText
    readonly property color lavender: blue
    readonly property color mauve: magenta
    readonly property color maroon: red
    readonly property color sapphire: cyan
}
