# Howto use

## Initialize
```
mkdir ~/my-fai
cd ~/my-fai
git clone https://github.com/slspeek/fai-cmds.git
git clone https://github.com/slspeek/fai.git
cd fai-cmds
make init
```

## Create live ISO

### Fast and simple proof of the concept
```
make test-build/live-simpel.iso
```

### Gnome minimaal
```
make build/live-gnome-minimaal.iso
```
### Test this ISO in a virtual machine
```
make test-build/live-gnome-minimaal.iso
```
## Run installer ISO in VM

### With mirror on ISO

```
make test-build/fai-cd-mirror.iso
```
Or just create the ISO
```
make build/fai-cd-mirror.iso
```
### Without mirror
```
make test-build/fai-cd.iso
```
Or just create the ISO
```
make test-build/fai-cd.iso
```

