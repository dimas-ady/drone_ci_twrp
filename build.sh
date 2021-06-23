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
mkdir -p ~/OrangeFox_
cd ~/OrangeFox
apt install openssh-server -y
git clone https://gitlab.com/OrangeFox/misc/scripts
cd scripts
sudo bash setup/android_build_env.sh
sudo bash setup/install_android_sdk.sh

msg "Syncing Recovery Source"
cd ~/OrangeFox
repo init -u https://gitlab.com/OrangeFox/Manifest.git -b fox_9.0
repo sync -j$(nproc --all) --force-sync
cd ~/OrangeFox
ls
git clone --depth=1 $DT_LINK $DT_PATH

msg "Building Recovery"
rm -rf out
ls
source build/envsetup.sh
msg "source build/envsetup.sh done"
export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL="C"
lunch omni_${DEVICE}-eng || abort " lunch failed with exit status $?"
msg "lunch omni_${DEVICE}-eng done"
tg_post_msg "<b>Recovery build triggered!</b>"
mka recoveryimage || abort " mka failed with exit status $?"
msg "mka recoveryimage done"

# Upload zips & recovery.img (U can improvise lateron adding telegram support etc etc)
if [ -f "out/target/product/$DEVICE/recovery.img" ]
then
  msg "Uploading Recovery"
  version=$(cat bootable/recovery/variables.h | grep "define FOX_MAIN_VERSION_STR" | cut -d \" -f2)
  OUTFILE=TWRP-${version}-${DEVICE}-$(date "+%Y%m%d-%I%M")

  cd out/target/product/$DEVICE

  msg "Upload started"
  tg_post_build "recovery.img"  "$CHATID" "Recovery Build Succesfull! | Name : <code>$OUTFILE</code>" 
else
  tg_post_msg "<b>Recovery build failed!</b>"
fi