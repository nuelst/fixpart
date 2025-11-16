# 🔧 FixPart - Automatic Partition Repair Script

An intelligent bash script to automatically repair corrupted partitions on Ubuntu/Linux systems, with support for multiple filesystem types.

## 🚨 Problem Solved

This script addresses common partition corruption issues, including:

- **I/O Errors**: "Input/output error" when accessing directories
- **Mount Failures**: "Could not display all contents" errors
- **Filesystem Corruption**: Various filesystem-specific issues
- **Access Denied**: Permission and mounting problems

### Example Error Fixed:
```
"Unable to access 'backdoor'
Error mounting /dev/sdb1 at /media/manuel/backdoor5: 
wrong fs type, bad option, bad superblock on /dev/sdb1, 
missing codepage or helper program, or other error"
```

## ✨ Features

- 🔍 **Automatic detection** of filesystem type
- 🛠️ **Intelligent repair** based on partition type
- 🎨 **Colorful and friendly** interface
- 🔒 **Permission verification** (root execution required)
- 📋 **Automatic listing** of available partitions
- 🚀 **Automatic mounting** after repair
- 🔧 **Multi-filesystem support**

## 📋 Supported Filesystems

| Filesystem | Repair Command | Status |
|------------|----------------|--------|
| **NTFS** (Windows) | `ntfsfix` | ✅ Supported |
| **EXT2/3/4** (Linux) | `fsck` / `e2fsck` | ✅ Supported |
| **exFAT** | `fsck.exfat` | ✅ Supported |
| **FAT32** | `fsck.vfat` | ✅ Supported |

## 🚀 Installation

1. **Clone the repository:**
```bash
git clone https://github.com/your-username/fix-disk.git
cd fix-disk
```

2. **Make the script executable:**
```bash
chmod +x fixpart.sh
```

3. **Run as root:**
```bash
sudo ./fixpart.sh
```

## 💻 Usage

### Basic Execution
```bash
sudo ./fixpart.sh
```

### Script Flow

1. **Permission verification** - Confirms running as root
2. **Partition listing** - Shows all available partitions
3. **Partition selection** - User chooses which partition to repair
4. **Automatic analysis** - Detects filesystem type and state
5. **Unmounting** - Removes partition from system if necessary
6. **Repair** - Executes appropriate command based on type
7. **Mounting** - Offers option to remount after repair

### Usage Example

```bash
$ sudo ./fixpart.sh

╔════════════════════════════════════════════╗
║  Script de Reparo de Partições - Ubuntu   ║
╚════════════════════════════════════════════╝

📋 Partições disponíveis:
NAME    SIZE FSTYPE MOUNTPOINT LABEL
sda1    500G ntfs   /media/win Windows
sda2    100G ext4   /          Ubuntu

Digite a partição com problema (ex: /dev/sda1): /dev/sda1

🔍 Analisando /dev/sda1...
✓ Tipo de sistema de arquivos: ntfs
✓ Label: Windows

🪟 Sistema NTFS detectado (Windows)
Executando ntfsfix...
✓ Reparo NTFS concluído!

✅ Reparo concluído!
Deseja tentar montar a partição agora? (s/n): s
✅ Partição montada com sucesso em: /media/usuario/Windows
```

## 🔧 Dependencies

The script automatically installs necessary dependencies:

- **NTFS**: `ntfs-3g`
- **exFAT**: `exfat-fuse exfatprogs`
- **EXT/FAT**: Already included in the system

## ⚠️ Important Warnings

- ⚠️ **ALWAYS backup** before running repairs
- ⚠️ **Run as root** - script verifies automatically
- ⚠️ **Mounted partitions** will be unmounted automatically
- ⚠️ **Data may be lost** in severe corruption cases

## 🛡️ Security

- ✅ Root permission verification
- ✅ Partition existence validation
- ✅ Safe unmounting before repair
- ✅ Automatic permission adjustment after mounting

## 🐛 Troubleshooting

### Error: "Partition does not exist"
```bash
# Check available partitions
lsblk
```

### Error: "Failed to unmount"
```bash
# Force unmount manually
sudo umount -l /dev/sdX
```

### Error: "Unsupported filesystem type"
- Check if the filesystem is in the supported list
- Run `blkid /dev/sdX` to verify the type

## 📝 Logs and Debug

To see detailed logs:
```bash
sudo ./fixpart.sh 2>&1 | tee repair.log
```

## 🤝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/new-functionality`)
3. Commit your changes (`git commit -am 'Add new functionality'`)
4. Push to the branch (`git push origin feature/new-functionality`)
5. Open a Pull Request

## 📄 License

This project is under the MIT license. See the [LICENSE](LICENSE) file for more details.

## 👨‍💻 Author

**Claude Assistant** - *Initial development*

## 🙏 Acknowledgments

- Ubuntu/Linux community
- Filesystem tools developers
- Project contributors

---

⭐ **If this project helped you, consider giving it a star!**
