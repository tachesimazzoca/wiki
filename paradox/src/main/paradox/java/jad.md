# JAD Java Decompiler

## Overview

* <http://www.varaneckas.com/jad/>

## Unix

    % jad A.class
    # .jad is decompiled source
    % ls A.*
    A.class A.jad

    # To output STDOUT, use -p option
    % jad -p B.class > B.java
    % ls B.*
    B.class B.java

If you get the following error, you need to install the shared library `libstdc++-libc6.2-2.so.3`.

    jad: error while loading shared libraries: libstdc++-libc6.2-2.so.3: cannot open shared object file: No such file or directory

Here is an example for yum package `libstdc++-libc6.2-2.so.3`:

    % yum provides libstdc++-libc6.2-2.so.3

    ....

    compat-libstdc++-296-2.96-138.i386 : Compatibility 2.96-RH standard C++ libraries
    Repo        : base
    Matched from:
    Other       : libstdc++-libc6.2-2.so.3

    ....

    % yum install compat-libstdc++-296
