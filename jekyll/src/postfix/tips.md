---
layout: page

title: TIPS
---

## 設定更新

`main.cf` を変更した場合、設定をすぐに反映させるには `reload` を行います。

    % postfix reload
    postfix/postfix-script: refreshing the Postfix mail system

`reload` を行わなくても、`main.cf` の変更は反映されるため、更新の際には注意してください。設定が不正な状態で保存されていると問題が起こります。

`reload` では更新されない設定項目があります。この場合は `stop/start` で更新を行います。

    % postfix reload
    postfix/postfix-script: refreshing the Postfix mail system

    # /var/log/maillog を確認すると inet_interfaces を変更する場合は stop/start を行うように警告されている
    % less /var/log/maillog
    .... postfix/postfix-script[xxxx]: refreshing the Postfix mail system
    .... postfix/master[xxxx]: reload -- version 2.6.6, configuration /etc/postfix
    .... postfix/master[xxxx]: warning: service smtp: ignoring inet_interfaces change
    .... postfix/master[xxxx]: warning: to change inet_interfaces, stop and start Postfix

    % postfix stop
    % postfix start
    % less /var/log/maillog
    .... postfix/postfix-script[xxxx]: stopping the Postfix mail system
    .... postfix/master[xxxx]: terminating on signal 15
    .... postfix/postfix-script[xxxx]: starting the Postfix mail system
    .... postfix/master[xxxx]: daemon started -- version 2.6.6, configuration /etc/postfix

## バーチャルなメールアドレス

実ユーザを作成しなくても、`virtual_alias_maps` を用いて、バーチャルなメールアドレスでのメール受信ができます。

### エイリアスマップの作成

#### hash

ハッシュテーブルを用いる方法です。`/etc/postfix/virtual` に作成する例です。

    % cat /etc/postfix/virtual
    example.net anything
    support@example.net username
    info@example.net username

`postmap` コマンドで、ハッシュテーブルを作成します。

    # /etc/postfix/virtual.db が作成されます。
    % postmap /etc/postfix/virtual

#### regexp

正規表現で設定を記述します。`/etc/postfix/virtual_regexp` に作成する例です。

    % cat /etc/postfix/virtual_regexp
    /^[0-9a-z]{16}@example\.net$/ username@example.net

### エイリアスマップの指定

`main.cf` でエイリアスマップを指定します。

    % cat /etc/postfix/main.cf
    ....
    # 外部ホストからの配送を許可
    inet_interfaces = all
    ....
    # 配送を受け付けるドメイン example.net を追加
    mydestination = $myhostname, localhost.$mydomain, localhost, example.net
    ....
    # エイリアスマップを指定
    virtual_alias_maps = hash:/etc/postfix/virtual, regexp:/etc/postfix/virtual_regexp

## ハイフンで始まるメールアドレス

ハイフンで始まるメールアドレスは、コマンドオプションと認識される危険性があるため送信されません。危険性を了承した上で送信を行う場合は、`main.cf` で `allow_min_user` の値を設定することで送信されるようになります。

    allow_min_user = yes

## 外部SMTPサーバへの中継

### クライアント（中継元）側の設定

`relayhost` に中継先のホストを指定します。ローカル外のメールは全て指定したホストに中継されます。

    relayhost = [smtp.example.net]:25

### サーバ（中継先）側の設定

外部ホストからの配送を許可します。

    # 外部ホストからの配送を許可
    inet_interfaces = all

    # 信頼するネットワークを指定
    #mynetworks_style = subnet
    mynetworks = 127.0.0.0/8, 192.168.56.0/24

* `mynetworks` が指定された場合には、`mynetworks_style` は無視されます。
* `mynetworks` は CIDR 形式でカンマ切りで複数指定します。
* `mynetworks_style` のデフォルト値は `subnet` です。ローカルLAN内のみに制限する際には便利ですが、公衆 LAN 内等で有効にしてしまうと、同一 LAN 内にいる全てのMTAを許可してしまいます。
* `mynetworks_style = class` は同一アドレスクラスを許可します。インターネット接続にプロバイダを介している場合、全ての同一プロバイダ上のMTAから中継を受け付けてしまうため、スパムメールの踏み台となってしまいます。通常 `class` とすることはありません。

`myhostname` が重複していると中継時にエラーとなります。ローカルLAN内で中継する際に、インストール時デフォルトのホスト名 `localdomain.localhost` のままとなっている場合があります。マシン毎に適切なホスト名を設定するか、`myhostname` を設定します。

    myhostname = smtp.localdomain

### SMTP認証の設定

Postfix-2.x 以降であれば、[SASL](http://ja.wikipedia.org/wiki/Simple_Authentication_and_Security_Layer) によるSMTP認証 _SMTP-AUTH_ に対応しています。

あらかじめ `postmap` コマンドでパスワードデータベースを作成します。

    # relayhost の値は main.cf と完全一致している必要があります。
    % cat /etc/postfix/sasl_password
    [smtp.example.net]:587   username:password

    # sasl_password.db を作成します
    % postmap hash:/etc/postfix/sasl_password
    % ls /etc/postfix/sasl_password.*
    sasl_password.db

`main.cf` に、SMTP認証の設定を追記します。作成しておいたパスワードデータベース `sasl_password.db` を指定します。

    relayhost = [smtp.example.net]:587

    smtp_sasl_auth_enable = yes
    # 拡張子 .db は不要
    smtp_sasl_password_maps = hash:/etc/postfix/sasl_password
    # デフォルト値は noanonymous, noplaintext のため、AUTH PLAIN を有効にする
    smtp_sasl_security_options = noanonymous

    # サポートされていれば STARTTLS を使う
    smtp_tls_CAfile = /etc/pki/tls/cert.pem
    smtp_tls_security_level = may
    smtp_tls_loglevel = 1

設定を読み込み、送信確認を行ないます。

    % postfix reload
    % echo "test sasl" | mail -s "Tesing SMTP-AUTH" foo@example.net

`SASL authentication failure: No worthy mechs found` となる場合には、必要な認証方式に対応していません。

    % less /var/log/maillog
    ... SASL authentication failure: No worthy mechs found ...

RHEL系の yum では `cyrus-sasl` パッケージを利用するようになっていますが、特に追加インストールしていない場合、必要なライブラリがインストールされていない場合があります。

    % postconf -a
    cyrus
    ...

    # ANONYMOUS（認証しないゲストアクセス）しかインストールされていない
    % ls /usr/lib/sasl2
    libanonymous.la  libanonymous.so  libanonymous.so.2  libanonymous.so.2.0.22

`cyrus-sasl-*` パッケージで認証方式を追加できます。

* cyrus-sasl-plain: `PLAIN|LOGIN`
* cyrus-sasl-md5: `CRAM-MD5|DIGEST-MD5`

利用可能な認証方法が不明な場合 `telnet` で `EHLO` コマンドを送信して調べる事ができます。

    % telnet smtp.example.net 587
    ...
    EHLO localhost.localdomain
    ...
    250-AUTH PLAIN LOGIN
    250 STARTTLS
    ...
    QUIT

上記の応答の場合 `AUTH PLAIN` または `AUTH LOGIN` です。`cyrus-sasl-plain` を追加インストールします。

    % yum install cyrus-sasl-plain

