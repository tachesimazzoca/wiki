---
layout: plain

title: rbenv
---

## Installation

    % git clone https://github.com/sstephenson/rbenv.git ~/.rbenv

    % vi ~/.bash_profile
    ...
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
    ....
    % source ~/.bash_profile
    % rbenv -v
    rbenv 0.4.0-89-g14bc162

    # For upgrading it, simply pull the origin repository.
    % cd ~/.rbenv
    % git pull

then install `ruby-build` plugin which provides `rbenv install` command.

    % git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    % rbenv help install
    ...


## Usage

### install/uninstall

    % rbenv install -l
    ...
    ruby-2.0.0p353
    2.0.0-preview1
    2.0.0-preview2
    ...

    % CONFIGURE_OPTS="--disable-install-doc" rbenv install 2.0.0-p353

    % rbenv uninstall 2.0.0-p353


### versions/version

    % rbenv versions
    * 2.0.0-p353 (set by /home/vagrant/.rbenv/version)
    ....
    % rbenv version
    * 2.0.0-p353 (set by /home/vagrant/.rbenv/version)


### global/local

    % rbenv global 2.0.0-p353

    # Sets a local application-specific Ruby version
    % cd /path/to/local/project
    % rbenv local 2.0.0-p353
    % cat .ruby-version
    2.0.0-p353

## RubyGems

    % echo 'gem: --no-ri --no-rdoc' >> ~/.gemrc


### Bundler

You should install `bundler` manually by using the `gem` command, if you need it.

    % rbenv exec gem install bundler
    ...
    % rbenv rehash
    % rbenv which bundle
    /home/vagrant/.rbenv/versions/2.0.0-p353/bin/bundle

    % cd /path/to/bundler/project
    % vi Gemfile
    ....
    % bundle install --path vendor/bundle

