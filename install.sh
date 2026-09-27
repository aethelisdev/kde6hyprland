#!/usr/bin/env bash

# ==============================================================================
#  KDE 6 Rice Installer - by AethelisDEV
#  Repository: https://github.com/aethelisdev/kde6hyprland
# ==============================================================================

set -e

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.kde6_rice_backup_$(date +%Y%m%d_%H%M%S)"

echo -e "${CYAN}${BOLD}"
echo "=========================================================="
echo "          KDE 6 Rice & Layout Installer                   "
echo "                by AethelisDEV                            "
echo "=========================================================="
echo -e "${NC}"

# KDE 6 Kontrolü
if ! command -v kreadconfig6 &> /dev/null && ! command -v plasmashell &> /dev/null; then
    echo -e "${YELLOW}[!] Uyarı: Sisteminizde KDE 6 tespit edilemedi veya komutlar bulunamadı.${NC}"
    read -p "Yine de devam etmek istiyor musunuz? (e/h): " choice
    if [[ "$choice" != "e" && "$choice" != "E" ]]; then
        echo -e "${RED}[x] Kurulum iptal edildi.${NC}"
        exit 1
    fi
fi

# 1. Yedekleme
echo -e "${BLUE}[*] Mevcut KDE yapılandırmalarınız yedekleniyor...${NC}"
mkdir -p "$BACKUP_DIR"

for cfg in "plasma-org.kde.plasma.desktop-appletsrc" "kdeglobals" "kwinrc" "plasmarc" "kglobalshortcutsrc"; do
    if [ -f "$HOME/.config/$cfg" ]; then
        cp "$HOME/.config/$cfg" "$BACKUP_DIR/"
    fi
done

echo -e "${GREEN}[✓] Yedek başarıyla alındı: ${BOLD}$BACKUP_DIR${NC}"
echo -e "    (İleride geri dönmek isterseniz bu klasördeki dosyaları ~/.config içine kopyalayabilirsiniz)\n"

# 2. Dizinleri Oluşturma
echo -e "${BLUE}[*] Gerekli dizinler oluşturuluyor...${NC}"
mkdir -p "$HOME/.local/share/plasma/plasmoids"
mkdir -p "$HOME/.local/share/plasma/wallpapers"
mkdir -p "$HOME/.local/share/plasma/desktoptheme"
mkdir -p "$HOME/.local/share/aurorae/themes"
mkdir -p "$HOME/.local/share/color-schemes"
mkdir -p "$HOME/.local/share/icons"
mkdir -p "$HOME/.local/share/wallpapers"
mkdir -p "$HOME/.config"

# 3. Plasmoid'leri (Widget'ları) Kopyalama
echo -e "${BLUE}[*] Eklentiler (Plasmoids) kopyalanıyor...${NC}"
if [ -d "$SCRIPT_DIR/plasmoids" ]; then
    cp -rf "$SCRIPT_DIR/plasmoids/"* "$HOME/.local/share/plasma/plasmoids/"
fi

# 4. Duvar Kağıdı Eklentisini Kopyalama
echo -e "${BLUE}[*] Video Duvar Kağıdı eklentisi kopyalanıyor...${NC}"
if [ -d "$SCRIPT_DIR/wallpaper-plugin" ]; then
    cp -rf "$SCRIPT_DIR/wallpaper-plugin/"* "$HOME/.local/share/plasma/wallpapers/"
fi

# 5. Temalar, Renk Şemaları ve İkonları Kopyalama
echo -e "${BLUE}[*] Pencere dekorasyonları ve temalar kopyalanıyor...${NC}"
if [ -d "$SCRIPT_DIR/themes/aurorae" ]; then
    cp -rf "$SCRIPT_DIR/themes/aurorae/"* "$HOME/.local/share/aurorae/themes/"
fi
if [ -d "$SCRIPT_DIR/themes/color-schemes" ]; then
    cp -rf "$SCRIPT_DIR/themes/color-schemes/"* "$HOME/.local/share/color-schemes/"
fi
if [ -d "$SCRIPT_DIR/themes/desktoptheme" ]; then
    cp -rf "$SCRIPT_DIR/themes/desktoptheme/"* "$HOME/.local/share/plasma/desktoptheme/"
fi
if [ -d "$SCRIPT_DIR/themes/icons" ]; then
    echo -e "${BLUE}[*] BigSur İkon paketi kopyalanıyor (bu biraz sürebilir)...${NC}"
    cp -rf "$SCRIPT_DIR/themes/icons/"* "$HOME/.local/share/icons/"
fi

# 6. Duvar Kağıtlarını Kopyalama
echo -e "${BLUE}[*] Duvar kağıtları kopyalanıyor...${NC}"
if [ -d "$SCRIPT_DIR/wallpapers" ]; then
    cp -rf "$SCRIPT_DIR/wallpapers/"* "$HOME/.local/share/wallpapers/"
    if [ -f "$SCRIPT_DIR/wallpapers/live/ayanami-rei_2K.mp4" ]; then
        cp -f "$SCRIPT_DIR/wallpapers/live/ayanami-rei_2K.mp4" "$HOME/.local/share/wallpapers/ayanami-rei_2K.mp4"
    fi
fi

# 7. Kullanıcıya Özel Değişkenleri Tespit Etme
echo -e "${BLUE}[*] Sisteminizin Etkinlik ve Masaüstü ID'leri algılanıyor...${NC}"
ACT_ID=""
if [ -f "$HOME/.config/kactivitymanagerdrc" ]; then
    ACT_ID=$(awk -F= '/^\[activities\]/{flag=1;next}/^\[/{flag=0}flag && NF{print $1; exit}' "$HOME/.config/kactivitymanagerdrc")
fi
if [ -z "$ACT_ID" ] && command -v qdbus &> /dev/null; then
    ACT_ID=$(qdbus org.kde.ActivityManager /ActivityManager/Activities CurrentActivity 2>/dev/null || true)
fi
if [ -z "$ACT_ID" ]; then
    ACT_ID="00000000-0000-0000-0000-000000000000"
fi

DESK_UUID=""
if [ -f "$HOME/.config/kwinrc" ]; then
    DESK_UUID=$(grep -E "^Id_1=" "$HOME/.config/kwinrc" | cut -d'=' -f2 | head -n1)
fi
if [ -z "$DESK_UUID" ]; then
    DESK_UUID="e3f5e79e-585d-4b40-90c3-e101aaa3a047"
fi

echo -e "    -> Bulunan Activity ID: ${GREEN}$ACT_ID${NC}"
echo -e "    -> Bulunan Desktop UUID: ${GREEN}$DESK_UUID${NC}"

# 8. Yapılandırma Dosyalarını Hazırlama ve Yerleştirme
echo -e "${BLUE}[*] Yapılandırmalar sisteme uygulanıyor...${NC}"

for file in "plasma-org.kde.plasma.desktop-appletsrc" "plasmarc" "kglobalshortcutsrc" "kwinrc" "kdeglobals"; do
    if [ -f "$SCRIPT_DIR/config/$file" ]; then
        sed -e "s|{{USER_HOME}}|$HOME|g" \
            -e "s|{{ACTIVITY_ID}}|$ACT_ID|g" \
            -e "s|{{DESKTOP_UUID}}|$DESK_UUID|g" \
            "$SCRIPT_DIR/config/$file" > "$HOME/.config/$file"
    fi
done

# Alacritty terminal ayarı (İsteğe bağlı)
if [ -f "$SCRIPT_DIR/config/alacritty.toml" ]; then
    mkdir -p "$HOME/.config/alacritty"
    if [ ! -f "$HOME/.config/alacritty/alacritty.toml" ]; then
        cp "$SCRIPT_DIR/config/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
    fi
fi

# 9. Plasma Shell'i Yeniden Başlatma
echo -e "${BLUE}[*] Değişikliklerin görünmesi için KDE Plasma yeniden başlatılıyor...${NC}"

if command -v kquitapp6 &> /dev/null; then
    kquitapp6 plasmashell 2>/dev/null || killall -9 plasmashell 2>/dev/null || true
else
    killall -9 plasmashell 2>/dev/null || true
fi

sleep 1

# KWin reconfigure
if command -v qdbus &> /dev/null; then
    qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
fi

# Plasmashell başlat
nohup kstart plasmashell >/dev/null 2>&1 & disown 2>/dev/null || nohup plasmashell --replace >/dev/null 2>&1 & disown 2>/dev/null || true

echo -e "\n${GREEN}${BOLD}=========================================================="
echo "          KURULUM BAŞARIYLA TAMAMLANDI!                   "
echo "==========================================================${NC}"
echo -e "${CYAN}Tüm paneller, kısayollar, temalar ve widget'lar uygulandı.${NC}"
echo -e "Eğer bazı widget'lar hemen güncellenmediyse oturumu kapatıp (Log Out) tekrar açabilirsiniz."
echo -e "Yedeklenen eski ayarlarınız: ${BOLD}$BACKUP_DIR${NC}\n"
