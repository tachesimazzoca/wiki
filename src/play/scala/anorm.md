---
layout: page

title: Anorm
---

## Overview

* https://github.com/playframework/anorm/blob/master/docs/manual/working/scalaGuide/main/sql/ScalaAnorm.md

v2.4 以降は、playframework とは別プロジェクトになっている。

{% highlight scala %}
libraryDependencies ++= Seq(
  jdbc,
  //anorm, // v2.3
  "com.typesafe.play" %% "anorm" % "2.5.0" // v2.4 or higher
)
{% endhighlight %}

## SQL

ヘルパーメゾッド `SQL` により、SQL文字列が `SqlQuery` に変換される。

{% highlight scala %}
def SQL(stmt: String): SqlQuery =
  SqlStatementParser.parse(stmt).map(ts => SqlQuery.prepare(ts, ts.names)).get
{% endhighlight %}

### SqlStatementParser

`SqlStatementParser.parse` により、SQL文字列が `Try[TokenizedStatement]` に変換される。

{% highlight scala %}
val ts = SqlStatementParser.parse(
  "SELECT * FROM users WHERE id = {id} AND status = ?").get

println(ts.names)
// List("id")

println(ts.tokens)
// List(
//   TokenGroup(List(StringToken("SELECT * FROM users WHERE id = ")), Some(id)),
//   TokenGroup(List(StringToken(" AND status = ?")), None)
// )
{% endhighlight %}

`TokenizedStatement` は別モジュール `anorm-tokenizer` に含まれている。パッケージプライベート `private[anorm]` のため直接扱うことはない。

### SqlQuery

`SqlQuery` 自体は、単に `TokenizedStatement` を保持しておくだけの箱である。Implicit conversion により`SqlQuery#asSimple` が呼ばれ `SimpleSql` のメゾッドが利用可能になる。

都度、ヘルパーメゾッド `SQL` を呼ぶと変換コストがかかってしまうので、変換済みの `SqlQuery` インスタンスを保持しておくようにする。

{% highlight scala %}
import anorm._
import anorm.SqlParser._

val stmt = "SELECT email FROM users WHERE id = {id}"
val sql = SQL(stmt)
val parser = get[String]("email").*

// NG
for (n <- 1 to 10000) {
  SQL(stmt).on('id -> n).as(parser)
}

// OK
for (n <- 1 to 10000) {
  sql.on('id -> n).as(parser)
}
{% endhighlight %}

## WithResult

`WithResult` は、SELECT 結果を得るメゾッドを提供する。scala-arm の `resource.ManagedResource` により、自動的に `java.sql.(PreparedStatement|ResultSet)` がクローズされる。

### as

`as` メゾッドに `ResultSetParser` を渡すことで、結果セットを任意のモデルに変換できる。

{% highlight scala %}
import anorm._
import anorm.SqlParser._

val parser: RowParser[(Long, String)] =
  get[Long]("id") ~ get[String]("email") map {
    case id ~ email => (id -> email)
  }

val usersList: List[(Long, String)] =
  SQL("SELECT * FROM users WHERE status = 1 ORDER BY id").as(parser.*)
{% endhighlight %}

### withResult

`withResult` メゾッドを使えば、結果を一度にメモリに入れることなく一行づつ処理できる。Loan pattern でカーソルを受け取る関数 `Option[Cursor] => T` を渡す。`List[Row]` を組み立てる場合を例にすると、 アキュムレータを使った再帰関数を部分適用して渡せば良い。

{% highlight scala %}
@annotation.tailrec
def go(op: Option[Cursor], acc: List[Row]): List[Row] =
  op match {
    case Some(c) => go(c.next, acc :+ c.row)
    case None => acc
  }

val result: Either[List[Throwable], List[Row]] =
  SQL("SELECT * FROM users WHERE status = 1 ORDER BY id")
    .withResult(go(_, List.empty[Row]))
{% endhighlight %}

### fold

通常は `fold` メゾッドを使うと良い。内部で `withResult` を呼んでいる。

{% highlight scala %}
val result: Either[List[Throwable], List[Row]] =
  SQL("SELECT * FROM users ORDER BY id")
    .fold(List.empty[Row]) { (acc, row) => acc :+ row }
{% endhighlight %}

### foldWhile

`foldWhile` を使えば、カーソル走査を中断することができる。

{% highlight scala %}
val result: Either[List[Throwable], List[Row]] =
  SQL("SELECT * FROM users ORDER BY id")
    .foldWhile(List.empty[Row]) { (acc, row) =>
      if (acc.size < 10) (acc :+ row, true)
      else (acc, false)
    }
{% endhighlight %}

## RowParser

`RowParser[+A]` の実体は、関数 `Row => SqlResult[A]` である。

ヘルパーメゾッド `SqlParser.get[T]` で、指定のカラム名またはカラム番号の RowParser を得られる。

{% highlight scala %}
import anorm.SqlParser._

val idColumnParser = get[Long]("id")
val emailColumnParser = get[String]("email")
val thirdColumnParser = get[Int](3)
{% endhighlight %}

一般的な型のヘルパーメゾッドが定義されているので、通常はこれらを使う。

{% highlight scala %}
import anorm.SqlParser._

val idColumnParser = long("id")
val emailColumnParser = str("email")
val thirdColumnParser = int(3)
{% endhighlight %}

* `bool`: `get[Boolean]`
* `(byte|short|int|long)`: `get[(Byte|Short|Int|Long)]`
* `float`: `get[Float]`
* `double`: `get[Double]`
* `str`: `get[String]`
  * `String`
  * `java.sql.Clob`
* `date`: `get[java.util.Date]`
  * `java.sql.Date`
  * `Long`
  * `{ def getTimestamp: java.sql.Timestamp }`
* `binaryStream`: `get[java.io.InputStream]`
  * `Array[Byte]`
  * `String`
  * `java.io.InputStream`
  * `java.sql.Blob`

`~` で `RowParser` を連結することで、複数カラムの RowParser を作成できる。

{% highlight scala %}
trait RowParser[+A] extends (Row => SqlResult[A]) { parent =>
  ...
  final case class ~[+A, +B](_1: A, _2: B)
  ...
  def ~[B](p: RowParser[B]): RowParser[A ~ B] =
    RowParser(row => parent(row).flatMap(a => p(row).map(new ~(a, _))))
  ...
}

val parser: RowParser[Long ~ String ~ Int ~ java.util.Date] =
  long("id") ~ str("email") ~ int("status") ~ date("birthday")
val userParser: RowParser[User] = parser map {
  case id ~ email ~ status ~ birthday =>
    User(id, email, status, new java.util.Date(birthday.getTime))
}
{% endhighlight %}

正確には連結しているように見えるだけで、`case class ~[+A, +B](_1: A, _2: B)` がネストしているだけである。

{% highlight scala %}
val parser: RowParser[~[~[~[Long, String], Int], java.util.Date]] =
  ~(~(~(long("id"), str("email")), int("status")), date("birthday"))
val userParser: RowParser[User] = parser map {
  case ~(~(~(id, email), status, birthday) =>
    User(id, email, status, new java.util.Date(birthday.getTime))
}
{% endhighlight %}

### Row

`Row` は、`java.sql.ResultSet` を内部に持つ `Cursor` を介して得られる。

{% highlight scala %}
sealed trait Cursor {
  def row: Row
  def next: Option[Cursor]
}

object Cursor {
  private[anorm] def apply(rs: ResultSet): Option[Cursor] =
    if (!rs.next) None else Some(new Cursor {
      ...
    })
  ...
}
{% endhighlight %}

カラム情報 `MetaData` と SELECT 節の `List[Any]` を内部に持ち、`apply[T]` でカラム名か位置番号からカラム値を得ることができる。

{% highlight scala %}
trait Row {
  private[anorm] def metaData: MetaData
  private[anorm] val data: List[Any]
  ...
  def apply[B](name: String)(implicit c: Column[B]): B = ???
  def apply[B](position: Int)(implicit c: Column[B]): B = ???
  ...
}
{% endhighlight %}

`Column[T]` が Any から指定した型への変換器で、`anorm.Column._` に implicit で変換可能なパターンが定義されている。

{% highlight scala %}
trait Column[A] extends ((Any, MetaDataItem) => MayErr[SqlRequestError, A])
{% endhighlight %}

### SqlResult

`SqlResult` は `Row` の指定カラムの解析結果となる。

{% highlight scala %}
case class Success[A](a: A) extends SqlResult[A]
case class Error(msg: SqlRequestError) extends SqlResult[Nothing]
{% endhighlight %}

モナド則を満たしており、連結した RowParser で複数カラムを変換する過程で、いずれかに失敗するとエラーになる。

{% highlight scala %}
object SqlParser {
  ...
  def get[T](name: String)(implicit extractor: Column[T]): RowParser[T] =
    RowParser { row =>
      (for {
        // Does the column exist?
        col <- row.get(name) // MayErr[SqlRequestError, (Any, MetaDataItem)]
        // Can the extractor convert the column value?
        res <- extractor.tupled(col) // (Any, MetaDataItem) => MayErr[SqlRequestError, A]
      } yield res).fold(Error(_), Success(_))
    }
}
{% endhighlight %}

`MayErr` についてはAPI公開されているが、すでに非推奨であり使うことはない。_for-comprehension_ で記述するための内部クラスで `Either` の `RightProjection` のようなものと理解しておけばよい。
