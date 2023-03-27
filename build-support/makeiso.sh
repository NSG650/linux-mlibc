#!/bin/sh

set -ex

./jinx host-build limine

dd if=/dev/zero bs=1G count=0 seek=100 of=image.hdd

parted -s image.hdd mklabel gpt

parted -s image.hdd mkpart ESP fat32 2048s 1%
parted -s image.hdd set 1 esp on

parted -s image.hdd mkpart root ext4 1% 100%

USED_LOOPBACK=$(sudo losetup -Pf --show image.hdd)

sudo mkfs.fat -F 32 ${USED_LOOPBACK}p1
sudo mkfs.ext4 ${USED_LOOPBACK}p2

rm -rf sysroot
mkdir -p sysroot
sudo mount ${USED_LOOPBACK}p2 sysroot
sudo mkdir -p sysroot/boot
sudo mount ${USED_LOOPBACK}p1 sysroot/boot

sudo ./jinx sysroot

sudo mkdir -p sysroot/boot/EFI/BOOT
sudo cp -r host-pkgs/limine/usr/local/share/limine/limine.sys sysroot/boot/
sudo cp -r host-pkgs/limine/usr/local/share/limine/BOOTX64.EFI sysroot/boot/EFI/BOOT/

sudo sync
sudo umount sysroot/boot
sudo umount sysroot
sudo losetup -d ${USED_LOOPBACK}

host-pkgs/limine/usr/local/bin/limine-deploy image.hdd
