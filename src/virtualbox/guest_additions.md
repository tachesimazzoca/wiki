---
layout: index

title: VirtualBox Guest Additions
---

## CentOS5

* gcc
* kernel
* kernel-devel

のパッケージが必要になります。

`kernel-devel` は `kernel` と同じバージョンを指定してインストールしておきます。

    % yum list installed | grep kernel
    kernel.i686 2.6.18-274.el5
    ...
    % yum install kernel-devel-2.6.18-274.el5

ゲストOSのウインドウメニューより

    デバイス > Guest Additions のインストール

を選択すると、インストールCDが `/dev/cdrom` にマウントされます。

`/mnt/cdrom` などにマウントし、インストールCD内の `VBoxLinuxAdditions.run` を実行します。

    % mkdir /mnt/cdrom
    % mount -r /dev/cdrom /mnt/cdrom
    % cd /mnt/cdrom
    % ./VBoxLinuxAdditions.run

