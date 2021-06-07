#!/bin/sh

mkdir ~/work

echo "===+++ Cloning kernel sources +++==="
cd ~/work
git clone --depth=1 https://github.com/HemanthJabalpuri/android_kernel_realme_mt6765 -b android-10.0 kernel

echo "===+++ Downloading toolchain +++==="
mkdir toolchain && cd toolchain
git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 clang
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 los-4.9-64
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 los-4.9-32

echo "===+++ Building kernel +++==="
cd ~/work/kernel
mkdir out
export LC_ALL=C
make O=out ARCH=arm64 oppo6765_defconfig

echo "===+++ Compiling... +++==="
PATH="$HOME/work/toolchain/clang/clang-r353983c/bin:${PATH}:$HOME/work/toolchain/los-4.9-32/bin:${PATH}:$HOME/work/toolchain/los-4.9-64/bin:${PATH}" \
make O=out \
     ARCH=arm64 \
     CC="ccache clang" \
     CLANG_TRIPLE=aarch64-linux-gnu- \
     CROSS_COMPILE="$HOME/work/toolchain/los-4.9-64/bin/aarch64-linux-android-" \
     CROSS_COMPILE_ARM32="$HOME/work/toolchain/los-4.9-32/bin/arm-linux-androideabi-" \
     CONFIG_NO_ERROR_ON_MISMATCH=y \
     -j8

