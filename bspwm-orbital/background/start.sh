#!/usr/bin/env bash
# Orbital — arranca el fondo animado (una sola instancia) y lo baja al fondo
# de toda la pila de ventanas, para que polybar y las ventanas queden encima.
DIR="$HOME/.config/orbital/background"
pkill -f "qml6\? $DIR/Background.qml" 2>/dev/null
pkill -f "bin/qml $DIR/Background.qml" 2>/dev/null
QML=$(command -v qml6 || echo /usr/lib/qt6/bin/qml)
"$QML" "$DIR/Background.qml" &
PID=$!
for _ in $(seq 1 50); do
    W=$(xdotool search --sync --onlyvisible --name '^OrbitalBg$' 2>/dev/null | head -1)
    [ -n "$W" ] && break
    sleep 0.2
done
[ -n "$W" ] && xdotool windowlower "$W"
wait $PID
