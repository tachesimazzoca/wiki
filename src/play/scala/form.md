---
layout: page

title: Form
---

## Overview

* <https://www.playframework.com/documentation/2.3.x/ScalaForms>

## Mapping

トレイト `play.api.data.Mapping[T]` により、フォーム入力 `Map[String, String]` とデータオブジェクトの変換ルールを定義し、相互変換を行なうことができる。

{% highlight scala %}
import play.api.data._
import play.api.data.Forms._
import play.api.data.format.Formats._
import play.api.data.validation.Constraints._

case class Item(id: Option[Long], code: String, name: String, price: Int)

val m: Mapping[Item] = mapping(
  "id" -> optional(longNumber),
  "code" -> text.verifying(pattern( """[A-Z][0-9]{5}""".r)),
  "name" -> nonEmptyText,
  "price" -> number(min = 1, max = 100000)
)(Item.apply)(Item.unapply)
{% endhighlight %}

`play.api.data.Forms.mapping` 関数を用いて、`ObjectMapping` を生成する。フィールド型を保つために、フィールド数に応じた `play.api.data.ObjectMapping(1..18)` が定義されている。

* 引数 1..n は `(String, Mapping)` で、フィールド毎のキーと変換ルールのペアを指定する。
* 引数 n+1 は `(A1, A2, ...) => R` で、タプルからデータオブジェクトを生成する関数を指定する。
* 引数 n+2 は `(R) => Option[(A1, A2, ...)]` で、データオブジェクトからタプルを抽出する関数を指定する。

データオブジェクトをタプルとするには `play.api.data.Forms.tuple` 関数を使えばよい。

{% highlight scala %}
// The following code should be replaced with using "tuple".
//
//   val m: Mapping[(Long, String)] = mapping(
//     "id" -> of[Long],
//     "name" -> of[String]
//   )((a1: Long, a2: String) => (a1, a2))((t: (Long, String)) => Some(t))
//
val m: Mapping[(Long, String)] = tuple(
  "id" -> of[Long],
  "name" -> of[String]
)
val t: (Long, String) = m.bind(Map("id" -> "123", "name" -> "Foo")).right.get

assert(t._1 == 123L)
assert(t._2 == "Foo")
{% endhighlight %}

ただし `Tuple1` の `tuple` 関数は提供されていないので、`play.api.data.Forms.single` を使う。

{% highlight scala %}
val m: Mapping[String] = single("name" -> of[String])
val v: String = m.bind(Map("name" -> "Foo")).right.get
assert(v == "Foo")
{% endhighlight %}

### FieldMapping

`play.api.data.FiledMapping` は単一値のマッピングを行なう。

`play.api.data.Forms.of[T](implicit binder: Formatter[T])` を用いる事で、型パラメータ `T` に応じた `FieldMapping` を生成できる。基本的な `Formatter` は `play.api.data.format.Formats._` に暗黙パラメータとして定義されている。

{% highlight scala %}
import play.api.data._
import play.api.data.Forms._
import play.api.data.format.Formats._

val m: Mapping[(Long, String)] = tuple(
  "id" -> of[Long],    // play.api.data.format.Formats.longFormat
  "name" -> of[String] // play.api.data.format.Formats.stringFormat
)
{% endhighlight %}

`play.api.data.Forms._` に、ほとんどのフォーマットに対応したヘルパーメゾッドが定義されているので、基本的にはそれらを使えばよい。

### RepeatedMapping

`play.api.data.RepeatedMapping` は、`(List|Seq)` へのマッピングを行なう。`FieldMapping` を `play.api.data.Forms.(list|seq)` 関数で括ればよい。

リスト値のフォーム入力のキーは `tags[0], tags[1], tags[2], ...` のように、インデックス文字列 `[i]` を付与する。

{% highlight scala %}
val m = tuple(
  "numbers" -> list(of[Int]),
  "tags" -> seq(of[String])
)

val a = m.bind(Map(
  "numbers[0]" -> "123",
  "numbers[1]" -> "456",
  "tags[0]" -> "scala",
  "tags[1]" -> "play",
  "tags[2]" -> "framework"
)).right.get

assert(a._1 == List(123, 456))
assert(a._2 == Seq("scala", "play", "framework"))
{% endhighlight %}

### OptionalMapping

`play.api.data.OptionalMapping` は `Option` へのマッピングを行なう。`FieldMapping` を `play.api.data.Forms.option` 関数で括ればよい。

{% highlight scala %}
case class User(id: Option[Long], name: String)

val m = mapping(
  "id" -> optional(of[Long]),
  "name" -> of[String]
)(User.apply)(User.unapply)
{% endhighlight %}

### ObjectMapping

`play.api.data.ObjectMapping` は、それ自身も `Mapping` 型を持つので、変換ルールの入れ子となりうる。必ずしもトップレベルのみにあるのではない。

`ObjectMapping` は、最大 18 フィールド `ObjectMapping18` までのため、18 個までしかフィールド定義できないが、住所や確認入力などのグループで入れ子にすればよい。

入れ子に対するフォーム入力のキーは `address.street` のように、ドットで区切る。

{% highlight scala %}
case class Address(street: String, city: String)
case class User(name: String, address: Address)

val m = mapping(
  "name" -> text,
  "address" -> mapping(
    "street" -> text,
    "city" -> text
  )(Address.apply)(Address.unapply)
)(User.apply)(User.unapply)

val user = m.bind(Map(
  "name" -> "Nested Values",
  "address.street" -> "1-2-3",
  "address.city" -> "Fukuoka"
)).right.get

assert(user.name == "Nested Values")
assert(user.address.street == "1-2-3")
assert(user.address.city == "Fukuoka")
{% endhighlight %}

