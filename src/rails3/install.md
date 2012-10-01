---
layout: page

title: Install
---

## RVM + Bundler

RVM と Bundler を使ってプロジェクト毎に Rails 環境を作る手順です。`rvm gemset` で gem を管理する方法もありますが、本セクションでは RVM は Ruby のバージョン切替のみに利用し、プロジェクトに依存する gem は Bundler で管理します。

Rails プロジェクトのディレクトリ直下に `.rvmrc` を置いておくことで、同ディレクトリに `cd` した時に初期コマンドとして読み込まれます。

    % mkdir /path/to/rails/sandbox
    % cd /path/to/rails/sandbox
    % vi .rvmrc
    rvm use 1.9.2

    # cd した時に .rvmrc が読み込まれます。初回は Warning が表示されます。
    % cd .
    ...
    y[es], n[o], v[iew], c[ancel]> y
    Using .../.rvm/gems/ruby-1.9.2-p320

始めに `rails` のみインストールする `Gemfile` を作成します。

    source 'https://rubygems.org'

    gem 'rails', '3.2.6'

`bundle` コマンドでインストールします。`--path` オプションでプロジェクトディレクトリ直下の `vendor/bundle` にインストールするようにします。

    % ls -a
    . .. .rvmrc Gemfile

    % cd /path/to/rails/sandbox
    % bundle install --path vendor/bundle
    ...
    Installing railties (3.2.6)
    Installing rails (3.2.6)
    Your bundle is complete! It was installed into ./vendor/bundle
    ...

    % ls -a
    . .. .bundle/ .rvmrc Gemfile Gemfile.lock vendor/

Bundler でインストールした `rails` コマンドは `bundle exec` を付与して実行できます。

    % rails --version
    /usr/bin/which: no rails in ..
    # bundle exec 経由で rails コマンドが実行できます。
    % bundle exec rails --version
    Rails 3.2.6

`rails new (プロジェクト名)` でプロジェクトを作成します。`Gemfile` が上書き確認されますので `Y - yes` を選択します。

    # カレントディレクトリに mysql 利用の rails プロジェクトを作成
    % bundle exec rails new . -d mysql
           exist
          create  README.rdoc
          create  Rakefile
          create  config.ru
          create  .gitignore
        conflict  Gemfile
    Overwrite /path/to/rails/sandbox/Gemfile? (enter "h" for help) [Ynaqdh]

`jquery-rails` が見つからないと言われますが、もう一度 `bundle install` するとインストールできます。

    ..../.rvm/gems/ruby-1.9.2-p320@global/gems/bundler-1.1.4/lib/bundler/resolver.rb:287:in `resolve': Could not find gem 'jquery-rails (>= 0) ruby' in the gems available on this machine. (Bundler::GemNotFound)

    % bundle install

`config/database.yml` を利用データベース環境に合わせて設定します。設定したユーザに権限があれば `rake db:create` でデータベースを作成することもできます。

    % vim config/database.yml
    ...
    % bundle exec rake db:create
    % echo "SHOW DATABASES" | mysql -u root
    ...
    sandbox_develpment
    sandbox_test
    ...

V8 Node.js などの Javascript runtime がないと `rake` コマンドでエラーとなります。

    % bundle exec rake db:create
    rake aborted!
    Could not find a JavaScript runtime. See https://github.com/sstephenson/execjs for a list of available runtimes.

この場合は `Gemfile` に `therubyracer` (Google V8)を追加して `bundle install` します。

    % vim Gemfile
    ...
    gem "therubyracer"
    ...

    % bundle install
    Installing libv8 (3.3.10.4)
    ...
    Installing therubyracer (0.10.1) with native extensions
    ...

    % bundle exec rake db:create

`rails server` でサーバを起動します。

    # http://(ホスト名):3000/ で確認できます。
    % bundle exec rails server

