# Orbital — funciones de pentesting (bash y zsh)
# Se carga desde ~/.bashrc (o ~/.zshrc) con:  source ~/.config/orbital/orbital.sh

ORBITAL_TARGET_FILE="$HOME/.config/archhacker/target_ip"

# Fija el objetivo que muestra la polybar (y el widget de KDE)
atajos() {
    cat <<'TXT'
 Orbital · atajos   (Super = tecla Windows)
 ─────────────────────────────────────────────────────────────
 Terminal ........ Super+Enter   ·  Ctrl+Alt+Enter  ·  Ctrl+Alt+T
 Menú de apps .... Super+D       ·  Alt+D  ·  logo · clic der. fondo
 Cerrar ventana .. Super+W       ·  Alt+F4
 Escritorio 1-6 .. Super+1..6    ·  Ctrl+Alt+1..6
 Mover foco ...... Super+flechas
 Pantalla compl. . Super+F       ·  flotante: Super+S
 Salir a login ... Super+Shift+Q ·  o botón rojo arriba a la derecha
 Objetivo ........ settarget <ip>  ·  cleartarget
TXT
}

settarget() {
    if [ -z "$1" ]; then
        echo "uso: settarget <ip>"; return 1
    fi
    mkdir -p "$(dirname "$ORBITAL_TARGET_FILE")"
    printf '%s' "$1" > "$ORBITAL_TARGET_FILE"
    export IP="$1"
    echo "[+] Objetivo fijado: $1"
}

cleartarget() {
    : > "$ORBITAL_TARGET_FILE"
    unset IP
    echo "[+] Objetivo borrado"
}

# Carga $IP al abrir una terminal si hay objetivo fijado
[ -s "$ORBITAL_TARGET_FILE" ] && export IP="$(cat "$ORBITAL_TARGET_FILE")"

# Crea la estructura de trabajo de una máquina: nmap/ content/ exploits/
mkt() {
    mkdir -p nmap content exploits
    echo "[+] Carpetas nmap/ content/ exploits/ creadas"
}

# Lee un archivo -oG de nmap y copia los puertos abiertos al portapapeles
extractPorts() {
    local file="${1:-allPorts}"
    [ -f "$file" ] || { echo "no existe $file"; return 1; }
    local ports ip
    ports="$(grep -oP '\d{1,5}/open' "$file" | awk -F/ '{print $1}' | xargs | tr ' ' ',')"
    ip="$(grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' "$file" | sort -u | head -n 1)"
    printf '\n[*] Extracting information...\n\n\t[*] IP Address: %s\n\t[*] Open ports: %s\n\n' "$ip" "$ports" > extractPorts.tmp
    printf '%s' "$ports" | xclip -sel clip 2>/dev/null
    printf '[*] Ports copied to clipboard\n' >> extractPorts.tmp
    if command -v bat >/dev/null; then bat --paging=never extractPorts.tmp; else cat extractPorts.tmp; fi
    rm -f extractPorts.tmp
}

# Adivina el sistema por el TTL del ping (≈64 Linux, ≈128 Windows)
whichsystem() {
    local host="${1:-$IP}"
    [ -z "$host" ] && { echo "uso: whichsystem <ip>"; return 1; }
    local ttl os="desconocido"
    ttl="$(ping -c 1 -W 2 "$host" 2>/dev/null | grep -oP 'ttl=\K\d+')"
    [ -z "$ttl" ] && { echo "sin respuesta de $host"; return 1; }
    if   [ "$ttl" -le 64 ];  then os="Linux"
    elif [ "$ttl" -le 128 ]; then os="Windows"
    fi
    printf '\n\t%s (ttl -> %s): %s\n\n' "$host" "$ttl" "$os"
}

# Prompt de dos líneas como en el diseño
if [ -n "$BASH_VERSION" ]; then
    __orb() { printf '\[\e[38;2;%sm\]' "$1"; }
    __orb_status() { [ $? -eq 0 ] && printf '\e[38;2;155;213;154m' || printf '\e[38;2;255;77;94m'; }
    PS1="$(__orb '143;164;255')╭─ $(__orb '111;211;232')\u$(__orb '138;147;166')@$(__orb '230;233;239')\h $(__orb '229;199;107')\w\[\e[0m\]\n$(__orb '143;164;255')╰─\[\$(__orb_status)\]❯\[\e[0m\] "
elif [ -n "$ZSH_VERSION" ] && [ -z "$POWERLEVEL9K_MODE" ]; then
    PROMPT=$'%F{#8fa4ff}╭─%f %F{#6fd3e8}%n%f%F{#8a93a6}@%f%m %F{#e5c76b}%~%f\n%F{#8fa4ff}╰─%f%(?.%F{#9bd59a}.%F{#ff4d5e})❯%f '
fi
