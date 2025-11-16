# 🚀 Quick Start - Empacotamento FixPart

## 📦 Opção 1: Pacote Debian (.deb) - Recomendado para Ubuntu/Debian

### Construir e Instalar:
```bash
# Construir pacote
make deb

# Instalar
sudo dpkg -i build/fixpart_1.0.0_all.deb
sudo apt-get install -f  # Instalar dependências se necessário

# Usar
sudo fixpart
```

### Publicar no PPA (Launchpad):
1. Criar conta em https://launchpad.net
2. Criar PPA: `ppa:seu-usuario/fixpart`
3. Fazer upload do pacote

## 📦 Opção 2: Pacote Snap - Funciona em múltiplas distros

### Construir e Instalar:
```bash
# Instalar snapcraft (se necessário)
sudo snap install snapcraft --classic

# Construir snap
make snap

# Instalar localmente
sudo snap install --dangerous fixpart_1.0.0_amd64.snap

# Usar
sudo fixpart
```

### Publicar no Snap Store:
```bash
# Registrar nome (apenas primeira vez)
snapcraft register fixpart

# Login
snapcraft login

# Publicar
snapcraft upload --release=stable fixpart_1.0.0_amd64.snap
```

## 📋 Estrutura Criada

```
fix-disk/
├── fixpart.sh              # Script principal
├── Makefile                # Build automation
├── debian/                 # Estrutura pacote Debian
│   └── DEBIAN/
│       ├── control         # Metadados
│       ├── postinst        # Script pós-instalação
│       └── prerm           # Script pré-remoção
├── snap/                   # Estrutura pacote Snap
│   └── snapcraft.yaml      # Configuração
├── PACKAGING.md            # Guia completo
└── QUICK_START.md          # Este arquivo
```

## ✅ Próximos Passos

1. **Testar localmente**: `make install-deb` ou `make install-snap`
2. **Verificar funcionamento**: `sudo fixpart`
3. **Publicar**: Escolher PPA ou Snap Store
4. **Atualizar README**: Adicionar instruções de instalação via apt/snap

## 📚 Documentação Completa

Veja `PACKAGING.md` para detalhes completos sobre empacotamento.

