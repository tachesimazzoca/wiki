# Cheat Sheet

## init

```shell
$ cd /path/to/git/project
$ git init

$ ls -a
. .. .git
```

## config

```shell
$ git config user.name "Foo Bar"
$ git config user.email "foo@example.net"
$ git config -l
...
```

## add

```shell
$ touch a.txt
$ touch b.txt
$ git add .
$ git status -s
A  a.txt
A  b.txt

$ touch c.txt
$ rm a.txt
$ git status -s
AD a.txt
A  b.txt
?? c.txt
```

The `-u` option removes as well as modifies index entries to match the working tree, but adds no new files.

```shell
$ git add -u .
$ git status -s
A  b.txt
?? c.txt
```

To add, modifiy and remove them, use the `-A` option.

```shell
$ rm b.txt
$ git add -A .
$ git status -s
A  c.txt
```

## update-index

```shell
$ chomod 755 setup.sh
$ git update-index --chmod=+x setup.sh
```

## rm

```shell
$ git rm /path/to/file
$ git rm -r /path/to/dir/
```

The following is an one-liner to remove index entries that start with `^.D` as tracking status. (i.e. Each file tracked by the index entries has already been removed without using git-rm.)

```shell
$ git status -s | grep ^'.D' | awk '{print $2}' | xargs git rm
```

## remote

```shell
$ git remote -v
origin  ssh://gitolite-server/foo.git (fetch)
origin  ssh://gitolite-server/foo.git (push)

$ git remote set-url origin ssh://gitolite-server/bar.git
$ git remote -v
origin  ssh://gitolite-server/bar.git (fetch)
origin  ssh://gitolite-server/bar.git (push)

$ git remote remove origin
$ git remote add origin ssh://codecommit-user/v1/repos/sandbox
```

## commit

```shell
# コミット候補を追加
$ git add a.txt
# add 時点の状態でコミットされる
$ git commit

$ vi a.txt
....
# 更新をコミットする場合も add してコミット候補に含める
$ git add a.txt
$ git commit

# -a オプションで作業ファイルの状態でコミットできる
# 全ての追跡対象ファイルを add したのち commit することと同義
$ git commit -a

# reset author
$ git config user.name "Foo Bar"
$ git config user.email "foo@example.net"
$ git commit --amend --reset-author

# commit with empty message
$ git commit -a --allow-empty-message -m ''
```

## clean

カレントディレクトリ以下の追跡対象外のファイルを削除します。

```shell
# 未追跡ファイル/ディレクトリを確認
$ git clean -nd
# 未追跡ファイル/ディレクトリを削除
$ git clean -fd
# x オプションで .gitignore 対象も含めることができます
$ git clean -ndx
$ git clean -fdx
```

## tag

バージョンのタグについては `-a` オプションで注釈つきでタグをつける方法を推奨します。

```shell
$ git tag -a v1.0 -m "version 1.0"
```

コミットへのポインタのみのタグを作成することもできます。作業時など単に特定リビジョンをマークしたい場合に便利です。

```shell
$ git tag 20120123-01
```

リモートリポジトリにはタグは送信されません。タグを `push` する必要があります。

```shell
# タグ v1.0 をリモート origin に送信
$ git push origin v1.0

# ローカルリポジトリの全てのタグを origin に送信
$ git push origin --tags
```

## log

ログのフォーマットを指定することができます。

```shell
$ git log --pretty="format:%h %s"

# フォーマットについての詳細はマニュアルを参照
$ man git-log
```

## show

`git show (リビジョン):(ファイル名)` で特定リビジョンのファイルを表示できます。

```shell
# ひとつ前のコミットの ./README.md を表示
$ git show HEAD^:./README.md
# コミット deadbeef.... の ./README.md を表示
$ git show deadbeef:./README.md
```

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

## diff-index

```shell
# Commit only if there are some files to be committed.
$ git diff-index --quiet HEAD || git commit -m "Add some files"
```

## fetch

To download objects and references from another repository, use the command `git fetch <remote>`.

```shell
$ git fetch origin

# The remote "origin" will be used, when no remote is specified.
$ git fetch
```

By default, the command won't remove any references that no longer exist on the remote. To prune them, use the `-p --prune` option.

```shell
$ git fetch -p
```

## branch

```shell
# 現在のブランチを確認
$ git branch
    * master

# current ブランチを作成
$ git branch current
$ git branch
  current
    * master

# current ブランチに切替
$ git checkout current
$ git branch
    * current
  master

....

# master ブランチにマージされていないブランチを確認
$ git checkout master
$ git branch --no-merge
  current
# master / current ブランチの差分を確認
$ git diff master..curent
....
# master ブランチに current ブランチをマージ
$ git merge current
....
# master ブランチにマージされているブランチを確認
$ git branch --merged
  current
    * master

# current ブランチを削除
$ git branch -d current
```

## Working with Remote Repositories

```shell
# List remote-tracking repositories with the verbose option.
$ git remote -v
origin  git@github.com:foo/bar.git (fetch)
origin  git@github.com:foo/bar.git (push)

# List both remote-tracking branches and local branches.
$ git branch -a
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
$ git fetch origin
....
#  2. fetch したリモート origin の最新と比較
$ git diff FETCH_HEAD
....
#  3. リモート origin の master ブランチを、作業ブランチにマージ
$ git merge origin/master
....
#  4. pull で fetch + merge をまとめて行うこともできる
$ git pull

#
# 作業ブランチの更新を、リモートブランチへ反映
#
#  1. 作業ブランチの変更を commit
....
$ git commit
....
#
#  2. master ブランチをリモート origin へ反映
#
#      git push (リモート名) (ブランチ名)
#      git push (リモート名) (ローカルブランチ名):(リモートブランチ名)
#
$ git push origin master

# リモート origin/development をローカルブランチ development としてチェックアウト
$ git checkout -b development origin/development

# リモートブランチ origin/development を削除
# 空のローカルブランチでリモートブランチ development を更新と考えると覚えやすい
$ git push origin :development
```

## History

To reset authorship information, use `git-rebase` with the option `-i`. The following is an example to modify last 2 commits.

```shell
$ git rebase -i HEAD~2
pick b234567  Do something
pick a123456  Do something at last

# Rebase ....
#
# Commands:
#  p, pick = use commit
...
#  e, edit = use commit, but stop for amending
...
```

Replace `pick` at each line with `edit` and then quit the editor.

```shell
edit b234567  Do something
edit a123456  Do something at last
...
:q

You can amend the commit now, with

        git commit --amend

Once you are satisfied with your changes, run

        git rebase --continue
```

Repeat running the commands `commit --amend --reset-author` and `rebase --continue` alternately.

```shell
$ git commit --amend --reset-author
$ git rebase --continue
$ git commit --amend --reset-author
$ git rebase --continue
Successfully rebased and updated refs/heads/...
```

You can also use `filter-branch` to reset all commits.

```shell
$ git filter-branch --commit-filter '
GIT_AUTHOR_NAME="Foo Bar"
GIT_AUTHOR_EMAIL="foo@example.net"
git commit-tree "$@"
' HEAD
```

## Merging a Pull Request Manually

```shell
# Fork the repository "sandbox" made by Alice
$ git remote add upstream http://github.com/alice/sandbox.git
$ git pull upstream master
$ git checkout -b hotfix
$ git commit
$ git push origin hotfix

# Merge the pull request sent by Bob
$ git remote add bob http://github.com/bob/sandbox.git
$ git fetch bob
$ git checkout -b bob-hotfix bob/hotfix
$ git checkout master
$ git merge --no-ff hotfix
$ git push origin master
```
