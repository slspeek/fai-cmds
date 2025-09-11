SHELL=/bin/bash
export PATH:=$(PWD)/bin:$(PATH)

LENIENT=1
export LENIENT


FAI_CD_LIVE_OPTS=
export FAI_CD_LIVE_OPTS

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

.PHONY: clean init profiles

.PRECIOUS: $(BUILDDIR)/live-%.iso $(FAI_CD) $(FAI_CD_MIRROR) $(MIRROR) 

clean:
	sudo rm -rf $(BUILDDIR)

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
	@mkdir -p $(BUILDDIR)
	@rm -rf $(FAI_CONFIG) || true
	@cp -r ${FAI_CONFIG_DIR} $(FAI_CONFIG)

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
	create-live-iso.sh "$*" DUTCH $(PWD)/$(FAI_CONFIG) $(FAI_ETC) $(BUILDDIR)

test-$(BUILDDIR)/live-%.iso: $(BUILDDIR)/live-%.iso
	@echo "Testing live-$*.iso"
	test-iso.sh -l -i "$(BUILDDIR)/live-$*.iso"

test-$(FAI_CD): $(FAI_CD)
	@echo "Testing $(FAI_CD)"
	test-iso.sh -i $(FAI_CD)

test-$(FAI_CD_MIRROR): $(FAI_CD_MIRROR)
	@echo "Testing $(FAI_CD_MIRROR)"
	test-iso.sh -i $(FAI_CD_MIRROR)

.ONESHELL:
all-live-isos:
	@for PROFILE in $$($(MAKE) --no-print-directory profiles| cut -d: -f1); do 
		echo "Building live-$$PROFILE.iso"
		if [ "$$PROFILE" = "gnome-compleet" ]; then 
			$(MAKE) "$(BUILDDIR)/live-$$PROFILE.iso" FAI_CD_LIVE_OPTS="-s1000" || exit 1; 
		else 
			$(MAKE) "$(BUILDDIR)/live-$$PROFILE.iso" || exit 1;
		fi 
	done

all: all-live-isos $(FAI_CD) $(FAI_CD_MIRROR)
