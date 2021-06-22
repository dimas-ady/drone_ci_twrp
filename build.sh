#!/bin/sh

abort() { echo "$1"; exit 1; }

cd ~

echo "===+++ Cloning kernel sources +++==="
git clone --depth=1 https://github.com/MiCode/Xiaomi_Kernel_OpenSource -b land-m-oss kernel


echo "===+++ Downloading toolchain +++==="
mkdir toolchain && cd toolchain
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 gcc64
#git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 gcc

echo "===+++ Building kernel +++==="
cd ~/kernel
#export KBUILD_COMPILER_STRING=$($HOME/toolchain/gcc64/bin/aarch64-linux-android-gcc --version | head -n 1)
#export KBUILD_BUILD_USER="HemanthJabalpuri"
export ARCH=arm64
export SUBARCH=arm64

export PATH=$HOME/toolchain/gcc64/bin:$PATH
#export PATH=$HOME/toolchain/gcc64/bin:$HOME/toolchain/gcc:$PATH
#export CROSS_COMPILE_ARM32=$HOME/toolchain/gcc/bin/arm-linux-androideabi-
export CROSS_COMPILE=$HOME/toolchain/gcc64/bin/aarch64-linux-android-

make msm8937_defconfig || abort " make msm8937_defconfig failed with $?"
echo " make msm8937_defconfig done"
make -j$(nproc --all) || abort " make -j$(nproc --all) failed with $?"
echo "make -j$(nproc --all) done"

echo "===+++ Uploading kernel +++==="
curl -T out/arch/arm64/boot/Image.gz-dtb https://oshi.at
