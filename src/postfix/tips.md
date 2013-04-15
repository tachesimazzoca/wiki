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
