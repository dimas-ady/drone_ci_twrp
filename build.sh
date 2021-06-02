#!/bin/sh

mkdir ~/work

echo "===+++ Cloning kernel sources +++==="
cd ~/work
git clone --depth=1 https://github.com/HemanthJabalpuri/android_kernel_realme_mt6765 -b android-10.0 kernel

echo "===+++ Downloading toolchain +++==="
mkdir ~/work/toolchain && cd ~/work/toolchain
wget https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/84fb09fafc92a3d9b4d160f049d46c3c784cc941.tar.gz -O gcc.tar.gz
tar zxvf gcc.tar.gz
rm -f gcc.tar.gz

echo "===+++ Building kernel +++==="
cd ~/work/kernel
mkdir out
export ARCH=arm64
export CROSS_COMPILE=$HOME/toolchain/bin/aarch64-linux-android-
make O=out RMX2185_defconfig
make O=out -j$(nproc --all)
