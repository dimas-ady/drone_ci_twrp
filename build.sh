#!/bin/sh

export USE_CCACHE=1
ccache -M 50G

apt install openssh-server -y
git clone https://github.com/akhilnarang/scripts.git
cd scripts
bash setup/android_build_env.sh

cd
mkdir work && cd work
repo init -u git://github.com/LineageOS/android.git -b lineage-18.1
repo sync --force-sync -c --no-tags --no-clone-bundle --optimized-fetch --prune -j$(nproc)

git clone --depth=1 https://github.com/HemanthJabalpuri/android_device_realme_RMX2185 -b initial device/realme/RMX2185

source build/envsetup.sh
lunch lineage_RMX2185-eng
mka bacon
