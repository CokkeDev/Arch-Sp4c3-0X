// Crea un panel superior con: Objetivo IP (izquierda), Calaveras (centro), reloj (derecha).
var p = new Panel;
p.location = "top";
p.height = 40;

var ipw = p.addWidget("org.archhacker.iptarget");
var sp1 = p.addWidget("org.kde.plasma.panelspacer");
var skull = p.addWidget("org.archhacker.skulltasks");
var sp2 = p.addWidget("org.kde.plasma.panelspacer");
var clock = p.addWidget("org.kde.plasma.digitalclock");

[sp1, sp2].forEach(function (s) {
    s.currentConfigGroup = ["General"];
    s.writeConfig("expanding", true);
    s.reloadConfig();
});

print("panel-top-creado id=" + p.id);
