#!/bin/bash
#
# Cronos Build Script
# For Exynos7870
# Coded by BlackMesa/AnanJaser1211 @2018
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software

# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Directory Contol
CR_DIR=$(pwd)
CR_TC=/home/ananjaser/Desktop/ToolChain/UBERTC-aarch64-linux-android-6.0/bin/aarch64-linux-android-
CR_DTS=arch/arm64/boot/dts
CR_OUT=$CR_DIR/rf-tools/out
CR_AIK=$CR_DIR/rf-tools/AIK-Linux
CR_RAMDISK=$CR_DIR/rf-tools/Unified
CR_KERNEL=$CR_DIR/arch/arm64/boot/Image
CR_DTB=$CR_DIR/boot.img-dtb
# Kernel Variables
CR_VERSION=v2.8-Stable
CR_NAME=Refined_Kernel
CR_JOBS=5
CR_ANDROID=7
CR_ARCH=arm64
CR_DATE=$(date +%Y%m%d)
# Init build
export CROSS_COMPILE=$CR_TC
export ANDROID_MAJOR_VERSION=$CR_ANDROID
export $CR_ARCH
##########################################
# Device specific Variables [SM-J530F/G]
CR_DTSFILES_J530F="exynos7870-j5y17lte_eur_open_00.dtb exynos7870-j5y17lte_eur_open_01.dtb exynos7870-j5y17lte_eur_open_02.dtb exynos7870-j5y17lte_eur_open_03.dtb exynos7870-j5y17lte_eur_open_05.dtb exynos7870-j5y17lte_eur_open_07.dtb"
CR_CONFG_J530F=j5y17lte_01_defconfig
CR_VARIANT_J530F=J530F
# Device specific Variables [SM-J530GM/FM]
CR_DTSFILES_J530M="exynos7870-j5y17lte_eur_openm_00.dtb exynos7870-j5y17lte_eur_openm_01.dtb exynos7870-j5y17lte_eur_openm_02.dtb exynos7870-j5y17lte_eur_openm_03.dtb exynos7870-j5y17lte_eur_openm_05.dtb exynos7870-j5y17lte_eur_openm_07.dtb"
CR_CONFG_J530M=j5y17lte_eur_openm_defconfig
CR_VARIANT_J530M=J530GM-FM
# Device specific Variables [SM-J530Y/YM]
CR_DTSFILES_J530Y="exynos7870-j5y17lte_eur_openm_00.dtb exynos7870-j5y17lte_eur_openm_01.dtb exynos7870-j5y17lte_eur_openm_02.dtb exynos7870-j5y17lte_eur_openm_03.dtb exynos7870-j5y17lte_eur_openm_05.dtb exynos7870-j5y17lte_eur_openm_07.dtb"
CR_CONFG_J530Y=j5y17lte_eur_openm_defconfig
CR_VARIANT_J530Y=J530Y-YM
# Device specific Variables [SM-J730F/G]
CR_DTSFILES_J730F="exynos7870-j7y17lte_eur_open_00.dtb exynos7870-j7y17lte_eur_open_01.dtb exynos7870-j7y17lte_eur_open_02.dtb exynos7870-j7y17lte_eur_open_03.dtb exynos7870-j7y17lte_eur_open_04.dtb exynos7870-j7y17lte_eur_open_05.dtb exynos7870-j7y17lte_eur_open_06.dtb exynos7870-j7y17lte_eur_open_07.dtb"
CR_CONFG_J730F=j7y17lte_eur_open_defconfig
CR_VARIANT_J730F=J730F-G
##########################################

# Script functions
CLEAN_SOURCE()
{
echo "----------------------------------------------"
echo " "
echo "Cleaning"	
make clean
make mrproper
# rm -r -f $CR_OUT/*
rm -r -f $CR_DTB
rm -rf $CR_DTS/.*.tmp
rm -rf $CR_DTS/.*.cmd
rm -rf $CR_DTS/*.dtb	
echo " "
echo "----------------------------------------------"	
}
DIRTY_SOURCE()
{
echo "----------------------------------------------"
echo " "
echo "Cleaning"	
# make clean
# make mrproper
# rm -r -f $CR_OUT/*
rm -r -f $CR_DTB
rm -rf $CR_DTS/.*.tmp
rm -rf $CR_DTS/.*.cmd
rm -rf $CR_DTS/*.dtb	
echo " "
echo "----------------------------------------------"	
}
BUILD_ZIMAGE()
{
	echo "----------------------------------------------"
	echo " "
	echo "Building zImage for $CR_VARIANT"	
	export LOCALVERSION=-$CR_NAME-$CR_VERSION-$CR_VARIANT-$CR_DATE
	make  $CR_CONFG
	make -j$CR_JOBS
	echo " "
	echo "----------------------------------------------"	
}
BUILD_DTB()
{
	echo "----------------------------------------------"
	echo " "
	echo "Building DTB for $CR_VARIANT"	
	export $CR_ARCH
	export CROSS_COMPILE=$CR_TC
	export ANDROID_MAJOR_VERSION=$CR_ANDROID
	make  $CR_CONFG
	make $CR_DTSFILES
	./scripts/dtbTool/dtbTool -o ./boot.img-dtb -d $CR_DTS/ -s 2048
	du -k "./boot.img-dtb" | cut -f1 >sizT
	sizT=$(head -n 1 sizT)
	rm -rf sizT
	echo "Combined DTB Size = $sizT Kb"
	rm -rf $CR_DTS/.*.tmp
	rm -rf $CR_DTS/.*.cmd
	rm -rf $CR_DTS/*.dtb	
	echo " "
	echo "----------------------------------------------"
}
PACK_BOOT_IMG()
{
	echo "----------------------------------------------"
	echo " "
	echo "Building Boot.img for $CR_VARIANT"
	cp -rf $CR_RAMDISK/* $CR_AIK
	mv $CR_KERNEL $CR_AIK/split_img/boot.img-zImage
	mv $CR_DTB $CR_AIK/split_img/boot.img-dtb
	$CR_AIK/repackimg.sh
	echo -n "SEANDROIDENFORCE" » $CR_AIK/image-new.img
	mv $CR_AIK/image-new.img $CR_OUT/$CR_NAME-$CR_VERSION-$CR_DATE-$CR_VARIANT.img
	$CR_AIK/cleanup.sh
}

# Main Menu
clear
echo "----------------------------------------------"
echo "$CR_NAME $CR_VERSION Build Script"
echo "----------------------------------------------"
PS3='Please select your option (1-5): '
menuvar=("SM-J530F-G" "SM-J530FM-GM" "SM-J530Y-YM" "SM-J730F-G" "Exit")
select menuvar in "${menuvar[@]}"
do
    case $menuvar in
        "SM-J530F-G")
            clear
            CLEAN_SOURCE
            echo "Starting $CR_VARIANT_J530F kernel build..."
	    CR_VARIANT=$CR_VARIANT_J530F
	    CR_CONFG=$CR_CONFG_J530F
            CR_DTSFILES=$CR_DTSFILES_J530F
	    BUILD_ZIMAGE
            BUILD_DTB
            PACK_BOOT_IMG
            echo " "
            echo "----------------------------------------------"
            echo "$CR_VARIANT kernel build finished."
            echo "$CR_VARIANT Ready at $CR_OUT"
            echo "Combined DTB Size = $sizT Kb"
	    echo "Press Any key to end the script"
            echo "----------------------------------------------"
            read -n1 -r key
            break
            ;;
        "SM-J530FM-GM")
            clear
            CLEAN_SOURCE
            echo "Starting $CR_VARIANT_J530M kernel build..."
	    CR_VARIANT=$CR_VARIANT_J530M
       	    CR_CONFG=$CR_CONFG_J530M
            CR_DTSFILES=$CR_DTSFILES_J530M
	    BUILD_ZIMAGE
            BUILD_DTB
            PACK_BOOT_IMG
            echo " "
            echo "----------------------------------------------"
            echo "$CR_VARIANT kernel build finished."
            echo "$CR_VARIANT Ready at $CR_OUT"
            echo "Combined DTB Size = $sizT Kb"
	    echo "Press Any key to end the script"
            echo "----------------------------------------------"
            read -n1 -r key
            break
            ;;
        "SM-J530Y-YM")
            clear
            CLEAN_SOURCE
            echo "Starting $CR_VARIANT_J530Y kernel build..."
	    CR_VARIANT=$CR_VARIANT_J530Y
	    CR_CONFG=$CR_CONFG_J530Y
            CR_DTSFILES=$CR_DTSFILES_J530Y
	    BUILD_ZIMAGE
            BUILD_DTB
            PACK_BOOT_IMG
            echo " "
            echo "----------------------------------------------"
            echo "$CR_VARIANT kernel build finished."
            echo "$CR_VARIANT Ready at $CR_OUT"
            echo "Combined DTB Size = $sizT Kb"
	    echo "Press Any key to end the script"
            echo "----------------------------------------------"
            read -n1 -r key
            break
            ;;
        "SM-J730F-G")
            clear
            CLEAN_SOURCE
            echo "Starting $CR_VARIANT_J730F kernel build..."
            CR_VARIANT=$CR_VARIANT_J730F
	    CR_CONFG=$CR_CONFG_J730F
            CR_DTSFILES=$CR_DTSFILES_J730F
	    BUILD_ZIMAGE
            BUILD_DTB
            PACK_BOOT_IMG
            echo " "
            echo "----------------------------------------------"
            echo "$CR_VARIANT kernel build finished."
            echo "$CR_VARIANT Ready at $CR_OUT"
            echo "Combined DTB Size = $sizT Kb"
	    echo "Press Any key to end the script"
            echo "----------------------------------------------"
            read -n1 -r key
            break
            ;;			
        "Exit")
            break
            ;;
        *) echo Invalid option.;;
    esac
done
