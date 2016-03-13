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
val stmt = "SELECT email FROM users WHERE id = {id}"
val sql = SQL(stmt)
val parser = SqlParser.str("email").*

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

パッケージプライベート `private[anorm]` のトレイト `WithResult` は、SELECT 結果を得るメゾッドを提供する。scala-arm の `resource.ManagedResource` により、自動的に `java.sql.(PreparedStatement|ResultSet)` がクローズされる。

### withResult

`withResult` メゾッドでは、Loan pattern を用いて `Option[anorm.Cursor]` を受け取り、組み立て結果を返す関数を渡す。`List[Row]` を組み立てる場合を例にすると、 アキュムレータを使った再帰の Partial function を渡せば良い。

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

