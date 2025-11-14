# Makefile for building fixpart packages
# Author: Manuel dos Santos

PACKAGE_NAME=fixpart
VERSION=1.0.0
DEB_DIR=debian
BUILD_DIR=build
SNAP_DIR=snap

.PHONY: all deb snap clean install-deb install-snap help

all: help

help:
	@echo "FixPart Package Builder"
	@echo ""
	@echo "Available targets:"
	@echo "  make deb        - Build Debian package (.deb)"
	@echo "  make snap       - Build Snap package"
	@echo "  make clean      - Clean build directories"
	@echo "  make install-deb - Install .deb package locally"
	@echo "  make install-snap - Install snap package locally"
	@echo ""

deb: clean
	@echo "Building Debian package..."
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(DEB_DIR)/usr/bin
	@mkdir -p $(DEB_DIR)/usr/share/doc/$(PACKAGE_NAME)
	@cp fixpart.sh $(DEB_DIR)/usr/bin/$(PACKAGE_NAME)
	@chmod +x $(DEB_DIR)/usr/bin/$(PACKAGE_NAME)
	@cp README.md $(DEB_DIR)/usr/share/doc/$(PACKAGE_NAME)/
	@chmod +x $(DEB_DIR)/DEBIAN/postinst
	@chmod +x $(DEB_DIR)/DEBIAN/prerm
	@dpkg-deb --build $(DEB_DIR) $(BUILD_DIR)/$(PACKAGE_NAME)_$(VERSION)_all.deb
	@echo ""
	@echo "✅ Package built: $(BUILD_DIR)/$(PACKAGE_NAME)_$(VERSION)_all.deb"
	@echo "Install with: sudo dpkg -i $(BUILD_DIR)/$(PACKAGE_NAME)_$(VERSION)_all.deb"

snap: clean
	@echo "Building Snap package..."
	@cd $(SNAP_DIR) && snapcraft --destructive-mode
	@echo ""
	@echo "✅ Snap package built"
	@echo "Install with: sudo snap install --dangerous $(PACKAGE_NAME)_$(VERSION)_amd64.snap"

install-deb: deb
	@echo "Installing Debian package..."
	@sudo dpkg -i $(BUILD_DIR)/$(PACKAGE_NAME)_$(VERSION)_all.deb || sudo apt-get install -f -y
	@echo "✅ Package installed!"

install-snap: snap
	@echo "Installing Snap package..."
	@sudo snap install --dangerous $(PACKAGE_NAME)_$(VERSION)_amd64.snap
	@echo "✅ Snap installed!"

clean:
	@echo "Cleaning build directories..."
	@rm -rf $(BUILD_DIR)
	@rm -rf $(DEB_DIR)/usr/bin
	@rm -rf $(DEB_DIR)/usr/share/doc
	@rm -f *.deb *.snap
	@echo "✅ Cleaned!"

