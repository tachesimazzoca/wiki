---
layout: page

title: 基本操作
---

## プロジェクト作成

以下の構成でファイル/ディレクトリをあらかじめ作成します

* buid.sbt
* project/build.properties
* src/main/java/
* src/main/scala/
* src/main/resources/
* src/test/java/
* src/test/scala/
* src/test/resources/
* lib/

`build.sbt` にプロジェクトの情報を記載しておきます。

    name := "sandbox"

    version := "1.0"

    scalaVersion := "2.10.4"

`project/build.properties` に sbt の情報を記載しておきます。

    sbt.version=0.13.5

ソースは `src/main/(java|scala)` に置きます。`src/main/scala/Sandbox.scala` を作成してみます。

    object Sandbox {
      def main(args:Array[String]) {
         println("Hello World")
      }
    }

プロジェクトディレクトリ直下で `sbt` コマンドを実行するとインタラクティブモードでコンソールが立ち上がります。初回起動時は必要なパッケージがダウンロードされます。

    % cd /path/to/sbt/project/sandbox
    % sbt
    ...
    [info] Done updating.
    [info] Set current project to sandbox (in build file:...)
    >

`run` でコンパイルが行われ main ブロックが実行されます。

    > run
    [info] Compiling 1 Scala source to ...
    [info] Running Sandbox
    [success] Total time: ....
    Hello World

`compile` でコンパイルのみ行われます。先頭に `~` を付けるとファイル更新を検知して、自動でコンパイルしてくれます。

    > ~compile
    1. Waiting for source changes... (press enter to interrupt)


### lib/

`sbt` で管理しない jar パッケージは、`lib/` に置いておきます。自動で `-classpath` を通してくれます。


### src/main/resources

データファイル関連は `src/main/resources` に置きます。

`src/main/resources/sandbox.properties` を読み込む `src/main/scala/Sandbox.scala` のサンプルコードです。

    import java.io.FileInputStream
    import java.util.Properties

    import scala.collection.JavaConversions._

    object Sandbox {
      def main(args:Array[String]) {

        val prop = new Properties()
        prop.load(getClass().getResourceAsStream("/sandbox.properties"))

        prop.stringPropertyNames().foreach { key =>
          println(prop.getProperty(key))
        }
      }
    }

