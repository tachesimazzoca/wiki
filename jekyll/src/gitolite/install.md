---
layout: page

title: インストール
---

## gitolite-2.3

github からソースを取得します。2.3.x 系のブランチは `g2` になります。

    % cd /tmp
    % git https://github.com/sitaramc/gitolite.git
    % cd /tmp/gitolite
    % git checkout g2

`gitolite` ユーザを作成し、`gl-system-install` コマンドを実行します。

    % su -
    % useradd gitolite
    % su - gitolite
    % /tmp/gitolite/src/gl-system-install

 * `%HOME/bin`
 * `%HOME/share`

にインストールされます。`$HOME/bin` にパスが通っていなければ追加します。

    % su - gitolite
    % vim ~/.bash_profile
    ...
    export PATH=$PATH:$HOME:/bin
    ...
    % source ~/.bash_profile

    % which gl-setup
    ~/bin/gl-setup

gitolite 管理ユーザ用の SSH 鍵を作成します。ファイル名はユーザ名と同じにします。

    # admin ユーザの SSH鍵を作成します
    % ssh-keygen -t rsa
    Enter file in which to save the key (/home/gitolite/.ssh/id_rsa): /home/gitolite/.ssh/admin
    Enter passphrase (empty for no passphrase):
    Enter same passphrase again:
    Your identification has been saved in /home/gitolite/.ssh/admin.
    Your public key has been saved in /home/gitolite/.ssh/admin.pub.

公開鍵 `*.pub` へのファイルパスを指定して `gl-setup` を実行します。

    % gl-setup ~/.ssh/admin.pub

セットアップ間で `$HOME/.gitolite.rc` の編集画面が開きますが、特に変更せずそのまま保存します。以上でセットアップは完了です。

* `$HOME/.gitolite`
* `$HOME/repositries`
* `$HOME/projects.list`

が作成されています。

`$HOME/.ssh/authorized_keys` に `gl-setup` 時に指定した公開鍵が追加されています。通常の SSH 鍵でのログインとは異なり `gl-auth-command` が実行されます。

    # gitolite start
    command="/home/gitolite/bin/gl-auth-command admin",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa ...
    # gitolite end

公開鍵により gitolite ユーザを判別し、UNIX ユーザ `gitolite` が、実際に git リポジトリを操作することになります。

