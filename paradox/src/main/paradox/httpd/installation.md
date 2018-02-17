# Installation

## yum

    % yum install httpd


## Apache 2.2

**archive.apache.org**

<http://archive.apache.org/dist/httpd/>

httpd-2.2.x.tar.gz のソースを取得し展開します。

    % cd /usr/local/src/
    % wget "http://archive.apache.org/dist/httpd/httpd-2.2.16.tar.gz"
    % tar httpd-2.2.16.tar.gz

`apr` `apr-util` をあらかじめインストールしておきます。

    % cd /usr/local/src/httpd-2.2.16/srclib/apr
    % ./configure --prefix=/usr/local/apr --enable-threads
    % make
    % make install

    % cd /usr/local/src/httpd-2.2.16/srclib/apr-util
    % ./configure \
    --prefix=/usr/local/apr \
    --with-apr=/usr/local/apr
    % make
    % make install

その後 `httpd` をインストールします。

    % cd /usr/local/src/httpd-2.2.16
    % ./configure \
    --prefix=/usr/local/apache-2.2.16 \
    --enable-mods-shared=all \
    --with-apr=/usr/local/apr \
    --with-apr-util=/usr/local/apr
    % make
    % make install

上記の例では `/usr/local/apache-2.2.16/` にインストールされます。`/usr/local/apache/` としてシンボリックリンクを作成しておくとよいでしょう。

    % cd /usr/local/
    % ln -s apache-2-2.16/ apache


## Apache 1.3 + mod_ssl

**archive.apache.org**

<http://archive.apache.org/dist/httpd/>

**mod_ssl**

<http://www.modssl.org/>

以下のパッケージが必要です。

* `gcc`
* `gdbm-devel`
* `openssl-devel`

`mod_ssl` のソース内から apache_1.3 を `configure` します。その後 `apache_1.3.x/` のディレクトリ下で `make` を行います。

    % cd /usr/local/src/

    # あらかじめ apache-1.3 のソースを展開しておきます。
    % wget "http://archive.apache.org/dist/httpd/apache_1.3.41.tar.gz"
    % tar xvfz apache_1.3.41.tar.gz

    % wget "http://www.modssl.org/source/mod_ssl-2.8.31-1.3.41.tar.gz"
    % tar xvfz mod_ssl-2.8.31-1.3.41.tar.gz
    % cd mod_ssl-2.8.31-1.3.41
    % ./configure \
    --with-apache=/usr/local/src/apache_1.3.41 \
    --with-ssl=/usr/local/ssl \
    --prefix=/usr/local/apache_1.3.41+mod_ssl-2.8.31 \
    --enable-module=most --enable-shared=ssl --enable-shared=max

    % cd /usr/local/src/apache_1.3.41
    % make
    % make install

上記の例では `/usr/local/apache_1.3.41+mod_ssl-2.8.31/` にインストールされます。`/usr/local/apache/` としてシンボリックリンクを作成しておくとよいでしょう。

    % cd /usr/local/
    % ln -s apache_1.3.41+mod_ssl-2.8.31/ apache


## chkconfig

yum パッケージからのインストールを行った場合は `/etc/init.d/httpd` に起動スクリプトが作成されています。

ソースからのインストールを行った場合は `/usr/local/apache/bin/apachectl` を起動スクリプトとして `/etc/init.d/httpd` にコピーします。

    % cp /usr/local/apache/bin/apachectl /etc/init.d/httpd

コピーしただけでは `chkconfig` でスクリプトとして認識してくれません。

    % chkconfig --add httpd
    service httpd does not support chkconfig

`chkconfig` に認識させるために、`/etc/init.d/httpd` のコメントブロックに以下を追加します。

    #!/bin/sh
    #
    # chkconfig: - 85 15
    # description: Apache is a World Wide Web server.  It is used to serve \
    #              HTML files and CGI.
    ....

`chkconfig: (ランレベル) (起動時の優先順位) (停止時の優先順位)` で指定します。例ではランレベルに `-` を指定していますが、これは `2345` を指定したことと同義です。

`chkconfig --add` で起動スクリプトに追加します。

    % chkconfig --add httpd
    % chkconfig --list httpd
    httpd           0:off   1:off   2:off   3:off   4:off   5:off   6:off

    % chkconfig httpd on
    % chkconfig --list httpd
    httpd           0:off   1:off   2:on    3:on    4:on    5:on    6:off

