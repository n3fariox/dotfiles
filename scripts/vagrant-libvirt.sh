#!/bin/bash
set -e  # error on first problem
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. "$THIS_DIR/check-sudo.sh"

$SUDO apt install \
    qemu qemu-kvm cpu-checker virt-manager virt-viewer \
    libvirt-daemon-system libvirt-clients bridge-utils

# NOTE: groups are already there after instal Ubuntu 18.04+
$SUDO usermod -aG libvirt "$(whoami)"
$SUDO usermod -aG libvirt-qemu "$(whoami)"
$SUDO usermod -aG kvm "$(whoami)"

# docker pull vagrantlibvirt/vagrant-libvirt:latest

mkdir -p ~/.vagrant.d/{boxes,data,tmp}

. "$THIS_DIR/utils.sh"

# ALIAS_CMD="alias vagrant='
#   mkdir -p ~/.vagrant.d/{boxes,data,tmp}; \
#   docker run -it --rm \
#     -e LIBVIRT_DEFAULT_URI \
#     -v /var/run/libvirt/:/var/run/libvirt/ \
#     -v ~/.vagrant.d:/.vagrant.d \
#     -v $(pwd):$(pwd) \
#     -w $(pwd) \
#     --network host \
#     vagrantlibvirt/vagrant-libvirt:latest \
#     vagrant'
# "
# TODO: somehow make this the multiline above
ALIAS_CMD="alias vagrant='mkdir -p ~/.vagrant.d/{boxes,data,tmp}; docker run -it --rm -e LIBVIRT_DEFAULT_URI -v /var/run/libvirt/:/var/run/libvirt/ -v ~/.vagrant.d:/.vagrant.d -v $(pwd):$(pwd) -w $(pwd) --network host vagrantlibvirt/vagrant-libvirt:latest vagrant'"
# from utils.sh
append_line 1 "$ALIAS_CMD" ~/.bashrc


echo "
Fully logout/reboot to apply groups
Best to use the docker vagrant for libvirt:
    docker pull vagrantlibvirt/vagrant-libvirt:latest

'vagrant' alias has been added to bashrc
"
