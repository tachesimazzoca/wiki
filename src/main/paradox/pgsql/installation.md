# Installation

## yum

    % yum install postgresql-server postgresql-devel
    % service postgresql initdb
    % service postgresql start

If you need another version of PostgreSQL .rpm, please consult the following URL:

* <https://wiki.postgresql.org/wiki/YUM_Installation>

Let's say you install _PostgreSQL-9.6(-3) RHEL7 x86\_64_.

Exclude `postgresql.*` package from CentOS-Base.repo.

    # Add exclude option in each section
    $ cat /etc/yum.repos.d/CentOS-Base.repo
    [base]
    ...
    exclude=postgresql*

    [updates]
    ...
    exclude=postgresql*

And then add your specific PGDG RPM file into `/etc/yum.repos.d` with `yum` command. The list of PGDG RPM files can be found in [PostgreSQL yum repository](https://yum.postgresql.org/).

    $ yum install https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-redhat96-9.6-3.noarch.rpm

    $ cat /etc/yum.repos.d/pgdg-96-redhat.repo
    [pgdg96]
    name=PostgreSQL 9.6 $releasever - $basearch
    ...

    $ yum list postgresql*
    $ yum install postgresql96-server

    # The binaries will be installed at /usr/pgsal-x.y
    $ ls /usr/pgsql-9.6
    $ /usr/pgsql-9.6/bin/postgresql96-setup initdb
    $ systemctl enable postgresql-9.6.service
    $ systemctl start postgresql-9.6.service

## postgresql-8.x

    # インストール / 実行用の postgres ユーザを作成 (rootは不可)
    # /usr/local/pgsql をホームディレクトリとする
    % useradd -d /usr/local/pgsql postgres

    # インストール先ディレクトリ以下を postgres ユーザが書き込み可としておく
    % mkdir /usr/local/pgsql
    % chown -R postgres:postgres /usr/local/pgsql

    # postgres ユーザでインストール
    % cd /usr/local/src/
    % tar xvfz postgresql-8.3.7.tar.gz
    % chown -R postgres:postgres postgresql-8.3.7
    % su - postgres
    % cd /usr/local/src/postgresql

    % export LANG=C
    % ./configure --prefix=/usr/local/pgsql
    % make
    % make install

postgres ユーザの環境変数を設定し、データベースを初期化します。

    % vi ~/.bash_profile
    ....
    export PATH=$PATH:/usr/local/pgsql/bin
    export POSTGRES_HOME=/usr/local/pgsql
    export PGLIB=$POSTGRES_HOME/lib
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"$PGLIB"
    export MANPATH="$MANPATH":$POSTGRES_HOME/man
    export PGDATA=/usr/local/pgsql/data
    ....
    % source ~/.bash_profile

    % /usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data

必要に応じて、アクセスポリシーを `ident sameuser` から `trust` や `password` に変更します。

    % vim /usr/local/pgsql/data/pg_hba.conf
    ....
    # "local" is for Unix domain socket connections only
    local   all         all                               trust
    # IPv4 local connections:
    host    all         all         127.0.0.1/32          trust
    # IPv6 local connections:
    host    all         all         ::1/128               trust
    ....

`postgres` ユーザで PostgreSQL データベースサーバ `postmaster` を起動/停止します。

    % su - postgres

    # pg_ctl での起動/停止
    % /usr/local/pgsql/bin/pg_ctl -o "-S -i" start
    % /usr/local/pgsql/bin/pg_ctl stop

    # 手動で postmaster を起動する例
    % /usr/local/pgsql/bin/postmaster -D /usr/local/pgsql/data & >> /usr/local/pgsql/pgstartuup.log 2>&1 < /dev/null

