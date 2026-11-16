// Orbital — tema SDDM: terminal verde sobre la Tierra ASCII de Orbiter.
// Diseño: https://claude.ai/artifact/EACVk7iA4wJZnFBHtK6u1H (tablero Login)
import QtQuick
import "orbiter"

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "black"

    readonly property color green: "#39ff6e"
    readonly property color greenDim: "#2bbf55"
    readonly property color greenSoft: "#9dffb8"
    readonly property color greenFaint: "#1f7a3c"
    readonly property color greenLine: "#0f3d1e"
    readonly property string mono: "JetBrainsMono Nerd Font"

    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property string userName: userModel.lastUser !== "" ? userModel.lastUser : "hacker"
    property string message: ""
    readonly property string host: sddm.hostName !== "" ? sddm.hostName : "archhacker"
    property string currentSession: {
        const it = sessRep.count > 0 ? sessRep.itemAt(sessionIndex) : null
        return it ? it.sname : ""
    }

    function describe(n) {
        const s = n.toLowerCase()
        if (s.indexOf("bspwm") >= 0) return "tiling · X11 · pentesting"
        if (s.indexOf("wayland") >= 0 || s === "plasma") return "escritorio completo · Wayland"
        if (s.indexOf("plasma") >= 0) return "escritorio completo"
        return ""
    }
    function execName(n) {
        const s = n.toLowerCase()
        if (s.indexOf("bspwm") >= 0) return "bspwm"
        if (s.indexOf("plasma") >= 0) return "startplasma-wayland"
        return n
    }
    function cycle(d) {
        if (sessRep.count === 0) return
        sessionIndex = (sessionIndex + d + sessRep.count) % sessRep.count
    }
    function doLogin() {
        message = "autenticando…"
        sddm.login(userName, pw.text, sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.message = "Login incorrect"
            pw.text = ""
            pw.forceActiveFocus()
        }
        function onLoginSucceeded() { root.message = "" }
    }

    // F2 reinicia, F3 apaga (las teclas que el campo de contraseña no usa suben hasta aquí)
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_F2 && sddm.canReboot) { sddm.reboot(); event.accepted = true }
        else if (event.key === Qt.Key_F3 && sddm.canPowerOff) { sddm.powerOff(); event.accepted = true }
    }

    // ---------- Fondo: la escena de Orbiter, sin seguir al ratón ----------
    AsciiScene {
        anchors.fill: parent
        target: Qt.point(0, 0)
    }

    // ---------- Estado arriba ----------
    Text {
        x: 40; y: 28
        text: "● " + root.host + " · Arch Linux"
        color: root.greenDim; font.family: root.mono; font.pixelSize: 13
    }
    Text {
        anchors.right: parent.right; anchors.rightMargin: 40; y: 28
        text: "tty1"
        color: root.greenDim; font.family: root.mono; font.pixelSize: 13
    }

    // ---------- Reloj en bloques ----------
    Column {
        id: clockCol
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(root.height * 0.068)
        spacing: 14

        property var now: new Date()
        Timer { interval: 1000; running: true; repeat: true; onTriggered: clockCol.now = new Date() }

        function block(t) {
            const F = {
                "0": ["███", "█ █", "█ █", "█ █", "███"], "1": [" █ ", "██ ", " █ ", " █ ", "███"],
                "2": ["███", "  █", "███", "█  ", "███"], "3": ["███", "  █", "███", "  █", "███"],
                "4": ["█ █", "█ █", "███", "  █", "  █"], "5": ["███", "█  ", "███", "  █", "███"],
                "6": ["███", "█  ", "███", "█ █", "███"], "7": ["███", "  █", "  █", "  █", "  █"],
                "8": ["███", "█ █", "███", "█ █", "███"], "9": ["███", "█ █", "███", "  █", "███"],
                ":": [" ", "█", " ", "█", " "]
            }
            const lines = ["", "", "", "", ""]
            for (let i = 0; i < t.length; i++) {
                const g = F[t[i]] || F["0"]
                for (let r = 0; r < 5; r++) lines[r] += g[r] + " "
            }
            return lines.join("\n")
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: clockCol.block(Qt.formatTime(clockCol.now, "hh:mm"))
            color: root.green; font.family: root.mono; font.pixelSize: 22
            lineHeightMode: Text.FixedHeight; lineHeight: 22
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: clockCol.now.toLocaleDateString(Qt.locale("es_ES"), "dddd, d 'de' MMMM 'de' yyyy")
            color: root.greenDim; font.family: root.mono; font.pixelSize: 15
        }
    }

    // ---------- Terminal de login ----------
    Rectangle {
        id: term
        width: 820
        height: body.implicitHeight + bar.height + 44
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(root.height * 0.27)
        color: "#f0010603"
        radius: 10
        border.color: root.greenLine
        border.width: 1
        clip: true

        Rectangle { width: parent.width; height: 2; color: root.green }

        Item {
            id: bar
            width: parent.width; height: 32; y: 2
            Text { x: 16; anchors.verticalCenter: parent.verticalCenter; text: "login — /dev/tty1"; color: root.greenDim; font.family: root.mono; font.pixelSize: 12 }
            Text { anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter; text: "sddm-orbital"; color: root.greenDim; font.family: root.mono; font.pixelSize: 12 }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.greenLine }
        }

        Column {
            id: body
            x: 24; y: bar.y + bar.height + 18
            width: parent.width - 48
            spacing: 4

            Text { text: "Arch Linux (tty1)"; color: root.greenDim; font.family: root.mono; font.pixelSize: 15 }
            Item { width: 1; height: 10 }
            Text {
                text: root.host + " login: <b><font color='" + root.greenSoft + "'>" + root.userName + "</font></b>"
                textFormat: Text.StyledText
                color: root.green; font.family: root.mono; font.pixelSize: 15
            }
            Row {
                spacing: 12
                Text { text: "Password:"; color: root.green; font.family: root.mono; font.pixelSize: 15 }
                TextInput {
                    id: pw
                    width: 600
                    focus: true
                    color: root.greenSoft
                    font.family: root.mono; font.pixelSize: 15; font.letterSpacing: 2
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    selectByMouse: true
                    cursorDelegate: Rectangle {
                        width: 9; color: root.green
                        // único elemento que parpadea: lento (1 s encendido / 1 s apagado)
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            PauseAnimation { duration: 1000 }
                            NumberAnimation { to: 0; duration: 0 }
                            PauseAnimation { duration: 1000 }
                            NumberAnimation { to: 1; duration: 0 }
                        }
                    }
                    Keys.onReturnPressed: root.doLogin()
                    Keys.onEnterPressed: root.doLogin()
                    Keys.onUpPressed: root.cycle(-1)
                    Keys.onDownPressed: root.cycle(1)
                    Text {
                        visible: pw.text.length === 0
                        text: "escribe tu contraseña"
                        color: root.greenFaint; font.family: root.mono; font.pixelSize: 15
                    }
                }
            }
            Text {
                visible: root.message !== ""
                text: root.message
                color: root.message === "Login incorrect" ? "#ff4d5e" : root.greenDim
                font.family: root.mono; font.pixelSize: 14
            }
            Item { width: 1; height: 8 }

            Text {
                text: ":: Selecciona la sesión <font color='" + root.greenDim + "'>(↑/↓ o clic)</font>"
                textFormat: Text.StyledText
                color: root.green; font.family: root.mono; font.pixelSize: 15
            }
            Column {
                x: -8
                Repeater {
                    id: sessRep
                    model: sessionModel
                    delegate: Rectangle {
                        required property int index
                        required property string name
                        readonly property string sname: name
                        readonly property bool on: index === root.sessionIndex
                        width: body.width + 8; height: 40; radius: 6
                        color: on ? "#1a39ff6e" : (ma.containsMouse ? "#0f39ff6e" : "transparent")
                        Row {
                            x: 8; anchors.verticalCenter: parent.verticalCenter; spacing: 14
                            Text { width: 10; text: on ? "›" : " "; color: root.green; font.family: root.mono; font.pixelSize: 15 }
                            Text { text: on ? "[x]" : "[ ]"; color: on ? root.greenSoft : root.greenDim; font.family: root.mono; font.pixelSize: 15 }
                            Text { width: 240; text: name; elide: Text.ElideRight; color: on ? root.greenSoft : root.greenDim; font.family: root.mono; font.pixelSize: 15; font.bold: true }
                            Text { anchors.verticalCenter: parent.verticalCenter; text: root.describe(name); color: root.greenDim; font.family: root.mono; font.pixelSize: 13 }
                        }
                        MouseArea {
                            id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: { root.sessionIndex = index; pw.forceActiveFocus() }
                        }
                    }
                }
            }
            Item { width: 1; height: 10 }

            Item {
                width: body.width; height: 44
                Rectangle {
                    id: goBtn
                    width: goText.implicitWidth + 36; height: 44; radius: 6
                    color: goMa.containsMouse ? "#5cff8a" : root.green
                    Text { id: goText; anchors.centerIn: parent; text: "[ ENTER ] iniciar " + root.currentSession; color: "#021006"; font.family: root.mono; font.pixelSize: 14; font.bold: true }
                    MouseArea { id: goMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.doLogin() }
                }
                Row {
                    anchors.right: parent.right; spacing: 8
                    Repeater {
                        model: [
                            { label: "F2 reiniciar", act: "reboot" },
                            { label: "F3 apagar", act: "poweroff" }
                        ]
                        delegate: Rectangle {
                            required property var modelData
                            width: kt.implicitWidth + 24; height: 44; radius: 6
                            color: "transparent"
                            border.color: km.containsMouse ? root.greenDim : "#145c2a"
                            Text { id: kt; anchors.centerIn: parent; text: modelData.label; color: km.containsMouse ? root.greenSoft : root.greenDim; font.family: root.mono; font.pixelSize: 13 }
                            MouseArea {
                                id: km; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: modelData.act === "reboot" ? sddm.reboot() : sddm.powerOff()
                            }
                        }
                    }
                }
            }

            Row {
                topPadding: 8
                Text { text: "❯ "; color: root.green; font.family: root.mono; font.pixelSize: 15 }
                Text { text: "exec " + root.execName(root.currentSession); color: root.greenDim; font.family: root.mono; font.pixelSize: 15 }

            }
        }
    }

    Component.onCompleted: pw.forceActiveFocus()
}
