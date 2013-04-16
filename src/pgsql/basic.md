---
layout: page

title: 基本操作
---

## ユーザ作成

ユーザ作成は `postgres` ユーザで行い、データベースのみを作成できるユーザを作成しておくとよいでしょう。

    % su - postgres
    % createuser dev
    Shall the new role be a superuser? (y/n) n
    Shall the new role be allowed to create databases? (y/n) y
    Shall the new role be allowed to create more new roles? (y/n) n
    CREATE ROLE


## データベース作成

    % su - postgres
    % createdb -U dev (データベース名)
    CREATE DATABASE

`pg_hba.conf` での設定が `ident sameuser` となっていると、同名のOSユーザが存在しなければ作成できません。ポリシーに応じて `trust` や `password` 等に変更します。


## ログイン

    #
    # -W : パスワード認証を要求
    # -U : ユーザ名
    # -d : データベース名。オプションでなく最後の引数としても指定可
    #
    % psql -W -U (ユーザ名) -d (データベース名)
    Password for user dev:
    ....


## SELECT 結果を CSV 形式で出力する

    #
    # -A : 位置揃え無しの出力モード
    # -F : 区切り文字
    #
    % echo "SELECT * FROM emp LIMIT 5" | psql -A -F "," ...


## SQL ダンプ

    #
    # -O : 所有権を元のデータベースに一致させるためのコマンドを出力しない
    # -x : アクセス権限のダンプを抑制
    # -s : テーブル定義のみをダンプ
    #
    % pg_dump -O -x -U dev (データベース名) > dump.sql

SQL ダンプからのレストアは `psql` コマンド経由で行います。

    # シェルからの入力リダイレクトの場合は、手入力を行った場合と同等です。
    % psql .... -d (データベース名) < dump.sql

    # -f オプションでのファイル名指定であれば、行番号付でエラーメッセージが確認できます。
    % psql .... -d (データベース名) -f dump.sql


