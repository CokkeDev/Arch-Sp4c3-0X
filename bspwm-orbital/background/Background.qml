// Orbital — fondo animado de bspwm: la misma escena Orbiter que el login (SDDM).
// La lanza bspwmrc con el runtime `qml` de Qt 6; bspwm la deja flotante, abajo
// y en todos los escritorios (regla por título "OrbitalBg").
import QtQuick
import QtQuick.Window
import "orbiter"

Window {
    id: win
    title: "OrbitalBg"
    color: "black"
    visible: true
    x: 0; y: 0
    width: Screen.width
    height: Screen.height
    // No toma foco ni clics: los clics llegan al escritorio (menú con clic derecho).
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnBottomHint
         | Qt.WindowDoesNotAcceptFocus | Qt.WindowTransparentForInput

    AsciiScene {
        anchors.fill: parent
        target: Qt.point(0, 0)      // igual que el login: sin seguir al ratón
    }
}
