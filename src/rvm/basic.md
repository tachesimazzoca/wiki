---
layout: page

title: 基本操作
---

## バージョン一覧

    % rvm list
    # インストール可能なバージョンを確認
    % rvm list known

## 指定バージョンのインストール

`rvm install (パッケージ名)` で、指定バージョンのソース取得/ビルド/パッチまで行ってくれます。`~/.rvm/rubies/` に保存されます。

    % rvm install ruby-1.8.7
    ...
    % rvm install ruby-1.9.2
    ...

## バージョン切替

    % rvm use ruby-1.8.7
    % ruby --version
    ruby 1.8.7 (2012-02-08 patchlevel 358) [i686-linux]

    % rvm use ruby-1.9.2
    % ruby --version
    ruby 1.9.2p320 (2012-04-20 revision 35421) [i686-linux]

環境変数の書き換えにより、バージョン切り換えが行われていることがわかります。

    % env
    ...
    GEM_HOME=.../.rvm/gems/ruby-1.8.7-p358
    ...
    IRBRC=.../.rvm/rubies/ruby-1.8.7-p358/.irbrc
    ...
    PATH=.../.rvm/gems/ruby-1.8.7-p358/bin:...
    rvm_env_string=ruby-1.8.7-p358
    rvm_ruby_string=ruby-1.8.7-p358
    ...
    GEM_PATH=.../.rvm/gems/ruby-1.8.7-p358:...
    ...
    RUBY_VERSION=ruby-1.8.7-p358
    ...

## ライブラリの手動追加

`rvm requirements` により確認できる必要なパッケージがインストールされていないと、ライブラリ不足でエラーとなります。この場合は、ライブラリを手動で再インストールすることで解決します。

    % yum install openssl-devel

    % cd ~/.rvm/src/ruby-1.8.7-p358/ext/openssl
    % ruby extconf.rb
    % make
    % make install

