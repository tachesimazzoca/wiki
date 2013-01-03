---
layout: page

title: TIPS
---
## screen 上で利用

[Using RVM inside GNU Screen](https://rvm.io/workflow/screen/)

`~/.screenrc` に以下のコマンドを設定する

    shell -${SHELL}

## ruby-1.9.3 で yaml.rb の Warning

ruby-1.9.3 より YAML パーサに [psych](http://doc.ruby-lang.org/ja/1.9.3/library/psych.html) が採用されています。libyaml がインストールされていないと、以下の警告が出力され、代わりに [syck](http://doc.ruby-lang.org/ja/1.9.3/library/syck.html) が用いられます。

    It seems your ruby installation is missing psych (for YAML output).
    To eliminate this warning, please install libyaml and reinstall your ruby.

RVM は libyaml を `~/.rvm/usr` 以下にソースインストールしてくれるのですが、バージョンによってはコンパイルオプションが正常に渡らない場合があります。この場合は明示的にパス指定してインストールしなおします。

    % rvm pkg install libyaml
    % rvm reinstall 1.9.3 -C --with-libyaml-dir=$HOME/.rvm/usr

