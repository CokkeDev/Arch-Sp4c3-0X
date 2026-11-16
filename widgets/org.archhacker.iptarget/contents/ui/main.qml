import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root

    property color okColor: "#39FF14"   // verde: IP valida
    property color badColor: "#FF2A2A"  // rojo: IP invalida / vacia

    readonly property bool valid: isValidIp(ipField.text)

    function isValidIp(s) {
        var m = ("" + s).match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/)
        if (!m) return false
        for (var i = 1; i <= 4; i++) {
            var n = parseInt(m[i], 10)
            if (n < 0 || n > 255) return false
        }
        return true
    }

    // Permite guardar la IP objetivo en un archivo que las herramientas pueden leer.
    P5Support.DataSource {
        id: runner
        engine: "executable"
        connectedSources: []
        onNewData: function(source, data) { disconnectSource(source) }
        function exec(cmd) { connectSource(cmd) }
    }

    preferredRepresentation: fullRepresentation

    fullRepresentation: RowLayout {
        spacing: 6
        Layout.minimumWidth: 230
        Layout.minimumHeight: 28

        TargetIcon {
            id: tgt
            width: 24; height: 24
            color: root.valid ? root.okColor : root.badColor
            Layout.alignment: Qt.AlignVCenter
        }

        QQC2.TextField {
            id: ipField
            Layout.fillWidth: true
            placeholderText: "IP víctima  (ej. 10.0.0.5)"
            color: "#EAEAEA"
            selectByMouse: true
            font.family: "monospace"
            background: Rectangle {
                radius: 4
                color: "#0E1116"
                border.width: 2
                border.color: root.valid ? root.okColor : root.badColor
            }
            onAccepted: {
                if (root.valid) {
                    runner.exec("sh -c 'mkdir -p ~/.config/archhacker && printf %s \"" + text + "\" > ~/.config/archhacker/target_ip'")
                }
            }
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: root.valid ? ("Objetivo: " + text + "  (Enter para guardar)")
                                          : "Escribe una IPv4 válida"
        }
    }
}
