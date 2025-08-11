SHELL=/bin/bash
export PATH:=$(PWD)/bin:$(PATH)

LENIENT=1
export LENIENT
BUILDDIR=build
FAI_CONFIG_DIR=$(PWD)/../fai
FAI_CONFIG_SRC=file://$(FAI_CONFIG_DIR)
FAI_CONFIG=$(BUILDDIR)/fai-config
FAI_ETC_BASE=fai-etc-dir
FAI_ETC=$(BUILDDIR)/$(FAI_ETC_BASE)
NFSROOT=$(BUILDDIR)/nfsroot
FAI_CD_TRIXIE=$(BUILDDIR)/fai-cd-trixie.iso
GNOME_LIVE=$(BUILDDIR)/live-GNOME_CORE.iso

.PHONY: clean clean-config init profiles

clean:
	sudo rm -rf $(BUILDDIR)

clean-config:
	rm -rf $(FAI_CONFIG)

init:
	sudo apt-get update
	sudo apt-get install extrepo
	sudo extrepo enable fai
	sudo apt-get update
	sudo apt-get install fai-client fai-server

profiles: $(FAI_CONFIG)
	@echo "Available profiles:"
	@get-profiles.sh $(FAI_CONFIG) | sort

fai-mirror:
	sudo fai-mirror -C/home/tux/fai-cmds/fai-etc-dir -c"DEMO" -v /mirror/


$(FAI_CONFIG): $(shell find $(FAI_CONFIG_DIR) -type f)
	@echo "Copying FAI configuration..."
	mkdir -p $(BUILDDIR)
	rm -rf $(FAI_CONFIG) || true
	cp -r ${FAI_CONFIG_DIR} $(FAI_CONFIG)

$(FAI_CD_TRIXIE):  $(FAI_CONFIG) $(NFSROOT)
	@echo "Creating FAI CD Trixie ISO..."
	sudo fai-cd -f -C $(FAI_ETC) -M $(BUILDDIR)/fai-cd-trixie.iso

$(FAI_ETC): $(shell find $(FAI_ETC_BASE) -type f)
	@echo "Copying FAI etc directory..."
	mkdir -p $(BUILDDIR)
	rm -rf $(FAI_ETC) || true
	cp -r $(FAI_ETC_BASE) $(BUILDDIR)/

$(NFSROOT): $(FAI_ETC)
	@echo "Make NFS root directory..."	
	sudo fai-make-nfsroot -C $(FAI_ETC) -f

$(BUILDDIR)/live-%.iso: $(FAI_CONFIG) $(FAI_ETC) $(NFSROOT)
	@echo "Creating $* live ISO..."
	rm -f "build/live-$*.iso" || true
	create-live-iso.sh "$*" DUTCH $(PWD)/$(FAI_CONFIG) $(FAI_ETC) $(BUILDDIR)

test-$(BUILDDIR)/live-%.iso: $(BUILDDIR)/live-%.iso
	@echo "Testing live-$*.iso"
	test-iso.sh -i "$(BUILDDIR)/live-$*.iso"

test-$(FAI_CD_TRIXIE): $(FAI_CD_TRIXIE)
	@echo "Testing $(FAI_CD_TRIXIE)"
	test-iso.sh -i $(FAI_CD_TRIXIE)
