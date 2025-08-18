packer {
  required_plugins {
    qemu = { source = "github.com/hashicorp/qemu", version = ">= 1.0.0" }
  }
}

locals {
  cwd           = path.cwd
  firmware_code = "${local.cwd}/firmware/edk2-aarch64-code.fd"
  firmware_vars = "${local.cwd}/machines/rdns/edk2-aarch64-vars.fd"
  seed_iso      = "${local.cwd}/machines/rdns/seed.iso"
  base_disk     = "${local.cwd}/machines/base/ubuntu-arm64.qcow2"
#  user_data     = "${local.cwd}/machines/rdns/seed/user-data"
#  meta_data     = "${local.cwd}/machines/rdns/seed/meta-data"
}

source "qemu" "arm64" {
  qemu_binary = "qemu-system-aarch64"
  accelerator = "hvf"
  headless    = true
  cpus        = 4
  memory      = 4096

  # Keep these so Packer tracks an artifact, but WE attach drives via qemuargs.
  disk_image   = true
  iso_url      = local.base_disk
  iso_checksum = "sha256:6177a7958f0168e38ca58c13961bdc613d71b9771148add03bc4ad637eb01b8d"
  format       = "qcow2"

  # DO NOT set disk_interface / cd_files / cd_label / cdrom_interface

  # Firmware (let builder add pflash once; don’t also add it in qemuargs)
  # efi_firmware_code = local.firmware_code
  # efi_firmware_vars = local.firmware_vars   # writable copy!
  # use_pflash        = true
  # Pin the host port used for the forward
  host_port_min = 2222
  host_port_max = 2222
  communicator = "ssh"
  ssh_username = "ubuntu"
  # or ssh_private_key_file = "~/.ssh/id_ed25519" if your user-data uses a key
  ssh_password = "ubuntu"
  ssh_host = "127.0.0.1"
  ssh_port = "22"
  ssh_timeout  = "30m"

# qemu-system-aarch64 \
#  -machine virt,highmem=on \
#  -cpu host -smp 4 -m 4096 \
#  -drive if=pflash,format=raw,readonly=on,file=$PWD/firmware/edk2-aarch64-code.fd \
#  -drive if=pflash,format=raw,file=$PWD/firmware/edk2-aarch64-vars.fd \
#  -monitor none \

  qemuargs = [
    # Machine + highmem
    ["-accel","hvf"],
    ["-machine","virt,highmem=on"],
    ["-device","virtio-rng-pci"],  

    ["-drive","if=pflash,format=raw,readonly=on,file=${local.firmware_code}"],
    ["-drive","if=pflash,format=raw,file=${local.firmware_vars}"],

    # A) virtio-blk (your CLI style):
    #   -drive if=none,id=disk0,file=$PWD/machines/$1/ubuntu-arm64.qcow2,format=qcow2 \
    #   -device virtio-blk-pci,drive=disk0,bootindex=0 \
    ["-drive","if=none,id=disk0,file=${local.base_disk},format=qcow2"],
    ["-device","virtio-blk-pci,drive=disk0,bootindex=0"],

    # B) (Alternative) scsi-hd (comment A and use these two instead)
    #   -drive if=none,id=cidata,file=$PWD/machines/$1/seed.iso,format=raw,media=cdrom \
    #   -device virtio-scsi-pci,id=scsi0 \
    #   -device scsi-cd,drive=cidata \
    # cloud-init seed ISO as SCSI CD (exactly like your CLI)
    ["-drive","if=none,id=cidata,file=${local.seed_iso},format=raw,media=cdrom"],
    ["-device","virtio-scsi-pci,id=scsi0"],
    ["-device","scsi-cd,drive=cidata"],

    # (Optional) add bridged NIC in addition to Packer’s user-mode NIC:
    # ["-netdev","vmnet-bridged,id=net0,ifname=en0"],
    # ["-device","virtio-net-pci,netdev=net0"],
    #   -netdev vmnet-bridged,id=net0,ifname=en0 \
    #   -device virtio-net-pci,netdev=net0 \
    
    # user-mode NIC for Packer communicator (hostfwd 2222 -> guest 22)
    # ["-netdev","user,id=user0,hostfwd=tcp::2222-:22"],
    # ["-device","virtio-net-pci,netdev=user0"],
    
    # bridged NIC (optional at build time)
    # ["-netdev","vmnet-bridged,id=net0,ifname=en0"],
    # ["-device","virtio-net-pci,netdev=net0"],

    ["-boot", "order=c"],
    ["-display","none"],
    ["-serial","telnet:127.0.0.1:5555,server,nowait"],
  ]
}

build {
  name    = "ubuntu-arm64-rdns"
  sources = ["source.qemu.arm64"]

  # (optional) add provisioners here...
}