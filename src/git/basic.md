---
layout: page

title: 基本操作
---

## リポジトリの作成

    % cd /path/to/git/project
    % git init

    % ls -a
    . .. .git


## ユーザ情報の登録

    % git config user.name "Taro Yamada"
    % git config user.email "yamada@example.net"


## コミット

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
    # 全ての追跡対象ファイルを ad したのち commit することと同義
    % git commit -a


## 差分比較

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


## ブランチ操作

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


## リモート操作

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

