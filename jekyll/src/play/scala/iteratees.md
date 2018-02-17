---
layout: page

title: Iteratees
---

## Overview

* https://www.playframework.com/documentation/2.3.x/Iteratees

`play.api.libs.iteratee.Iteratee[E, +A]` は入力から出力を組み立てる _Consumer_ となる。単に入力 `E` に対して、どのように出力 `A` を組み立てるかのみを定義する。

ヘルパーメゾッド `Iteratee.fold[E, A]` により、アキュームレータ `A` と入力 `E` から、出力 `A` を返す関数を指定するだけで `Iteratee[E, A]` を実装できる。

{% highlight scala %}
val it: Iteratee[String, Int] = Iteratee.fold[String, Int](0) { (acc, x) =>
  acc + x.toInt
}
{% endhighlight %}

`play.api.libs.iteratee.Enumerator[E]` は `Iteratee` に入力を与える _Producer_ となる。

{% highlight scala %}
val result: Future[Int] = Enumerator("1", "2", "3") |>>> it
result.onComplete(println) // Success(6) ... 1 + 2 + 3
{% endhighlight %}

## Iteratee

_Iteratee_ は、一つのインスタンスで連続する入力を処理する（ループ等を繰り返す）のではない。ステップ毎に新たな _Iteratee_ を生成して引き継いでいく。

### Input

`play.api.libs.iteratee.Input` は _Iteratee_ に送る入力を表す。

{% highlight scala %}
trait Input[+E]

object Input {
  case class El[+E](e: E) extends Input[E]
  case object Empty extends Input[Nothing]
  case object EOF extends Input[Nothing]
}
{% endhighlight %}

* `Input.El(e)` は入力があることを示す: _Iteratee_ は入力を出力に変換し、次の _Iteratee_ に引き継ぐ。
* `Input.Empty` は入力がないことを示す: _Iteratee_ は何もせずに、次の _Iteratee_ に引き継ぐ。
* `Input.EOF` は入力の終端を示す: _Iteratee_ は処理結果を返す。

### DoneIteratee

`play.api.libs.iteratee.Done[E, A]` により、どのような入力があっても固定の結果を返す _Iteratee_ を生成できる。`Input.EOF` が送られた時に、最終の出力結果を返すために用いる。

{% highlight scala %}
val doneIt = Done[String, Int](123, Input.Empty)
// It will print Success(123) regardless of the type of input.
Iteratee.flatten(doneIt.feed(Input.EOF)).run.onComplete(println)
Iteratee.flatten(doneIt.feed(Input.Empty)).run.onComplete(println)
Iteratee.flatten(doneIt.feed(Input.El("345"))).run.onComplete(println)
{% endhighlight %}

### ContIteratee

`play.api.libs.iteratee.Cont[E, A])` により、継続する _Iteratee_ を生成できる。入力に応じた次の _Iteratee_ を返す関数 `Input[E] => Iteratee[E, A]` を `apply` メゾッドに渡せばよい。

{% highlight scala %}
def step(acc: Int)(in: Input[String]): Iteratee[String, Int] = in match {
  // Add the number converted from a string to the state
  case Input.El(e: String) => Cont(step(acc + e.toInt))
  // Keep the state
  case Input.Empty => Cont(step(acc))
  // Done iteration
  case Input.EOF => Done(acc, Input.EOF)
}

val contIt = Cont[String, Int](step(0))
Iteratee.flatten(contIt.feed(Input.EOF)).run
  .onComplete(a => assert(Success(0) === a))
Iteratee.flatten(contIt.feed(Input.El("123"))).run
  .onComplete(a => assert(Success(123) === a))

(for {
  it1 <- contIt.feed(Input.El("12"))
  it2 <- it1.feed(Input.El("34"))
  it3 <- it2.feed(Input.Empty)
  it4 <- it3.feed(Input.El("56"))
  a <- it4.run
} yield a).onComplete(println) // Success(102) ... 12 + 34 + 56
{% endhighlight %}

### ErrorIteratee

`play.api.libs.iteratee.Error[E]` により、エラーを返す _Iteratee_ を生成できる。`Done` と同様に、この _Iteratee_ に引き継がれた場合は、以降の入力は無視される。

{% highlight scala %}
def step(acc: Int)(in: Input[String]): Iteratee[String, Int] = in match {
  case Input.El(e: String) =>
    if (!e.isEmpty) Cont(step(acc + e.toInt))
    else Error("empty string", Input.Empty)
  case Input.Empty => Cont(step(acc))
  case Input.EOF => Done(acc, Input.EOF)
}

(for {
  it1 <- errorIt.feed(Input.El("12"))
  it2 <- it1.feed(Input.El(""))
  // The following feed will be ignored because it just
  // returns Error(msg, e) regardless of the type of input.
  it3 <- it2.feed(Input.El("56"))
  a <- it3.run
} yield a).onComplete(println) // Failure(java.lang.RuntimeException: empty string)
{% endhighlight %}

### Step

独自の _Iteratee_ を作成するには、`Iteratee#fold` メゾッドを実装する。

{% highlight scala %}
def fold[B](folder: Step[E, A] => Future[B])
           (implicit ec: ExecutionContext) : Future[B]
{% endhighlight %}

`fold` メゾッドにより、`folder` 関数を通じて、_Iteratee_ は、自身がどのステップ `play.api.libs.iteratee.Step` であるかを伝えて処理結果を得る。

{% highlight scala %}
trait Step[E, +A]

object Step {
  case class Done[+A, E](a: A, remaining: Input[E]) extends Step[E, A]
  case class Cont[E, +A](k: Input[E] => Iteratee[A, E]) extends Step[E, A]
  case class Error[E](msg: String, input: Input[E]) extends Step[E, Nothing]
}
{% endhighlight %}

`folder` 関数はどのようなものかは、`Iteratee#run` の実装を参考にするとよい。_ContIteratee_ であれば、`Input.EOF` を送って処理結果を得ている。

{% highlight scala %}
def run: Future[A] = fold({
  case Step.Done(a, _) => Future.successful(a)
  case Step.Cont(k) => k(Input.EOF).fold({
    case Step.Done(a1, _) => Future.successful(a1)
    case Step.Cont(_) => sys.error("diverging iteratee after Input.EOF")
    case Step.Error(msg, e) => sys.error(msg)
  })(dec)
  case Step.Error(msg, e) => sys.error(msg)
})(dec)
{% endhighlight %}

_Done / Cont / Error_ の各 _Iteratee_ の `fold` の実装は、以下と同等である。

{% highlight scala %}
val k(in: Step): Iteratee[String, Int] = in match {
  ...
}
// val contIteratee = Cont[String, Int](k)
val contIteratee = new Iteratee[String, Int] {
  def fold[B](folder: Step[String,Int] => Future[B])
             (implicit ec: ExecutionContext) : Future[B] =
    folder(Step.Cont(k))
}

// val doneIteratee = Done[String, Int](1, Input.Empty)
val doneIteratee = new Iteratee[String, Int] {
  def fold[B](folder: Step[String,Int] => Future[B])
             (implicit ec: ExecutionContext) : Future[B] =
    folder(Step.Done(1, Input.Empty))
}

// val errorIteratee = Error[String]("something wrong", Input.Empty)
val errorIteratee = new Iteratee[String, Int] {
  def fold[B](folder: Step[String,Int] => Future[B])
             (implicit ec: ExecutionContext) : Future[B] =
    folder(Step.Error("something wrong", Input.Empty)
}
{% endhighlight %}

### Helper Methods

#### consume

{% highlight scala %}
val it: Iteratee[String, String] = Iteratee.consume[String]()
val result: Future[String] = Enumerator("foo", "bar", "baz") |>>> it
result.onComplete(println) // foobarbaz
{% endhighlight %}

#### foreach

{% highlight scala %}
val it: Iteratee[String, Unit] = Iteratee.foreach[String](prinln)
Enumerator("foo", "bar", "baz") |>>> it
// foo
// bar
// baz
{% endhighlight %}

#### flatten

継続する _Iteratee_ は、遅延評価で非同期に得るため `Future[Iteratee[E, A]]` となる。`Iteratee#run` で `Input.EOF` を送るには、`flatMap` や _for-comprehension_ を介して行なう必要がある。

{% highlight scala %}
val it: Iteratee[String, String] = Iteratee.consume[String]()
val newIt: Future[Iteratee[String, String]] = Enumerator("foo", "bar") |>> it
val result: Future[String] = newIt.flatMap(_.run)
{% endhighlight %}

`Iteratee.flatten` は `Iteratee#fold` 内部で `flatMap` を行う `Iteratee` を生成する。あたかも初回の _Iteratee_ のように振る舞う。

{% highlight scala %}
val futureIt: Iteratee[String, String] = Iteratee.flatten(newIt)
val result: Future[String] = futureIt.run
{% endhighlight %}

## Enumerator

_Enumerator_ は、_Iteratee_ に送る入力ストリームを生成する。

{% highlight scala %}
val enumerator1: Enumerator[String] = Enumerator("foo", "bar")
val enumerator2: Enumerator[String] = Enumerator("baz", "qux")
val enumerator = enumerator1.andThen(enumerator2)

val it: Iteratee[String, String] = Iteratee.consume[String]()
val newIt: Future[Iteratee[String, String]] = enumerator(it)

val result: Future[String] = Iteratee.flatten(newIt).run
result.onComplete(println) // foobarbazqux
{% endhighlight %}

### >>> (andThen)

`Enumerator#andThen` で _Enumerator_ を連結することができる。エイリアスとして `Enumerator#>>>` が提供されている。

{% highlight scala %}
val enumerator1: Enumerator[String] = Enumerator("foo", "bar")
val enumerator2: Enumerator[String] = Enumerator("baz", "qux")
//val enumerator = enumerator1.andThen(enumerator2)
val enumerator = enumerator1 >>> enumerator2
{% endhighlight %}

### |>> (apply)

`Enumerator#apply` に _Iteratee_ を渡す事で、`Future[Iteratee[E, A]]` が得られる。`Iteratee#feed` は内部的には同等のことを行なっている。エイリアスとして `Enumerator#|>>` が提供されている。

{% highlight scala %}
val it: Iteratee[String, String] = Iteratee.consume[String]()
val enumerator: Enumerator[String] = Enumerator("Foo", "Bar", "Baz")
//val newIt: Future[Iteratee[String, String]] = enumerator(it)
val newIt: Future[Iteratee[String, String]] = enumerator |>> it
{% endhighlight %}

### |>>> (run)

`Enumerator#|>>>` により、入力ストリームの送信後に `Input.EOF` を送信して処理結果を得ることができる。

{% highlight scala %}
val it: Iteratee[String, String] = Iteratee.consume[String]()
val enumerator: Enumerator[String] = Enumerator("Foo", "Bar", "Baz")
//val result: Future[String] = enumerator(it).flatMap(_.run)
val result: Future[String] = enumerator |>>> it
{% endhighlight %}

`Future[Iteratee[E, A]]` のまま `flatMap` で `Iteratee#run` を送って `Future[B]` を得るので、`Iteratee` に置き換える `Iteratee.flatten` とは異なる。

{% highlight scala %}
val newIt: Future[Iteratee[String, String]] = enumerator |>> it
val futureIt: Iteratee[String, String] = Iteratee.flatten(newIt)
val result: Future[String] = futureIt.run
{% endhighlight %}

### Helper Methods

#### repeatM / generateM

_Enumerator_ は、無限の入力ストリームを扱うことができる。`Enumerator.repeatM` に `Future[E]` を返す関数を渡すことで、無限に反復実行される。

{% highlight scala %}
import play.api.libs.concurrent.Promise
...
val dateEnumerator: Enumerator[Date] = Enumerator.repeatM {
  Promise.timeout(new Date(), 1.seconds)
}
{% endhighlight %}

`Enumerator.generateM` では、`Future[Option[E]]` を返す関数を渡すことで、`None` の場合に反復実行を停止する。

{% highlight scala %}
val endOfTime = System.currentTimeMillis() + 3000L
val dateEnumerator: Enumerator[Date] = Enumerator.generateM {
  Promise.timeout({
    if (System.currentTimeMillis() < endOfTime) Some(new Date())
    else None
  }, 1.seconds)
}
{% endhighlight %}

#### fromStream / fromFile

`Enumerator.fromStream` では `java.io.InputStream` を入力ソースとすることができる。内部的には `Enumerator.generateM` を用いており、読み込み中に `Some[Array[Byte]]` を返し、読み込み完了後に `None` を返している。

{% highlight scala %}
val streamEnumerator: Enumerator[Array[Byte]] = {
  Enumerator.fromStream(new FileInputStream(new File("/path/to/file")))
}
// or use Enumerator.fromFile
val fileEnumerator: Enumerator[Array[Byte]] = {
  Enumerator.fromFile(new File("/path/to/file"))
}
{% endhighlight %}

## Enumeratee

`plap.api.libs.iteratee.Enumeratee[From, To]` により、ストリームデータを変換をすることができる。

ヘルパーメゾッド `Enumeratee.map` に変換関数を渡せば、_Enumeratee_ を生成できる。

{% highlight scala %}
val byteToHexStr: Enumeratee[Byte, String] = Enumeratee.map[Byte] { b =>
  "%02X".format(b)
}
{% endhighlight %}

### &>> (transform)

`Enumeratee#transform` により、前段に変換を加えた _Iteratee_ を生成できる。エイリアスとして `Enumeratee#&>>` が提供されている。

{% highlight scala %}
val consume: Iteratee[String, String] = Iteratee.consume[String]()
//val it = byteToHexStr.transform(consume)
val it: Iteratee[Byte, String] = byteToHexStr &>> consume
{% endhighlight %}

### &> (through)

_Enumeratee_ は _Enumerator_ に対しても適用できる。`Enumerater#through` により、後段に変換を加えた _Enumerator_ を生成できる。エイリアスとして `Enumerator#&>` が提供されている。

{% highlight scala %}
// Make sure that either "&>" or "through" is defined
// on Enumerator, not on Enumeratee.

val enumerator = Enumerator("Hello".getBytes())
//val hexStrEnumerator = enumerator.through(byteHexStr)
val hexStrEnumerator: Enumerator[Byte] = enumerator &> byteToHexStr
{% endhighlight %}

### apply

元の _Iteratee_ がすでに `EOF` を受けて完了していた場合、`Enumeratee#transform` で _Iteratee_ を変換したところで、その後の入力は破棄されてしまう。

{% highlight scala %}
val sum = Iteratee.fold[Int, Int](0) { (acc, x) =>
  acc + x
}
val strToInt = Enumeratee.map[String](_.toInt)

val doneIt = Iteratee.flatten(Enumerator(1, 2) >>> Enumerator.eof |>> sum)
// The iteratee doneIt has been done,
Iteratee.isDoneOrError(doneIt).onComplete(println) // Success(true)
val transformedIt = strToInt &>> doneIt
// so any inputs after that will be ignored.
(Enumerator("3", "4", "5") |>>> transformedIt).onComplete(println) // Success(3)
{% endhighlight %}

`Enumeratee#apply` は、変換前の _Iteratee_ を出力とする _Iteratee_ を生成する。

{% highlight scala %}
// The method apply returns Iteratee[String, Iteratee[Int, Int]],
val adaptedIt: Iteratee[String, Iteratee[Int, Int]] = strToInt(sum)
// so we can get the original iteratee after the adaptedIt is done.
val originalIt: Interatee[Int, Int] = Iteratee.flatten(
    Enumerator("1", "2") |>>> adaptedIt)
// The original iteratee has not been done yet because it's just
// an output of the adaptedIt.
Iteratee.isDoneOrError(originalIt).onComplete(println) // Success(false)
(Enumerator(3, 4, 5) |>>> originalIt).onComplete(println) // Success(15)
{% endhighlight %}

変換した _Iteratee_ を `EOF` で完了させた後でも、出力は変換元の _Iteratee_ であるので、入力を継続できる。すなわち _Enumeratee_ を切り替えながら、異なる _Enumerator_ からの入力を _Iteratee_ にまとめることができる。

### Traversable

`Enumeratee.(take|drop|takeWhile|dropWhile|...)` 等のヘルパーメゾッドは、他のコレクション API のように、要素を切り出す _Enumeratee_ を生成できる。

ただし切り出し位置は _Enumerator_ から送信されるチャンク単位になる。

{% highlight scala %}
val it = Iteratee.fold[Array[Byte], String]("") { (acc, x) =>
  acc ++ x.map(_.toChar).mkString("")
}

val enumerator = Enumerator(
  "123".getBytes(),
  "456".getBytes(),
  "789".getBytes()
)

def limitChunks(n: Int) = {
  Enumeratee.take[Array[Byte]](n)
}
(enumerator |>>> limitChunks(2) &>> it)
  .onComplete(println) // Success("123456")
{% endhighlight %}

入力が `scala.collection.TraversableLike` を含んでいれば、`play.api.iteratee.Traversable` を使うことで、`TraversableLike` の実装に応じて切り出し位置を決定する。つまり `Array[Byte]` なら、配列インデックスでカウントされる。

{% highlight scala %}
def limitBytes(n: Int) = {
  Traversable.take[Array[Byte]](n)
}
(enumerator |>>> limitBytes(5) &>> it)
  .onComplete(println) // Success("12345")
{% endhighlight %}
