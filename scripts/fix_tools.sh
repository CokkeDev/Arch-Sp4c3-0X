#!/usr/bin/env bash
# Reinstala individualmente las herramientas que fallaron en lote.
set -uo pipefail
: > /root/fix_result.txt
: > /root/fix.log
pacman -Sy --noconfirm >>/root/fix.log 2>&1 || true

pkgs="john hashcat hydra hashid medusa seclists wordlists \
wireshark-qt wireshark-cli tcpdump gnu-netcat openbsd-netcat socat bettercap ettercap responder \
theharvester hcxtools hcxdumptool nuclei whatweb wfuzz dirb \
dnsenum fierce dnsrecon netdiscover cowpatty bully macchanger"

for p in $pkgs; do
  if pacman -S --needed --noconfirm "$p" >>/root/fix.log 2>&1; then
    echo "OK   $p"
  else
    echo "FAIL $p"
  fi
done >> /root/fix_result.txt

# wireshark: permitir captura al usuario
usermod -aG wireshark hacker 2>/dev/null || true
echo "FIXDONE $(date)" >> /root/fix_result.txt
