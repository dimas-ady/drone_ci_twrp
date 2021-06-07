#!/bin/sh

mkdir ~/work

echo "===+++ Cloning kernel sources +++==="
cd ~/work
git clone --depth=1 https://github.com/HemanthJabalpuri/android_kernel_realme_mt6765 -b android-10.0 kernel

echo "===+++ Downloading toolchain +++==="
cd ~/work
git clone --depth=1 https://github.com/techyminati/android_prebuilts_clang_host_linux-x86_clang-5484270 -b 9.0.3 toolchain

echo "===+++ Building kernel +++==="
cd ~/work/kernel
mkdir out
make O=out ARCH=arm64 oppo6765_defconfig

echo "===+++ Compiling... +++==="
PATH=$HOME/work/toolchain/bin:$PATH \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi-
