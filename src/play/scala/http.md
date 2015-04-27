---
layout: page

title: HTTP
---

## Overview

* https://www.playframework.com/documentation/2.3.x/HttpApi

## Result

`play.api.mvc.Result` は、HTTP レスポンスを表す。ボディ部は `Enumerator[Array[Byte]]` になっており、すべてのボディ部をメモリに格納することなく、ストリームとして出力エンジンに受け渡せる。

{% highlight scala %}
case class Result(header: ResponseHeader, body: Enumerator[Array[Byte]],
    connection: HttpConnection.Connection = HttpConnection.KeepAlive)
{% endhighlight %}

`Content-Type: text/plain` を返す HTTP レスポンスは以下のようになる。

{% highlight scala %}
import play.api.http.HeaderNames._
import play.api.libs.iteratee._
import play.api.mvc._
...
val response: Result = Result(
  header = ResponseHeader(200, Map(CONTENT_TYPE -> "text/plain")),
  body = Enumerator("Hello World".getBytes())
)
{% endhighlight %}

`HttpConnection.Connection` は接続リソースではなく、`Connection: (keep-alive|close)` ヘッダの _Enum_ である。明示的に `Connection: close` を送信したい場合を除いて、デフォルト値の `HttpConnection.KeepAlive` のままでよい。

### Writeable

ボディ部の `Array[Byte]` への変換のために、`play.api.http.Writeable[E]` に各タイプ毎の暗黙関数が定義されている。

{% highlight scala %}
import play.api.http.Writeable

def enumerator[E](in: E)(implicit w: Writeable[E]): Enumerator[Array[Byte]] = {
  Enumerator(w.transform(in))
}
val enumratorFromStr: Enumerator[Array[Byte]] = enumerator("Hello")
val enumratorFromXml: Enumerator[Array[Byte]] = enumerator(<foo>bar</foo>)
{% endhighlight %}

### Status

`Result` インスタンスの生成には、通常は `play.api.mvc.Results._` のヘルパーメゾッドを使えばよい。ボディ部は `Writeable[E]` により、暗黙的に `Array[Byte]` に変換される。

{% highlight scala %}
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
val withQueryString = Redirect("/path/to/url",
    Map("foo" -> Seq("bar", "baz")))
{% endhighlight %}

