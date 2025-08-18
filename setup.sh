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



# this one works




