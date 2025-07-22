SHELL=/bin/bash
export PATH:=$(PWD)/bin:$(PATH)

BUILDDIR=build
FAI_CONFIG_DIR=$(PWD)/../fai
FAI_CONFIG_SRC=file://$(FAI_CONFIG_DIR)
FAI_CONFIG=$(PWD)/$(BUILDDIR)/fai-config
FAI_ETC_BASE=fai-etc-dir
FAI_ETC=$(BUILDDIR)/$(FAI_ETC_BASE)
NFSROOT=$(BUILDDIR)/nfsroot
FAI_CD_TRIXIE=$(BUILDDIR)/fai-cd-trixie.iso
GNOME_LIVE=$(BUILDDIR)/live-GNOME.iso

.PHONY: clean init

clean:
	sudo rm -rf $(BUILDDIR)

init:
	sudo apt-get update
	sudo apt-get install extrepo
	sudo extrepo enable fai
	sudo apt-get update
	sudo apt-get install fai-client fai-server

$(FAI_CD_TRIXIE): $(NFSROOT)
	sudo fai-cd -C $(FAI_ETC) -M  $(BUILDDIR)/fai-cd-trixie.iso

.ONE_SHELL:
$(FAI_CONFIG): 
# 	@echo "Cloning FAI configuration repository..."
# 	git clone --depth 1 $(FAI_CONFIG_SRC) $(FAI_CONFIG)
	@echo "Copying FAI configuration..."
	mkdir -p $(BUILDDIR)
	cp -r ${FAI_CONFIG_DIR} $(FAI_CONFIG)

$(FAI_ETC): $(FAI_ETC_BASE)
	@echo "Copying FAI etc directory..."
	mkdir -p $(BUILDDIR)
	cp -rv $(FAI_ETC_BASE) $(BUILDDIR)/

$(NFSROOT): $(FAI_CONFIG) $(FAI_ETC)
	@echo "Make NFS root directory..."	
	sudo fai-make-nfsroot -C $(FAI_ETC) -f

$(GNOME_LIVE): $(FAI_CONFIG) $(FAI_ETC)
	@echo "Creating GNOME live ISO..."
	create-live-iso.sh GNOME DUTCH $(BUILDDIR)/live-install-dir $(FAI_CONFIG) $(FAI_ETC) $(BUILDDIR)

test-$(GNOME_LIVE): $(GNOME_LIVE)
	@echo "Testing GNOME live ISO..."
	test-iso.sh -i $(GNOME_LIVE)

test-$(FAI_CD_TRIXIE): $(FAI_CD_TRIXIE)
	@echo "Testing FAI CD Trixie ISO..."
	test-iso.sh -i $(FAI_CD_TRIXIE)