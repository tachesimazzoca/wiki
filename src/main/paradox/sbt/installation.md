# Installation

## Universal Package

[sbt 公式 の Universal package](https://bintray.com/sbt/native-packages/sbt/view) を利用することを推奨します。[Bintray](https://bintray.com) で配布されています。

### Unix

Universal package を _dotfiles_ でインストールする例です。`~/.sbt` 以下にダウンロードし解凍します。

    % mkdir ~/.sbt
    % cd .sbt
    % curl -LO "http://dl.bintray.com/sbt/native-packages/sbt/0.13.5/sbt-0.13.5.zip"
    % unzip sbt-0.13.5.zip

`~/.sbt/sbt/bin/sbt` が _sbt_ を起動する bash スクリプトになります。

    # -h オプションでヘルプを表示します
    % ~/.sbt/sbt/bin/sbt -h

`~/.bash_profile` で、この `sbt` コマンドへのパスを通しておきます。

    % vi ~/.bash_profile
    ...
    export PATH=~/.sbt/sbt/bin:${PATH}
    ...

    % source ~/.bash_profile
    % which sbt
    ~/.sbt/sbt/bin/sbt


## Manual Installation

`sbt-launch.jar` を [typesafe のリポジトリ](http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/) から取得します。

    % curl -LO "http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.5/sbt-launch.jar"

同ディレクトリに、以下のシェルスクリプトで `sbt-launch.jar` を起動する `sbt` コマンドを作成します。

    #!/bin/sh

    SBT_OPTS="java -Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=256M"
    java $SBT_OPS -jar `dirname $0`/sbt-launch.jar "$@"

32bit OS で JavaVM のメモリ制限にかかる場合は -Xmx (ヒープの最大サイズ) を下げます。

    SBT_OPS="-Xms512M -Xmx1024M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=256M"

## Links

* [sbt - Download](http://www.scala-sbt.org/download.html)
