---
layout: page

title: WS
---

## Overview

* https://www.playframework.com/documentation/2.3.x/ScalaWS
* https://github.com/AsyncHttpClient/async-http-client

_WS API_ は非同期の HTTP クライアントを提供する。コアには含まれないため、パッケージの追加が必要になる。

{% highlight scala %}
libraryDependencies ++= Seq(
  ws
)
{% endhighlight %}

## WSClient

ヘルパーメゾッド `play.api.libs.ws.WS.client` より、アプリケーション内に _WSPlugin_ 経由でロードされている HTTP クライアント `play.api.libs.ws.WSClient` が得られる。

{% highlight scala %}
val client: WSClient = WS.client
{% endhighlight %}

この HTTP クライアントはリクエスト毎に作られるのではない。アプリケーションが持つインスタンスは一つで、`WSClient#url` より `play.api.libs.ws.WSRequestHolder` をリクエスト毎に得る。一つの HTTP クライアントがアプリケーション上に常駐し、複数のリクエスト送信とレスポンス取得を非同期に行うと考えればよい。

{% highlight scala %}
val client: WSClient = WS.client
val holder1: WSRequestHolder = client.url("http://sv1.example.net/feed")
val holder2: WSRequestHolder = client.url("http://sv2.example.net/feed")
val response1: Future[WSResponse] = holder1.get()
val response2: Future[WSResponse] = holder2.get()
Future.firstCompleteOf(Seq(response1, response2)).map { response =>
  ...
}
{% endhighlight %}

複数の HTTP クライアントが必要なら、`WS.client` とは別にインスタンスを作成する。

{% highlight scala %}
val config: AsyncHttpClientConfig = ...
val customClient: WSClient = new NingWSClient(config)
...
customeClient.close()
{% endhighlight %}

注意すべき点として、プラグインによりロードされた `WS.client` は、アプリケーションの終了時に `WSPlugin#onStop` で自動的に閉じられるが、独自に作成した _WSClient_ は各自で `WSClient#close` を行なう必要がある。

### underlying

`WSClient#underlying[T]` により、HTTP クライアントの実装元エンジンを取得できる。`WSRequestHolder` がカバーしていない機能を直接利用したい時に利用する。

{% highlight scala %}
import com.ning.http.client.AsyncHttpClient
...
val asyncHttpClient = WS.client.underlying[AsyncHttpClient]
println(asyncHttpClient.getConfig.getMaxRequestRetry)
{% endhighlight %}

## NingWSClient

デフォルトの `WSClient` は、_Java_ ライブラリの _AsyncHttpClient_ による実装の `play.api.libs.ws.ning.NingWSClient` になる。

{% highlight scala %}
import play.api.libs.ws._
import play.api.libs.ws.ning.NingAsyncHttpClientConfigBuilder

val clientConfig = DefaultWSClientConfig(
  requestTimeout = Some(1000L),
  userAgent = Some("Mozilla/5.0 (...")
)
val builder = new com.ning.http.client.AsyncHttpClientConfig.Builder()
  .setMaxRequestRetry(0)
val config = new NingAsyncHttpClientConfigBuilder(clientConfig, builder).build()

val client = new NingWSClient(config)
val response: Future[WSResponse] = client.url("http://ws.example.net").get()
client.close()
{% endhighlight %}

* `NingAsynHttpClientConfigBuilder` を使って `AsyncHttpClientConfig` を組み立てる。
* `WSClientConfig` だけではカバーしていない _AsyncHttpClient_ 独自のオプションを指定したい場合は、第二引数に `AsyncHttpClientConfig.Builder` を渡す。

## WS

HTTP リクエスト `WSRequestHolder` を作成する場合、 通常はヘルパーメゾッド `WS.url` を使えばよい。HTTP クライアントは `WS.client` が使われる。

{% highlight scala %}
val holderWithDefaultClient: WSRequestHolder = WS.url("http://example.net")
{% endhighlight %}

`WS.clientUrl` を使うと、暗黙パラメータで `WSClient` を指定できる。

{% highlight scala %}
val config: AsyncHttpClientConfig = ...
implicit val implicitClient = new NingWSClient(config)
...
val holderWithImplicitClient: WSRequestHolder = WS.clientUrl("http://example.net")
{% endhighlight %}

## WSRequestHolderMagnet

`WSRequestholder` の生成に _Magnet_ パターンが使える。`WSRequestHolderManet` を引数とした `WS.url` がオーバーロードされている。

{% highlight scala %}
def url(magnet: WSRequestHolderMagnet): WSRequestHolder = magnet()
{% endhighlight %}

`WSRequestHolderMagnet` からの暗黙変換を定義しておけば、任意の引数で `WSRequestHolder` を作成できる。

{% highlight scala %}
object URLMagnet {
  private val anotherClient = ...

  implicit def fromURL(url: java.net.URL) = new WSRequestHolderMagnet {
    def apply(): WSRequestHolder = {
      val urlString = url.toString
      if (urlString.startsWith("https://"))
        anotherClient.url(urlString)
      else
        WS.client.url(urlString)
    }
  }

  def close(): Unit = {
    anotherClient.close()
  }
}

import scala.language.implicitConversions
import URLMagnet._

// via URLMagnet.anotherClient
val httpsHolder = WS.url(new java.net.URL("https://secure.exmaple.net"))
// via WS.client
val httpHolder = WS.url(new java.net.URL("http://exmaple.net"))
...
URLMagnet.close()
{% endhighlight %}

