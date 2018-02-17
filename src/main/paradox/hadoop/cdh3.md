# CDH3

## Overview

**Cloudera**

<http://www.cloudera.com/>

**CDH3 Installation**

<https://ccp.cloudera.com/display/CDHDOC/CDH3+Installation>


## RHEL

CDH3 のリポジトリを追加します。

RHEL5:

    % vi /etc/yum.repos.d/cloudera-cdh3.repo

    ....

    [cloudera-cdh3]
    # Packages for Cloudera's Distribution for Hadoop, Version 3, on RedHat or CentOS 5
    name=Cloudera's Distribution for Hadoop, Version 3
    mirrorlist=http://archive.cloudera.com/redhat/cdh/3/mirrors
    gpgkey = http://archive.cloudera.com/redhat/cdh/RPM-GPG-KEY-cloudera
    gpgcheck = 1

    ....

    # (Optional) Add the Cloudera Public GPG Key
    % rpm --import http://archive.cloudera.com/redhat/cdh/RPM-GPG-KEY-cloudera

RHEL6(x86\_64):

    % vi /etc/yum.repos.d/cloudera-cdh3.repo

    ....

    [cloudera-cdh3]
    # Packages for Cloudera's Distribution for Hadoop, Version 3, on RedHat or CentOS 6
    name=Cloudera's Distribution for Hadoop, Version 3
    mirrorlist=http://archive.cloudera.com/redhat/6/x86_64/cdh/3/mirrors
    gpgkey = http://archive.cloudera.com/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera
    gpgcheck = 1

    ....

    # (Optional) Add the Cloudera Public GPG Key
    % rpm --import http://archive.cloudera.com/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera

すべてのマシンに `hadoop-0.20` `hadoop-0.20-native` パッケージをインストールします。

    % yum search hadoop
    % yum install hadoop-0.20 hadoop-0.20-native

各割り当てマシン毎に必要なデーモンのパッケージをインストールします。

    % yum install hadoop-0.20-<daemon type>
    ....

* namenode
* datanode
* secondarynamenode
* jobtracker
* tasktracker


## Java Development Kit

Oracle JDK (Sun JDK) の利用が推奨されています。

`/etc/hadoop-0.20/conf/hadoop-evn.sh` の `JAVA_HOME` を設定しておきます。

    % vim /etc/hadoop-0.20/conf/hadoop-env.sh

    ....
    # export JAVA_HOME=/usr/lib/j2sdk1.6-sun
    export JAVA_HOME=/usr/local/jdk1.6.0_35

    ....


## Pseudo Distributed Mode

`hadoop-0.20-conf-pseudo` パッケージで１台構成の疑似分散モードでの設定と一通りのデーモンがインストールできます。

    % yum install hadoop-0.20-conf-pseudo

疑似分散モードの設定ファイル `/etc/hadoop-0.20/conf.pseudo` が作られます。 `alternatives` で `/etc/hadoop-0.20/conf/` が `/etc/hadoop-0.20/conf.pseudo/` のシンボリックリンクになっている事がわかります。

    % ls -l /etc/hadoop-0.20/
    lrwxrwxrwx 1 root root   34  ... conf -> /etc/alternatives/hadoop-0.20-conf
    drwxr-xr-x 2 root root 4096  ... conf.empty
    drwxr-xr-x 2 root root 4096  ... conf.pseudo

    % ls -l /etc/alternatives/hadoop-0.20-conf
    lrwxrwxrwx 1 root root 28    ... /etc/alternatives/hadoop-0.20-conf -> /etc/hadoop-0.20/conf.pseudo

Hadoop 用に以下のユーザが追加されます。

* ``mapred`` : Hadoop MapReduce
* ``hdfs`` : Hadoop HDFS

`hdfs` ユーザで NameNode を初期化し `hadoop-0.20-*` のすべてのデーモンを起動します。

    % sudo -u hdfs hadoop namenode -format
    % for service in /etc/init.d/hadoop-0.20-*; do sudo $service start; done

