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

    # 利用可能な ja_JP ロケールを確認
    % locale -a | grep ja_JP
    % ja_JP
    % ja_JP.eucjp
    % ja_JP.ujis
    % ja_JP.utf8

    # ja_JP.utf8 を指定
    % vim /etc/sysconfig/i18n
    LANG="ja_JP.utf8"
    LC_CTYPE="ja_JP.utf8"


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


## EPEL リポジトリの追加

    % rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-5
    # i386(32bit)
    % rpm -ivh http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
    # x86_64(64bit)
    % rpm -ivh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm

* /etc/yum.repos.d/epel.repo
* /etc/yum.repos.d/epel-testing.repo

が追加されます。通常は EPEL は含めないように `enabled=0` としておくとよいでしょう。

    [epel]
    name=Extra Packages for Enterprise Linux 5 - $basearch
    #baseurl=http://download.fedoraproject.org/pub/epel/5/$basearch
    mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=epel-5&arch=$basearch
    failovermethod=priority
    enabled=0
    gpgcheck=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL

    ....

