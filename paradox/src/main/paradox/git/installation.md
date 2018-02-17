# Installation

## yum

    % yum install git

## CentOS5

公式リポジトリに含まれていないため、yum リポジトリを追加します。

    % vi /etc/yum.repos.d/rpmforge.repo

    [rpmforge]
    name = Red Hat Enterprise $releasever - RPMforge.net - dag
    mirrorlist = http://apt.sw.be/redhat/el5/en/mirrors-rpmforge
    enabled = 0
    gpgcheck = 0

上記設定例では、`enabled = 0` として、通常の yum コマンドでは参照しないようにしています。追加リポジトリに rpmforge を指定して `yum install` します。

    % yum install git --enablerepo=rpmforge
