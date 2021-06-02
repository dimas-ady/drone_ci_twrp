#!/bin/sh

mkdir ~/work

echo "===+++ Cloning kernel sources +++==="
cd ~/work
git clone --depth=1 https://github.com/HemanthJabalpuri/android_kernel_realme_mt6765 -b android-10.0 kernel

echo "===+++ Downloading toolchain +++==="
mkdir ~/work/toolchain && cd ~/work/toolchain
wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/ee5ad7f5229892ff06b476e5b5a11ca1f39bf3a9/clang-r365631c.tar.gz -O clang.tar.gz
tar zxvf clang.tar.gz
rm -f clang.tar.gz

echo "===+++ Building kernel +++==="
cd ~/work/kernel
echo "Start of ls output"
ls
echo "End of ls output"
mkdir out
make O=out ARCH=arm64 RMX2185_defconfig

echo "===+++ Compiling... +++==="
PATH=$HOME/work/toolchain/bin:$PATH \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi-
