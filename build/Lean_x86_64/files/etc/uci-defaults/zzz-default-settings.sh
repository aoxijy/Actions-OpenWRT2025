# 修改主机名称为 OpenWrt
uci set system.@system[0].hostname='OpenWrt'

# 设置默认主题
uci set luci.main.mediaurlbase='/luci-static/design' && uci commit luci

# 设置登录地址192.168.11.41
uci set network.lan.ipaddr='192.168.11.41'
uci commit network
/etc/init.d/network restart

exit 0
