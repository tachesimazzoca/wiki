---
layout: page

title: Filters
---

## Overview

* https://www.playframework.com/documentation/2.3.x/ScalaHttpFilters
* https://www.playframework.com/documentation/2.3.x/ScalaInterceptors
* https://www.playframework.com/documentation/2.3.x/ScalaLogging
* https://www.playframework.com/documentation/2.3.x/ScalaCsrf
* https://www.playframework.com/documentation/2.3.x/GzipEncoding
* https://www.playframework.com/documentation/2.3.x/SecurityHeaders

## Filter

`play.api.mvc.Filter` により、アプリケーション共通のフィルタ処理を記述できる。

{% highlight scala %}
object LoggingFilter extends Filter {
  override def apply(f: (RequestHeader) => Future[Result])
                    (rh: RequestHeader): Future[Result] = {
    val startTime = System.currentTimeMillis
    f(rh).map { result =>
      val ua = rh.headers.get("User-Agent").getOrElse("-")
      val ms = System.currentTimeMillis - startTime
      val line = s"""${rh.remoteAddress} ${rh.method} ${rh.uri} ${result.header.status} ${ua} ${ms}"""
      Logger.info(line)
      result
    }
  }
}

// or just use the helper method "Filter"
val noopFilter = Filter { (next, rh) =>
  next(rh)
}
{% endhighlight %}

_Global_ オブジェクトを `play.api.GlobalSetting` から `play.api.mvc.WithFilters` に置き換えて、_Filter_ を指定する。

{% highlight scala %}
object Global extends WithFilters(LoggingFilter, CSRFFilter()) {
}
{% endhighlight %}

`play.api.mvc.ActionBuilder` でも同様のことができるが、ユースケースごとフィルタ処理にとどめ、この _Filter_ をログやアクセス制限などのアプリケーション全体のために用いるとよい。

## EssentialFilter

`play.api.mvc.EssentialFilter` は、`EssentialAction` を返すフィルタになる。

`EsssitialAction` の実体は `(RequestHeader) => Iteratee[Array[Byte], Result]` であるので、_Iteratee_ の前段、すなわちリクエストボディ部 `Array[Byte]` に  _Enumeratee_ を適用できる。例えば gzip 圧縮されたリクエストボディ部を解凍する事が出来る。

{% highlight scala %}
import play.filters.gzip.Gzip

val gunzipFilter = new EssentialFilter {
  override def apply(next: EssentialAction) = new EssentialAction {
    override def apply(rh: RequestHeader): Iteratee[Array[Byte], Result] = {
      if (rh.headers.get(CONTENT_ENCODING).exists(_ === "gzip")) {
        val gunzip: Enumeratee[Array[Byte], Array[Byte]] = Gzip.gunzip()
        gunzip &>> next(rh)
      } else next(rh)
    }
  }
}
{% endhighlight %}

リクエストボディ部の変換が必要なければ、`play.api.mvc.Filter` を使えば良い。

