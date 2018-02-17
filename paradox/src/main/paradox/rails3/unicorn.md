# Unicorn

## インストール

`rails server` で起動するデフォルトのサーバは WEBrick で実用レベルではありません。代わりに Unicorn を利用します。

    # gem パッケージに含まれていなければ追加します
    % vi Gemfile
    ...
    gem 'unicorn'

    % bundle update

## 設定

`config/unicorn.rb` として設定ファイルを作成します。

    worker_processes 2

    stderr_path File.expand_path('../../log/unicorn/stderr.log', __FILE__)
    stdout_path File.expand_path('../../log/unicorn/stdout.log', __FILE__)

    pid File.expand_path('../../log/unicorn/unicorn.pid', __FILE__)

    preload_app false

詳しくは [Unicorn::Configurator](http://unicorn.bogomips.org/Unicorn/Configurator.html) を参照してください。

* <http://unicorn.bogomips.org/examples/unicorn.conf.rb>
* <http://unicorn.bogomips.org/examples/unicorn.conf.minimal.rb>

## 基本操作

### 起動/停止/再起動

unicorn_rails コマンドで起動します。`http://(ホスト名):8080` で確認できます。

    # -c 設定ファイルへのパス
    # -p ポート番号
    # -D デーモン起動
    % bundle exec unicorn_rails -c config/unicorn.rb -p 8080 -D

unicorn を停止するには、親プロセスに `-QUIT` シグナルを送ります。

    % kill -QUIT `cat /path/to/unicorn.pid`

unicorn を再起動するには、親プロセスに `-HUP` シグナルを送ります。

    % kill -HUP `cat /path/to/unicorn.pid`

### 緩やかな再起動

`-USR2` シグナルを用いることで、旧プロセスを保持したまま、新プロセスを起動できます。

    % kill -USR2 `cat /path/to/unicorn.pid`

新プロセスで pid ファイルが更新されます。旧プロセスの pid は `.oldbin` が付与されたファイル名に保存されます。

    % ls /path/to/pid/dir
    unicorn.pid unicorn.pid.oldbin

このままでは旧プロセスが残ったままですので、旧 master プロセスに `WINCH` シグナルを送り、旧 worker プロセスを停止 (graceful stop) させます。

    % kill -WINCH `cat /path/to/unicorn.pid.oldbin`

旧 worker が全て停止したら、旧 master プロセスに `QUIT` シグナルを送り、旧プロセスを停止させます。

    % kill -QUIT `cat /path/to/unicorn.pid.oldbin`

Unicorn サイトの設定ファイル例 <http://unicorn.bogomips.org/examples/unicorn.conf.rb> にあるように、`befor_fork` のフックを追加しておくことで、`USR2`シグナルの送信だけで旧プロセスを停止することもできます。

    before_fork do |server, worker|
      old_pid = "#{server.config[:pid]}.oldbin"
      if old_pid != server.pid
        begin
          sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
          Process.kill(sig, File.read(old_pid).to_i)
        rescue Errno::ENOENT, Errno::ESRCH
        end
      end
    end

## make コマンドを使った運用

以下のような Makefile を作成し make コマンドで起動/停止できるようにしておくとよいでしょう。

    PID = /path/to/unicorn.pid

    all:
        @echo Usage: (start|stop|restart|graceful)
    start:
        @bundle exec unicorn_rails -c config/unicorn.rb -D
    stop:
        @[[ -s "$(PID)" ]] && kill -QUIT `cat $(PID)`
    restart:
        @[[ -s "$(PID)" ]] && kill -HUP `cat $(PID)`
    graceful:
        @[[ -s "$(PID)" ]] && kill -USR2 `cat $(PID)`

