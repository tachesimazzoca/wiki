---
layout: page

title: 入出力
---
## バイトストリーム

* [java.io.InputStream](http://docs.oracle.com/javase/6/docs/api/java/io/InputStream.html)
* [java.io.OutputStream](http://docs.oracle.com/javase/6/docs/api/java/io/OutputStream.html)

によりバイト単位での入出力を行うことができます。

    // input.dat から output.dat へファイルコピー
    FileInputStream fis = new FileInputStream("/path/to/input.dat");
    FileOutputStream fos = new FileOutputStream("/path/to/output.dat");

    int b;
    while ((b = fis.read()) != -1) {
        // 1バイトづつ読み書き
        System.out.println(String.format("%02X", b));
        fos.write(b);
    }

    fos.close();
    fis.close();

上記例では１バイトづつ読み書きを行っていますので非効率です。

* [java.io.BufferedInputStream](http://docs.oracle.com/javase/6/docs/api/java/io/BufferedInputStream.html)
* [java.io.BufferedOutputStream](http://docs.oracle.com/javase/6/docs/api/java/io/BufferedOutputStream.html)

を用いて、バッファを介して読み書きすることができます。

    FileInputStream fis = new FileInputStream("/path/to/input.dat");
    BufferedInputStream bis = new BufferedInputStream(fis);
    FileOutputStream fos = new FileOutputStream("/path/to/output.dat");
    BufferedOutputStream bos = new BufferedOutputStream(fos);

    byte[] buf = new byte[8]; // 8バイトづつ読み込み
    int len;
    while ((len = bis.read(buf)) != -1) {
        for (int i = 0; i < len; i++) {
            System.out.print(String.format("%02X ", buf[i]));
        }
        System.out.println();

        bos.write(buf, 0, len);
    }

    bos.flush(); // 溜めているバッファを出力します。
    bos.close();
    bis.close();

`BufferedOutputStream#write` ではバッファに溜め込むだけで、実際に出力が行われるわけではありません。以下の条件で出力が行われます。

* バッファがいっぱいになった時
* `BufferedOutputStream#flush` メゾッドにより、任意のタイミングでバッファを出力
* `BufferedOutputStream#close` メゾッドにより、ストリームを閉じる際にバッファを出力

## 文字ストリーム

Java では文字データは Unicode で扱われます。Unicode 以外の文字は、システムのエンコード方式 `System.getProperty("file.encoding")` に従い変換されます。

* [java.io.InputStreamReader](http://docs.oracle.com/javase/6/docs/api/java/io/InputStreamReader.html)
* [java.io.OutputStreamReader](http://docs.oracle.com/javase/6/docs/api/java/io/OutputStreamWriter.html)

により `char` 単位での入出力を行うことができます。

    // EUC-JP のテキストファイルを UTF-8 に変換
    FileInputStream fis = new FileInputStream("/path/to/euc.txt");
    InputStreamReader isr = new InputStreamReader(fis, "EUC-JP");
    FileOutputStream fos = new FileOutputStream("/path/to/utf8.txt");
    OutputStreamWriter osw = new OutputStreamWriter(fos, "UTF-8");

    int chr;
    while ((chr = isr.read()) != -1) {
        System.out.println(String.format("%c", chr));
        osw.write(chr);
    }

    osw.close();
    isr.close();

上記例では１文字づつ読み書きを行っていますので非効率です。

* [java.io.BufferedReader](http://docs.oracle.com/javase/6/docs/api/java/io/BufferedReader.html)
* [java.io.BufferedWriter](http://docs.oracle.com/javase/6/docs/api/java/io/BufferedWriter.html)

を用いて、バッファを介して読み書きすることができます。

    FileInputStream fis = new FileInputStream("/path/to/euc.txt");
    InputStreamReader isr = new InputStreamReader(fis, "EUC-JP");
    BufferedReader br = new BufferedReader(isr);
    FileOutputStream fos = new FileOutputStream("/path/to/utf8.txt");
    OutputStreamWriter osw = new OutputStreamWriter(fos, "UTF-8");
    BufferedWriter bw = new BufferedWriter(osw);

    char[] cbuf = new char[8]; // 8文字づつ読み込み
    int len;
    while ((len = br.read(cbuf)) != -1) {
        for (int i = 0; i < len; i++) {
            System.out.print(String.format("%c", cbuf[i]));
        }
        System.out.println();

        bw.write(cbuf, 0, len);
    }

    bw.flush(); // 溜めているバッファを出力します。
    bw.close();
    br.close();

`BufferedWriter#write` ではバッファに溜め込むだけで、実際に出力が行われるわけではありません。以下の条件で出力が行われます。

* バッファがいっぱいになった時
* `BufferedWriter#flush` メゾッドにより、任意のタイミングでバッファを出力
* `BufferedWriter#close` メゾッドにより、ストリームを閉じる際にバッファを出力

