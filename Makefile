SHELL=/bin/bash
export PATH:=$(PWD)/bin:$(PATH)

BUILDDIR=build
FAI_CONFIG_SRC=https://github.com/slspeek/fai.git
FAI_CONFIG=$(BUILDDIR)/fai-config
FAI_ETC_BASE=fai-etc-dir
FAI_ETC=$(BUILDDIR)/$(FAI_ETC_BASE)
NFSROOT=$(BUILDDIR)/nfsroot

.PHONY: clean init

clean:
	sudo rm -rf $(BUILDDIR)

init:
	sudo apt-get update
	sudo apt-get install extrepo
	sudo extrepo enable fai
	sudo apt-get update
	sudo apt-get install fai-client fai-server

$(BUILDDIR)/fai-cd-trixie.iso: $(NFSROOT)
	sudo fai-cd -C $(FAI_ETC) -M  $(BUILDDIR)/fai-cd-trixie.iso

$(FAI_CONFIG): 
	@echo "Cloning FAI configuration repository..."
	git clone --depth 1 $(FAI_CONFIG_SRC) $(FAI_CONFIG)

$(FAI_ETC): $(FAI_ETC_BASE)
	@echo "Copying FAI etc directory..."
	mkdir -p $(BUILDDIR)
	cp -rv $(FAI_ETC_BASE) $(BUILDDIR)/

$(NFSROOT): $(FAI_CONFIG) $(FAI_ETC)
	@echo "Make NFS root directory..."	
	sudo fai-make-nfsroot -C $(FAI_ETC) -f