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

`play.api.libs.iteratee.Done[E, A]` により、どのような入力があっても固定の結果を返す _Iteratee_ を生成できる。`Input.EOF` が送られた時に、最終の出力結果を返すために用いられる。

{% highlight scala %}
val doneIt = Done[String, Int](123, Input.Empty)
// Whatever the type of input, it will print Success(123)
Iteratee.flatten(doneIt.feed(Input.EOF)).run.onComplete(println)
Iteratee.flatten(doneIt.feed(Input.Empty)).run.onComplete(println)
Iteratee.flatten(doneIt.feed(Input.El("345"))).run.onComplete(println)
{% endhighlight %}

### ContIteratee

`play.api.libs.iteratee.Cont[E, A])` は、継続する _Iteratee_ を生成できる。入力に応じた次の _Iteratee_ を返す関数 `Input[E] => Iteratee[E, A]` を `apply` メゾッドに渡せばよい。

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
  // returns Error(msg, e) whatever the type of Input.
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

_DoneIteratee_ の `fold` の実装は、以下と同等である。

{% highlight scala %}
// val doneIteratee = Done[String, Int](1, Input.Empty)
val doneIteratee = new Iteratee[String, Int] {
  def fold[B](folder: Step[String,Int] => Future[B])
             (implicit ec: ExecutionContext) : Future[B] =
    folder(Step.Done(1, Input.Empty))
}
{% endhighlight %}

