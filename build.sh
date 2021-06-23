#!/bin/bash
# Just a basic script U can improvise lateron asper ur need xD 

msg() { 
  echo -e "\e[1;32m// $* //\e[0m"
}
abort() { echo "$1"; exit 1; }

MANIFEST="git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0"
DEVICE=X00TD
DT_LINK="https://github.com/dimas-ady/twrp_device_asus_X00TD.git"
DT_PATH=device/asus/$DEVICE
token=$TELEGRAM_TOKEN
CHATID="-1001328821526"
BOT_MSG_URL="https://api.telegram.org/bot$token/sendMessage"
BOT_BUILD_URL="https://api.telegram.org/bot$token/sendDocument"


tg_post_msg() {
	curl -s -X POST "$BOT_MSG_URL" -d chat_id=$CHATID \
	-d "disable_web_page_preview=true" \
	-d "parse_mode=html" \
	-d text="$1"
}
  
tg_post_build() {
	#Post MD5Checksum alongwith for easeness
	msg "Checking MD5sum..."
	MD5CHECK=$(md5sum "$1" | cut -d' ' -f1)

	#Show the Checksum alongwith caption
	curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
	-F chat_id="$2"  \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=html" \
	-F caption="$3 | <b>MD5 Checksum : </b><code>$MD5CHECK</code>"  
}

msg "Setting up Build Environment"
mkdir -p /tmp/recovery
cd /tmp/recovery
apt install openssh-server -y
apt update --fix-missing
apt install openssh-server -y

msg "Syncing Recovery Source"
repo init --depth=1 -u $MANIFEST -g default,-device,-mips,-darwin,-notdefault 
repo sync -j$(nproc --all)
git clone --depth=1 $DT_LINK $DT_PATH

msg "Building Recovery"
rm -rf out
source build/envsetup.sh
msg "source build/envsetup.sh done"
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL="C"
lunch omni_${DEVICE}-eng || abort " lunch failed with exit status $?"
msg "lunch omni_${DEVICE}-eng done"
tg_post_msg "<b>Recovery build triggered!</b>"
mka recoveryimage || abort " mka failed with exit status $?"
msg "mka recoveryimage done"

# Upload zips & recovery.img (U can improvise lateron adding telegram support etc etc)
if [ -f "out/target/product/$DEVICE" ]
then
  msg "Uploading Recovery"
  version=$(cat bootable/recovery/variables.h | grep "define TW_MAIN_VERSION_STR" | cut -d \" -f2)
  OUTFILE=TWRP-${version}-${DEVICE}-$(date "+%Y%m%d-%I%M")

  cd out/target/product/$DEVICE

  msg "Upload started"
  tg_post_build "recovery.img"  "$CHATID" "Recovery Build Succesfull! | Name : <code>$OUTFILE</code>" 
else
  tg_post_msg "<b>Recovery build failed!</b>"
fi