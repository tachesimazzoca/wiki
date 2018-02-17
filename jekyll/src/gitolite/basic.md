---
layout: page

title: 基本操作
---

## gitolite-admin

`gitolite-admin` という管理用のリポジトリで権限設定を行います。

管理ユーザの SSH 秘密鍵を `~/.ssh/` 以下にコピーします。

    % cp /path/to/gitolite-adimn/private/key ~/.ssh/gitolite_admin.pem
    % chmod 600 ~/.ssh/gitolite_admin.pem

`~/.ssh/config` にて SSH のホスト設定を行っておきます。

    host gitolite-admin
        user gitolite
        hostname gitolite.example.net
        port 22
        identityfile ~/.ssh/gitolite_admin.pem

設定した SSH ホストから `gitolite-admin` リポジトリを取得します。

    % git clone ssh://gitolite-admin/gitolite-admin.git


## ユーザ追加

ユーザごとに SSH 鍵を作成します。

* 秘密鍵 `staff.pem`
* 公開鍵 `staff.pub`

を例にします。

公開鍵を `gitolite-admin/keydir/(ユーザ名).pub` として push することで追加されます。

    % cd /path/to/gitolite-admin/keydir
    % cp /path/to/new/id_rsa.pub staff.pub
    % git add staff.pub
    % git commit -m 'Add user staff'

ユーザ側は秘密鍵を使ってアクセスできるようになります。

    % vim ~/.ssh/config
    ...

    host gitolite-staff
        user gitolite
        hostname ....
        port 22
        identityfile ~/.ssh/staff.pem

    ...

    % git clone ssh://gitolite-staff/testing.git


## 権限設定

`gitolite-admin/conf/gitolite.conf` を編集し push することで反映されます。

    repo    gitolite-admin
            RW+     = admin

    repo    testing
            RW+     = @all


