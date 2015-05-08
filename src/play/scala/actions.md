---
layout: page

title: Actions
---

## Overview

* https://www.playframework.com/documentation/2.3.x/ScalaActions
* https://www.playframework.com/documentation/2.3.x/HttpApi

## EssentialAction

トレイト`play.api.mvc.EssentialAction` の実体は、HTTP リクエストヘッダ `play.api.mvc.RequestHeader` を引数とし、`Iteratee[Array[Byte], Result]` を返す関数である。

{% highlight scala %}
trait EssentialAction extends (RequestHeader => Iteratee[Array[Byte], Result])
{% endhighlight %}

`Array[Byte]` は HTTP ボディ部のチャンクにあたる。ストリームとしてボディ部を受け取り、どのように `Result` を組み立てるかを _Iteratee_ として定義する。

## Action

トレイト `play.api.mvc.Action[A]` は `EssentialAction` を継承している。

すなわち `RequestHeader` を受け取り `Iteratee[Array[Byte], Result]` を返す関数であり、実装は `play.api.mvc.BodyParser[+A]` を介して行なっている。

{% highlight scala %}
trait Action[A] extends EssentialAction {
  ...
  def parser: BodyParser[A]

  def apply(request: Request[A]): Future[Result]

  def apply(rh: RequestHeader): Iteratee[Array[Byte], Result] = parser(rh).mapM {
    case Left(r) =>
      Play.logger.trace("Got direct result from the BodyParser: " + r)
      Future.successful(r)
    case Right(a) =>
      val request = Request(rh, a)
      Play.logger.trace("Invoking action with request: " + request)
      Play.maybeApplication.map { app =>
        play.utils.Threads.withContextClassLoader(app.classloader) {
          apply(request)
        }
      }.getOrElse {
        apply(request)
      }
  }
  ...
}
{% endhighlight %}

`BodyParser` の実体は `RequestHeader` を受け取り `Itereatee[Array[Byte], Either[Result, A]]` を返す関数である。

* 失敗時の `Left` は、直接エラー応答の `Result` となる。
* 成功時の `Right` は、ボディ部で、`Action#apply(request: Request[A])` を介して `Result` を得る。

`parser` に、ボディ部が渡っていないのが疑問に思いがちだが、返すのは _Iteratee_ であって、どのようにボディ部 `Array[Byte]` から出力 `A` を組み立てるかの定義だけである。ボディ部は、然るべき _Enumerator_ からストリーム送信されるのであって、_BodyParser_  が全てのボディ部を得るのではない。

### Helper Methods

ヘルパーメゾッド `Action.apply` を使って `Action#apply(request: Request[A])` を実装できる。

{% highlight scala %}
def noRequest: Action[AnyContent] = Action {
  Ok("Hello")
}
def withDefaultContent: Action[AnyContent] = Action { result =>
  Ok("Request: " + request)
}
{% endhighlight %}

明示的に `Future[Result]` で返したい場合は `Action.async` を使う。

{% highlight scala %}
import play.api.libs.ws._

def wsAction = Action.async {
  WS.url("http://foo.example.net").get().map { response =>
    Ok(response.body)
  }
}
{% endhighlight %}

`Action.async` は非同期処理用ではなく、明示的に `Future[Result]` を返したい場合のヘルパーメゾッドである。いずれのヘルパーメゾッドを使ったとしても、実装される `Action#apply(request: Request)` が返すのは `Future[Result]` であり、どちらも非同期に実行されることに違いはない。

`Future` を使えば、自動的にノンブロッキングとなるのではない。ブロックする処理を書かなければいけない場合は、コアのスレッドを占有しないように、別の `ExecutionContext` を使う必要がある。

{% highlight scala %}
import play.api.libs.concurrent.Akka

implicit val expensiveOperations =
  Akka.system.dispatchers.lookup("contexts.expensive-operations")

// OK: To avoid blocking operation, use a separate execution context.
def search: Action[AnyContent] = Action.async {
  val job1 = Promise.timeout({ ... } 5.second)
  val job2 = Promise.timeout({ ... } 5.second)
  Future.firstCompleteOf(Seq(job1, job2) map { x =>
    ...
    Ok(...)
  }) (expensiveOperations)
}

// NG: The thread of defaultContext is going to block.
def block: Action[AnyContent] = Action.async {
  Future {
    Thread.sleep(10000L)
    Ok(...)
  }
}
{% endhighlight %}

