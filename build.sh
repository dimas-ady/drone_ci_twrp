#!/bin/sh

mkdir ~/work

echo "===+++ Cloning kernel sources +++==="
cd ~/work
git clone --depth=1 https://github.com/HemanthJabalpuri/android_kernel_realme_mt6765 -b android-10.0 kernel

echo "===+++ Downloading toolchain +++==="
mkdir toolchain && cd toolchain
git clone --depth=1 https://github.com/kdrag0n/proton-clang

echo "===+++ Building kernel +++==="
cd ~/work/kernel
mkdir out
make O=out ARCH=arm64 RMX2185_defconfig

PATH="$HOME/work/toolchain/bin:${PATH}" \
make O=out \
     ARCH=arm64 \
     CC=clang \
     CROSS_COMPILE=aarch64-linux-gnu- \
     CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
     -j$(nproc --all)

echo "===+++ Uploading kernel +++==="
curl -T out/arch/arm64/boot/Image https://oshi.at
curl -T out/arch/arm64/boot/mtk.dtb https://oshi.at
