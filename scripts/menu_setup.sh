#!/usr/bin/env bash
# Crea un menu KDE con categorias en espanol y lanzadores para las
# herramientas de pentest que esten instaladas.
set -uo pipefail
exec > /root/menu.log 2>&1
echo "### MENU INICIO $(date)"

APPS=/usr/share/applications
DIRS=/usr/share/desktop-directories
MENUD=/etc/xdg/menus/applications-merged
BIN=/usr/local/bin
mkdir -p "$APPS" "$DIRS" "$MENUD" "$BIN"

# Lanzador generico: abre la herramienta en konsole y deja una shell abierta
cat > "$BIN/ahk-run" <<'EOF'
#!/usr/bin/env bash
tool="$1"; shift || true
echo "==================  $tool  =================="
command -v "$tool" >/dev/null 2>&1 && "$tool" "$@"
echo
echo "[ $tool terminó — shell interactiva. Escribe 'exit' para cerrar ]"
exec bash
EOF
chmod +x "$BIN/ahk-run"

# Lanzador que precarga la IP objetivo en \$IP
cat > "$BIN/ahk-shell" <<'EOF'
#!/usr/bin/env bash
[ -f "$HOME/.config/archhacker/target_ip" ] && export IP="$(cat "$HOME/.config/archhacker/target_ip")"
[ -n "${IP:-}" ] && echo "Objetivo actual: IP=$IP" || echo "Sin IP objetivo fijada (usa el widget de la barra)."
exec bash
EOF
chmod +x "$BIN/ahk-shell"

# Directorio raiz del menu
cat > "$DIRS/archhacker.directory" <<EOF
[Desktop Entry]
Type=Directory
Name=ArchHacker
Icon=security-high
EOF

# Categorias: clave -> "Nombre visible|Icono"
declare -A CATS=(
 [recon]="Reconocimiento|system-search"
 [web]="Web|applications-internet"
 [exploit]="Explotación|security-low"
 [pass]="Contraseñas|dialog-password"
 [net]="Redes|network-wired"
 [wifi]="WiFi|network-wireless"
)
for k in "${!CATS[@]}"; do
  IFS='|' read -r nm ic <<< "${CATS[$k]}"
  cat > "$DIRS/archhacker-${k}.directory" <<EOF
[Desktop Entry]
Type=Directory
Name=$nm
Icon=$ic
EOF
done

# mkentry <catkey> <bin> <etiqueta> <gui:0/1>
mkentry(){
  local cat="$1" bin="$2" label="$3" gui="$4"
  command -v "$bin" >/dev/null 2>&1 || { echo "  (omito, no instalado) $bin"; return 0; }
  local safe="${bin//[^a-zA-Z0-9]/_}"
  local f="$APPS/ahk-${cat}-${safe}.desktop"
  local execl term
  if [ "$gui" = "1" ]; then execl="$bin"; term="false"
  else execl="konsole -e ahk-run $bin"; term="false"; fi
  cat > "$f" <<EOF
[Desktop Entry]
Type=Application
Name=$label
Exec=$execl
Icon=utilities-terminal
Terminal=$term
Categories=X-ArchHacker-${cat};
EOF
  echo "  OK $bin -> $cat"
}

echo "### Reconocimiento"
mkentry recon nmap "Nmap — escáner de puertos" 0
mkentry recon masscan "Masscan — escáner masivo" 0
mkentry recon whois "Whois" 0
mkentry recon dig "Dig — consultas DNS" 0
mkentry recon netdiscover "Netdiscover — descubre hosts" 0
mkentry recon amass "Amass — enumeración de subdominios" 0
mkentry recon theHarvester "theHarvester — OSINT" 0
mkentry recon dnsenum "DNSenum" 0
mkentry recon fierce "Fierce" 0
mkentry recon dnsrecon "DNSrecon" 0

echo "### Web"
mkentry web nikto "Nikto — escáner web" 0
mkentry web gobuster "Gobuster — fuerza bruta de rutas" 0
mkentry web ffuf "ffuf — fuzzing web" 0
mkentry web dirb "Dirb" 0
mkentry web sqlmap "sqlmap — inyección SQL" 0
mkentry web wpscan "WPScan — WordPress" 0
mkentry web whatweb "WhatWeb — fingerprint" 0
mkentry web wfuzz "Wfuzz" 0
mkentry web nuclei "Nuclei — plantillas" 0
mkentry web burpsuite "Burp Suite" 1
mkentry web zaproxy "OWASP ZAP" 1

echo "### Explotación"
mkentry exploit msfconsole "Metasploit Framework" 0
mkentry exploit searchsploit "SearchSploit — Exploit-DB" 0

echo "### Contraseñas"
mkentry pass john "John the Ripper" 0
mkentry pass hashcat "Hashcat" 0
mkentry pass hydra "Hydra — fuerza bruta de login" 0
mkentry pass hashid "hashid — identifica hashes" 0
mkentry pass medusa "Medusa" 0

echo "### Redes"
mkentry net wireshark "Wireshark" 1
mkentry net tcpdump "tcpdump" 0
mkentry net nc "Netcat (nc)" 0
mkentry net socat "socat" 0
mkentry net bettercap "Bettercap" 0
mkentry net ettercap "Ettercap" 0
mkentry net responder "Responder" 0

echo "### WiFi (análisis)"
mkentry wifi aircrack-ng "Aircrack-ng" 0
mkentry wifi wifite "Wifite" 0
mkentry wifi reaver "Reaver" 0
mkentry wifi bully "Bully" 0
mkentry wifi hcxpcapngtool "hcxtools" 0
mkentry wifi cowpatty "coWPAtty" 0

# Entradas especiales
if [ -d /usr/share/wordlists ] || [ -d /usr/share/seclists ]; then
  cat > "$APPS/ahk-pass-wordlists.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Diccionarios (wordlists)
Exec=dolphin /usr/share/wordlists
Icon=folder-txt
Terminal=false
Categories=X-ArchHacker-pass;
EOF
fi
cat > "$APPS/ahk-recon-shell.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Terminal del objetivo (\$IP)
Exec=konsole -e ahk-shell
Icon=utilities-terminal
Terminal=false
Categories=X-ArchHacker-recon;
EOF

# Archivo .menu que arma el arbol de categorias
cat > "$MENUD/archhacker.menu" <<'EOF'
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN" "http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd">
<Menu>
  <Name>Applications</Name>
  <Menu>
    <Name>ArchHacker</Name>
    <Directory>archhacker.directory</Directory>
    <Menu>
      <Name>Reconocimiento</Name>
      <Directory>archhacker-recon.directory</Directory>
      <Include><Category>X-ArchHacker-recon</Category></Include>
    </Menu>
    <Menu>
      <Name>Web</Name>
      <Directory>archhacker-web.directory</Directory>
      <Include><Category>X-ArchHacker-web</Category></Include>
    </Menu>
    <Menu>
      <Name>Explotacion</Name>
      <Directory>archhacker-exploit.directory</Directory>
      <Include><Category>X-ArchHacker-exploit</Category></Include>
    </Menu>
    <Menu>
      <Name>Contrasenas</Name>
      <Directory>archhacker-pass.directory</Directory>
      <Include><Category>X-ArchHacker-pass</Category></Include>
    </Menu>
    <Menu>
      <Name>Redes</Name>
      <Directory>archhacker-net.directory</Directory>
      <Include><Category>X-ArchHacker-net</Category></Include>
    </Menu>
    <Menu>
      <Name>WiFi</Name>
      <Directory>archhacker-wifi.directory</Directory>
      <Include><Category>X-ArchHacker-wifi</Category></Include>
    </Menu>
  </Menu>
</Menu>
EOF

update-desktop-database "$APPS" 2>/dev/null || true
echo "### MENU_DONE $(date)"
