#!/bin/bash
#===============================================
# Description: DIY script
# File name: diy-script.sh
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#===============================================

# enable rk3568 model adc keys
cp -f $GITHUB_WORKSPACE/configfiles/adc-keys.txt adc-keys.txt
! grep -q 'adc-keys {' package/boot/uboot-rk35xx/src/arch/arm/dts/rk3568-easepi.dts && sed -i '/\"rockchip,rk3568\";/r adc-keys.txt' package/boot/uboot-rk35xx/src/arch/arm/dts/rk3568-easepi.dts

# 不集成联发科开源WiFi驱动
getconfig=$(cat ${GITHUB_WORKSPACE}/configfiles/nowifi.txt)
echo "$getconfig" >> .config

# update ubus git HEAD
cp -f $GITHUB_WORKSPACE/configfiles/ubus_Makefile package/system/ubus/Makefile

# 近期istoreos网站文件服务器不稳定，临时增加一个自定义下载网址
sed -i "s/push @mirrors, 'https:\/\/mirror2.openwrt.org\/sources';/&\\npush @mirrors, 'https:\/\/github.com\/xiaomeng9597\/files\/releases\/download\/iStoreosFile';/g" scripts/download.pl


# 修改内核配置文件
sed -i "/.*CONFIG_ROCKCHIP_RGA2.*/d" target/linux/rockchip/rk35xx/config-5.10
# sed -i "/# CONFIG_ROCKCHIP_RGA2 is not set/d" target/linux/rockchip/rk35xx/config-5.10
# sed -i "/CONFIG_ROCKCHIP_RGA2_DEBUGGER=y/d" target/linux/rockchip/rk35xx/config-5.10
# sed -i "/CONFIG_ROCKCHIP_RGA2_DEBUG_FS=y/d" target/linux/rockchip/rk35xx/config-5.10
# sed -i "/CONFIG_ROCKCHIP_RGA2_PROC_FS=y/d" target/linux/rockchip/rk35xx/config-5.10




# 替换dts文件
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3566-jp-tvbox.dts target/linux/rockchip/dts/rk3568/rk3566-jp-tvbox.dts

cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3566-panther-x2.dts target/linux/rockchip/dts/rk3568/rk3566-panther-x2.dts

cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-dg-nas-lite-core.dtsi target/linux/rockchip/dts/rk3568/rk3568-dg-nas-lite-core.dtsi
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-dg-nas-lite.dts target/linux/rockchip/dts/rk3568/rk3568-dg-nas-lite.dts

cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-mrkaio-m68s-core.dtsi target/linux/rockchip/dts/rk3568/rk3568-mrkaio-m68s-core.dtsi
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-mrkaio-m68s.dts target/linux/rockchip/dts/rk3568/rk3568-mrkaio-m68s.dts
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-mrkaio-m68s-plus.dts target/linux/rockchip/dts/rk3568/rk3568-mrkaio-m68s-plus.dts



# 修改uhttpd配置文件，启用nginx
# sed -i "/.*uhttpd.*/d" .config
# sed -i '/.*\/etc\/init.d.*/d' package/network/services/uhttpd/Makefile
# sed -i '/.*.\/files\/uhttpd.init.*/d' package/network/services/uhttpd/Makefile
sed -i "s/:80/:81/g" package/network/services/uhttpd/files/uhttpd.config
sed -i "s/:443/:4443/g" package/network/services/uhttpd/files/uhttpd.config
cp -a $GITHUB_WORKSPACE/configfiles/etc/* package/base-files/files/etc/
# ls package/base-files/files/etc/




# 轮询检查ubus服务是否崩溃，崩溃就重启ubus服务，只针对rk3566机型，如黑豹X2和荐片TV盒子。
# cp -f $GITHUB_WORKSPACE/configfiles/httpubus package/base-files/files/etc/init.d/httpubus
# cp -f $GITHUB_WORKSPACE/configfiles/ubus-examine.sh package/base-files/files/bin/ubus-examine.sh
# chmod 755 package/base-files/files/etc/init.d/httpubus
# chmod 755 package/base-files/files/bin/ubus-examine.sh



# 集成黑豹X2和荐片TV盒子WiFi驱动，默认不启用WiFi
# cp -a $GITHUB_WORKSPACE/configfiles/packages/* package/firmware/
# cp -f $GITHUB_WORKSPACE/configfiles/opwifi package/base-files/files/etc/init.d/opwifi
# chmod 755 package/base-files/files/etc/init.d/opwifi
# sed -i "s/wireless.radio\${devidx}.disabled=1/wireless.radio\${devidx}.disabled=0/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh



# 集成CPU性能跑分脚本
cp -f $GITHUB_WORKSPACE/configfiles/coremark/coremark-arm64 package/base-files/files/bin/coremark-arm64
cp -f $GITHUB_WORKSPACE/configfiles/coremark/coremark-arm64.sh package/base-files/files/bin/coremark.sh
chmod 755 package/base-files/files/bin/coremark-arm64
chmod 755 package/base-files/files/bin/coremark.sh





sed -i "s/192.168.100.1/192.168.200.1/g" package/base-files/files/bin/config_generate
sed -i "s/192.168.1.1/192.168.200.1/g" package/base-files/files/bin/config_generate


# 加入初始化交换机脚本
cp -f $GITHUB_WORKSPACE/configfiles/swconfig_install package/base-files/files/etc/init.d/swconfig_install
chmod 755 package/base-files/files/etc/init.d/swconfig_install



# 删除会导致编译失败的补丁
rm -f target/linux/generic/hack-5.10/747-1-rtl8367b-support-rtl8367s.patch
rm -f target/linux/generic/hack-5.10/747-2-rtl8366_smi-phy-id.patch
rm -f target/linux/generic/hack-5.10/744-rtl8366_smi-fix-ce-debugfs.patch



# 电工大佬的rtl8367b驱动资源包，暂时使用这样替换
wget https://github.com/xiaomeng9597/files/releases/download/files/rtl8367b.tar.gz
tar -xvf rtl8367b.tar.gz


# openwrt主线rtl8367b驱动资源包，暂时使用这样替换
# wget https://github.com/xiaomeng9597/files/releases/download/files/rtl8367b-openwrt.tar.gz
# tar -xvf rtl8367b-openwrt.tar.gz



# cp -f $GITHUB_WORKSPACE/configfiles/init.sh target/linux/rockchip/rk35xx/base-files/lib/board/init.sh

cp -f $GITHUB_WORKSPACE/configfiles/02_network target/linux/rockchip/rk35xx/base-files/etc/board.d/02_network



# 增加nsy_g68-plus
echo -e "\\ndefine Device/nsy_g68-plus
\$(call Device/rk3568)
  DEVICE_VENDOR := NSY
  DEVICE_MODEL := G68
  DEVICE_DTS := rk3568-nsy-g68-plus
  SUPPORTED_DEVICES += nsy,g68-plus
  DEVICE_PACKAGES := kmod-nvme kmod-scsi-core kmod-hwmon-pwmfan kmod-thermal kmod-switch-rtl8306 kmod-switch-rtl8366-smi kmod-switch-rtl8366rb kmod-switch-rtl8366s kmod-switch-rtl8367b swconfig kmod-swconfig kmod-r8168
endef
TARGET_DEVICES += nsy_g68-plus" >> target/linux/rockchip/image/rk35xx.mk



# 增加nsy_g16-plus
echo -e "\\ndefine Device/nsy_g16-plus
\$(call Device/rk3568)
  DEVICE_VENDOR := NSY
  DEVICE_MODEL := G16
  DEVICE_DTS := rk3568-nsy-g16-plus
  SUPPORTED_DEVICES += nsy,g16-plus
  DEVICE_PACKAGES := kmod-nvme kmod-scsi-core kmod-hwmon-pwmfan kmod-thermal kmod-switch-rtl8306 kmod-switch-rtl8366-smi kmod-switch-rtl8366rb kmod-switch-rtl8366s kmod-switch-rtl8367b swconfig kmod-swconfig kmod-r8168
endef
TARGET_DEVICES += nsy_g16-plus" >> target/linux/rockchip/image/rk35xx.mk



# 增加bdy_g18-pro
echo -e "\\ndefine Device/bdy_g18-pro
\$(call Device/rk3568)
  DEVICE_VENDOR := BDY
  DEVICE_MODEL := G18
  DEVICE_DTS := rk3568-bdy-g18-pro
  SUPPORTED_DEVICES += bdy,g18-pro
  DEVICE_PACKAGES := kmod-nvme kmod-scsi-core kmod-hwmon-pwmfan kmod-thermal kmod-switch-rtl8306 kmod-switch-rtl8366-smi kmod-switch-rtl8366rb kmod-switch-rtl8366s kmod-switch-rtl8367b swconfig kmod-swconfig kmod-r8168
endef
TARGET_DEVICES += bdy_g18-pro" >> target/linux/rockchip/image/rk35xx.mk



cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-nsy-g68-plus.dts target/linux/rockchip/dts/rk3568/rk3568-nsy-g68-plus.dts
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-nsy-g16-plus.dts target/linux/rockchip/dts/rk3568/rk3568-nsy-g16-plus.dts
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-bdy-g18-pro.dts target/linux/rockchip/dts/rk3568/rk3568-bdy-g18-pro.dts


# iStoreOS-settings
git clone --depth=1 -b main https://github.com/xiaomeng9597/istoreos-settings package/default-settings


# 定时限速插件
git clone --depth=1 https://github.com/sirpdboy/luci-app-eqosplus package/luci-app-eqosplus
