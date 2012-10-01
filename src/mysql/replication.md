---
layout: page

title: レプリケーション
---

## MyISAM

Master 側では、バイナリログを記録する設定とし `server-id` を設定します。

    % vim /etc/my.cnf
    ....
    [mysqld]
    ...
    # バイナリログを保管
    log-bin
    # Master の ID
    server-id=1
    ...

Slave サーバに `REPLICATION SLAVE` 権限を与えます。

    -- 192.168.0.0/24 からの slave ユーザを許可
    mysql> GRANT REPLICATION SLAVE ON *.* TO slave@'192.168.0.%' IDENTIFIED BY '';

レプリケーションを開始する Master のバイナリログの現在位置を調べておきます。

    mysql> SHOW MASTER STATUS;
    +---------------+----------+--------------+------------------+
    | File          | Position | Binlog_Do_DB | Binlog_Ignore_DB |
    +---------------+----------+--------------+------------------+
    | db-bin.000003 |       79 |              |                  |
    +---------------+----------+--------------+------------------+
    1 row in set (0.00 sec)

Slave サーバにユニークな `server-id` を設定し、Slave の `mysqld` を起動します。

    % vim /etc/my.cnf
    ....
    [mysqld]
    ...
    # Slave の ID
    server-id=2
    ...

    % /etc/init.d/mysqld start

Slave サーバにて Master の設定を行いレプリケーションを開始します。

    -- Master データベース 192.168.0.10 から同期
    mysql> CHANGE MASTER TO MASTER_HOST='192.168.0.10',
           MASTER_USER='slave',
           MASTER_PASSWORD='',
           MASTER_LOG_FILE='db-bin.000003',
           MASTER_LOG_POS=79;

    -- レプリケーション開始
    mysql> START SLAVE;

    -- Slave 状況を確認
    mysql> SHOW SLAVE STATUS \G
    ....

