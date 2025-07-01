#!/bin/bash

# 启用18.06Luci
sed -i 's|^#src-git luci https://github.com/coolsnowwolf/luci$|src-git luci https://github.com/coolsnowwolf/luci|' feeds.conf.default
sed -i 's|^src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-23.05$|#src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-23.05|' feeds.conf.default
echo "✅ Luci 源已切换为 18.06"

echo "📄 当前 feeds.conf.default 内容如下："
cat feeds.conf.default

# 添加第三方软件包
echo "📦 正在克隆第三方软件包"
git clone https://github.com/xcz-ns/OpenWrt-Packages package/OpenWrt-Packages
echo "✅ 第三方软件包克隆完成"

# 更新并安装源
echo "🔄 清理旧 feeds..."
./scripts/feeds clean
echo "🔄 更新所有 feeds..."
./scripts/feeds update -a
echo "📥 安装所有 feeds（强制覆盖冲突项）..."
./scripts/feeds install -a -f
echo "📥 再次安装所有 feeds（确保完整）..."
./scripts/feeds install -a -f
echo "✅ feeds 更新与安装完成"

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

# ●●●●●●●●●●●●●●●●●●●●●●●●定制部分●●●●●●●●●●●●●●●●●●●●●●●● #

# ===================== 个性化部分 =======================
sed -i 's#192.168.1.1#192.168.0.1#g' $NET                                          # 定制默认 IP 地址
sed -i 's#LEDE#OpenWrt#g' $NET                                                     # 修改默认主机名为 OpenWrt
sed -i "s/LEDE /Built on $(TZ=UTC-8 date "+%Y.%m.%d") @ LEDE /g" $ZZZ              # 增加编译日期个性标识
sed -i 's#localtime  = os.date()#localtime  = os.date("%Y年%m月%d日") .. " " .. translate(os.date("%A")) .. " " .. os.date("%X")#g' package/lean/autocore/files/*/index.htm                                            # 修改默认时间格式
sed -i 's#%D %V, %C#%D %V, %C Lean_R3S#g' package/base-files/files/etc/banner      # 自定义banner显示
echo "uci set luci.main.mediaurlbase=/luci-static/design" >> $ZZZ                  # 设置默认主题为 argon（如编译器强制覆盖可能失效）

# ====================== 性能跑分 ========================
# echo "rm -f /etc/uci-defaults/xxx-coremark" >> "$ZZZ"
# cat >> $ZZZ <<EOF
# cat /dev/null > /etc/bench.log
# echo " (CpuMark : 191219.823122" >> /etc/bench.log
# echo " Scores)" >> /etc/bench.log
# EOF

# ===================== 网络设置 =========================
cat >> $ZZZ <<-EOF
# 设置网络 - 旁路由模式
# uci set network.lan.gateway='192.168.11.1'                      # 设置 IPv4 网关
# uci set network.lan.dns='114.114.114.114'                       # 设置 DNS（多个用空格分隔）
# uci set dhcp.lan.ignore='1'                                     # 禁用 LAN 口 DHCP 功能
# uci delete network.lan.type                                     # 禁用桥接模式
# uci set network.lan.delegate='0'                                # 禁用 IPv6 委托（如需 IPv6 改为 '1'）
# uci set dhcp.@dnsmasq[0].filter_aaaa='0'                        # 禁止解析 IPv6 DNS 记录（如需 IPv6 改为 '0'）

# 设置防火墙 - 旁路由模式
# uci set firewall.@defaults[0].syn_flood='0'                     # 禁用 SYN Flood 防护
# uci set firewall.@defaults[0].flow_offloading='0'               # 禁用软件 NAT 加速
# uci set firewall.@defaults[0].flow_offloading_hw='0'            # 禁用硬件 NAT 加速
# uci set firewall.@defaults[0].fullcone='0'                      # 禁用 FullCone NAT
# uci set firewall.@defaults[0].fullcone6='0'                     # 禁用 FullCone NAT6
# uci set firewall.@zone[0].masq='1'                              # 启用 LAN 口 IP 动态伪装

# 禁用 IPv6（旁路模式下推荐）
# uci del network.lan.ip6assign                                     # 禁用 IPv6 分配长度
# uci del dhcp.lan.ra                                               # 禁用 IPv6 路由通告服务
# uci del dhcp.lan.dhcpv6                                           # 禁用 DHCPv6 服务
# uci del dhcp.lan.ra_management                                    # 禁用 DHCPv6 管理模式

# 如需启用 IPv6，可取消下面注释启用：
# uci set network.ipv6=interface                                  # 新建 IPv6 网络接口
# uci set network.ipv6.proto='dhcpv6'                             # 协议设为 DHCPv6 自动获取
# uci set network.ipv6.ifname='@lan'                              # 绑定 LAN 接口
# uci set network.ipv6.reqaddress='try'                           # 尝试获取 IPv6 地址
# uci set network.ipv6.reqprefix='auto'                           # 自动请求前缀长度
# uci set firewall.@zone[0].network='lan ipv6'                    # 把 IPv6 接口加入防火墙 LAN 区域

uci commit dhcp                                                   # 保存 DHCP 配置
uci commit network                                                # 保存网络配置
uci commit firewall                                               # 保存防火墙配置
EOF

# =============== 检查 OpenClash 是否启用编译 ==================
# if grep -qE '^(CONFIG_PACKAGE_luci-app-openclash=n|# CONFIG_PACKAGE_luci-app-openclash=)' "${WORKPATH}/$CUSTOM_SH"; then
#   # OpenClash 未启用，不执行任何操作
#   echo "OpenClash 未启用编译"
#   echo 'rm -rf /etc/openclash' >> $ZZZ
# else
#   # OpenClash 已启用，执行配置
#   if grep -q "CONFIG_PACKAGE_luci-app-openclash=y" "${WORKPATH}/$CUSTOM_SH"; then
#     # 判断系统架构
#     arch=$(uname -m)  # 获取系统架构
#     case "$arch" in
#       x86_64)
#         arch="amd64"
#         ;;
#       aarch64|arm64)
#         arch="arm64"
#         ;;
#     esac
#     # OpenClash Meta 开始配置内核
#     echo "正在执行：为OpenClash下载内核"
#     mkdir -p $HOME/clash-core
#     mkdir -p $HOME/files/etc/openclash/core
#     cd $HOME/clash-core
#     # 下载Meta内核
#     wget -q https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-$arch.tar.gz
#     if [[ $? -ne 0 ]];then
#       wget -q https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-$arch.tar.gz
#     else
#       echo "OpenClash Meta内核压缩包下载成功，开始解压文件"
#     fi
#     tar -zxvf clash-linux-$arch.tar.gz
#     if [[ -f "$HOME/clash-core/clash" ]]; then
#       mv -f $HOME/clash-core/clash $HOME/files/etc/openclash/core/clash_meta
#       chmod +x $HOME/files/etc/openclash/core/clash_meta
#       echo "OpenClash Meta内核配置成功"
#     else
#       echo "OpenClash Meta内核配置失败"
#     fi
#     rm -rf $HOME/clash-core/clash-linux-$arch.tar.gz
#     rm -rf $HOME/clash-core
#   fi
# fi

# ================ 修改退出命令到最后 =======================
cd $HOME && sed -i '/exit 0/d' $ZZZ && echo "exit 0" >> $ZZZ


# ●●●●●●●●●●●●●●●●●●●●●●●●固件定制●●●●●●●●●●●●●●●●●●●●●●●● #

# 创建自定义配置文件
cd $WORKPATH
touch ./.config

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

# 编译R3S固件:
cat >> .config <<EOF
CONFIG_TARGET_rockchip=y
CONFIG_TARGET_rockchip_armv8=y
CONFIG_TARGET_rockchip_armv8_DEVICE_friendlyarm_nanopi-r3s=y
EOF

# 设置固件大小:
cat >> .config <<EOF
CONFIG_TARGET_ROOTFS_PARTSIZE=2048
EOF

# 固件压缩:
# cat >> .config <<EOF
# CONFIG_TARGET_IMAGES_GZIP=y
# EOF

# IPv6支持:
# cat >> .config <<EOF
# CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y
# CONFIG_PACKAGE_ipv6helper=y
# EOF

# 编译PVE/KVM、Hyper-V、VMware镜像以及镜像填充
# cat >> .config <<EOF
# CONFIG_QCOW2_IMAGES=y
# CONFIG_VHDX_IMAGES=y
# CONFIG_VMDK_IMAGES=y
# CONFIG_TARGET_IMAGES_PAD=y
# EOF

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
# cat >> .config <<EOF
# CONFIG_PACKAGE_kmod-usb-ohci=y
# CONFIG_PACKAGE_kmod-usb-ohci-pci=y
# CONFIG_PACKAGE_kmod-usb2=y
# CONFIG_PACKAGE_kmod-usb2-pci=y
# CONFIG_PACKAGE_kmod-usb3=y
# EOF

# 多线多拨:
# cat >> .config <<EOF
# CONFIG_PACKAGE_luci-app-syncdial=y #多拨虚拟WAN
# CONFIG_PACKAGE_luci-app-mwan3=y #MWAN负载均衡
# CONFIG_PACKAGE_luci-app-mwan3helper=n #MWAN3分流助手
# EOF

# 第三方插件选择:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-poweroff=y           # 关机（增加关机功能）
CONFIG_PACKAGE_luci-app-openclash=y          # OpenClash 客户端
CONFIG_PACKAGE_luci-app-argon-config=y       # argon 主题设置
CONFIG_PACKAGE_luci-app-design-config=y      # design 主题设置

CONFIG_PACKAGE_luci-app-oaf=n                # 应用过滤
CONFIG_PACKAGE_luci-app-nikki=n              # nikki 客户端
CONFIG_PACKAGE_luci-app-serverchan=n         # 微信推送
CONFIG_PACKAGE_luci-app-eqos=n               # IP 限速
CONFIG_PACKAGE_luci-app-control-weburl=n     # 网址过滤
CONFIG_PACKAGE_luci-app-smartdns=n           # smartdns 服务器
CONFIG_PACKAGE_luci-app-adguardhome=n        # AdGuardHome 广告拦截
CONFIG_PACKAGE_luci-app-autotimeset=n        # 定时重启系统/网络
CONFIG_PACKAGE_luci-app-ddnsto=n             # DDNS.to 内网穿透（小宝开发）
CONFIG_PACKAGE_ddnsto=n                      # DDNS.to 内网穿透软件包
EOF

# ShadowsocksR 插件:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-ssr-plus=n                                    # SSR Plus 插件（已禁用）
EOF

# Passwall 插件:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-passwall=n                           # Passwall 主插件（已禁用）
CONFIG_PACKAGE_luci-app-passwall2=n                          # Passwall2 插件（已禁用）
CONFIG_PACKAGE_naiveproxy=n                                  # NaiveProxy 支持
CONFIG_PACKAGE_chinadns-ng=n                                 # ChinaDNS-NG 解析辅助
CONFIG_PACKAGE_brook=n                                       # Brook 协议支持
CONFIG_PACKAGE_trojan-go=n                                   # Trojan-Go 协议支持
CONFIG_PACKAGE_xray-plugin=n                                 # Xray 插件支持
CONFIG_PACKAGE_shadowsocks-rust-sslocal=n                    # Shadowsocks Rust 客户端
EOF

# Turbo ACC 网络加速:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-turboacc=y                           # Turbo ACC 网络加速（已启用）
EOF

# 常用 LuCI 插件:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-filebrowser=y               # 文件浏览器
CONFIG_PACKAGE_luci-app-ddns=y                      # DDNS 服务
CONFIG_PACKAGE_luci-app-filetransfer=y              # 系统 - 文件传输
CONFIG_PACKAGE_luci-app-wol=y                       # 网络唤醒
CONFIG_PACKAGE_luci-app-diskman=y                   # 磁盘管理
CONFIG_PACKAGE_luci-app-ttyd=y                      # ttyd 终端
CONFIG_PACKAGE_luci-app-wireguard=y                 # WireGuard 客户端
CONFIG_PACKAGE_luci-proto-wireguard=y               # WireGuard 协议支持
CONFIG_PACKAGE_luci-app-store=y                     # Store 应用商店
CONFIG_PACKAGE_luci-app-uhttpd=y                    # uhttpd 管理界面
CONFIG_PACKAGE_luci-app-nlbwmon=y                   # 宽带流量统计
CONFIG_PACKAGE_luci-app-dockerman=y                 # Docker 管理
CONFIG_PACKAGE_luci-app-wolplus=y                   # 网络唤醒plus
CONFIG_PACKAGE_luci-app-tailscale=y                 # tailscale VPN

CONFIG_PACKAGE_luci-app-wol=n                       # 网络唤醒
CONFIG_PACKAGE_luci-app-gowebdav=n                  # GoWebDAV 文件访问
CONFIG_PACKAGE_luci-app-lucky=n                     # lucky 定时任务
CONFIG_PACKAGE_luci-app-accesscontrol=n             # 上网时间控制
CONFIG_PACKAGE_luci-app-wrtbwmon=n                  # 实时流量监控
CONFIG_PACKAGE_luci-app-vlmcsd=n                    # KMS 激活服务器
CONFIG_PACKAGE_luci-app-arpbind=n                   # IP/MAC 绑定
CONFIG_PACKAGE_luci-app-sqm=n                       # SQM 智能队列管理
CONFIG_PACKAGE_luci-app-adbyby-plus=n               # Adbyby 去广告
CONFIG_PACKAGE_luci-app-webadmin=n                  # Web 管理页面设置
CONFIG_PACKAGE_luci-app-autoreboot=n                # 定时重启
CONFIG_PACKAGE_luci-app-upnp=n                      # UPnP 自动端口转发
CONFIG_PACKAGE_luci-app-nps=n                       # NPS 内网穿透
CONFIG_PACKAGE_luci-app-frpc=n                      # Frp 内网穿透
CONFIG_PACKAGE_luci-app-haproxy-tcp=n               # Haproxy 负载均衡
CONFIG_PACKAGE_luci-app-transmission=n              # Transmission 离线下载
CONFIG_PACKAGE_luci-app-qbittorrent=n               # qBittorrent 离线下载
CONFIG_PACKAGE_luci-app-amule=n                     # 电驴（aMule）离线下载
CONFIG_PACKAGE_luci-app-xlnetacc=n                  # 迅雷快鸟提速
CONFIG_PACKAGE_luci-app-zerotier=n                  # Zerotier 内网穿透
CONFIG_PACKAGE_luci-app-hd-idle=n                   # 磁盘休眠
CONFIG_PACKAGE_luci-app-unblockmusic=n              # 解锁网易云灰色歌曲
CONFIG_PACKAGE_luci-app-airplay2=n                  # Apple AirPlay2 音频接收
CONFIG_PACKAGE_luci-app-music-remote-center=n       # PCHiFi 数字转盘遥控
CONFIG_PACKAGE_luci-app-usb-printer=n               # USB 打印机支持
CONFIG_PACKAGE_luci-app-jd-dailybonus=n             # 京东签到服务
CONFIG_PACKAGE_luci-app-uugamebooster=n             # UU 游戏加速器

# VPN 相关插件:
CONFIG_PACKAGE_luci-app-v2ray-server=n              # V2Ray 服务器
CONFIG_PACKAGE_luci-app-pptp-server=n               # PPTP VPN 服务器
CONFIG_PACKAGE_luci-app-ipsec-vpnd=n                # IPsec VPN 服务
CONFIG_PACKAGE_luci-app-openvpn-server=n            # OpenVPN 服务端
CONFIG_PACKAGE_luci-app-softethervpn=n              # SoftEther VPN 服务器

# 文件共享相关:
CONFIG_PACKAGE_luci-app-samba4=y                    # Samba4 网络共享（推荐）
CONFIG_PACKAGE_samba4-server=y                      # Samba4 服务器
CONFIG_PACKAGE_samba4-libs=y                        # Samba4 库文件

CONFIG_PACKAGE_luci-app-minidlna=n                  # miniDLNA 媒体共享
CONFIG_PACKAGE_luci-app-vsftpd=n                    # FTP 服务器
CONFIG_PACKAGE_luci-app-ksmbd=n                     # KSMBD 网络共享（禁用避免混用）
CONFIG_PACKAGE_luci-app-samba=n                     # Samba3 网络共享
CONFIG_PACKAGE_autosamba=n                          # 自动配置 Samba
CONFIG_PACKAGE_samba36-server=n                     # Samba36 服务（老版本）
EOF

# LuCI主题:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-theme-design=y

CONFIG_PACKAGE_luci-theme-edge=n
EOF

# 常用软件包:
cat >> .config <<EOF
CONFIG_PACKAGE_firewall=y                # 启用 firewall（传统防火墙）
CONFIG_PACKAGE_curl=y                    # 命令行 HTTP 工具 curl
CONFIG_PACKAGE_htop=y                    # 交互式进程查看器 htop
CONFIG_PACKAGE_nano=y                    # 轻量级文本编辑器 nano
# CONFIG_PACKAGE_screen=y                # 终端多路复用工具 screen（未启用）
# CONFIG_PACKAGE_tree=y                  # 目录树形显示工具 tree（未启用）
# CONFIG_PACKAGE_vim-fuller=y            # Vim 全功能版本（未启用）
CONFIG_PACKAGE_wget=y                    # 命令行下载工具 wget
CONFIG_PACKAGE_bash=y                    # Bash shell 解释器
CONFIG_PACKAGE_fdisk=y                   # fdisk工具
CONFIG_PACKAGE_kmod-tun=y                # TUN/TAP 驱动，支持 VPN 等虚拟网络设备
CONFIG_PACKAGE_snmpd=y                   # SNMP 代理服务
CONFIG_PACKAGE_libcap=y                  # Linux 权限管理库 libcap
CONFIG_PACKAGE_libcap-bin=y              # libcap 的用户空间工具
CONFIG_PACKAGE_ip6tables-mod-nat=y       # IPv6 NAT 模块
CONFIG_PACKAGE_iptables-mod-extra=y      # iptables 额外模块
CONFIG_PACKAGE_vsftpd=y                  # VSFTPD FTP 服务器
CONFIG_PACKAGE_vsftpd-alt=n              # VSFTPD 替代版本（未启用）
CONFIG_PACKAGE_openssh-sftp-server=y     # OpenSSH SFTP 服务端
CONFIG_PACKAGE_qemu-ga=y                 # QEMU 客户端代理（Guest Agent）
# CONFIG_PACKAGE_autocore-x86=y          # X86 优化工具（未启用）
CONFIG_PACKAGE_firewall4=n               # 适配18.04版本，关闭 firewall4
EOF

cat >> .config <<EOF
# 核心功能与系统模块
CONFIG_PACKAGE_kmod-button-hotplug=y            # 支持物理按钮热插拔（如 Reset/Wi-Fi）
CONFIG_PACKAGE_kmod-gpio-button-hotplug=y       # GPIO 按键热插拔支持
CONFIG_PACKAGE_kmod-hwmon-core=y                # 硬件监控基础模块（温度、风扇）
CONFIG_PACKAGE_kmod-input-core=y                # 输入设备支持（键盘、鼠标等）
CONFIG_PACKAGE_kmod-lib-crc16=y                 # CRC16 校验库，内核常用
CONFIG_PACKAGE_kmod-lib-crc32c=y                # CRC32C 校验库
CONFIG_PACKAGE_kmod-lib-lzo=y                   # LZO 压缩算法支持
CONFIG_PACKAGE_kmod-lib-textsearch=y            # 文本搜索支持，常用于 netfilter
CONFIG_PACKAGE_kmod-lib-xor=y                   # XOR 操作库（RAID）
CONFIG_PACKAGE_kmod-lib-zlib-deflate=y          # zlib deflate 压缩算法支持
CONFIG_PACKAGE_kmod-lib-zlib-inflate=y          # zlib inflate 解压算法支持
CONFIG_PACKAGE_kmod-lib-zstd=y                  # Zstandard 压缩算法支持
CONFIG_PACKAGE_kmod-lib-raid6=y                 # RAID6 编码支持模块
CONFIG_PACKAGE_kmod-mii=y                       # 网络接口中 MII 接口支持
CONFIG_PACKAGE_kmod-veth=y                      # 虚拟以太网对接口（veth）

# 文件系统支持
CONFIG_PACKAGE_kmod-fs-ext4=y                   # 支持 EXT4 文件系统
CONFIG_PACKAGE_kmod-fs-btrfs=y                  # 支持 Btrfs 文件系统
CONFIG_PACKAGE_kmod-fs-exfat=y                  # 支持 exFAT 文件系统
CONFIG_PACKAGE_kmod-fs-xfs=y                    # 支持 XFS 文件系统
CONFIG_PACKAGE_kmod-fs-vfat=y                   # 支持 FAT32/VFAT 文件系统
CONFIG_PACKAGE_kmod-fs-ntfs3=y                  # 支持 NTFS3 文件系统（比 ntfs-3g 快）
CONFIG_PACKAGE_kmod-fs-exportfs=y               # NFS 导出支持
CONFIG_PACKAGE_kmod-fs-autofs4=y                # 自动挂载支持（自动文件系统）
CONFIG_PACKAGE_kmod-fuse=y                      # FUSE 文件系统用户空间挂载支持

# 加密与安全模块
CONFIG_PACKAGE_kmod-crypto-acompress=y          # 压缩相关加密模块
CONFIG_PACKAGE_kmod-crypto-aead=y               # AEAD 加密算法支持
CONFIG_PACKAGE_kmod-crypto-authenc=y            # Authenticated encryption 支持
CONFIG_PACKAGE_kmod-crypto-cbc=y                # CBC 模式支持
CONFIG_PACKAGE_kmod-crypto-ccm=y                # CCM 模式支持
CONFIG_PACKAGE_kmod-crypto-cmac=y               # CMAC 支持
CONFIG_PACKAGE_kmod-crypto-crc32c=y             # CRC32C 校验支持
CONFIG_PACKAGE_kmod-crypto-ctr=y                # CTR 模式加密支持
CONFIG_PACKAGE_kmod-crypto-deflate=y            # DEFLATE 压缩算法（加密中用）
CONFIG_PACKAGE_kmod-crypto-des=y                # DES 加密算法支持
CONFIG_PACKAGE_kmod-crypto-ecb=y                # ECB 模式支持
CONFIG_PACKAGE_kmod-crypto-echainiv=y           # 加密链支持
CONFIG_PACKAGE_kmod-crypto-gcm=y                # GCM 加密模式
CONFIG_PACKAGE_kmod-crypto-gf128=y              # GF128 乘法支持（GCM 用）
CONFIG_PACKAGE_kmod-crypto-ghash=y              # GHASH 支持
CONFIG_PACKAGE_kmod-crypto-hash=y               # 通用哈希接口
CONFIG_PACKAGE_kmod-crypto-hmac=y               # HMAC 支持
CONFIG_PACKAGE_kmod-crypto-kpp=y                # 密钥派生协议支持
CONFIG_PACKAGE_kmod-crypto-md5=y                # MD5 支持
CONFIG_PACKAGE_kmod-crypto-null=y               # 空加密（测试用）
CONFIG_PACKAGE_kmod-crypto-rng=y                # 随机数生成器支持
CONFIG_PACKAGE_kmod-crypto-seqiv=y              # IV 生成支持
CONFIG_PACKAGE_kmod-crypto-sha1=y               # SHA1 哈希支持
CONFIG_PACKAGE_kmod-crypto-sha256=y             # SHA256 哈希支持
CONFIG_PACKAGE_kmod-crypto-user=y               # 用户空间加密 API
CONFIG_PACKAGE_kmod-cryptodev=y                 # 使用 cryptodev 设备进行加密加速

# 网络协议与 NAT/防火墙
CONFIG_PACKAGE_kmod-br-netfilter=y              # 桥接网卡的 netfilter 支持
CONFIG_PACKAGE_kmod-ipt-core=y                  # iptables 核心支持
CONFIG_PACKAGE_kmod-ipt-conntrack=y             # iptables 连接跟踪模块
CONFIG_PACKAGE_kmod-ipt-conntrack-extra=y       # 连接跟踪扩展支持
CONFIG_PACKAGE_kmod-ipt-extra=y                 # iptables 额外扩展
CONFIG_PACKAGE_kmod-ipt-nat=y                   # IPv4 NAT 支持
CONFIG_PACKAGE_kmod-ipt-nat6=y                  # IPv6 NAT 支持
CONFIG_PACKAGE_kmod-ipt-ipset=y                 # 支持 IP 集合（ipset）
CONFIG_PACKAGE_kmod-ipt-tproxy=y                # 透明代理支持（TPROXY）
CONFIG_PACKAGE_kmod-ipt-ipopt=y                 # IP 选项支持
CONFIG_PACKAGE_kmod-ipt-iprange=y               # IP 范围匹配支持
CONFIG_PACKAGE_kmod-ipt-ipsec=y                 # IPsec 匹配支持
CONFIG_PACKAGE_kmod-ipt-offload=y               # 硬件 offload 支持
CONFIG_PACKAGE_kmod-ipt-physdev=y               # 物理设备匹配
CONFIG_PACKAGE_kmod-ipt-raw=y                   # 原始数据包处理
CONFIG_PACKAGE_kmod-ipt-fullconenat=y           # FullCone NAT 支持

# 网络协议与隧道
CONFIG_PACKAGE_kmod-ip6tables=y                 # IPv6 的 iptables 支持
CONFIG_PACKAGE_kmod-iptunnel=y                  # IP 隧道支持
CONFIG_PACKAGE_kmod-iptunnel4=y                 # IPv4 隧道支持
CONFIG_PACKAGE_kmod-iptunnel6=y                 # IPv6 隧道支持
CONFIG_PACKAGE_kmod-sit=y                       # IPv6 over IPv4 隧道（SIT）
CONFIG_PACKAGE_kmod-gre=y                       # GRE 隧道协议支持
CONFIG_PACKAGE_kmod-l2tp=y                      # L2TP 协议支持
CONFIG_PACKAGE_kmod-udptunnel4=y                # UDP over IPv4 隧道支持
CONFIG_PACKAGE_kmod-udptunnel6=y                # UDP over IPv6 隧道支持

# 路由加速 / QoS / 调度
CONFIG_PACKAGE_kmod-sched=y                     # 通用流量调度支持
CONFIG_PACKAGE_kmod-sched-core=y                # 核心调度功能支持
CONFIG_PACKAGE_kmod-sched-cake=y                # CAKE 流控算法支持（推荐）
CONFIG_PACKAGE_kmod-nf-flow=y                   # 流表加速支持（flow offload）
CONFIG_PACKAGE_kmod-nf-ipt=y                    # IPv4 netfilter 支持
CONFIG_PACKAGE_kmod-nf-ipt6=y                   # IPv6 netfilter 支持
CONFIG_PACKAGE_kmod-nf-reject=y                 # 拒绝响应模块（IPv4）
CONFIG_PACKAGE_kmod-nf-reject6=y                # 拒绝响应模块（IPv6）
CONFIG_PACKAGE_kmod-nf-nat=y                    # IPv4 NAT 模块
CONFIG_PACKAGE_kmod-nf-nat6=y                   # IPv6 NAT 模块
CONFIG_PACKAGE_kmod-nf-nathelper=y              # NAT 辅助模块
CONFIG_PACKAGE_kmod-nf-nathelper-extra=y        # NAT 辅助额外模块
CONFIG_PACKAGE_kmod-nfnetlink=y                 # netfilter 与用户空间通信支持
CONFIG_PACKAGE_kmod-nfnetlink-queue=y           # netfilter 队列支持
CONFIG_PACKAGE_kmod-nf-conntrack=y              # 连接跟踪支持
CONFIG_PACKAGE_kmod-nf-conntrack6=y             # IPv6 连接跟踪支持
CONFIG_PACKAGE_kmod-nf-conntrack-netlink=y      # 连接跟踪 netlink 接口

# 无线驱动与相关模块
CONFIG_PACKAGE_kmod-cfg80211=y                  # Linux 无线配置框架支持
CONFIG_PACKAGE_kmod-mac80211=y                  # 主流 Wi-Fi 驱动框架
CONFIG_PACKAGE_kmod-macvlan=y                   # MAC VLAN 支持
CONFIG_PACKAGE_kmod-mt76-core=y                 # MT76 无线核心驱动
CONFIG_PACKAGE_kmod-mt76-connac=y               # MT76 connac 系列无线芯片驱动
CONFIG_PACKAGE_kmod-mt7615-common=y             # MT7615 通用驱动
CONFIG_PACKAGE_kmod-mt7615e=y                   # MT7615e 无线芯片驱动
CONFIG_PACKAGE_kmod-mt7915-firmware=y           # MT7915 固件支持
CONFIG_PACKAGE_kmod-mt7915e=y                   # MT7915e 无线芯片驱动
CONFIG_PACKAGE_kmod-mt7916-firmware=y           # MT7916 固件支持
CONFIG_PACKAGE_kmod-mt7921-common=y             # MT7921 通用驱动
CONFIG_PACKAGE_kmod-mt7921-firmware=y           # MT7921 固件支持
CONFIG_PACKAGE_kmod-mt7921e=y                   # MT7921e 无线芯片驱动
CONFIG_PACKAGE_kmod-mt7922-firmware=y           # MT7922 固件支持
CONFIG_PACKAGE_kmod-mt792x-common=y             # MT792x 通用驱动
CONFIG_PACKAGE_kmod-rtl8821cu=y                 # RTL8821CU 无线驱动（USB）
CONFIG_PACKAGE_kmod-rtl8822cu=y                 # RTL8822CU 无线驱动（USB）
CONFIG_PACKAGE_kmod-rtw88-usb=y                 # rtw88 USB 系列无线驱动
CONFIG_PACKAGE_kmod-mt76x2u=y                   # USB网卡
CONFIG_PACKAGE_kmod-mt76=y                      # USB网卡

# USB 支持及相关驱动
CONFIG_PACKAGE_kmod-usb-core=y                  # USB 核心支持
CONFIG_PACKAGE_kmod-usb-uhci=y                  # USB UHCI 控制器支持
CONFIG_PACKAGE_kmod-usb-ohci=y                  # USB OHCI 控制器支持
CONFIG_PACKAGE_kmod-usb-ehci=y                  # USB EHCI 控制器支持
CONFIG_PACKAGE_kmod-usb2=y                      # USB 2.0 支持
CONFIG_PACKAGE_kmod-usb-storage=y               # USB 存储支持
CONFIG_PACKAGE_kmod-usb-storage-extras=y        # USB 存储扩展支持（多种文件系统）
CONFIG_PACKAGE_kmod-usb-storage-uas=y           # USB UAS 协议支持
CONFIG_PACKAGE_kmod-usb-net=y                   # 通用 USB 网络支持
CONFIG_PACKAGE_kmod-usb-net-aqc111=y            # Aquantia USB 网卡驱动
CONFIG_PACKAGE_kmod-usb-net-asix-ax88179=y      # ASIX AX88179 USB 以太网驱动
CONFIG_PACKAGE_kmod-usb-net-cdc-ether=y         # CDC Ethernet USB 网卡驱动
CONFIG_PACKAGE_kmod-usb-net-cdc-ncm=y           # CDC NCM (Network Control Model) 支持
CONFIG_PACKAGE_kmod-usb-net-huawei-cdc-ncm=y    # 华为专用 CDC NCM 支持
CONFIG_PACKAGE_kmod-usb-net-ipheth=y            # Apple iPhone USB 网络驱动
CONFIG_PACKAGE_kmod-usb-net-qmi-wwan=y          # QMI WWAN 网络支持
CONFIG_PACKAGE_kmod-usb-net-rndis=y             # RNDIS 协议 USB 网卡支持
CONFIG_PACKAGE_kmod-usb-net-rtl8152-vendor=y    # Realtek 8152 USB 网卡驱动（厂商版本）
CONFIG_PACKAGE_kmod-usb-net-sierrawireless=y    # Sierra Wireless USB 网卡支持
CONFIG_PACKAGE_kmod-usb-serial=y                # 通用 USB 串口驱动
CONFIG_PACKAGE_kmod-usb-serial-option=y         # USB 串口选项驱动
CONFIG_PACKAGE_kmod-usb-serial-qualcomm=y       # Qualcomm USB 串口支持
CONFIG_PACKAGE_kmod-usb-serial-wwan=y           # WWAN USB 串口驱动
CONFIG_PACKAGE_kmod-usb-wdm=y                   # USB WDM 设备支持
CONFIG_PACKAGE_kmod-usb-acm=y                   # USB ACM 通用串口支持
CONFIG_PACKAGE_kmod-usb-printer=y               # USB 打印机支持

# PPP 与 WAN 连接支持
CONFIG_PACKAGE_kmod-ppp=y                        # PPP 协议核心模块
CONFIG_PACKAGE_kmod-pppoe=y                      # PPPoE 支持（常用于 DSL 宽带）
CONFIG_PACKAGE_kmod-pppol2tp=y                   # L2TP over PPP 支持
CONFIG_PACKAGE_kmod-pppox=y                      # PPP over Ethernet/PPPoE 支持

# 存储与磁盘相关
CONFIG_PACKAGE_kmod-dm=y                         # 设备映射器支持（LVM、RAID 等）
CONFIG_PACKAGE_kmod-dax=y                        # 直接访问存储支持（DAX）
CONFIG_PACKAGE_kmod-nvme=y                       # NVMe 存储支持
CONFIG_PACKAGE_kmod-scsi-core=y                  # SCSI 核心支持

# 其他常用驱动及模块
CONFIG_PACKAGE_kmod-bonding=y                   # 绑定多个网口（链路聚合）
CONFIG_PACKAGE_kmod-keys-encrypted=y            # 加密密钥支持
CONFIG_PACKAGE_kmod-keys-trusted=y              # 可信密钥支持
CONFIG_PACKAGE_kmod-thermal=y                   # 温度传感器支持
CONFIG_PACKAGE_kmod-tpm=y                       # TPM 硬件安全模块支持
CONFIG_PACKAGE_kmod-random-core=y               # 随机数核心模块
CONFIG_PACKAGE_kmod-ifb=y                       # Intermediate Functional Block，流量镜像
CONFIG_PACKAGE_kmod-ikconfig=y                  # 内核配置导出支持
CONFIG_PACKAGE_kmod-netem=y                     # 网络仿真模块（延迟、丢包等）
CONFIG_PACKAGE_kmod-nls-base=y                  # 字符集支持基础
CONFIG_PACKAGE_kmod-nls-cp437=y                 # CP437 编码支持
CONFIG_PACKAGE_kmod-nls-iso8859-1=y             # ISO8859-1 字符集支持
CONFIG_PACKAGE_kmod-nls-utf8=y                  # UTF8 字符集支持

# 特殊网卡驱动
CONFIG_PACKAGE_kmod-r8125=y                     # Realtek 8125 网卡驱动
CONFIG_PACKAGE_kmod-r8168=y                     # Realtek 8168 网卡驱动
EOF

# 其他软件包:
cat >> .config <<EOF
CONFIG_HAS_FPU=y                         # 设备支持硬件浮点单元 (FPU)
EOF

sed -i 's/^[ \t]*//g' ./.config

# ●●●●●●●●●●●●●●●●●●●●●●●●固件定制部分结束●●●●●●●●●●●●●●●●●●●●●●●● #

# 返回目录
cd $HOME

# 配置文件创建完成