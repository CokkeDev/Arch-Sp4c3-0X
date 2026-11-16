#!/usr/bin/env bash
# Instalación base de Arch Linux + KDE Plasma 6 (UEFI). Se ejecuta desde la ISO de Arch.
# ⚠️ BORRA POR COMPLETO el disco indicado. Pensado para una máquina virtual nueva.
#
# Uso:  DISK=/dev/sda AH_USER=hacker AH_HOSTNAME=archhacker AH_TZ=UTC bash arch_base_install.sh
# Las contraseñas se piden al ejecutar (no se guardan en el script).
set -euo pipefail

DISK="${DISK:-/dev/sda}"
HOSTNAME="${AH_HOSTNAME:-archhacker}"
USERNAME="${AH_USER:-hacker}"
TZ="${AH_TZ:-UTC}"            # p. ej. Europe/Madrid, America/New_York

[ -b "$DISK" ] || { echo "No existe el disco $DISK"; exit 1; }

echo "Discos disponibles:"
lsblk -d -o NAME,SIZE,MODEL
echo
echo "⚠️  Se BORRARÁ TODO el contenido de $DISK."
if [ "${AH_YES:-}" != "1" ]; then
    read -r -p "Escribe el nombre del disco ($DISK) para confirmar: " ok
    [ "$ok" = "$DISK" ] || { echo "Cancelado."; exit 1; }
fi

if [ -z "${ROOTPASS:-}" ]; then
    read -r -s -p "Contraseña para root: " ROOTPASS; echo
fi
if [ -z "${USERPASS:-}" ]; then
    read -r -s -p "Contraseña para $USERNAME: " USERPASS; echo
fi
[ -n "$ROOTPASS" ] && [ -n "$USERPASS" ] || { echo "Las contraseñas no pueden estar vacías."; exit 1; }

ESP=${DISK}1
ROOT=${DISK}2

echo "### 1. Reloj NTP"
timedatectl set-ntp true || true

echo "### 2. Particionado GPT (ESP 1G + root resto) en $DISK"
sgdisk --zap-all "$DISK"
sgdisk -n1:0:+1GiB -t1:ef00 -c1:EFI "$DISK"
sgdisk -n2:0:0     -t2:8300 -c2:ROOT "$DISK"
partprobe "$DISK"
sleep 2

echo "### 3. Formato de particiones"
mkfs.fat -F32 -n EFI "$ESP"
mkfs.ext4 -F -L ROOT "$ROOT"

echo "### 4. Montaje"
mount "$ROOT" /mnt
mount --mkdir "$ESP" /mnt/boot

echo "### 5. Keyring + pacstrap (base + KDE Plasma 6)"
pacman -Sy --noconfirm archlinux-keyring || true
pacstrap -K /mnt \
  base base-devel linux linux-firmware linux-headers intel-ucode \
  e2fsprogs dosfstools reflector zram-generator \
  networkmanager sudo nano vim git wget curl openssh which rsync \
  man-db man-pages terminus-font bash-completion \
  pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber \
  plasma-meta sddm konsole dolphin kate ark spectacle firefox \
  noto-fonts noto-fonts-emoji ttf-dejavu ttf-liberation \
  open-vm-tools gtkmm3 xorg-xwayland mesa

echo "### 6. fstab"
genfstab -U /mnt >> /mnt/etc/fstab

ROOTUUID=$(blkid -s UUID -o value "$ROOT")
echo "### ROOTUUID=$ROOTUUID"

echo "### 7. Configuracion en chroot"
arch-chroot /mnt /bin/bash -euo pipefail <<CHROOT
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
hwclock --systohc

sed -i 's/^#\(es_ES.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo 'LANG=es_ES.UTF-8' > /etc/locale.conf
echo 'KEYMAP=la-latam' > /etc/vconsole.conf

echo '$HOSTNAME' > /etc/hostname
printf '127.0.0.1   localhost\n::1         localhost\n127.0.1.1   $HOSTNAME.localdomain $HOSTNAME\n' > /etc/hosts

printf '[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd\n' > /etc/systemd/zram-generator.conf

echo 'root:$ROOTPASS' | chpasswd

useradd -m -G wheel,network,video,audio,storage,power,rfkill -s /bin/bash $USERNAME
echo '$USERNAME:$USERPASS' | chpasswd
printf '%%wheel ALL=(ALL:ALL) ALL\n' > /etc/sudoers.d/10-wheel
chmod 440 /etc/sudoers.d/10-wheel

bootctl install
printf 'default arch.conf\ntimeout 3\nconsole-mode max\neditor no\n' > /boot/loader/loader.conf
printf 'title   Arch Linux (ArchHacker)\nlinux   /vmlinuz-linux\ninitrd  /intel-ucode.img\ninitrd  /initramfs-linux.img\noptions root=UUID=$ROOTUUID rw quiet\n' > /boot/loader/entries/arch.conf

systemctl enable NetworkManager sddm sshd vmtoolsd vmware-vmblock-fuse fstrim.timer
CHROOT

echo "### 8. SSH: solo con clave y sin acceso directo de root"
# Si arrancaste la ISO con tu clave pública en /root/.ssh/authorized_keys,
# se copia al usuario normal. root no puede entrar por SSH.
if [ -s /root/.ssh/authorized_keys ]; then
    install -d -m700 /mnt/home/$USERNAME/.ssh
    cp /root/.ssh/authorized_keys /mnt/home/$USERNAME/.ssh/authorized_keys
    chmod 600 /mnt/home/$USERNAME/.ssh/authorized_keys
    arch-chroot /mnt chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
fi
install -d /mnt/etc/ssh/sshd_config.d
echo 'PermitRootLogin no' > /mnt/etc/ssh/sshd_config.d/10-archhacker.conf

echo "### INSTALL_BASE_DONE"
