---
layout: page

title: インストール
---

## mysql-4.1

    % su -
    % cd /usr/local/src
    % curl -O "http://ftp.iij.ad.jp/pub/db/mysql/Downloads/MySQL-4.1/mysql-4.1.22.tar.gz"
    % tar xvfz mysql-4.1.22.tar.gz
    % cd mysql-4.1.22
    % CFLAGS="-O3 -DPIC -fPIC -DUNDEF_HAVE_INITGROUPS -fno-strict-aliasing" \
      CXXFLAGS="-O3 -fno-strict-aliasing -felide-constructors -fno-exceptions -fno-rtti -fPIC -DPIC -DUNDEF_HAVE_INITGROUPS" \
      ./configure --without-readline \
      --with-charset=ujis --with-extra-charsets=all \
      --with-mysqld-user=mysql --prefix=/usr/local/mysql
    % make
    % make test
    % make install

    % cp /usr/local/mysql/share/mysql/my-medium.cnf /etc/my.cnf
    % /usr/local/mysql/bin/mysql_install_db --user=mysql
    % chown -R root:mysql /usr/local/mysql
    % chown -R mysql:mysql /usr/local/mysql/var

    % cp /usr/local/mysql/share/mysql/mysql.server /etc/init.d/mysqld
    % chkconfig --add mysqld
    % chkconfig mysqld on

    % /etc/init.d/mysqld start


CentOS5系に含まれる gcc-4.x 系の場合 `make test` で `mysql_client_test` が失敗します。

    TEST                            RESULT
    -------------------------------------------------------
    ....
    mysql_client_test              [ fail ]

    Errors are (from /usr/src/mysql-4.1.18/mysql-test/var/log/mysqltest-time) :
    mysql_client_test.c:3573: check failed: '(int) i8_data == rc'
    mysqltest: At line 10: command "$MYSQL_CLIENT_TEST --getopt-ll-test=25600M" failed
    (the last lines may be the most important ones)

`configure` 時に以下の環境変数を設定することで解決します。

    CFLAGS="-O3 -DPIC -fPIC -DUNDEF_HAVE_INITGROUPS -fno-strict-aliasing"
    CXXFLAGS="-O3 -fno-strict-aliasing -felide-constructors -fno-exceptions -fno-rtti -fPIC -DPIC -DUNDEF_HAVE_INITGROUPS"


