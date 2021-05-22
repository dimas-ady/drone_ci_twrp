#!/bin/bash
# Just a basic script U can improvise lateron asper ur need xD 

MANIFEST="git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-10.0"
DEVICE=RMX2185
DT_LINK="https://github.com/HemanthJabalpuri/android_recovery_realme_RMX2185"
DT_PATH=device/realme/$DEVICE
TARGET=recoveryimage
OUTFILE=OFox-${DEVICE}.zip

echo " ===+++ Setting up Build Environment +++==="
mkdir -p ~/OrangeFox_10
cd ~/OrangeFox_10
apt install openssh-server -y
git clone https://gitlab.com/OrangeFox/misc/scripts
cd scripts
sudo bash setup/android_build_env.sh
sudo bash setup/install_android_sdk.sh

echo " ===+++ Syncing Recovery Sources +++==="
cd ~/OrangeFox_10
git clone https://gitlab.com/OrangeFox/sync.git
cd sync
echo 'y' | ./get_fox_10.sh ~/OrangeFox_10/fox_10.0
cd ~/OrangeFox_10/fox_10.0
git clone --depth=1 $DT_LINK $DT_PATH

echo " ===+++ Building Recovery +++==="
export OF_KEEP_DM_VERITY=1
export OF_QUICK_BACKUP_LIST="/boot;/data;"
export OF_SCREEN_H=2400
export OF_HIDE_NOTCH=1
export OF_FLASHLIGHT_ENABLE=0
export OF_USE_MAGISKBOOT=1
export OF_USE_MAGISKBOOT_FOR_ALL_PATCHES=1
export OF_DONT_PATCH_ENCRYPTED_DEVICE=1
export OF_NO_TREBLE_COMPATIBILITY_CHECK=1
export OF_SUPPORT_OZIP_DECRYPTION=1
export OF_FIX_OTA_UPDATE_MANUAL_FLASH_ERROR=1
export OF_DISABLE_MIUI_SPECIFIC_FEATURES=1
export OF_SKIP_MULTIUSER_FOLDERS_BACKUP=1

export OF_MAINTAINER="HemanthJabalpuri"
export FOX_R11=1
export FOX_VERSION="R11.1_0"
export FOX_BUILD_TYPE="test"
export FOX_INSTALLER_DEBUG_MODE=1
export FOX_RESET_SETTINGS="disabled"
export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1
export FOX_RECOVERY_INSTALL_PARTITION="/dev/block/by-name/recovery"
export FOX_RECOVERY_SYSTEM_PARTITION="/dev/block/mapper/system"
export FOX_RECOVERY_VENDOR_PARTITION="/dev/block/mapper/vendor"
export FOX_EXCLUDE_NANO_EDITOR=1
export FOX_REMOVE_BASH=1
export FOX_DELETE_AROMAFM=1
#export FOX_DELETE_MAGISK_ADDON=1
export FOX_USE_SPECIFIC_MAGISK_ZIP="$HOME/OrangeFox_10/Magisk.zip"
export FOX_DELETE_INITD_ADDON=1

wget -O ~/OrangeFox_10/Magisk.zip https://github.com/topjohnwu/Magisk/releases/download/v23.0/Magisk-v23.0.apk

rm -rf out
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true 
export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1 
export LC_ALL="C"
lunch omni_${DEVICE}-eng && mka $TARGET

# Upload zips & recovery.img (U can improvise lateron adding telegram support etc etc)
echo " ===+++ Uploading Recovery +++==="
cd out/target/product/$DEVICE

transferFile() {
  echo " Uploading $1"
  curl -T $1 https://oshi.at
  if [ $? != 0 ]; then
    if ! [ -f transfer ]; then
      curl -sL https://git.io/file-transfer | sh
    fi
    ./transfer wet $1
    if [ $? != 0 ]; then
      #https://github.com/dutchcoders/transfer.sh/issues/116
      curl --upload-file $1 http://transfer.sh/$OUTFILE
    fi
  fi
}

for i in *.zip; do
  transferFile $i
done
