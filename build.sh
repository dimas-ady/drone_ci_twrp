#!/bin/bash
# Just a basic script U can improvise lateron asper ur need xD 

abort() { echo "$1"; exit 1; }

MANIFEST="git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0"
DEVICE=X573
DT_LINK="https://github.com/HemanthJabalpuri/Hot-S3-Infinix-X573-device -b test2"
DT_PATH=device/infinix/$DEVICE

echo " ===+++ Setting up Build Environment +++==="
mkdir -p /tmp/recovery
cd /tmp/recovery
apt install openssh-server openjdk-8-jdk -y
apt update --fix-missing
apt install openssh-server openjdk-8-jdk -y

echo " ===+++ Syncing Recovery Sources +++==="
repo init --depth=1 -u $MANIFEST -g default,-device,-mips,-darwin,-notdefault 
repo sync -j$(nproc --all)
git clone --depth=1 $DT_LINK $DT_PATH

echo " ===+++ Building Recovery +++==="
rm -rf out
source build/envsetup.sh
echo " source build/envsetup.sh done"
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL="C"
lunch omni_${DEVICE}-eng || abort " lunch failed with exit status $?"
echo " lunch omni_${DEVICE}-eng done"
mka recoveryimage || abort " mka failed with exit status $?"
echo " mka recoveryimage done"

echo " ===+++ Signing Recovery +++==="
version=$(cat bootable/recovery/variables.h | grep "define TW_MAIN_VERSION_STR" | cut -d \" -f2)
OUTFILE=TWRP-${version}-${DEVICE}-$(date "+%Y%m%d-%I%M")-signed

cd out/target/product/$DEVICE
git clone https://github.com/HemanthJabalpuri/boot_signer
java -jar boot_signer/boot_signer.jar /recovery recovery.img boot_signer/verity.pk8 boot_signer/verity.x509.pem ${OUTFILE}.img

# Upload zips & recovery.img (U can improvise lateron adding telegram support etc etc)
echo " ===+++ Uploading Recovery +++==="
zip -r9 ${OUTFILE}.zip ${OUTFILE}.img
curl -T ${OUTFILE}.zip https://oshi.at
#curl -F "file=@${OUTFILE}.zip" https://file.io
#curl --upload-file ${OUTFILE}.zip http://transfer.sh/
