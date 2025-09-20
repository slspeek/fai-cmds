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

```
make test-build/fai-cd.iso
```
Or just create the ISO
```
make test-build/fai-cd.iso
```

## Test the creation of all ISOs

```
make clean
time make all LENIENT=0 2>&1 | tee make-all-NOT-LENIENT.log
```
Requires 50Gb disk space and at least one hour.
