#!/bin/sh

mkdir ~/work

# Clone kernel sources
mkdir ~/work/kernel && cd ~/work/kernel
git clone --depth=1 https://github.com/HemanthJabalpuri/android_kernel_realme_mt6765 -b android-10.0

# Download toolchain
mkdir ~/work/toolchain && cd ~/work/toolchain
wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/tags/android-10.0.0_r47/clang-r353983c.tar.gz -O clang-r353983c.tar.gz
tar zxvf clang-r353983c.tar.gz
rm -f clang-r353983c.tar.gz

# Build kernel
cd ~/work/kernel
mkdir out
export ARCH=arm64
make O=out ARCH=arm64 RMX2185_defconfig
export PATH=$HOME/toolchain/bin:$PATH
make O=out \
     ARCH=arm64 \
     CC=clang \
     CROSS_COMPILE=aarch64-linux-gnu- \
     CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
     -j8 
