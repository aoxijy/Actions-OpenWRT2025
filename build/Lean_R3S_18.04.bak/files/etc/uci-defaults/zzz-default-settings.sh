# 修改主机名称为 QWRT
uci set system.@system[0].hostname='OpenWrt'

# 设置默认主题
uci set luci.main.mediaurlbase='/luci-static/design' && uci commit luci

# 设置登录地址192.168.0.1
uci set network.lan.ipaddr='192.168.0.1'
uci commit network
/etc/init.d/network restart

# 添加密钥登录
mkdir -p /etc/dropbear
cat << 'EOF' > /etc/dropbear/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5SRidt7m4PX/4KmA7lBx2DLhSss+fKvK+UurPZFszo root@Z4Pro
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDt8P9E0E99vPtY2n8SfOEV469/Yo2QTSYP3qEKY93e7 Public
EOF
chmod 600 /etc/dropbear/authorized_keys
/etc/init.d/dropbear restart

# 给予执行权限
chmod 777 /usr/bin/filebrowser

# 删除README
rm -rf /README

exit 0
