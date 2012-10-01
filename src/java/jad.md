---
layout: page

title: JAD Java Decompiler
---

## 概要

**JAD Java Decompiler Download Mirror**

<http://www.varaneckas.com/jad/>

## Unix

jad コマンドを実行するだけです。

    % jad A.class
    # .java ファイルを上書きしないように、デフォルトでは .jad で書き出されます。
    % ls A.*
    A.class A.jad

    # -p オプションで標準出力に出力されます。
    % jad -p B.class > B.java
    % ls B.*
    B.class B.java

以下のエラーが表示される場合は `libstdc++-libc6.2-2.so.3` が含まれていません。

    jad: error while loading shared libraries: libstdc++-libc6.2-2.so.3: cannot open shared object file: No such file or directory

`libstdc++-libc6.2-2.so.3` が含まれるパッケージを yum でインストールする例です。

    % yum provides libstdc++-libc6.2-2.so.3

    ....

    compat-libstdc++-296-2.96-138.i386 : Compatibility 2.96-RH standard C++ libraries
    Repo        : base
    Matched from:
    Other       : libstdc++-libc6.2-2.so.3

    ....

    % yum install compat-libstdc++-296

