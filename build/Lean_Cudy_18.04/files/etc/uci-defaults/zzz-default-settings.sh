# 修改主机名称为 QWRT
uci set system.@system[0].hostname='QWRT'

# 设置默认主题
uci set luci.main.mediaurlbase='/luci-static/argon' && uci commit luci

# 设置登录地址192.168.3.1
# uci set network.lan.ipaddr='192.168.3.1'
# uci commit network
# /etc/init.d/network restart

# 删除README
rm -rf /README

exit 0
