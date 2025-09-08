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

### Gnome minimaal
```
make build/live-gnome-minimaal.iso
```

## Create installer ISO

### With mirror on ISO

```
make build/fai-cd-mirror.iso
```

### Without mirror
```
make build/fai-cd.iso
```

