---
layout: page

title: Cheat Sheet
---

## init

    % cd /path/to/git/project
    % git init

    % ls -a
    . .. .git

## config

    % git config user.name "Foo Bar"
    % git config user.email "foo@example.net"

## add

    % touch a.txt
    % touch b.txt
    % git add .
    % git status -s
    A  a.txt
    A  b.txt

    % touch c.txt
    % rm a.txt
    % git status -s
    AD a.txt
    A  b.txt
    ?? c.txt

The `-u` option removes as well as modifies index entries to match the working tree, but adds no new files.

    % git add -u .
    % git status -s
    A  b.txt
    ?? c.txt

To Add, modifiy and remove them, use the `-A` option.

    % rm b.txt
    % git add -A .
    % git status -s
    A  c.txt

## rm

    % git rm /path/to/file
    % git rm -r /path/to/dir/

The following is an one-liner to remove index entries to match deleted files.

    % git status -s | grep ^'.D' | awk '{print $2}' | xargs git rm

## commit

    # コミット候補を追加
    % git add a.txt
    # add 時点の状態でコミットされる
    % git commit

    % vi a.txt
    ....
    # 更新をコミットする場合も add してコミット候補に含める
    % git add a.txt
    % git commit

    # -a オプションで作業ファイルの状態でコミットできる
    # 全ての追跡対象ファイルを add したのち commit することと同義
    % git commit -a

    # reset author
    % git config user.name "Foo Bar"
    % git config user.email "foo@example.net"
    % git commit --amend --reset-author

    # commit with empty message
    % git commit -a --allow-empty-message -m ''

## clean

カレントディレクトリ以下の追跡対象外のファイルを削除します。

    # 未追跡ファイル/ディレクトリを確認
    % git clean -nd
    # 未追跡ファイル/ディレクトリを削除
    % git clean -fd
    # x オプションで .gitignore 対象も含めることができます
    % git clean -ndx
    % git clean -fdx

## tag

バージョンのタグについては `-a` オプションで注釈つきでタグをつける方法を推奨します。

     % git tag -a v1.0 -m "version 1.0"

コミットへのポインタのみのタグを作成することもできます。作業時など単に特定リビジョンをマークしたい場合に便利です。

    % git tag 20120123-01

リモートリポジトリにはタグは送信されません。タグを `push` する必要があります。

    # タグ v1.0 をリモート origin に送信
    % git push origin v1.0

    # ローカルリポジトリの全てのタグを origin に送信
    % git push origin --tags


## log

ログのフォーマットを指定することができます。

    % git log --pretty="format:%h %s"

    # フォーマットについての詳細はマニュアルを参照
    % man git-log


## show

`git show (リビジョン):(ファイル名)` で特定リビジョンのファイルを表示できます。

    # ひとつ前のコミットの ./README.md を表示
    % git show HEAD^:./README.md
    # コミット deadbeef.... の ./README.md を表示
    % git show deadbeef:./README.md

## diff

<table class="table table-bordered table-striped">
<tr>
  <td><code>git diff</code></td>
  <td>作業ファイルと索引の差分 = コミットされない差分。ステージし忘れている差分を確認</td>
</tr>
<tr>
  <td><code>git diff --cached</code></td>
  <td>索引とHEADの差分 = コミットされる差分。コミットし忘れている差分を確認</td>
</tr>
<tr>
  <td><code>git diff HEAD</code></td>
  <td>作業ファイルとHEADの差分。`git commit -a` でコミットされる差分を確認</td>
</tr>
</table>


## branch

    # 現在のブランチを確認
    % git branch
    * master

    # current ブランチを作成
    % git branch current
    % git branch
      current
    * master

    # current ブランチに切替
    % git checkout current
    % git branch
    * current
      master

    ....

    # master ブランチにマージされていないブランチを確認
    % git checkout master
    % git branch --no-merge
      current
    # master / current ブランチの差分を確認
    % git diff master..curent
    ....
    # master ブランチに current ブランチをマージ
    % git merge current
    ....
    # master ブランチにマージされているブランチを確認
    % git branch --merged
      current
    * master

    # current ブランチを削除
    % git branch -d current


## Working with Remotes

    # リモートを確認
    % git remove -v
    origin  git@github.com:foo/bar.git (fetch)
    origin  git@github.com:foo/bar.git (push)

    # リモートブランチを含めた全てのブランチを確認
    % git branch -a
    * master
      remotes/origin/master

    #
    # リモートブランチの更新を、作業ブランチへ反映
    #
    #  1. リモート origin の変更を取得
    #
    #     git fetch
    #     git fetch (リモート名)
    #
    % git fetch origin
    ....
    #  2. fetch したリモート origin の最新と比較
    % git diff FETCH_HEAD
    ....
    #  3. リモート origin の master ブランチを、作業ブランチにマージ
    % git merge origin/master
    ....
    #  4. pull で fetch + merge をまとめて行うこともできる
    % git pull

    #
    # 作業ブランチの更新を、リモートブランチへ反映
    #
    #  1. 作業ブランチの変更を commit
    ....
    % git commit
    ....
    #
    #  2. master ブランチをリモート origin へ反映
    #
    #      git push (リモート名) (ブランチ名)
    #      git push (リモート名) (ローカルブランチ名):(リモートブランチ名)
    #
    % git push origin master

    # リモート origin/development をローカルブランチ development としてチェックアウト
    % git checkout -b development origin/development

    # リモートブランチ origin/development を削除
    # 空のローカルブランチでリモートブランチ development を更新と考えると覚えやすい
    % git push origin :development


## History

To rewrite Git history, use `filter-branch`. The following is an example:

    % git filter-branch --commit-filter '
    GIT_AUTHOR_NAME="Foo Bar"
    GIT_AUTHOR_EMAIL="foo@example.net"
    git commit-tree "$@"
    ' HEAD

