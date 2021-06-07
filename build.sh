#!/bin/bash
# Just a basic script U can improvise lateron asper ur need xD 

abort() { echo "$1"; exit 1; }

MANIFEST="git://github.com/LineageOS/android.git -b lineage-18.1"
DEVICE=RMX2185
DT_LINK="https://github.com/HemanthJabalpuri/android_device_realme_RMX2185 -b android-10.0"
DT_PATH=device/realme/$DEVICE

echo " ===+++ Setting up Build Environment +++==="
mkdir -p /tmp/recovery
cd /tmp/recovery
apt install openssh-server -y

echo " ===+++ Syncing Recovery Sources +++==="
repo init -u $MANIFEST
repo sync
git clone --depth=1 $DT_LINK $DT_PATH

echo " ===+++ Building Recovery +++==="
rm -rf out
source build/envsetup.sh
echo " source build/envsetup.sh done"
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL="C"
lunch lineage_${DEVICE}-eng || abort " lunch failed with exit status $?"
echo " lunch lineage_${DEVICE}-eng done"
mka recoveryimage || abort " mka failed with exit status $?"
echo " mka recoveryimage done"

# Upload zips & recovery.img (U can improvise lateron adding telegram support etc etc)
echo " ===+++ Uploading Recovery +++==="
OUTFILE=LineageRecovery-${DEVICE}-$(date "+%Y%m%d-%I%M").zip

cd out/target/product/$DEVICE
mv recovery.img ${OUTFILE%.zip}.img
zip -r9 $OUTFILE ${OUTFILE%.zip}.img

curl -T $OUTFILE https://oshi.at
#curl -F "file=@${OUTFILE}" https://file.io
#curl --upload-file $OUTFILE http://transfer.sh/
