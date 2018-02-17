# I/O

## Apache Commons IO

実際のプログラミングでは、[Apache Commons IO](http://commons.apache.org/proper/commons-io/) を利用、あるいは参考にするとよいでしょう。

_java.io_ の基本が詰まっているので、ぜひソースを読んでおく事を推奨します。

* [org.apache.commons.io.IOUtils](http://grepcode.com/file/repo1.maven.org/maven2/commons-io/commons-io/2.4/org/apache/commons/io/IOUtils.java)
* [org.apache.commons.io.FileUtils](http://grepcode.com/file/repo1.maven.org/maven2/commons-io/commons-io/2.4/org/apache/commons/io/FileUtils.java)

## InputStream / OutputStream

* [java.io.InputStream](http://docs.oracle.com/javase/6/docs/api/java/io/InputStream.html)
* [java.io.OutputStream](http://docs.oracle.com/javase/6/docs/api/java/io/OutputStream.html)

により `byte` 単位での入出力を行うことができます。

```java
public static void copy(
        InputStream input, OutputStream output) throws IOException {
    byte[] buffer = new byte[4096];
    int n = 0;
    while (-1 != (n = input.read(buffer))) {
        output.write(buffer, 0, n);
    }
}
```

* [java.io.BufferedInputStream](http://docs.oracle.com/javase/6/docs/api/java/io/BufferedInputStream.html)
* [java.io.BufferedOutputStream](http://docs.oracle.com/javase/6/docs/api/java/io/BufferedOutputStream.html)

は内部バッファを持ちます。都度、ストリームを介すのではなく、内部バッファにデータを溜め込んでおくことで、効率的にストリームにアクセスします。

`BufferedOutputStream#write` ではバッファに溜め込むだけで、実際に出力が行われるわけではありません。以下の条件で出力が行われます。

* バッファがいっぱいになった時
* `BufferedOutputStream#flush` メゾッドにより、任意のタイミングでバッファを出力
* `BufferedOutputStream#close` メゾッドにより、ストリームを閉じる際にバッファを出力

## Reader / Writer

* [java.io.Reader](http://docs.oracle.com/javase/6/docs/api/java/io/Reader.html)
* [java.io.Writer](http://docs.oracle.com/javase/6/docs/api/java/io/Writer.html)

により `char` 単位での入出力を行うことができます。

```java
public static void copy(
        Reader input, Writer output) throws IOException {
    char[] buffer = new char[4096];
    int n = 0;
    while (-1 != (n = input.read(buffer))) {
        output.write(buffer, 0, n);
    }
}
```

* [java.io.BufferedReader](http://docs.oracle.com/javase/6/docs/api/java/io/BufferedReader.html)
* [java.io.BufferedWriter](http://docs.oracle.com/javase/6/docs/api/java/io/BufferedWriter.html)

は、バイトストリーム同様、`char` 型の内部バッファを持ち、効率的にストリームにアクセスします。
