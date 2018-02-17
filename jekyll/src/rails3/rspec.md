---
layout: page

title: RSpec Rails + Spork
---
## 概要

* [RSpec Rails](https://github.com/rspec/rspec-rails)
* [Spork](https://github.com/sporkrb/spork)

## Gemfile

    group :development, :test do
      gem 'rspec-rails', '2.11.0'
      gem 'spork', '0.9.2'
    end

## 初期設定

はじめに `rspec-rails` の初期設定を行います。

    % bundle exec rails g rspec:install

これにより

* `rake spec` のタスク追加
* `spec/spec_helper.rb` の追加

が行われます。その後 `spork` の初期設定を行います。

    % bundle exec spork --bootstrap

`spec/spec_helper.rb` に以下のコードが追加されます。

    require 'spork'

    Spork.prefork do
      # Spork サーバ起動時の処理を記述
    end

    Spork.each_run do
      # テスト毎に実行する処理を記述
    end

必要に応じて、`Spork.prefork` `Spork.each_run` のブロックに初期化処理を記述しておきます。

## テストの実行

あらかじめ、テストサーバ Spork を起動しておきます。

    % bundle exec spork

`--drb` オプションを付けることで、テストサーバ経由で `rspec` を実行します。

    % bundle exec rspec --drb /path/to/spec

