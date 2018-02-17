# Installation

## rvm + ruby-1.9.x

Rails3 には Ruby 1.9 が必要です。rvm でインストールする手順です。

    % curl -L "get.rvm.io" | bash -s stable

    # rvm requirements:
    % yum install gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison

    # nokogiri:
    % yum install libxml2-devel libxslt-devel

    % rvm install 1.9.3 -C --with-opt-dir=$HOME/.rvm/usr
    % rvm use 1.9.3


## bundler

bundler を使って Rails 環境を作る手順です。gem パッケージをプロジェクトディレクトリ内に持ちます。

Rails プロジェクトのディレクトリ直下に `.rvmrc` を置いておきます。この方法で常に ruby-1.9.x に切り替わるようにしておきます。

    % mkdir /path/to/rails/sandbox
    % cd /path/to/rails/sandbox
    % vi .rvmrc
    rvm use 1.9.3

    # cd . した時に .rvmrc が読み込まれます。初回は Warning が表示されます。
    % cd .
    ...
    y[es], n[o], v[iew], c[ancel]> y
    Using .../.rvm/gems/ruby-1.9.3-p286

`Gemfile` を作成します。

    source 'https://rubygems.org'

    gem 'therubyracer', '0.10.2'
    gem 'unicorn', '4.4.0'

    gem 'rails', '3.2.8'

    gem 'mysql2', '0.3.11'

    # Gems used only for assets and not required
    # in production environments by default.
    group :assets do
      gem 'sass-rails', '3.2.5'
      gem 'coffee-rails', '3.2.2'
      gem 'uglifier', '1.2.3'
    end

    gem 'jquery-rails', '2.0.2'

    group :development, :test do
      gem 'rspec-rails', '2.11.0'
      gem 'spork', '0.9.2'
    end

    group :development do
      gem 'pry-rails', '0.2.2'
    end

上記例は以下のパッケージ構成になります。

* JavaScript runtime に `therubyracer` を利用
* アプリケーションサーバに `unicorn` を利用
* データベースに `mysql2` を利用
* テストツールに `rspec-rails` `spork` を利用
* コンソールに `pry-rails` を利用

`bundle install` で gem パッケージをインストールします。`--path` オプションで `vendor/bundle` 以下にインストールするようにします。

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

`rails` コマンドは `bundle exec` を付与して実行できます。

    % rails --version
    /usr/bin/which: no rails in ..
    # bundle exec 経由で rails コマンドが実行できます。
    % bundle exec rails --version
    Rails 3.2.8

カレントディレクトリに Rails プロジェクトを作成します。

    # -d 利用するデータベースを指定
    # --skip-test-unit テストツールに Test::Unit を利用しない
    % bundle exec rails new . -d mysql --skip-test-unit
           exist
          create  README.rdoc
          create  Rakefile
          create  config.ru
          create  .gitignore

`Gemfile` の上書きが確認されますが `n - No` を選択します。

        conflict  Gemfile
    Overwrite /path/to/rails/sandbox/Gemfile? (enter "h" for help) [Ynaqdh]

`rails server` でサーバを起動します。`http://(ホスト名):3000` で確認できます。

    % bundle exec rails server

`CTRL-C` でサーバを停止します。
