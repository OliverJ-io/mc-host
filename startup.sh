#!/bin/sh

qemu-system-aarch64 \
  -accel hvf \
  -machine virt,highmem=on \
  -cpu host -smp 4 -m 4096 \
  -drive if=pflash,format=raw,readonly=on,file=/opt/homebrew/share/qemu/edk2-aarch64-code.fd \
  -drive if=pflash,format=raw,file=$PWD/edk2-vars.fd \
  -drive if=none,id=disk0,file=ubuntu-arm64.img,format=qcow2 \
  -device virtio-blk-pci,drive=disk0,bootindex=0 \
  -drive if=none,id=cidata,file=$PWD/seed-$1.iso,format=raw,media=cdrom \
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
disown