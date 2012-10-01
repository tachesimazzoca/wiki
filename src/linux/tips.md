---
layout: page

title: Tips
---

## IPアドレスの設定

    # eth0 - DHCP
    % vim /etc/sysconfig/network-scripts/ifcfg-eth0
    DEVICE=eth0
    BOOTPROTO=dhcp
    ONBOOT=yes
    HWADDR=....
    # /etc/resolv.conf の自動書換をしない
    PEERDNS=no

    # eth1 - 固定アドレス
    % vim /etc/sysconfig/network-scripts/ifcfg-eth1
    DEVICE=eth1
    BOOTPROTO=static
    NETMASK=255.255.255.0
    IPADDR=192.168.56.101
    ONBOOT=yes
    HWADDR=....

    # 設定を反映させます
    % /etc/init.d/network restart


## SELinux

    % vim /etc/sysconfig/selinux
    ...
    SELINUX=disabled
    ..
    % shutdown -r now


## 内部ファイアーウォール

    # IPv4
    % /etc/init.d/iptables stop
    % chkconfig iptables off

    # IPv6
    % /etc/init.d/ip6tables stop
    % chkconfig ip6tables off


## タイムゾーンの設定

    % cp /usr/share/zoneinfo/Japan /etc/localtime
    % date


## システム言語の設定

    % vim /etc/sysconfig/i18n
    LANG="ja_JP.UTF-8"


## ネームサーバ指定

    % vim /etc/resolv.conf
    nameserver 8.8.8.8


DHCPサーバを利用している場合、自動的に設定が書き換わってしまいます。`/etc/sysconfig/network-scripts/ifcfg-*` で `PEERDNS=no` と指定することで無効にできます。

    # eth0 で DHCP を利用しているとします。
    % vim /etc/sysconfig/network-scripts/ifcfg-eth0
    ...
    BOOTPROTO=dhcp
    PEERDNS=no
    ...


## 時刻合わせ

    % yum install ntp
    % ntpdate 0.centos.pool.ntp.org
    % chkconfig ntpd on
    % /etc/init.d/ntpd start

    % hwclock --systohc


## yum 自動更新の停止

    % /etc/init.d/yum-updatesd stop
    % chkconfig yum-updatesd off

