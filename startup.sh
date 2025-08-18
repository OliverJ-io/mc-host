#!/bin/sh

qemu-system-aarch64 \
  -accel hvf \
  -machine virt,highmem=on \
  -cpu host -smp 4 -m 4096 \
  -drive if=pflash,format=raw,readonly=on,file=$PWD/firmware/edk2-aarch64-code.fd \
  -drive if=pflash,format=raw,file=$PWD/machines/$1/edk2-aarch64-vars.fd \
  -drive if=none,id=disk0,file=$PWD/machines/$1/ubuntu-arm64.qcow2,format=qcow2 \
  -device virtio-blk-pci,drive=disk0,bootindex=0 \
  -drive if=none,id=cidata,file=$PWD/machines/$1/seed.iso,format=raw,media=cdrom \
  -device virtio-scsi-pci,id=scsi0 \
  -device scsi-cd,drive=cidata \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -device virtio-net-pci,netdev=net0 \
  -boot order=c \
  -display none \
  -monitor none \
</dev/null >$PWD/machines/$1/qemu.log 2>&1 &
echo $! > $PWD/machines/$1/qemu.pid
disown