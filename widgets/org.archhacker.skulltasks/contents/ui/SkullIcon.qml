import QtQuick

// Calavera estilo 8-bit (diseno original) dibujada pixel a pixel.
// 'b' = hueso (toma 'color'), 'o' = hueco oscuro, '.' = transparente.
Item {
    id: sk
    property int cells: 9
    property color color: "#FF2A2A"

    readonly property var rows: [
        "..bbbbb..",
        ".bbbbbbb.",
        "bbbbbbbbb",
        "bbooboobb",
        "bbooboobb",
        "bbbbobbbb",
        ".bbbbbbb.",
        ".b.b.b.b.",
        "..bbbbb.."
    ]

    Grid {
        anchors.fill: parent
        columns: sk.cells
        rows: sk.cells
        Repeater {
            model: sk.cells * sk.cells
            Rectangle {
                width: sk.width / sk.cells
                height: sk.height / sk.cells
                property int cx: index % sk.cells
                property int cy: Math.floor(index / sk.cells)
                property string ch: sk.rows[cy].charAt(cx)
                color: ch === "b" ? sk.color
                       : (ch === "o" ? Qt.rgba(0, 0, 0, 0.6) : "transparent")
            }
        }
    }
}
