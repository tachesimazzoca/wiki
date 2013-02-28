---
layout: page

title: インストール
---
## Unix

以下の2つのファイルが必要になります。

* `sbt-launch.jar`
* `sbt-launch.jar` を起動するシェルスクリプト = `sbt` コマンド

`sbt-launch.jar` を [typesafe のリポジトリ](http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.12.2/) から取得します。

    % curl -LO "http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.12.2/sbt-launch.jar"

同ディレクトリに、以下のシェルスクリプトで `sbt-launch.jar` を起動する `sbt` コマンドを作成します。

    #!/bin/sh

    java -Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=384M -jar `dirname $0`/sbt-launch.jar "$@"

32bit OS で JavaVM のメモリ制限にかかる場合は -Xmx (ヒープの最大サイズ) を下げます。

    java -Xms512M -Xmx1024M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=384M -jar `dirname $0`/sbt-launch.jar "$@"

作成した `sbt` コマンドにパスを通しておきます。以下の例では `~/.sbt/bin` に設置しています。

    % vi ~/.bash_profile
    ...
    export PATH=~/.sbt/bin:${PATH}
    ...

    % source ~/.bash_profile
    % which sbt
    ~/.sbt/bin/sbt

## Links

### Setup - sbt Documentation

* <http://www.scala-sbt.org/release/docs/Getting-Started/Setup.html>

