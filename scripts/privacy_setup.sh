#!/usr/bin/env bash
# Privacidad básica: Tor, Tor Browser, uBlock Origin en Firefox y nombre de equipo
# que no se envía a la red. Ejecutar como root:  sudo bash privacy_setup.sh [nombre-equipo]
# Ej.: sudo bash privacy_setup.sh localhost
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Ejecútalo con sudo."; exit 1; }
NEWHOST="${1:-}"

echo "[1/4] Paquetes"
pacman -S --needed --noconfirm tor torsocks torbrowser-launcher firefox firefox-ublock-origin

echo "[2/4] Servicio Tor"
systemctl enable --now tor

echo "[3/4] uBlock Origin activado en Firefox (política del sistema)"
install -d /usr/lib/firefox/distribution
cat > /usr/lib/firefox/distribution/policies.json <<'JSON'
{
  "policies": {
    "ExtensionSettings": {
      "uBlock0@raymondhill.net": {
        "installation_mode": "normal_installed",
        "install_url": "file:///usr/lib/firefox/browser/extensions/uBlock0@raymondhill.net.xpi"
      }
    }
  }
}
JSON

echo "[4/4] Nombre de equipo"
# NetworkManager: no cambiar el nombre por DHCP ni enviarlo a la red
install -d /etc/NetworkManager/conf.d
cat > /etc/NetworkManager/conf.d/privacy-hostname.conf <<'CONF'
[main]
hostname-mode=none

[connection]
ipv4.dhcp-send-hostname=false
ipv6.dhcp-send-hostname=false
CONF
if [ -n "$NEWHOST" ]; then
    hostnamectl set-hostname "$NEWHOST"
    sed -i '/127\.0\.1\.1/d' /etc/hosts
    if [ "$NEWHOST" = "localhost" ]; then
        # systemd trata "localhost" como nombre vacío; este servicio lo fija al arrancar
        cat > /etc/systemd/system/hostname-localhost.service <<'UNIT'
[Unit]
Description=Fija el nombre de la maquina en "localhost"
After=systemd-hostnamed.service
Before=network-pre.target NetworkManager.service display-manager.service
Wants=network-pre.target

[Service]
Type=oneshot
ExecStart=/usr/bin/hostname localhost

[Install]
WantedBy=multi-user.target
UNIT
        systemctl daemon-reload
        systemctl enable --now hostname-localhost.service
    else
        printf '127.0.1.1   %s.localdomain %s\n' "$NEWHOST" "$NEWHOST" >> /etc/hosts
    fi
fi
nmcli general reload conf 2>/dev/null || systemctl reload NetworkManager || true

echo
echo "Comprobación de Tor (debe decir \"IsTor\":true):"
torsocks curl -s --max-time 30 https://check.torproject.org/api/ip || echo "  Tor aún no conecta; vuelve a probar en un minuto."
echo
echo "Tor Browser: ábrelo desde el menú; la primera vez descarga y verifica el navegador."
