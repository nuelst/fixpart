
# Automatic Partition Repair Script
# Author: Manuel dos Santos 
# Email: manueds@outlook.pt
# GitHub: https://github.com/nuelst
# LinkedIn: https://linkedin.com/in/nuelst
# Usage: sudo fixpart
#        sudo ./fixpart.sh (if not installed as package)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ This script needs to be run as root${NC}"
    echo -e "${YELLOW}Run: sudo $0${NC}"
    exit 1
fi

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Automatic Partition Repair Script - Ubuntu ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}📋 Available partitions:${NC}"
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,LABEL | grep -E "sd|nvme"
echo ""

read -p "Enter the problematic partition (ex: /dev/sda1): " PARTICAO

# Sanitize input - remove any dangerous characters
PARTICAO=$(echo "$PARTICAO" | tr -d ';|&<>`$(){}[]*?!')

if [ ! -b "$PARTICAO" ]; then
    echo -e "${RED}❌ Error: Partition $PARTICAO does not exist!${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🔍 Analyzing $PARTICAO...${NC}"
echo ""

FS_TYPE=$(blkid -o value -s TYPE "$PARTICAO" 2>/dev/null)
LABEL=$(blkid -o value -s LABEL "$PARTICAO" 2>/dev/null)

if [ -z "$FS_TYPE" ]; then
    echo -e "${RED}❌ Could not detect filesystem type${NC}"
    echo -e "${YELLOW}Partition may be corrupted or unformatted${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Filesystem type: $FS_TYPE${NC}"
[ -n "$LABEL" ] && echo -e "${GREEN}✓ Label: $LABEL${NC}"
echo ""

# Better mount check using findmnt
if findmnt "$PARTICAO" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Partition is mounted. Unmounting...${NC}"
    umount "$PARTICAO" 2>/dev/null
    UMOUNT_STATUS=$?
    if [ $UMOUNT_STATUS -eq 0 ]; then
        echo -e "${GREEN}✓ Unmounted successfully${NC}"
    else
        echo -e "${RED}❌ Failed to unmount. Force unmount? (y/n)${NC}"
        read -p "> " FORCE
        if [ "$FORCE" = "y" ] || [ "$FORCE" = "Y" ]; then
            umount -l "$PARTICAO"
            if [ $? -ne 0 ]; then
                echo -e "${RED}❌ Force unmount also failed${NC}"
                exit 1
            fi
        else
            exit 1
        fi
    fi
    echo ""
fi

echo -e "${BLUE}🔧 Starting automatic repair...${NC}"
echo ""

case "$FS_TYPE" in
    ntfs)
        echo -e "${YELLOW}🪟 NTFS system detected (Windows)${NC}"
        
        if ! command -v ntfsfix &> /dev/null; then
            echo -e "${YELLOW}📦 Installing NTFS tools...${NC}"
            if ! apt-get update -qq || ! apt-get install -y ntfs-3g; then
                echo -e "${RED}❌ Failed to install NTFS tools${NC}"
                exit 1
            fi
        fi
        
        echo -e "${BLUE}Running ntfsfix...${NC}"
        if ntfsfix "$PARTICAO"; then
            echo -e "${GREEN}✓ NTFS repair completed!${NC}"
        else
            NTFS_STATUS=$?
            echo -e "${RED}❌ NTFS repair error (exit code: $NTFS_STATUS)${NC}"
            exit 1
        fi
        ;;
    
    ext4|ext3|ext2)
        echo -e "${YELLOW}🐧 EXT system detected (Linux)${NC}"
        echo -e "${BLUE}Running fsck (may take time)...${NC}"
        echo ""
        
        fsck -y -f "$PARTICAO"
        FSCK_STATUS=$?
        
        if [ $FSCK_STATUS -eq 0 ] || [ $FSCK_STATUS -eq 1 ]; then
            echo -e "${GREEN}✓ EXT repair completed!${NC}"
        else
            echo -e "${YELLOW}⚠️  fsck returned code $FSCK_STATUS${NC}"
            echo -e "${YELLOW}Trying to repair with alternative superblock...${NC}"
            
            # Try to find alternative superblock first
            if command -v mke2fs &> /dev/null; then
                ALT_SB=$(mke2fs -n "$PARTICAO" 2>/dev/null | grep "Superblock backups" -A 1 | tail -1 | awk '{print $NF}')
                if [ -n "$ALT_SB" ]; then
                    echo -e "${BLUE}Using superblock backup at $ALT_SB${NC}"
                    e2fsck -b "$ALT_SB" -y "$PARTICAO"
                else
                    echo -e "${YELLOW}Using default superblock 32768...${NC}"
                    e2fsck -b 32768 -y "$PARTICAO"
                fi
            else
                echo -e "${YELLOW}Using default superblock 32768...${NC}"
                e2fsck -b 32768 -y "$PARTICAO"
            fi
        fi
        ;;
    
    exfat)
        echo -e "${YELLOW}💾 exFAT system detected${NC}"
        
        # Check if exfat is installed
        if ! command -v fsck.exfat &> /dev/null; then
            echo -e "${YELLOW}📦 Installing exFAT tools...${NC}"
            if ! apt-get update -qq || ! apt-get install -y exfat-fuse exfatprogs; then
                echo -e "${RED}❌ Failed to install exFAT tools${NC}"
                exit 1
            fi
        fi
        
        echo -e "${BLUE}Running fsck.exfat...${NC}"
        if fsck.exfat -y "$PARTICAO"; then
            echo -e "${GREEN}✓ exFAT repair completed!${NC}"
        else
            EXFAT_STATUS=$?
            echo -e "${RED}❌ exFAT repair error (exit code: $EXFAT_STATUS)${NC}"
            exit 1
        fi
        ;;
    
    vfat|fat32)
        echo -e "${YELLOW}💿 FAT32 system detected${NC}"
        echo -e "${BLUE}Running fsck.vfat...${NC}"
        
        if fsck.vfat -y "$PARTICAO"; then
            echo -e "${GREEN}✓ FAT32 repair completed!${NC}"
        else
            FAT32_STATUS=$?
            echo -e "${RED}❌ FAT32 repair error (exit code: $FAT32_STATUS)${NC}"
            exit 1
        fi
        ;;
    
    *)
        echo -e "${RED}❌ Filesystem type '$FS_TYPE' not supported by this script${NC}"
        echo -e "${YELLOW}Supported types: NTFS, EXT2/3/4, exFAT, FAT32${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Repair completed!${NC}"
echo ""

read -p "Do you want to try mounting the partition now? (y/n): " MONTAR

if [ "$MONTAR" = "y" ] || [ "$MONTAR" = "Y" ]; then
    # Handle case where SUDO_USER might be empty (if run as root directly)
    if [ -z "$SUDO_USER" ]; then
        SUDO_USER=$(logname 2>/dev/null || echo "root")
    fi
    
    # Sanitize label for use in path
    SAFE_LABEL=$(echo "${LABEL:-repaired_partition}" | tr -d '/\\:*?"<>|' | tr ' ' '_')
    MOUNT_POINT="/media/$SUDO_USER/$SAFE_LABEL"
    
    if [ ! -d "$MOUNT_POINT" ]; then
        mkdir -p "$MOUNT_POINT"
        echo -e "${GREEN}✓ Mount point created: $MOUNT_POINT${NC}"
    fi
    
    if mount "$PARTICAO" "$MOUNT_POINT"; then
        echo -e "${GREEN}✅ Partition mounted successfully at: $MOUNT_POINT${NC}"
        
        if [ "$SUDO_USER" != "root" ]; then
            chown -R "$SUDO_USER":"$SUDO_USER" "$MOUNT_POINT"
            echo -e "${GREEN}✓ Permissions adjusted${NC}"
        fi
    else
        MOUNT_STATUS=$?
        echo -e "${RED}❌ Mount error (exit code: $MOUNT_STATUS). Check manually with:${NC}"
        echo -e "${YELLOW}   sudo mount $PARTICAO $MOUNT_POINT${NC}"
    fi
else
    # Handle case where SUDO_USER might be empty
    if [ -z "$SUDO_USER" ]; then
        SUDO_USER=$(logname 2>/dev/null || echo "root")
    fi
    echo -e "${YELLOW}ℹ️  To mount manually later, use:${NC}"
    echo -e "${BLUE}   sudo mount $PARTICAO /media/$SUDO_USER/your_mount_point${NC}"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}Script finished!${NC}"
echo ""