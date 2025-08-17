###############

# install qemu
brew install qemu
mkdir -p ~/vm/ubuntu
cd ~/vm/ubuntu

# create writable NVRAM
truncate -s $(stat -f%z /opt/homebrew/share/qemu/edk2-aarch64-code.fd) edk2-vars.fd

# get ubuntu image, convert to qcow2 and resize
curl -L -o ubuntu-arm64.img \
  https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64.img

qemu-img convert -f qcow2 -O qcow2 ubuntu-arm64.img ubuntu.qcow2
qemu-img resize ubuntu.qcow2 +30G   # grow disk (optional)

# build iso image for cloud-init seed data
hdiutil makehybrid -o seed.iso seed -iso -joliet -default-volume-name cidata

# this one works
sudo /bin/sh -c 'qemu-system-aarch64 \
  -accel hvf \
  -machine virt,highmem=on \
  -cpu host -smp 4 -m 4096 \
  -drive if=pflash,format=raw,readonly=on,file=/opt/homebrew/share/qemu/edk2-aarch64-code.fd \
  -drive if=pflash,format=raw,file=$PWD/edk2-vars.fd \
  -drive if=none,id=disk0,file=ubuntu-arm64.img,format=qcow2 \
  -device virtio-blk-pci,drive=disk0,bootindex=0 \
  -drive if=none,id=cidata,file=$PWD/seed.iso,format=raw,media=cdrom \
  -device virtio-scsi-pci,id=scsi0 \
  -device scsi-cd,drive=cidata \
  -drive if=none,id=disk1,file=$PWD/ubuntu.qcow2,format=qcow2 \
  -netdev vmnet-bridged,id=net0,ifname=en0 \
  -device virtio-net-pci,netdev=net0 \
  -boot order=c \
  -display none \
  -monitor none \
</dev/null >qemu.log 2>&1 &
echo $! > qemu.pid
disown'




  -display none \
  -serial telnet:127.0.0.1:5000,server,nowait \
  -monitor unix:$PWD/qemu-monitor.sock,server,nowait \
  -pidfile $PWD/qemu.pid \
  -daemonize


  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -device virtio-net-pci,netdev=net0 \