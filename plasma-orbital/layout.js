// Orbital — paneles de Plasma como las píldoras de bspwm.
// Arriba: [Arch + escritorios]  ···  [ventanas (calaveras)]  ···  [sistema · bandeja · reloj · salir]
// Abajo:  dock centrado con las apps.
// Borra los paneles actuales (apply.sh respalda la config antes).
for (const p of panels()) p.remove();

function pill(location, alignment, height) {
    const p = new Panel("org.kde.panel");
    p.location = location;
    p.alignment = alignment;
    p.height = height;
    p.hiding = "none";
    p.lengthMode = "fit";
    return p;
}
function cfg(w, group, values) {
    w.currentConfigGroup = group;
    for (const k in values) w.writeConfig(k, values[k]);
}

const ids = [];

// --- arriba izquierda: logo de Arch (menú) + escritorios
const left = pill("top", "left", 36);
const menu = left.addWidget("org.kde.plasma.kickoff");
cfg(menu, ["General"], { icon: "orbital-arch" });
const pager = left.addWidget("org.kde.plasma.pager");
cfg(pager, ["General"], { displayedText: 0, showWindowIcons: false });   // 0 = número
ids.push(left.id);

// --- arriba centro: ventanas abiertas (calaveras 8-bit)
const center = pill("top", "center", 36);
center.addWidget("org.archhacker.skulltasks");
ids.push(center.id);

// --- arriba derecha: recursos, bandeja, reloj y salir
const right = pill("top", "right", 36);
if (knownWidgetTypes.indexOf("org.kde.plasma.kvitals") >= 0) right.addWidget("org.kde.plasma.kvitals");
right.addWidget("org.kde.plasma.systemtray");
const clock = right.addWidget("org.kde.plasma.digitalclock");
cfg(clock, ["Appearance"], {
    showDate: true, dateDisplayFormat: "BesideTime", dateFormat: "custom", customDateFormat: "ddd dd/MM",
    use24hFormat: 2, showSeconds: 0,
    autoFontAndSize: false, fontFamily: "JetBrainsMono Nerd Font", fontWeight: 400, fontSize: 10
});
const out = right.addWidget("org.kde.plasma.lock_logout");
cfg(out, ["General"], { show_lockScreen: false });
ids.push(right.id);

// --- abajo: dock
const dock = pill("bottom", "center", 52);
dock.addWidget("org.kde.plasma.icontasks");
ids.push(dock.id);

print(ids.join(" "));
