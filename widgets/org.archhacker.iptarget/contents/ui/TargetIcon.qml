import QtQuick

// Diana (tiro al blanco) estilo 8-bit: cuadros concentricos alternando color.
Item {
    id: ti
    property int cells: 9
    property color color: "#FF2A2A"
    property color ringColor: "#F5F5F5"

    Grid {
        anchors.fill: parent
        columns: ti.cells
        rows: ti.cells
        Repeater {
            model: ti.cells * ti.cells
            Rectangle {
                width: ti.width / ti.cells
                height: ti.height / ti.cells
                property int cx: index % ti.cells
                property int cy: Math.floor(index / ti.cells)
                property int c: Math.floor(ti.cells / 2)
                property int d: Math.max(Math.abs(cx - c), Math.abs(cy - c))
                // esquinas en blanco para una diana mas redonda
                visible: !(Math.abs(cx - c) === c && Math.abs(cy - c) === c)
                color: (d % 2 === 0) ? ti.color : ti.ringColor
            }
        }
    }
}
