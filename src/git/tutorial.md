---
layout: page

title: チュートリアル
---

## リポジトリの作成

作業ツリーのルートディレクトリで `git init` にてリポジトリを作成します。

    % cd /path/to/git/project
    % git init

ディレクトリ直下のみに ``.git`` ディレクトリができていることがわかります。

    % ls -a
    .  ..  .git

`git config` で

* `user.name` : 自身の名前
* `user.email` : メールアドレス

をリポジトリ設定 `.git/config` に登録しておきます。コミットを行う際に必須になります。

    % git config user.name "Taro Yamada"
    % git config user.email "yamada@example.net"


## ステージング

Git にはコミット前に更新内容を保管しておく操作があります。 以下の3つの領域があると考えてください。

<dl>
  <dt>ワーキングツリー</dt>
  <dd>実際の作業ファイル</dd>
  <dt>ステージ領域</dt>
  <dd>次にコミットする内容の保管領域</dd>
  <dt>リポジトリ</dt>
  <dd>最新コミット（HEAD）</dd>
</dl>

* 新規ファイルは `git add` でコミット内容に追加します。
* 更新ファイルも `git add` でコミット内容の更新が必要です。
* `git commit` でファイル名の指定が無い場合、ステージ領域の内容がコミットされます。作業ファイルの状態はコミット内容には関係ありません。
* `git commit (ファイル名)` で直接ファイル名を指定した場合は、ステージ領域とは関係なく指定した作業ファイルの内容でコミットされます。


## ファイル追加・更新

実際にファイル追加・更新をコミットしてみましょう。`README.md` を作成してみます。`git status` で状態を確認してみると、`Untrackd files:` になっています。このファイルが追跡対象でないことを示しています。

    % touch README.md

    % git status
    # On branch master
    # Untracked files:
    #   (use "git add <file>..." to include in what will be committed)
    #
    #       README.md

`(use "git add <file>..." to include in what will be committed)` とあるように、コミット対象となる新規ファイルは `git add` を行い追跡対象とする必要があります。``git status`` で確認すると `Changes to be committed: new file` でコミット内容に追加されていることがわかります。

    % git add README.md

    % git status
    # On branch master
    #
    # Initial commit
    #
    # Changes to be committed:
    #   (use "git rm --cached <file>..." to unstage)
    #
    #       new file:   README.md
    #

作業ファイルに変更を加えてみましょう。`git diff` で作業ファイルとステージ領域の差分を確認できます。

    % echo "# git の使い方" > README.md

    % git diff
    diff --git a/README.md b/README.md
    index e69de29..9bce96a 100644
    --- a/README.md
    +++ b/README.md
    @@ -0,0 +1 @@
    +# git の使い方

`git status` を見ると作業ファイルが `Changes not staged for commit: modified` となっています。これは変更がコミット内容に反映されていないことを表しています。

    % git status
    # On branch master
    #
    # Initial commit
    #
    # Changes to be committed:
    #   (use "git rm --cached <file>..." to unstage)
    #
    #       new file:   README.md
    #
    # Changes not staged for commit:
    #   (use "git add <file>..." to update what will be committed)
    #   (use "git checkout -- <file>..." to discard changes in working directory)
    #
    #       modified:   README.md
    #

この変更はコミット内容には含めずにコミットしてみます。

    % git commit -m "Add README.md"

`git status` を見ると作業ファイルが `Changes not staged for commit: modified:` となっており、先のコミットには変更が含まれていなかったことがわかります。

    % git status
    # On branch master
    # Changes not staged for commit:
    #   (use "git add <file>..." to update what will be committed)
    #   (use "git checkout -- <file>..." to discard changes in working directory)
    #
    #       modified:   README.md
    #
    no changes added to commit (use "git add" and/or "git commit -a")

`(use "git add <file>..." to update what will be committed)` とある通り、`gitt add` してみます。`git status` を見ると `Changes to be committed: modified:` で次のコミットに含まれたことがわかります。

    % git add README.md

    % git status
    # On branch master
    # Changes to be committed:
    #   (use "git reset HEAD <file>..." to unstage)
    #
    #       modified:   README.md
    #

`git commit` で変更をリポジトリに反映します。`git status` が示す通り、作業ファイルとリポジトリに差分はなくなりました。

    % git commit -m "Modified README.md"
    [master dbc5aba] Modified README.md
     1 file changed, 1 insertion(+)

    % git status
    # On branch master
    nothing to commit (working directory clean)


以上がコミットの流れです。コマンドを忘れてしまったときは `git status` で確認しましょう。


## ファイル削除

ファイル削除をコミットする場合は `git rm` で作業ファイルの削除をおこない、削除したことをコミット内容に追加します。

    % git rm README.md
    rm 'README.md'

    % git status
    # On branch master
    # Changes to be committed:
    #   (use "git reset HEAD <file>..." to unstage)
    #
    #       deleted:    README.md
    #

`(use "git reset HEAD <file>..." to unstage)` とあるように、削除したことをキャンセルできます。

    % git reset HEAD README.md
    Unstaged changes after reset:
    D       README.md

    % git status
    # On branch master
    # Changes not staged for commit:
    #   (use "git add/rm <file>..." to update what will be committed)
    #   (use "git checkout -- <file>..." to discard changes in working directory)
    #
    #       deleted:    README.md
    #
    no changes added to commit (use "git add" and/or "git commit -a")

これで作業ファイルの削除のみが行われた状態に戻りました。作業ファイルも復帰したければ、`(use "git checkout — <file>..." to discard changes in working directory)` とあるように `git checkout` でリポジトリの最新状態に戻すことができます。

    % git checkout -- README.md
    Unstaged changes after reset:
    D       README.md

    % git status
    # On branch master
    nothing to commit (working directory clean)

作業ファイルの変更を行ったまま削除する場合はどうでしょうか？

    % echo "## 変更後の削除" >> README.md
    % git rm README.md
    error: 'README.md' has changes staged in the index
    (use --cached to keep the file, or -f to force removal)

作業ファイルに変更が入っているためエラーになりました。リポジトリから作業ファイルに変更がある場合、うっかりミスで変更内容を失わないように気を効かせてくれています。`(use --cached to keep the file, or -f to force removal)` とあるように

* `--cached` オプションを付けて、作業ファイルは残してステージ領域からの削除のみ行う。
* `-f` オプションをつけて、作業ファイルも強制削除する。

ことを促しています。

`--cached` で作業ファイルは残し、削除のコミットのみ行ってみます。作業ファイルは追跡対象外として残り、次のコミットでリポジトリから削除されることがわかります。

    % git rm --cached README.md

    % git status
    # On branch master
    # Changes to be committed:
    #   (use "git reset HEAD <file>..." to unstage)
    #
    #       deleted:    README.md
    #
    # Untracked files:
    #   (use "git add <file>..." to include in what will be committed)
    #
    #       README.md

コミットするとリポジトリから削除されます。作業ファイルは追跡対象外として残ったままです。

    % git commit -m "Delete README.md"
    [master a5a5260] a
     1 file changed, 1 deletion(-)
     delete mode 100644 README.md

    % git status
    # On branch master
    # Untracked files:
    #   (use "git add <file>..." to include in what will be committed)
    #
    #       README.md


## ベアリポジトリ

Git ではベアリポジトリという作業ファイルを持たないリポジトリを作る方法があります。作業者のいない push されるだけのリポジトリで、複数作業者間の親リポジトリのように扱います。

ベアリポジトリは `--bare` オプションをつけて作成します。

    % cd /path/to/bare/repos/
    # (リポジトリ名).git とするのが慣例です。
    % git init --bare sandbox.git
    Initialized empty Git repository in /path/to/bare/repos/sandbox.git/

すでに存在するリポジトリをベアリポジトリとして複製する方法もあります。

    % cd /path/to/bare/repos/
    % git clone --bare /path/to/git/project/.git/ sandbox.git

通常のリポジトリ同様に `git clone` でリポジトリを取得します。

    % cd /path/to/workspace
    % git clone ssh://user@server/path/to/bare/repos/sandbox.git sandbox
    Cloning into sandbox ...
    done.

    % git remote
    origin

`git push` によりローカルブランチをリモートブランチへ反映します。

    % touch a.txt
    % git add a.txt
    # ここで commit していますが、ローカルブランチへのコミットでリモートブランチには反映されていません。
    % git commit -m "Add a.txt"
    # リモートリポジトリ origin の master ブランチへ反映します
    % git push origin master

リモートブランチの更新を取得するには `git fetch` でリモートブランチの最新コミットを取得し `git merge` でとローカルブランチと同期させます。

    % git fetch
    # 作業ツリーと fetch したリビジョンを比較
    % git diff FETCH_HEAD
    # リモート origin の master ブランチをマージ
    % git merge origin/master

`git pull` で `fetch` と `merge` をまとめて行うことができます。

    # git fetch && git merge origin/master と同じです
    % git pull origin master

