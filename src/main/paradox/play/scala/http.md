# HTTP

## Overview

* https://www.playframework.com/documentation/2.3.x/HttpApi

## Result

`play.api.mvc.Result` は、HTTP レスポンスを表す。ボディ部は `Enumerator[Array[Byte]]` であり、すべてのボディ部をメモリに格納することなく、ストリームとして出力エンジンに受け渡せる。

```scala
case class Result(header: ResponseHeader, body: Enumerator[Array[Byte]],
    connection: HttpConnection.Connection = HttpConnection.KeepAlive)
```

`Content-Type: text/plain` を返す HTTP レスポンスは以下のようになる。

```scala
import play.api.http.HeaderNames._
import play.api.libs.iteratee._
import play.api.mvc._
...
val response: Result = Result(
  header = ResponseHeader(200, Map(CONTENT_TYPE -> "text/plain")),
  body = Enumerator("Hello World".getBytes())
)
```

`HttpConnection.Connection` は接続リソースではなく、`Connection: (keep-alive|close)` ヘッダの _Enum_ である。明示的に `Connection: close` を送信したい場合を除いて、デフォルト値の `HttpConnection.KeepAlive` のままでよい。

### Writeable

ボディ部の `Array[Byte]` への変換のために、`play.api.http.Writeable[E]` に各タイプ毎の暗黙関数が定義されている。

```scala
import play.api.http.Writeable

def enumerator[E](in: E)(implicit w: Writeable[E]): Enumerator[Array[Byte]] = {
  Enumerator(w.transform(in))
}
val enumratorFromStr: Enumerator[Array[Byte]] = enumerator("Hello")
val enumratorFromXml: Enumerator[Array[Byte]] = enumerator(<foo>bar</foo>)
```

### Status

`Result` インスタンスの生成には、通常は `play.api.mvc.Results.Status` のヘルパーメソッドを使えばよい。ボディ部は `Writeable[E]` により、暗黙的に `Array[Byte]` に変換される。

```scala
// Result(123, Map(Content-Type -> text/plain; charset=utf-8))
val status = Status(123)("One-Two-Three")
// Result(200, Map(Content-Type -> text/html; charset=utf-8))
val ok = Ok("<html><body><p>Hello World!</p></body></html>").as(HTML)

// Result(200, Map(Content-Type -> application/xml; charset=utf-8))
val notFound = NotFound(<message>Page not found</message>)
// Result(503, Map())
val serverError = ServiceUnavailable

// Result(303, Map(Location -> /path/to/url))
val seeOther = SeeOther("/path/to/url")
// Result(301, Map(Location -> /path/to/url))
val movedPermanetly = Redirect("/path/to/url", MOVED_PERMANENTLY)
// Result(303, Map(Location -> /path/to/url?foo=bar&foo=baz))
val withQueryString = Redirect("/path/to/url", Map("foo" -> Seq("bar", "baz")))
```

### Chunked Transfer Encoding

ファイル送信を行なうには、ヘルパーメソッドの `Status.sendFile` を使えばよい。

```scala
val file = new java.io.File(getClass.getResource("/a.txt").getPath())
Ok.sendFile(
  content = file,
  inline = false,
  fileName = "download-a.txt"
)
```

* `inline`: `Content-Disposition` ヘッダを付与しない（ダウンロードファイルとして送信しない）
* `fileName`: `Content-Disposition` ヘッダの `filename` 属性（ダウンロードファイル名）

ファイルのように、ボディ部のサイズが大きい場合は注意が必要である。`Content-Length` ヘッダ値の算出のために、全てのボディ部をメモリに入れる必要があり、`Enumerator` を利用している意味がない。

独自に `Result` を組み立てる場合は、ボディ部のサイズを予め取得して `Content-Length` 値に指定しておく必要がある。

```scala
val file = new java.io.File(getClass.getResource("/a.txt").getPath())
Result(
  header = ResponseHeader(OK, Map(
    CONTENT_DISPOSITION -> "attachment; filename=a.txt",
    CONTENT_TYPE -> "application/octet-stream",
    CONTENT_LENGTH -> file.length().toString())),
  body = Enumerator.fromFile(file)
)
```

入力ソースが `java.io.InputStream` のように、あらかじめボディ部のサイズを得る事ができない場合は `Transfer-Encoding: chunked` で送信する。

ヘルパーメソッドの `Status.chunked` により、Chunked 形式で送信できる。

```scala
val input = getClass.getResourceAsStream("/a.txt")
  Ok.chunked(Enumerator.fromStream(input)).withHeaders(
    CONTENT_DISPOSITION -> "attachment; filename=a.txt",
    CONTENT_TYPE -> "application/octet-stream"
  )
}
```

独自に `Result` を組み立てたい場合は、`Results.chunked` により得られる `Enumeratee[Array[Byte], Array[Byte]]` を利用して Chunked 形式に変換する。`Status.chunked` のソースを参考にするとよい。

```scala
def chunked[C](content: Enumerator[C])(implicit writeable: Writeable[C]): Result = {
  Result(header = ResponseHeader(status,
    writeable.contentType.map(ct => Map(
      CONTENT_TYPE -> ct,
      TRANSFER_ENCODING -> CHUNKED
    )).getOrElse(Map(
      TRANSFER_ENCODING -> CHUNKED
    ))
  ),
    body = content &> writeable.toEnumeratee &> chunk,
    connection = HttpConnection.KeepAlive)
}
```

## Request

`play.api.mvc.Request` は、HTTP リクエストを表す。 _Action_ を通じて引数として得るのみで、アプリケーション側で組み立てることはない。

```scala
object Request {
  def apply[A](rh: RequestHeader, a: A): Request[A]
  ...
}
```

テスト時にモックを作りたい場合は、`play.api.test.FakeRequest` を使う。テストがしやすいように `withHeaders` などのメソッドが追加されている。

```scala
val rh: Request[NodeSeq] = FakeRequest("POST", "/create")
    .withHeaders("X-Requested-With" -> "0123456789abcdef")
    .withBody(<foo>bar</foo>)
```

`FakeRequest` ではボディ部も指定できるが _BodyParser_ で変換されたと仮定される `Request#body` である。HTTP リクエストのボディ部のバイト列や文字列ではない。 _BodyParser_ をテストするときは _Enumerator_ でボディ部を送る。

```scala
val it = parse.xml(FakeRequest().withHeaders(CONTENT_TYPE -> "application/xml"))
(Enumerator("<foo>bar</foo>".getBytes) |>>> it)
    .onComplete(println) // Success(Right(<foo>bar</foo>))
```
