#!/bin/bash

# 启用18.06Luci
sed -i 's|^#src-git luci https://github.com/coolsnowwolf/luci$|src-git luci https://github.com/coolsnowwolf/luci|' feeds.conf.default
sed -i 's|^src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-23.05$|#src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-23.05|' feeds.conf.default
echo "✅ Luci 源已切换为 18.06"
echo ""

echo "📄 当前 feeds.conf.default 内容如下："
cat feeds.conf.default
echo ""

# 添加第三方软件包
echo "📦 正在克隆第三方软件包"
git clone https://github.com/xcz-ns/OpenWrt-Packages package/OpenWrt-Packages
echo "✅ 第三方软件包克隆完成"
echo ""

# 更新并安装源
echo "🔄 清理旧 feeds..."
./scripts/feeds clean
echo ""

echo "🔄 更新所有 feeds..."
./scripts/feeds update -a
echo ""

echo "📥 安装所有 feeds（强制覆盖冲突项）..."
./scripts/feeds install -a -f
echo ""

echo "📥 再次安装所有 feeds（确保完整）..."
./scripts/feeds install -a -f
echo "✅ feeds 更新与安装完成"
echo ""

# 删除部分默认包
echo "🧹 删除部分默认包"
rm -rf feeds/luci/applications/luci-app-qbittorrent
rm -rf package/feeds/luci/luci-app-qbittorrent

rm -rf feeds/luci/applications/luci-app-openclash
rm -rf package/feeds/luci/luci-app-openclash

rm -rf feeds/luci/themes/luci-theme-design
rm -rf package/feeds/luci/luci-theme-design

rm -rf feeds/luci/themes/luci-theme-argon
rm -rf package/feeds/luci/luci-theme-argon
echo "✅ 默认包删除完成"
echo ""

# 自定义定制选项
NET="package/base-files/luci2/bin/config_generate"
ZZZ="package/lean/default-settings/files/zzz-default-settings"
# 读取内核版本
KERNEL_PATCHVER=$(cat target/linux/x86/Makefile|grep KERNEL_PATCHVER | sed 's/^.\{17\}//g')
KERNEL_TESTING_PATCHVER=$(cat target/linux/x86/Makefile|grep KERNEL_TESTING_PATCHVER | sed 's/^.\{25\}//g')
if [[ $KERNEL_TESTING_PATCHVER > $KERNEL_PATCHVER ]]; then
  sed -i "s/$KERNEL_PATCHVER/$KERNEL_TESTING_PATCHVER/g" target/linux/x86/Makefile        # 修改内核版本为最新
  echo "内核版本已更新为 $KERNEL_TESTING_PATCHVER"
else
  echo "内核版本不需要更新"
fi
echo ""

# ●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●● #

sed -i 's#localtime  = os.date()#localtime  = os.date("%Y年%m月%d日") .. " " .. translate(os.date("%A")) .. " " .. os.date("%X")#g' package/lean/autocore/files/*/index.htm               # 修改默认时间格式

# ●●●●●●●●●●●●●●●●●●●●●●●●定制部分●●●●●●●●●●●●●●●●●●●●●●●● #

# ========================性能跑分========================
echo "rm -f /etc/uci-defaults/xxx-coremark" >> "$ZZZ"
cat >> $ZZZ <<EOF
cat /dev/null > /etc/bench.log
echo " (CpuMark : 191219.823122" >> /etc/bench.log
echo " Scores)" >> /etc/bench.log
EOF

# 修改退出命令到最后
cd $HOME && sed -i '/exit 0/d' $ZZZ && echo "exit 0" >> $ZZZ

# ●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●● #


# 创建自定义配置文件

cd $WORKPATH
touch ./.config

#
# ●●●●●●●●●●●●●●●●●●●●●●●●固件定制部分●●●●●●●●●●●●●●●●●●●●●●●●
# 

# 
# 如果不对本区块做出任何编辑, 则生成默认配置固件. 
# 

# 以下为定制化固件选项和说明:
#

#
# 有些插件/选项是默认开启的, 如果想要关闭, 请参照以下示例进行编写:
# 
#          ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#        ■|  # 取消编译VMware镜像:                    |■
#        ■|  cat >> .config <<EOF                   |■
#        ■|  # CONFIG_VMDK_IMAGES is not set        |■
#        ■|  EOF                                    |■
#          ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#

# 
# 以下是一些提前准备好的一些插件选项.
# 直接取消注释相应代码块即可应用. 不要取消注释代码块上的汉字说明.
# 如果不需要代码块里的某一项配置, 只需要删除相应行.
#
# 如果需要其他插件, 请按照示例自行添加.
# 注意, 只需添加依赖链顶端的包. 如果你需要插件 A, 同时 A 依赖 B, 即只需要添加 A.
# 
# 无论你想要对固件进行怎样的定制, 都需要且只需要修改 EOF 回环内的内容.
# 

# 编译cudy固件:
cat >> .config <<EOF
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_filogic=y
CONFIG_TARGET_mediatek_filogic_DEVICE_cudy_tr3000-mod=y
EOF

# 设置固件大小:
cat >> .config <<EOF
# CONFIG_TARGET_KERNEL_PARTSIZE=16
# CONFIG_TARGET_ROOTFS_PARTSIZE=2048
EOF

# 固件压缩:
cat >> .config <<EOF
# CONFIG_TARGET_IMAGES_GZIP=y
EOF

# 编译UEFI固件:
cat >> .config <<EOF
# CONFIG_EFI_IMAGES=y
EOF

# IPv6支持:
cat >> .config <<EOF
CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y
# CONFIG_PACKAGE_ipv6helper=y
EOF

# 编译PVE/KVM、Hyper-V、VMware镜像以及镜像填充
cat >> .config <<EOF
# CONFIG_QCOW2_IMAGES=y
# CONFIG_VHDX_IMAGES=y
# CONFIG_VMDK_IMAGES=y
# CONFIG_TARGET_IMAGES_PAD=y
CONFIG_TARGET_ROOTFS_TARGZ=y
CONFIG_TARGET_ROOTFS_EXT4FS=y
EOF

# 多文件系统支持:
# cat >> .config <<EOF
# CONFIG_PACKAGE_kmod-fs-nfs=y
# CONFIG_PACKAGE_kmod-fs-nfs-common=y
# CONFIG_PACKAGE_kmod-fs-nfs-v3=y
# CONFIG_PACKAGE_kmod-fs-nfs-v4=y
# CONFIG_PACKAGE_kmod-fs-ntfs=y
# CONFIG_PACKAGE_kmod-fs-squashfs=y
# EOF

# USB3.0支持:
cat >> .config <<EOF
# CONFIG_PACKAGE_kmod-usb-ohci=y
# CONFIG_PACKAGE_kmod-usb-ohci-pci=y
# CONFIG_PACKAGE_kmod-usb2=y
# CONFIG_PACKAGE_kmod-usb2-pci=y
CONFIG_PACKAGE_kmod-usb3=y
EOF

# 多线多拨:
# cat >> .config <<EOF
# CONFIG_PACKAGE_luci-app-syncdial=y              #多拨虚拟WAN
# CONFIG_PACKAGE_luci-app-mwan3=y                 #MWAN负载均衡
# CONFIG_PACKAGE_luci-app-mwan3helper=n           #MWAN3分流助手
# EOF

# ShadowsocksR插件:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-ssr-plus=n
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_SagerNet_Core is not set
EOF

# Passwall插件:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-passwall=n
CONFIG_PACKAGE_luci-app-passwall2=n
CONFIG_PACKAGE_naiveproxy=n
CONFIG_PACKAGE_chinadns-ng=n
CONFIG_PACKAGE_brook=n
CONFIG_PACKAGE_trojan-go=n
CONFIG_PACKAGE_xray-plugin=n
CONFIG_PACKAGE_shadowsocks-rust-sslocal=n
EOF

# Turbo ACC 网络加速:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-turboacc=y
EOF

# 常用LuCI插件:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-poweroff=y
CONFIG_PACKAGE_luci-app-openclash=y
CONFIG_PACKAGE_luci-app-argon-config=y
CONFIG_PACKAGE_luci-app-filebrowser=y
CONFIG_PACKAGE_luci-app-ddns=y
CONFIG_PACKAGE_luci-app-filetransfer=y
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-ttyd=y #ttyd
CONFIG_PACKAGE_luci-app-wireguard=y
CONFIG_PACKAGE_luci-proto-wireguard=y
CONFIG_PACKAGE_luci-app-uhttpd=y
CONFIG_PACKAGE_luci-app-wrtbwmon=y                  #实时流量监测
#
CONFIG_PACKAGE_luci-app-design-config=n
CONFIG_PACKAGE_luci-app-smartdns=n
CONFIG_PACKAGE_luci-app-lucky=n
CONFIG_PACKAGE_luci-app-adguardhome=n
CONFIG_PACKAGE_luci-app-ddnsto=n
CONFIG_PACKAGE_ddnsto=n
CONFIG_PACKAGE_luci-app-gowebdav=n
CONFIG_PACKAGE_luci-app-wol=n
CONFIG_PACKAGE_luci-app-store=n
CONFIG_PACKAGE_luci-app-accesscontrol=n
CONFIG_PACKAGE_luci-app-upnp=n
CONFIG_PACKAGE_luci-app-dockerman=n
CONFIG_PACKAGE_luci-app-adbyby-plus=n
CONFIG_PACKAGE_luci-app-nlbwmon=n                   #宽带流量监控
CONFIG_PACKAGE_luci-app-oaf=n                       #应用过滤
CONFIG_PACKAGE_luci-app-nikki=n                     #nikki 客户端
CONFIG_PACKAGE_luci-app-serverchan=n                #微信推送
CONFIG_PACKAGE_luci-app-eqos=n                      #IP限速
CONFIG_PACKAGE_luci-app-control-weburl=n            #网址过滤
CONFIG_PACKAGE_luci-app-autotimeset=n               #定时重启系统，网络
CONFIG_PACKAGE_luci-app-vlmcsd=n                    #KMS激活服务器
CONFIG_PACKAGE_luci-app-arpbind=n                   #IP/MAC绑定
CONFIG_PACKAGE_luci-app-sqm=n                       #SQM智能队列管理
CONFIG_PACKAGE_luci-app-webadmin=n                  #Web管理页面设置
CONFIG_PACKAGE_luci-app-autoreboot=n                #定时重启
CONFIG_PACKAGE_luci-app-nps=n                       #nps内网穿透
CONFIG_PACKAGE_luci-app-frpc=n                      #Frp内网穿透
CONFIG_PACKAGE_luci-app-haproxy-tcp=n               #Haproxy负载均衡
CONFIG_PACKAGE_luci-app-transmission=n              #Transmission离线下载
CONFIG_PACKAGE_luci-app-qbittorrent=n               #qBittorrent离线下载
CONFIG_PACKAGE_luci-app-amule=n                     #电驴离线下载
CONFIG_PACKAGE_luci-app-xlnetacc=n                  #迅雷快鸟
CONFIG_PACKAGE_luci-app-zerotier=n                  #zerotier内网穿透
CONFIG_PACKAGE_luci-app-hd-idle=n                   #磁盘休眠
CONFIG_PACKAGE_luci-app-unblockmusic=n              #解锁网易云灰色歌曲
CONFIG_PACKAGE_luci-app-airplay2=n                  #Apple AirPlay2音频接收服务器
CONFIG_PACKAGE_luci-app-music-remote-center=n       #PCHiFi数字转盘遥控
CONFIG_PACKAGE_luci-app-usb-printer=n               #USB打印机
CONFIG_PACKAGE_luci-app-jd-dailybonus=n             #京东签到服务
CONFIG_PACKAGE_luci-app-uugamebooster=n             #UU游戏加速器
# 
# VPN相关插件(禁用):
#
CONFIG_PACKAGE_luci-app-v2ray-server=n        #V2ray服务器
CONFIG_PACKAGE_luci-app-pptp-server=n         #PPTP VPN 服务器
CONFIG_PACKAGE_luci-app-ipsec-vpnd=n          #ipsec VPN服务
CONFIG_PACKAGE_luci-app-openvpn-server=n      #openvpn服务
CONFIG_PACKAGE_luci-app-softethervpn=n        #SoftEtherVPN服务器
# 
# 文件共享相关(禁用):
#
CONFIG_PACKAGE_luci-app-samba4=n
CONFIG_PACKAGE_samba4-server=n
CONFIG_PACKAGE_samba4-libs=n
#
CONFIG_PACKAGE_luci-app-minidlna=n    #miniDLNA服务
CONFIG_PACKAGE_luci-app-vsftpd=n      #FTP 服务器
CONFIG_PACKAGE_luci-app-ksmbd=n       # 禁用 ksmbd LuCI 插件，彻底避免混用
CONFIG_PACKAGE_luci-app-samba=n       #网络共享
CONFIG_PACKAGE_autosamba=n            #网络共享
CONFIG_PACKAGE_samba36-server=n       #网络共享
EOF

# LuCI主题:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-theme-design=y
CONFIG_PACKAGE_luci-theme-edge=n
EOF

# 常用软件包:
cat >> .config <<EOF
CONFIG_PACKAGE_firewall4=n            # 适配18.04，关闭firewall4
CONFIG_PACKAGE_firewall=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_nano=y
# CONFIG_PACKAGE_screen=y
# CONFIG_PACKAGE_tree=y
# CONFIG_PACKAGE_vim-fuller=y
CONFIG_PACKAGE_wget=y
CONFIG_PACKAGE_bash=y
CONFIG_PACKAGE_kmod-tun=y
CONFIG_PACKAGE_snmpd=y
CONFIG_PACKAGE_libcap=y
CONFIG_PACKAGE_libcap-bin=y
CONFIG_PACKAGE_ip6tables-mod-nat=y
CONFIG_PACKAGE_iptables-mod-extra=y
CONFIG_PACKAGE_vsftpd=y
CONFIG_PACKAGE_vsftpd-alt=n
CONFIG_PACKAGE_openssh-sftp-server=y
CONFIG_PACKAGE_qemu-ga=y
CONFIG_PACKAGE_autocore-x86=y
# CONFIG_PACKAGE_kmod-fuse=y
EOF

# 其他软件包:
cat >> .config <<EOF
CONFIG_HAS_FPU=y                         # 设备支持硬件浮点单元 (FPU)，某些架构如 ARMv8 默认启用
CONFIG_PACKAGE_lvm2=y                    # 安装 LVM2 工具集（包含 pvcreate/vgcreate/lvcreate 等命令）
CONFIG_PACKAGE_kmod-dm=y                 # 启用 Device Mapper 内核支持（含 dm-mod，LVM 的核心内核依赖）
CONFIG_PACKAGE_libdevmapper=y            # 安装 libdevmapper 动态链接库，供 lvm2 命令工具使用
EOF


# 
# ●●●●●●●●●●●●●●●●●●●●●●●●固件定制部分结束●●●●●●●●●●●●●●●●●●●●●●●● #
# 

sed -i 's/^[ \t]*//g' ./.config

# 返回目录
cd $HOME

# 配置文件创建完成
