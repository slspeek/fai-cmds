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
FAI_CD=$(BUILDDIR)/fai-cd.iso
FAI_CD_MIRROR=$(BUILDDIR)/fai-cd-mirror.iso
MIRROR=$(BUILDDIR)/mirror
GNOME_LIVE=$(BUILDDIR)/live-GNOME_CORE.iso

.PHONY: clean clean-config init profiles all-live-isos test-%

clean:
	sudo rm -rf $(BUILDDIR)

clean-config:
	rm -rf $(FAI_CONFIG)

init:
	sudo apt-get update
	sudo apt-get install --yes extrepo virtinst virt-viewer reprepro squashfs-tools libvirt-daemon
	sudo extrepo enable fai
	sudo apt-get update
	sudo apt-get install --yes fai-client fai-server libgraph-perl

profiles: $(FAI_CONFIG)
	@get-profiles.sh $(FAI_CONFIG) | sort

.ONESHELL:
$(MIRROR): $(FAI_CONFIG) $(FAI_ETC)
	ALL_CLASSES_WITH_PACAKGES=$$(find $(FAI_CONFIG)/package_config -type f -printf '%f\n'|grep -v .gpg|sort)
	EXCLUDED_CLASSES=(FIREFOX GOOGLE_CHROME GAMES MATTERMOST VSCODE)
	MIRROR_CLASSES=$$(for CLASS in $$ALL_CLASSES_WITH_PACAKGES; do \
		if  ! [[ " $${EXCLUDED_CLASSES[@]} " =~ " $${CLASS} " ]]; then
			echo $$CLASS;
		fi
	done|tr '\n' ','|sed 's/,$$//')
	echo "Mirroring classes: $$MIRROR_CLASSES"
	fai-mirror -C$(FAI_ETC) -c$$MIRROR_CLASSES -v $(PWD)/$(MIRROR)

$(FAI_CONFIG): $(shell find $(FAI_CONFIG_DIR) -type f)
	@echo "Copying FAI configuration..."
	mkdir -p $(BUILDDIR)
	rm -rf $(FAI_CONFIG) || true
	cp -r ${FAI_CONFIG_DIR} $(FAI_CONFIG)

$(FAI_CD):  $(FAI_CONFIG) $(NFSROOT)
	@echo "Creating FAI CD ISO..."
	sudo fai-cd -f -C $(FAI_ETC) -M $(FAI_CD)

$(FAI_CD_MIRROR):  $(FAI_CONFIG) $(NFSROOT) $(MIRROR)
	@echo "Creating FAI CD Mirror ISO..."
	sudo fai-cd -f -C $(FAI_ETC) -m $(PWD)/$(MIRROR) $(FAI_CD_MIRROR)

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

test-$(FAI_CD): $(FAI_CD)
	@echo "Testing $(FAI_CD)"
	test-iso.sh -i $(FAI_CD)

test-$(FAI_CD_MIRROR): $(FAI_CD_MIRROR)
	@echo "Testing $(FAI_CD_MIRROR)"
	test-iso.sh -i $(FAI_CD_MIRROR)

.ONESHELL:
all-live-isos:
	@for PROFILE in $$($(MAKE) --no-print-directory profiles 2>/dev/null| cut -d: -f1); do 
		$(MAKE) "$(BUILDDIR)/live-$$PROFILE.iso"; 
	done

all: all-live-isos $(FAI_CD) $(FAI_CD_MIRROR)
