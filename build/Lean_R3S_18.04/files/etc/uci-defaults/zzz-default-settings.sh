# 修改主机名称为 OpenWrt
uci set system.@system[0].hostname='OpenWrt'

# 设置默认主题
uci set luci.main.mediaurlbase='/luci-static/design' && uci commit luci

# 设置登录地址192.168.0.1
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.0.1'
uci set network.lan.netmask='255.255.255.0'
uci commit network
/etc/init.d/network restart

# 删除README
rm -rf /README

exit 0
