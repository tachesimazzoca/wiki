---
layout: page

title: Form
---

## Overview

* <https://www.playframework.com/documentation/2.3.x/ScalaForms>

## Mapping

`play.api.data.Mapping[T]` により、フォーム入力 `Map[String, String]` とデータオブジェクトの変換ルールを定義し、相互に変換を行なうことができる。

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

`play.api.data.Forms._` に、ほとんどのフォーム入力のフォーマットに対応したヘルパー関数が定義されているので、基本的にはそれらを使えばよい。

### ObjectMapping

`play.api.data.Forms.mapping` 関数を用いて、`play.api.data.ObjectMapping` を生成する。フィールド型を保つために、フィールド数（最大 18）に応じた `ObjectMapping(1..18)` が定義されている。

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
m.bind(Map("id" -> "123", "name" -> "Foo")) match {
  case Right(t) =>
    assert(t._1 == 123L)
    assert(t._2 == "Foo")
  case Left(_) =>
}
{% endhighlight %}

ただし `Tuple1` の `tuple` 関数は提供されていないので、`play.api.data.Forms.single` を使う。

{% highlight scala %}
val m: Mapping[String] = single("name" -> of[String])
m.bind(Map("name" -> "Foo")) match {
  case Right(v) => assert(v == "Foo")
  case Left(_) =>
}
{% endhighlight %}

#### Maximum Number of Fields

`ObjectMapping` は最大 18 フィールドまでしか定義できないが、`Mapping` 型を持つので変換ルールとなりうるので、住所や確認入力などのグループで入れ子にすればよい。

入れ子に対するフォーム入力のキーは、`address.street` のようにドットで区切る。

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

m.bind(Map(
  "name" -> "Nested Values",
  "address.street" -> "1-2-3",
  "address.city" -> "Fukuoka"
)) match {
  case Right(user) =>
    assert(user.name == "Nested Values")
    assert(user.address.street == "1-2-3")
    assert(user.address.city == "Fukuoka")
  case Left(_) =>
}
{% endhighlight %}

入れ子になっているからといって、階層毎にデータ型が必要なわけではない。`(apply|unapply)` 関数を調整すれば、単一のデータオブジェクトに変換できる。

{% highlight scala %}
case class Item(id: Long, name: String, price: Int, description: String)

val m = mapping(
  "id" -> longNumber,
  "name" -> text,
  "meta" -> tuple(
    "price" -> number,
    "description" -> text
  )
) { (id, name, meta) =>
  Item(id, name, meta._1, meta._2)
} { (item) =>
  Some((item.id, item.name, (item.price, item.description)))
}
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

固定値には `play.api.data.Forms.ignored` を使う。`bind` で上書きはされない。`unbind` 時には除外される。

{% highlight scala %}
val m: Mapping[(Long, String)] = tuple(
  "id" -> ignored(123L),
  "name" -> text
)
assert(Right((123L, "Foo")) == m.bind(Map("name" -> "Foo")))
assert(Right((123L, "Foo")) == m.bind(Map("id" -> "999", "name" -> "Foo"))) // id:999 ignored
assert(Map("name" -> "Foo") == m.unbind((123L, "Foo"))) // id:123 removed
{% endhighlight %}

### RepeatedMapping

`play.api.data.RepeatedMapping` は、`(List|Seq)` へのマッピングを行なう。`FieldMapping` を `play.api.data.Forms.(list|seq)` 関数で括ればよい。

リスト値のフォーム入力のキーは `tags[0], tags[1], tags[2], ...` のように、インデックス文字列 `[i]` を付与する。

{% highlight scala %}
val m = tuple(
  "numbers" -> list(of[Int]),
  "tags" -> seq(of[String])
)

m.bind(Map(
  "numbers[0]" -> "123",
  "numbers[1]" -> "456",
  "tags[0]" -> "scala",
  "tags[1]" -> "play",
  "tags[2]" -> "framework"
)) match {
  case Right(a) =>
    assert(a._1 == List(123, 456))
    assert(a._2 == Seq("scala", "play", "framework"))
  case Left(_) =>
}
{% endhighlight %}

ユーティリィティメゾッドの `RepeatedMapping.indexes` により、`Map[String, String]` から、指定キーのインデックス値のリスト `Seq[Int]` を得る事ができる。キーは昇順ソートされ、重複キーは削除される。

{% highlight scala %}
val data = Map(
  "tags[0]" -> "foo",
  "tags[1]" -> "bar",
  "tags[2]" -> "baz"
)
assert(Seq(0, 1, 2) == RepeatedMapping.indexes("tags", data))
{% endhighlight %}

### OptionalMapping

`play.api.data.OptionalMapping` は `Option` へのマッピングを行なう。`Mapping` を `play.api.data.Forms.option` 関数で括ればよい。

`play.api.data.Forms.default` 関数を使うとデフォルト値を指定できる。内部的には `Mapping#transform` で `Option#getOrElse` から変換しているので、`FieldMapping` ではない点に注意する。

{% highlight scala %}
case class User(id: Option[Long], name: String, activated: Boolean)

val m = mapping(
  "id" -> optional(of[Long]),
  "name" -> of[String],
  "activated" -> default(of[Boolean], true)
)(User.apply)(User.unapply)
{% endhighlight %}

## Constraint

`play.api.data.validation.Constraint[T]` により、バリデータを作成できる。

{% highlight scala %}
import play.api.data.validation._

val yesOrNo = Constraint[String] { s: String =>
  s match {
    case "yes" | "no" => Valid
    case _ => Invalid("The string must be (yes|no).")
  }
}
assert(Valid == yesOrNo("yes"))

def range(min: Int, max: Int) = Constraint[Int]("constraint.range", min, max) { v: Int =>
  if (v >= min && v <= max) Valid
  else Invalid("error.range", min, max)
}
val validator = range(1, 10)
assert(Some("constraint.range") == validator.name)
assert(Seq(1, 10) == validator.args)
validator(0) match {
  case Invalid(errors) =>
    assert(1 == errors.size)
    assert("error.range" == errors(0).message)
    assert(Seq(1, 10) == errors(0).args)
  case _ =>
    assert(false)
}
{% endhighlight %}

* `Constraint[T].apply` を使ってバリデータを作成する。引数には、値をチェックする関数 `T => play.api.data.validation.ValidationResult` を渡す。
  * 正常時には `Valid` を返す。
  * エラー時には `Invalid` を返す。
* `Constraint[T]#apply` メゾッドで値をチェックして `ValidationResult` を受け取る。
* バリデータのメタ情報を外部から参照できるように、`Constraint[T].apply` でバリデーション名と引数 `Any*` を定義することができる。入力のヒント文字列の組み立て等のために、外部用に提供する属性であって、バリデーションを行なう関数内から参照はできない。設定が冗長になるのを回避するには、`Constraint[T]` インスタンスを生成するヘルパー関数を定義するとよい。

`Invalid` は `apply` メゾッドに `play.api.data.validation.ValidationError` を渡して作成する。メッセージと引数だけの `apply` も提供されている。インスタンスは `Invalid#++` でマージできる。

{% highlight scala %}
val result1 = Invalid(ValidationError("error.foo", 1))
val result2 = Invalid("error.bar", 2, 3)
val result3 = result1 ++ result2
assert(Seq(
  ValidationError("error.foo", 1),
  ValidationError("error.bar", 2, 3)
) == result3.errors)
{% endhighlight %}

`play.api.data.validation.Constraints._` に、基本的なバリデータは定義されているので、不足する場合に独自に作成すればよい。

{% highlight scala %}
import play.api.data.validation.Constraints.pattern

val alnum = pattern(regex = """^[A-Z0-9]+$""".r, error = "must be alphanumeric")
{% endhighlight %}

### Working with Mapping

`Mapping#verifying` メゾッドで、フィールド値の制約を定義できる。

{% highlight scala %}
val m = tuple(
  "username" -> tuple(
    "main" -> text.verifying(pattern( """[a-z][a-z0-9]{4,31}""".r)),
    "sub" -> text
  ).verifying("error.username.sub", { v =>
    v._1 == v._2
  }),
  "age" -> number.verifying(min(0), max(100))
)
m.bind(Map(
  "username.main" -> "abc123",
  "username.sub" -> "abc12",
  "age" -> "26"
)) match {
  case Left(errors) =>
    assert(1 === errors.size)
    assert("error.username.sub" === errors(0).message)
  case Right(_) =>
}
{% endhighlight %}

* `Constraint[T]` のインスタンスを可変長引数で渡す。
* `Constraint[T]` の代わりに、`T => Boolean` の関数を渡すこともできる。値の制約は `Constraint[T]` を作るのがよいが、入力確認フィールドの状態など、マッピング全体の制約にはこの方法が良いだろう。
* `Constraint#apply` で得られるエラーは `ValidationError` だが、`Mapping#bind` でのエラーは、エラーが起こったフィールドキーと共に、`play.api.data.FormError` に移し替えられる。

## Form

`play.api.data.Form` は、`Mapping` をラップした HTTP フォームのモデルを提供する。`Mapping` はマッピングのみで状態を持たないが、`Form` は入力値やエラーを保持する。

{% highlight scala %}
val userForm = Form(mapping(
  "name" -> nonEmptyText,
  "age" -> number.verifying(min(0), max(100))
)(User.apply)(User.unapply))
val boundForm = userForm.bind(Map("name" -> "Foo", "age" -> "26"))
assert(Some(User("Foo", 26)) == boundForm.value)
assert(false == boundForm.hasErrors)
{% endhighlight %}

状態は持つが `Form` はケースクラス、すなわちイミュータブルであり、副作用のメゾッドは持たない。言い換えると `Form#(bind|fill)` 等で状態を更新する度にコピーされるので、スレッドセーフについては考慮しなくてよい。

`Controller` 内で利用する際、リクエスト毎に `Mapping` から `Form` を毎回組み立てるのはコストがかかるので、`Controller` のメンバー変数などに、初期値でインスタンス化したものを保持しておくとよい。

{% highlight scala %}
import models.Contact
import play.api.data._
import play.api.mvc._

object ContactsController extends Controller {
  val contactForm = Form(mapping(
    ...
  )(Contact.apply)(Contact.unapply))

  def entry = Action {
    Ok(views.html.contacts.entry(contactForm))
  }

  def submit = Action { implicit request =>
    contactForm.bindFromRequest.fold(
      formWithErrors => BadRequest(views.html.contacts.entry(formWithErrors)),
      contact => {
        // TODO: Do something with the value contact.
        Redirect(routes.ContactController.done())
      }
    )
  }

  def done = Action {
    Ok(views.html.contacts.done())
  }
}
{% endhighlight %}

送信されるフォームデータは、`Form#bindFromRequest` で暗黙パラメータの `Request` からバインドし、`Form#fold` で、エラー時と正常時の関数を定義しておくと簡潔に書ける。

### Field

`Form#apply` メゾッドを介して、指定フィールドのモデル `play.api.data.Field` を得ることができる。フィールド状態の取得の他、HTMLの組み立てを想定した API が提供されている。

{% highlight scala %}
val itemForm = Form(mapping(
  "name" -> nonEmptyText,
  "tags" -> list(text)
)(Item.apply)(Item.unapply)).bind(
  Map(
    "tags[0]" -> "foo",
    "tags[1]" -> "bar"
  )
)

assert("tags_0" == itemForm("tags[0]").id)
assert("tags.0" == itemForm("tags[0]").label)
{% endhighlight %}

* `Field#id` により、入力 HTML 要素のid 属性文字列を得る。フィールド名と同じだが `foo.bar[0]` は `foo_bar_0`  に変換される。
* `Field#label` により、フィールド名のラベルに対応する`play.api.i18n.Messages` のキーを得る。フィールド名と同じだが `foo[0]` は `foo.0`  に変換される。

## FieldConstructor

Twirl 向けのHTMLフォームフィールドのヘルパーとして `views.html.helper.input` が提供されている。

{% highlight scala %}
@(field: play.api.data.Field, args: (Symbol, Any)*)
(inputDef: (String, String, Option[String], Map[Symbol, Any]) => Html)
(implicit handler: FieldConstructor, messages: play.api.i18n.Messages)
{% endhighlight %}

`views.html.helper.FieldConstructor` を暗黙パラメータに持ち、ラベルやエラーメッセージを含めたフィールドブロックの HTML を組み立てることができる。

{% highlight scala %}
@helper.input(
  userForm("name"),
  'id -> "userNameInput",
  'size -> 30,
  '_id -> "userNameBlock",
  '_showConstraints -> false
) { (id, name, value, args) =>
  <input type="text" name="@name" id="@id" @toHtmlArgs(args)>
}
{% endhighlight %}

* `field: play.api.data.Field`: 出力対象の `field:Field` オブジェクト
* `args: (Symbol, Any)*`
  * `'_id -> String`: フィールドブロック要素の id 属性。入力要素の id 属性ではない点に注意。
  * `'_label -> String`: label 属性。`messages` のキーとしては参照されない。
  * `'_help -> String`: 入力ガイド文字列。`messages` のキーとしても参照される。
  * `'_showConstraints -> Boolean`: 入力ガイドを表示するかどうか？
  * `'_error -> String`: エラーメッセージ文字列。`messages` のキーとしても参照される。
  * `'_showErrors -> Boolean`: エラーメッセージを表示するかどうか？
  * `'_(.+) -> Any`: 独自 `FieldConstructor` へのパラメータ
  * `id -> String`: 入力 HTML 要素 (input/select/textarea) の id 属性
  * `[^_](.+) -> Any`: 入力 HTML 要素の追加属性
* `inputDef`: 入力 HTML 要素の `play.twirl.api.Html` を返す関数
  * `id: String`: id 属性
  * `name: String`: name 属性
  * `value: Option[String]`: フィールド値
  * `args: (Symbol, Any)`: `'id` および `'_*` のエントリを除く追加属性の `Map`

