# Deploying

## Supervisor

* <http://supervisord.org/>

CentOS なら epel パッケージに含まれている。

    % yum install supervisor

* アプリケーション: `play-app`
* 実行ユーザ: `app`
* `(9001|9002)` の複数プロセスで起動

とすると以下のようになる。

    % cat /etc/supervisord.conf
    ...

    [program:play-app1]
    command=/path/to/play-app/bin/play-app -Dhttp.port=9001 -Dpidfile.path=/dev/null
    ;priority=999
    autostart=true
    autorestart=true
    startsecs=10
    startretries=3
    exitcodes=0,2
    stopsignal=TERM
    stopwaitsecs=10
    user=app
    log_stdout=true
    log_stderr=true
    logfile=/path/to/cat.log
    logfile_maxbytes=1MB
    logfile_backups=10

    [program:play-app2]
    command=/path/to/play-app/bin/play-app -Dhttp.port=9002 -Dpidfile.path=/dev/null
    ...

* `pidfile.path`  は `/dev/null` に送るようにする。 Supervisor がプロセスを管理するため不要。Play が生成する `RUNNING_PID` ファイルが残ってしまった場合に、自動再起動ができない。
* `stopsignal` は `TERM` を送る。設定サンプルにある `QUIT` では終了しない。

起動スクリプト `/etc/init.d/supervisord` を用いれば、設定したプロセスを一括してデーモン起動できる。

    % service supervisord {start|stop|status|restart|reload|force-reload|condrestart}

`supervisorctl` を使うことで、プロセス毎に管理できる。

    % supervisorctl
    play-app1    RUNNING    pid 12345, uptime 0:00:10
    play-app2    RUNNING    pid 23456, uptime 0:00:10
    supervisor> stop play-app2
    play-app2: stopped
    supervisor>

