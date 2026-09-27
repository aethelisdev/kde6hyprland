#!/usr/bin/env bash

# ==============================================================================
#  KDE 6 Rice Restore Script - by AethelisDEV
# ==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${YELLOW}${BOLD}KDE 6 Yedek Geri Yükleme Aracı${NC}\n"

# En son alınan yedeği bul
LATEST_BACKUP=$(ls -td "$HOME"/.kde6_rice_backup_* 2>/dev/null | head -n 1)

if [ -z "$LATEST_BACKUP" ] || [ ! -d "$LATEST_BACKUP" ]; then
    echo -e "${RED}[x] Herhangi bir yedek klasörü (~/.kde6_rice_backup_*) bulunamadı.${NC}"
    exit 1
fi

echo -e "${BLUE}[*] Bulunan en son yedek: ${BOLD}$LATEST_BACKUP${NC}"
read -p "Bu yedeği geri yüklemek istiyor musunuz? (e/h): " choice

if [[ "$choice" != "e" && "$choice" != "E" ]]; then
    echo -e "${RED}[x] İşlem iptal edildi.${NC}"
    exit 0
fi

cp -f "$LATEST_BACKUP/"* "$HOME/.config/"

echo -e "${BLUE}[*] Plasmashell yeniden başlatılıyor...${NC}"
kquitapp6 plasmashell 2>/dev/null || killall -9 plasmashell 2>/dev/null || true
sleep 1
nohup kstart plasmashell >/dev/null 2>&1 & disown 2>/dev/null || nohup plasmashell --replace >/dev/null 2>&1 & disown 2>/dev/null || true

echo -e "${GREEN}[✓] Eski KDE yapılandırmanız geri yüklendi!${NC}"
