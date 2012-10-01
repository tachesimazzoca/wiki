---
layout: page

title: 基本操作
---

## 設定確認

`httpd.conf` でサーバ全体の設定を行います。ファイルパスについては、起動スクリプト `/etc/init.d/httpd` または実行中のプロセスを確認して判断してください。

パッケージからのインストールを行った場合は

`/etc/httpd/conf/httpd.conf`

ソースから `/usr/local/apache` へインストールを行った場合は

`/usr/local/apache/conf/httpd.conf`

を確認してみてください。

起動前に `httpd.conf` の記述が正しいかをチェックします。エラーがある場合、httpd の起動ができませんので、必ずチェックします。

    % /etc/init.d/httpd configtest
    Syntax OK

`CustomLog` `ErrorLog` で指定したログファイルのディレクトリが存在しないことがよくあります。この場合、起動ができてもサーバが応答しなくなりますので注意してください。


## 起動と停止

`start` オプションで起動します。

    % /etc/init.d/httpd start

SSLを利用するには `startssl` オプションを指定します。

    % /etc/init.d/httpd startssl

`ps` コマンドで、親プロセスと子プロセスが起動していることが確認できます。

    % ps auxf | grep 'httpd' | grep -v grep

`stop` オプションで停止します。

    % /etc/init.d/httpd stop


## 再起動

緩やかな再起動方法として `graceful` オプションがあります。親プロセスに `USR1` シグナルを送ることで、処理中の子プロセスがある場合、処理終了後に新しいプロセスに置き換えます。

    % /etc/init.d/httpd graceful

    # 以下と同じことです
    % kill -USR1 (親プロセス番号)

`restart` オプションでは、親プロセスに ``HUP`` シグナルを送ることで、子プロセスを即座に終了させ新しい設定で子プロセスを起動します。親プロセスは終了しません。

    % /etc/init.d/httpd restart

    # 以下と同じことです
    % kill -HUP (親プロセス番号)

`stop` での停止後に `(start|startssl)` で起動する方法です。 `restart` との違いは `stop` オプションで `TERM` シグナルが送られ、親プロセスが終了する点です。

    % /etc/init.d/httpd stop
    % /etc/init.d/httpd start

`graceful` `restart` オプションでは親プロセスは終了しないため、SSL証明書の変更やモジュール追加の場合に変更が正しく反映されない場合があります。プロセスが中断しますが、最も確実な再起動方法です。

