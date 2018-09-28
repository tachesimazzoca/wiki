#Actions

## Overview

* https://www.playframework.com/documentation/2.3.x/ScalaActions
* https://www.playframework.com/documentation/2.3.x/HttpApi

## EssentialAction

トレイト`play.api.mvc.EssentialAction` の実体は、HTTP リクエストヘッダ `play.api.mvc.RequestHeader` を引数とし、`Iteratee[Array[Byte], Result]` を返す関数である。

```scala
trait EssentialAction extends (RequestHeader => Iteratee[Array[Byte], Result])
```

`Array[Byte]` は HTTP ボディ部のチャンクにあたる。ストリームとしてボディ部を受け取り、どのように `Result` を組み立てるかを _Iteratee_ として定義する。

## Action

トレイト `play.api.mvc.Action[A]` は `EssentialAction` を継承している。

すなわち `RequestHeader` を受け取り `Iteratee[Array[Byte], Result]` を返す関数であり、実装は `play.api.mvc.BodyParser[+A]` を介して行なっている。

```scala
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
```

`BodyParser` の実体は `RequestHeader` を受け取り `Itereatee[Array[Byte], Either[Result, A]]` を返す関数である。

* 失敗時の `Left` は、直接エラー応答の `Result` となる。
* 成功時の `Right` は、ボディ部で、`Action#apply(request: Request[A])` を介して `Result` を得る。

`parser` に、ボディ部が渡っていないのが疑問に思いがちだが、返すのは _Iteratee_ であって、どのようにボディ部 `Array[Byte]` から出力 `A` を組み立てるかの定義だけである。ボディ部は、然るべき _Enumerator_ からストリーム送信されるのであって _BodyParser_  が全てのボディ部を得るのではない。

### Helper Methods

ヘルパーメソッド `Action.apply` を使って `Action#apply(request: Request[A])` を実装できる。

```scala
def noRequest: Action[AnyContent] = Action {
  Ok("Hello")
}
def withDefaultContent: Action[AnyContent] = Action { result =>
  Ok("Request: " + request)
}
```

明示的に `Future[Result]` で返したい場合は `Action.async` を使う。

```scala
import play.api.libs.ws._

def wsAction = Action.async {
  WS.url("http://foo.example.net").get().map { response =>
    Ok(response.body)
  }
}
```

`Action.async` は非同期処理用ではなく、明示的に `Future[Result]` を返したい場合のヘルパーメソッドである。いずれのヘルパーメソッドを使ったとしても、実装される `Action#apply(request: Request)` が返すのは `Future[Result]` であり、どちらも非同期に実行されることに違いはない。

`Future` を使えば、自動的にノンブロッキングとなるのではない。ブロックする処理を書かなければいけない場合は、コアのスレッドを占有しないように、別の `ExecutionContext` を使う必要がある。

```scala
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
```

## BodyParser

基本的な _BodyParser_ は、あらかじめ `play.api.mvc.BodyParsers.parse` に定義されている。

デフォルトの _BodyParser_ は `parse.anyContent` が使われる。ボディ部は `play.api.mvc.AnyContent` になる。

```scala
def xmlFormat = Action { request =>
  request.body.asXml map { xml =>
    Ok(...)
  }.getOrElse {
    BadRequest(..)
  }
}
```

ヘルパーメソッド `Action.apply[A](parser: BodyParser[A])(...)` を使うと、ボディ部を明示的に指定できる。 不正なリクエストの場合は _Action_ ブロックには渡らず _BadReqeust_ 400 エラーが直接応答される。

```scala
def xmlOnly = Action(parse.xml) { request => ... }
```

`tolerant` がついているものは、リクエストヘッダのチェックを行なわず、ボディ部がパースできればエラーとならない。

```scala
def xmlOnly = Action(parse.torelantXml) { request => ... }
```

### file / temporaryFile / multipartFormData

`parse.file` を用いるとボディ部をファイルに保存できる。指定した `java.io.File` がボディ部になる。

```scala
val parser = parse.file(to = new java.io.File("/path/to/a.txt"))
```

`parse.temporaryFile` は一時ファイルで保存できる。`play.api.libs.Files.TemporaryFile` がボディ部になる。`TemporaryFIle` のメソッドは、旧 Java File API によるもののため _Deprecated_ となっている。

フォームからのファイルアップロード `multipart/form-data` 形式には、`parse.multipartFormData` を使う。

```scala
val upload = Action(parse.multipartFormData) { request =>
  request.body.file("pic").map { part =>
    val temp: TemporaryFile = part.ref
    val file: java.io.File = temp.file
    ...
    Ok(...)
  }.getOrElse {
    BadRequest(...)
  }
}
```

ファイルサイズに制限をかけたい場合は、ヘルパーメソッド `parse.maxLength` を使う。ボディ部は `Either[MaxSizeexceeded, A]` となる。

```scala
// up to 4096 bytes
val upload = Action(parse.maxLength(4096, parse.multipartFormData)) { request =>
  request.body match {
    case Left(MaxSizeExceeded(len)) => ...
    case Right(multipartFormdata) => ...
  }
}
```

## ActionBuilder

ヘルパーオブジェクト `Action` の実体は、トレイト `play.api.mvc.ActionBuilder[Request]` である。

```scala
object Action extends ActionBuilder[Request] {
  def invokeBlock[A](request: Request[A],
                     block: (Request[A]) => Future[Result]) = block(request)
}
```

同様に `ActionBuilder` を実装すれば、独自のヘルパーオブジェクトを作成できる。

```scala
object AppAction extends ActionBuilder[Request] {
  override def invokeBlock[A](request: Request[A],
                              block: (Request[A]) => Future[Result]): Future[Result] = {
    if (request.remoteAddress.equals("127.0.0.1")) {
      block(request).map { result =>
        result.withHeaders("X-UA-Compatible" -> "Chrome=1")
      }
    } else Future.successful(Forbidden) // localhost only
  }
}

val action = AppAction {
  Ok("...")
}
```

_ActionBuilder_ は `ActionBuilder#andThen` で連結できる。`Request` は外側から、`Future[Result]` は内側から伝播する。

```scala
val action = (LoggingAction andThen SecureAction) {
  Ok("...")
}
```

以下の様に _Action_ をラップしてもよい。

```scala
case class Logging[A](action: Action[A]) extends Action[A] {
  override def apply(request: Request[A]): Future[Result] = {
    Logger.info("...")
    action(request)
  }

  lazy val parser = action.parser
}

def action = Logging {
  Action {
    Ok("...")
  }
}
```

`Action.async` ブロック内で、元の `Action#apply` を呼ぶ方法でもよい。元の _BodyParser_ もみ消さないように明示する必要がある。

```scala
def logging(action: Action[A]): Action[A] =
  Action.async(action.parser) { request =>
    Logger.info("...")
    action(request)
  }
```

`ActionBuilder#composeAction` に _Action_ をラップする関数を指定できる。共通の前後処理をパーツ化しておいて、組み替えることで、コードを再利用できる。

```scala
def onlyHttps(action: Action[A]): Action[A] = ...
def loggingErrors(action: Action[A]): Action[A] = ...

object AppAction extends ActionBuilder[Request] {
  override def invokeBlock[A](request: Request[A],
                              block: (Request[A]) => Future[Result]) = {
    block(request)
  }

  override protected def composeAction[A](action: Action[A]): Action[A] =
    onlyHttps(loggingErrors(action))
}
```

## ActionRefiner

`play.api.mvc.ActionRefiner[R, P]` により _ActionBuilder_ の `Request` 型を変換できる。

`Future[Either[Result, P[A]]]` を返す `ActionRefiner#refine[A](request: R[A])` を実装する。`UserRequest` のコンストラクタの第一引数 `Request[A]` は、継承元の `WrappedRequest` に引き渡す引数になるので、重複してインスタンス変数に持つ必要はない。


```scala
case class User(id: Long, name: String)

object User {
  def find(id: Long): Option[User] = ???
}

class UserRequest[A](request: Request[A], val user: User) extends WrappedRequest[A](request)

val UserAction = new ActionRefiner[Request, UserRequest] {
  override protected def refine[A](request: Request[A]): Future[Either[Result, UserRequest]] =
    Future.successful {
      (for {
        userid <- request.sessions.get("userid")
        id <- java.lang.Long.parseLong(userid, 10)
        user <- User.find(id)
      } yield new UserRequest(request, user)).toRight(Forbidden)
    }
}

val action = (Action andThen UserAction) { userRequest =>
  Ok("Hello " + userRequest.user.name)
}
```

### ActionTransformer

`Request` 型の変換に際して例外が起こらないなら、`play.api.mvc.ActionTransformer[R, P]` を使えばよい。

```scala
class UserRequest[A](request: Request[A],
                     val lang: Lang,
                     val robot: Boolean) extends WrappedRequest[A](request)
object UserAction extends ActionTransformer[Request, UserRequest] {
  override protected def transform[A](request: Request[A]): Future[UserRequest[A]] =
    Future.successful {
      val lang: Lang = ...
      val robot: Booean = ...
      new UserRequest(request, lang, robot)
    }
  }
}
```

### ActionFilter

例外チェックのみを行ないたいなら `play.api.mvc.ActionFilter[R]` を使えばよい。例外時に `Some[Result]` を返すことで _Action_ ブロックを経由せずに直接応答する。正常時には `None` を返せばよい。

```scala
object RemoteAddressFilter extends ActionFilter[Request] {
  override protected def filter[A](request: Request[A]) =
    Future.successful {
      if (request.remoteAddress.equals("127.0.0.1")) None
      else Some(Forbidden)
    }
}
```
