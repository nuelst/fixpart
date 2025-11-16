# 📦 Guia de Empacotamento - FixPart

Este guia explica como criar pacotes Debian (.deb) e Snap para o FixPart.

## 📋 Pré-requisitos

### Para pacotes Debian (.deb):
```bash
sudo apt-get install build-essential dpkg-dev devscripts
```

### Para pacotes Snap:
```bash
sudo snap install snapcraft --classic
```

## 🔨 Construindo Pacotes

### Opção 1: Usando Makefile (Recomendado)

```bash
# Construir pacote Debian
make deb

# Construir pacote Snap
make snap

# Instalar localmente
make install-deb
# ou
make install-snap
```

### Opção 2: Manual

#### Debian Package (.deb)

```bash
# 1. Preparar estrutura
mkdir -p debian/usr/bin
cp fixpart.sh debian/usr/bin/fixpart
chmod +x debian/usr/bin/fixpart

# 2. Construir pacote
dpkg-deb --build debian fixpart_1.0.0_all.deb

# 3. Instalar
sudo dpkg -i fixpart_1.0.0_all.deb
sudo apt-get install -f  # Instalar dependências se necessário
```

#### Snap Package

```bash
# 1. Construir snap
snapcraft

# 2. Instalar
sudo snap install --dangerous fixpart_1.0.0_amd64.snap
```

## 📤 Publicando Pacotes

### Debian/Ubuntu Repository (PPA)

1. **Criar conta no Launchpad**: https://launchpad.net
2. **Configurar chave GPG**:
```bash
gpg --gen-key
gpg --send-keys YOUR_KEY_ID
```
3. **Criar PPA**:
```bash
dput ppa:seu-usuario/fixpart fixpart_1.0.0_source.changes
```

### Snap Store

1. **Registrar snap name**:
```bash
snapcraft register fixpart
```

2. **Fazer login**:
```bash
snapcraft login
```

3. **Publicar**:
```bash
snapcraft upload --release=stable fixpart_1.0.0_amd64.snap
```

## 🔍 Verificar Pacote

### Debian:
```bash
# Verificar estrutura
dpkg-deb -c fixpart_1.0.0_all.deb

# Verificar informações
dpkg-deb -I fixpart_1.0.0_all.deb

# Testar instalação
sudo dpkg -i fixpart_1.0.0_all.deb
```

### Snap:
```bash
# Verificar snap
snapcraft validate snap/snapcraft.yaml

# Testar localmente
snap try prime/
```

## 📝 Estrutura de Arquivos

```
fix-disk/
├── fixpart.sh              # Script principal
├── debian/
│   ├── DEBIAN/
│   │   ├── control         # Metadados do pacote
│   │   ├── postinst        # Script pós-instalação
│   │   └── prerm           # Script pré-remoção
│   └── usr/
│       └── bin/
│           └── fixpart     # Binário (copiado do fixpart.sh)
├── snap/
│   └── snapcraft.yaml      # Configuração do snap
├── Makefile                # Build automation
└── PACKAGING.md            # Este arquivo
```

## ⚠️ Notas Importantes

### Debian Package:
- **Confinement**: Não necessário (pacote tradicional)
- **Permissões**: Requer sudo para executar
- **Dependências**: Instaladas automaticamente via apt

### Snap Package:
- **Confinement**: `classic` (necessário para acesso a disco)
- **Permissões**: Requer sudo para executar
- **Plugs**: `hardware-observe`, `mount-observe`, `system-backup`

## 🚀 Distribuição

### Opção 1: PPA (Ubuntu/Debian)
- Mais fácil para usuários Ubuntu
- Integração nativa com apt
- Requer conta Launchpad

### Opção 2: Snap Store
- Funciona em múltiplas distribuições
- Atualizações automáticas
- Requer conta Snap Store

### Opção 3: GitHub Releases
- Simples e direto
- Usuários baixam e instalam manualmente
- Sem autenticação necessária

## 📚 Recursos Adicionais

- [Debian Packaging Guide](https://www.debian.org/doc/manuals/packaging-tutorial/)
- [Snapcraft Documentation](https://snapcraft.io/docs)
- [Launchpad PPA Guide](https://help.launchpad.net/Packaging/PPA)

