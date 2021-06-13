#!/bin/bash
# Just a basic script U can improvise lateron asper ur need xD 

abort() { echo "$1"; exit 1; }

MANIFEST="https://gitlab.com/OrangeFox/Manifest.git -b fox_9.0"
DEVICE=X573
DT_LINK="https://github.com/HemanthJabalpuri/Hot-S3-Infinix-X573-device -b test3"
DT_PATH=device/infinix/$DEVICE

echo " ===+++ Setting up Build Environment +++==="
git clone https://gitlab.com/OrangeFox/misc/scripts
cd scripts
sudo bash setup/android_build_env.sh
sudo bash setup/install_android_sdk.sh

echo " ===+++ Syncing Recovery Sources +++==="
mkdir ~/OrangeFox
cd ~/OrangeFox
repo init --depth=1 -u $MANIFEST
repo sync -j8 --force-sync
git clone --depth=1 $DT_LINK $DT_PATH

echo " ===+++ Building Recovery +++==="
rm -rf out
source build/envsetup.sh
echo " source build/envsetup.sh done"

# Flags
version=$(cat bootable/recovery/variables.h | grep "define FOX_MAIN_VERSION_STR" | cut -d \" -f2)
export OF_DISABLE_MIUI_SPECIFIC_FEATURES=1
export OF_MAINTAINER="HemanthJabalpuri"
export FOX_VERSION="${version}_0"
export FOX_BUILD_TYPE="test"
export FOX_REMOVE_AAPT=1
export FOX_DELETE_INITD_ADDON=1
export FOX_DELETE_AROMAFM=1
export FOX_DELETE_MAGISK_ADDON=1

export ALLOW_MISSING_DEPENDENCIES=true
export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1
export LC_ALL="C"
lunch omni_${DEVICE}-eng || abort " lunch failed with exit status $?"
echo " lunch omni_${DEVICE}-eng done"
mka recoveryimage || abort " mka failed with exit status $?"
echo " mka recoveryimage done"

# Upload zips & recovery.img (U can improvise lateron adding telegram support etc etc)
echo " ===+++ Uploading Recovery +++==="
cd out/target/product/$DEVICE
ofoxzip="$(ls *.zip)"
curl -T $ofoxzip https://oshi.at
#curl -F "file=@${ofoxzip}" https://file.io
#curl --upload-file $ofoxzip http://transfer.sh/
