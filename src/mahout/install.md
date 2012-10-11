---
layout: page

title: Install
---

## mahout-distribution

<http://www.apache.org/dyn/closer.cgi/mahout/>

にリンクされているミラーサイトからダウンロードします。

任意のディレクトリに展開し `bin/` ディレクトリにパスを通すだけです。

    % mkdir ~/.mahout
    % cd ~/.mahout
    % curl -L "http://ftp.riken.jp/net/apache/mahout/0.7/mahout-distribution-0.7.tar.gz"
    % tar xvfz mahout-distribution-0.7.tar.gz

    % vi ~/.bash_profile
    ...
    export PATH=$HOME/.mahout/mahout-distribution-0.7/bin:$PATH
    export MAHOUT_JAVA_HOME=/usr/local/java
    ...

