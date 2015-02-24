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
  "code" -> text.verifying(pattern """[A-Z][0-9]{5}""".r),
  "name" -> nonEmptyText,
  "price" -> number(min = 1, max = 100000)
)(Item.apply)(Item.unapply)
{% endhighlight %}

`play.api.data.Forms.mapping` 関数を用いて、`ObjectMapping` を生成する。フィールド型を保つために、フィールド数に応じた `play.api.data.ObjectMapping(1..18)` が定義されている。

* 引数 1..n は `(String, Mapping)` で、フィールド毎のキー名と変換ルールのペアを指定する。
* 引数 n+1 は `(A1, A2, ...) => R` で、タプルからデータオブジェクトを生成する関数を指定する。
* 引数 n+2 は `(R) => Option[(A1, A2, ...)]` で、データオブジェクトからタプルを抽出する関数を指定する。

`play.api.data.Forms.tuple` 関数は、データオブジェクトをタプルとした `ObjectMapping` を生成する。`Map[String, String]` から型変換する場合に使える。

{% highlight scala %}
// The following code should be replaced with using "tuple".
//
//    val m: Mapping[(Long, String)] = mapping(
//      "id" -> of[Long],
//      "name" -> of[String]
//    )((a1 :Long, a2 :String) => (a1, a2))((t: (Long, String)) => Some(t))
//
val m: Mapping[(Long, String)] = tuple(
  "id" -> of[Long],
  "name" -> of[String]
)
val t: (Long, String) = m.bind(Map("id" -> "123", "name" -> "Foo")).right.get
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

### OptionalMapping

変換値を `Option` で括るには、`play.api.data.Forms.option` 関数を使う。

{% highlight scala %}
case class User(id: Option[Long], name: String)

val u = mapping(
  "id" -> optional(of[Long]),
  "name" -> of[String]
)(User.apply)(User.unapply)
{% endhighlight %}

### ObjectMapping

`play.api.data.ObjectMapping` は、それ自身も `Mapping` 型を持つので、変換ルールの入れ子となりうる。必ずしもトップレベルのみにあるのではない。

`ObjectMapping` は、最大 18 フィールド `ObjectMapping18` までのため、18 個までしかフィールド定義できないが、住所や確認入力などのグループで入れ子にすればよい。

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
  "name" -> "Nested Tuple",
  "address.street" -> "1-2-3",
  "address.city" -> "Fukuoka"
)).right.get
{% endhighlight %}

ネストされた、キー名は `address.street` のようにピリオドで区切られる。

