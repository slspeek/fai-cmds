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

## Run a live ISO in a VM

### Fast and simple proof of the concept
```
make test-build/live-simpel.iso
```

### Gnome minimaal
```
make test-build/live-gnome-minimaal.iso
```
Or just create the ISO:
```
make build/live-gnome-minimaal.iso
```
## Run installer ISO in VM

### Without mirror
```
make test-build/fai-cd.iso
```
Or just create the ISO
```
make test-build/fai-cd.iso
```

### With mirror on ISO
```
make test-build/fai-cd-mirror.iso
```
Or just create the ISO
```
make build/fai-cd-mirror.iso
```


