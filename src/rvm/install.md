---
layout: page

title: インストール
---

<https://get.rvm.io> へアクセスすると、bash スクリプトにリダイレクトされることがわかります。

このスクリプトを bash コマンドに渡すことで、ログインユーザの `~/.rvm` ディレクトリ以下に RVM がインストールされます。

    % curl -L "get.rvm.io" | bash -s stable

`~/.bashrc` `~/.zshrc` に `~/.rvm/bin` へのコマンド検索パスが追加されています。

    PATH=$PATH:$HOME/.rvm/bin

`~/.bashrc` `~/.zlogin` に RVM 用のスクリプトが追加されていることが分かります。シェルログイン時に必要な環境変数が設定されます。

    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

これによりユーザディレクトリ以下の `~/.rvm` を見るようになります。

    % which rvm
    ~/.rvm/bin/rvm

`root` ユーザでインストールした場合には、`/root/.rvm` ではなく `/usr/local/rvm` 以下にインストールされます。`/etc/profile.d/rvm.sh` に、ユーザ共通のログインスクリプトが追加され `~/.rvm` のディレクトリが存在しないユーザは `/usr/local/rvm` を見るようになります。

    % which rvm
    /usr/local/rvm/bin/rvm

`rvm requirements` で必要なパッケージを教えてくれます。以下は CentOS 5.8 の例です。

    % rvm requirements

    Requirements for Linux ( CentOS release 5.8 (Final) )

    NOTE: 'ruby' represents Matz's Ruby Interpreter (MRI) (1.8.X, 1.9.X)
                 This is the *original* / standard Ruby Language Interpreter
          'ree'  represents Ruby Enterprise Edition
          'rbx'  represents Rubinius

    bash >= 4.1 required
    curl is required
    git is required (>= 1.7 for ruby-head)
    patch is required (for 1.8 rubies and some ruby-head's).

    To install rbx and/or Ruby 1.9 head (MRI) (eg. 1.9.2-head),
    then you must install and use rvm 1.8.7 first.

    Additional Dependencies:
    # For Ruby / Ruby HEAD (MRI, Rubinius, & REE), install the following:
      ruby: yum install -y gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel ## NOTE: For centos >= 5.4 iconv-devel is provided by glibc

    # For JRuby, install the following:
      jruby: yum install -y java

`For Ruby / Ruby HEAD (MRI, Rubinius, & REE), install the following:` にあるパッケージをあらかじめインストールしておきます。`iconv-devel` は `NOTE: For centos >= 5.4 iconv-devel is provided by glibc` とありますので除外します。

    % yum install gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison

