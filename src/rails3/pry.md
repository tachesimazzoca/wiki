---
layout: page

title: Pry
---
## 概要

* [Pry](http://pryrepl.org/)

## Gemfile

    group :development do
      gem 'pry-rails', '0.2.2'
    end

## 使い方

`rails console` コマンドで `irb` の代わりに `pry` が起動します。

    % bundle exec rails c
    Loading development environment (Rails 3.2.8)
    [1] pry(main)>

