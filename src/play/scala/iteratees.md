---
layout: page

title: Iteratees
---

## Overview

* https://www.playframework.com/documentation/2.3.x/Iteratees

`play.api.libs.iteratee.Iteratee[E, A]` は入力から出力を組み立てる _Consumer_ となる。単に入力 `E` に対して、どのように出力 `A` を組み立てるかのみを定義する。

ヘルパーメゾッド `Iteratee.fold[E, A]` により、アキュームレータ `A` と入力 `E` から、出力 `A` を返す関数を指定するだけで `Iteratee[E, A]` を実装できる。

{% highlight scala %}
val it: Iteratee[String, Int] = Iteratee.fold[String, Int](0) { (acc, x) =>
  acc + x.toInt 
}
{% endhighlight %}

`play.api.libs.iteratee.Enumerator[E]` は `Iteratee` に入力を与える _Producer_ となる。

{% highlight scala %}
val result: Future[Int] = Enumerator("1", "2", "3") |>>> it 
result.onComplete(a => println(a)) // Success(6) ... 1 + 2 + 3
{% endhighlight %}

## Input

`play.api.libs.iteratee.Input` は入力を表す。

{% highlight scala %}
object Input {
  case class El[+E](e: E) extends Input[E]
  case object Empty extends Input[Nothing]
  case object EOF extends Input[Nothing]
}
{% endhighlight %}

* `Input.El(e)` は入力の断片を示す: 処理を行なったのち、次の _Iteratee_ に引き継ぐ。
* `Input.Empty` は入力がないことを示す: 処理は行なわず、次の _Iteratee_ に引き継ぐ。
* `Input.EOF` はこれ以上入力がないことを示す: 処理を停止し、出力を得る。

## Step 

## Iteratee 

### DoneIteratee

### ContIteratee

### ErrorIteratee

