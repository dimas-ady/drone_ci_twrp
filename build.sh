#!/bin/bash
# Just a basic script U can improvise lateron asper ur need xD 

MANIFEST="git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-10.0"
DEVICE=RMX2185
DT_LINK="https://github.com/HemanthJabalpuri/android_recovery_realme_RMX2185"
DT_PATH=device/realme/$DEVICE
TARGET=recoveryimage
OUTFILE=OFox-${DEVICE}.zip

echo " ===+++ Setting up Build Environment +++==="
mkdir -p /tmp/recovery
cd /tmp/recovery
apt install openssh-server -y
git clone https://gitlab.com/OrangeFox/misc/scripts
cd scripts
sudo bash setup/android_build_env.sh
sudo bash setup/install_android_sdk.sh

echo " ===+++ Syncing Recovery Sources +++==="
git clone https://gitlab.com/OrangeFox/sync.git
cd sync
echo 'y' | ./get_fox_10.sh fox_10.0
cd fox_10.0
git clone --depth=1 $DT_LINK $DT_PATH

echo " ===+++ Building Recovery +++==="
rm -rf out
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true 
export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1 
export LC_ALL="C"
lunch omni_${DEVICE}-eng && mka $TARGET

# Upload zips & recovery.img (U can improvise lateron adding telegram support etc etc)
echo " ===+++ Uploading Recovery +++==="
cd out/target/product/$DEVICE
zip -r9 $OUTFILE recovery.img
curl -sL https://git.io/file-transfer | sh 
./transfer wet $OUTFILE
if [ $? != 0 ]; then
  curl -T ./$OUTFILE https://oshi.at
  if [ $? != 0 ]; then
    #https://github.com/dutchcoders/transfer.sh/issues/116
    curl --upload-file ./$OUTFILE http://transfer.sh/$OUTFILE
  fi
fi
