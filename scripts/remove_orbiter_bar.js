// Quita los paneles que contengan la barra de Orbiter, conservando el panel propio.
var ps = panels();
var toRemove = [];
for (var i = 0; i < ps.length; i++) {
    if (ps[i].widgets("org.orbiter.bar").length > 0) {
        toRemove.push(ps[i]);
    }
}
toRemove.forEach(function (p) { p.remove(); });
print("orbiter-bars-removed=" + toRemove.length);
