#!/bin/bash
# Just a basic script U can improvise lateron asper ur need xD 

msg() { 
  echo -e "\e[1;32m// $* //\e[0m"
}
abort() { echo "$1"; exit 1; }

MANIFEST="https://gitlab.com/OrangeFox/Manifest.git -b fox_9.0"
DEVICE=X00TD
DT_LINK="https://github.com/dimas-ady/twrp_device_asus_X00TD.git -b fox_9.0"
DT_PATH=device/asus/$DEVICE
token=$TELEGRAM_TOKEN
CHATID="-1001328821526"
BOT_MSG_URL="https://api.telegram.org/bot$token/sendMessage"
BOT_BUILD_URL="https://api.telegram.org/bot$token/sendDocument"
MAGISK="https://github.com/topjohnwu/Magisk/releases/download/v23.0/Magisk-v23.0.apk"
MAINTAINER_AVATAR="https://avatars.githubusercontent.com/dimas-ady"

tg_post_msg() {
	curl -s -X POST "$BOT_MSG_URL" -d chat_id=$CHATID \
	-d "disable_web_page_preview=true" \
	-d "parse_mode=html" \
	-d text="$1"
}
  
tg_post_build() {
	#Post MD5Checksum alongwith for easeness
	#msg "Checking MD5sum..."
	#MD5CHECK=$(md5sum "$1" | cut -d' ' -f1)
	MD5CHECK=$(cat $1.md5)

	#Show the Checksum alongwith caption
	curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
	-F chat_id="$2"  \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=html" \
	-F caption="$3 | <b>MD5 Checksum : </b><code>$MD5CHECK</code>"  
}

mkdir ~/tempfolder
msg "Setting up Build Environment"
apt install openssh-server openjdk-8-jdk -y
apt update --fix-missing
apt install openssh-server openjdk-8-jdk -y
git clone https://gitlab.com/OrangeFox/misc/scripts
cd scripts
sudo bash setup/android_build_env.sh
sudo bash setup/install_android_sdk.sh

msg "Syncing Recovery Source"
mkdir ~/OrangeFox
cd ~/OrangeFox
repo init --depth=1 -u $MANIFEST
repo sync -j$(nproc --all) --force-sync
git clone --depth=1 $DT_LINK $DT_PATH

msg "Building Recovery"
rm -rf out
ls
source build/envsetup.sh
msg "source build/envsetup.sh done"
version=$(cat bootable/recovery/variables.h | grep "define FOX_MAIN_VERSION_STR" | cut -d \" -f2)
wget -O ~/OrangeFox/Magisk.zip $MAGISK
wget -O ~/tempfolder/avatar.png $MAINTAINER_AVATAR
export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL="C"
export FOX_DISABLE_APP_MANAGER=1
export FOX_VERSION="${version}_0"
export OF_MAINTAINER="Dimas Adiyaksa - XZXZ Project"
export OF_MAINTAINER_AVATAR="$HOME/tempfolder/avatar.png"
export FOX_USE_SPECIFIC_MAGISK_ZIP="$HOME/OrangeFox/Magisk.zip"
lunch omni_${DEVICE}-eng || abort " lunch failed with exit status $?"
msg "lunch omni_${DEVICE}-eng done"
tg_post_msg "<b>Recovery build triggered!</b>"
mka recoveryimage || abort " mka failed with exit status $?"
msg "mka recoveryimage done"

# Upload zips & recovery.img (U can improvise lateron adding telegram support etc etc)
if [ -f "out/target/product/$DEVICE/recovery.img" ]
then
  msg "Uploading Recovery"
  OUTFILE=OrangeFox-${FOX_VERSION}-${DEVICE}-$(date "+%Y%m%d-%I%M")

  cd out/target/product/$DEVICE
  ofoxzip="OrangeFox-$FOX_VERSION-Unofficial-$DEVICE.zip"

  msg "Upload started"
  tg_post_build "$ofoxzip"  "$CHATID" "Recovery Build Succesfull! | Name : <code>$OUTFILE</code>" 
else
  tg_post_msg "<b>Recovery build failed!</b>"
fi