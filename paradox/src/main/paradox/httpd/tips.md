# Tips

## VirtualHost

    # VirtualHost
    NameVirtualHost :*:80

    # URLのホスト名に対応する設定がない場合、もっとも先頭の VirtualHost が利用されます。
    <VirtualHost *:80>
        DocumentRoot /var/www/hosts/localhost/htdocs
        ErrorLog /var/www/hosts/localhost/logs/error_log
        CustomLog /var/www/hosts/localhost/logs/access_log combined
        <Directory /var/www/hosts/localhost/htdocs>
            Options ExecCGI FollowSymlinks
            AllowOverride all
        </Directory>
    </VirtualHost>

    # example.net
    <VirtualHost *:80>
        ServerName example.net
        DocumentRoot /var/www/hosts/example.net/htdocs
        ErrorLog /var/www/hosts/example.net/logs/error_log
        CustomLog /var/www/hosts/example.net/logs/access_log combined
        <Directory /var/www/hosts/example.net/htdocs>
            Options ExecCGI FollowSymlinks
            AllowOverride all
        </Directory>
    </VirtualHost>


## Basic Authentication

htpasswd コマンドで、パスワードファイルを作成します。

    % htpasswd -c .htpasswd foo
    ....
    % less .htpasswd

アクセス制限を行うディレクトリに、`.htaccess` を設置します。

    AuthType Basic
    AuthName "Example Basic Authentication"

    # require または allow を満たす場合にアクセスを許可
    Satisfy any

    AuthUserFile /path/to/.htpasswd
    AuthGroupFile /dev/null

    # Basic認証済のユーザを全て許可
    require valid-user

    # ローカルIPからのホストを全て許可
    order deny,allow
    deny from all
    allow from 127.0.0.1
    allow from 192.168.0

    <Files ~ "^.(htpasswd|htaccess)$">
        deny from all
    </Files>


## Maitenance Mode

Webサイトをメンテナンス状態とする場合、単にページ内容を変更したり、メンテナンスページへリダイレクトする方法ではSEO対策として問題があります。検索エンジンのクローラにとっては、メンテナンス状態であるかの判断はできないため、通常のページ更新があったものとみなされてメンテナンスページが収集されてしまうことになります。

HTTPステータスコードを `503 Service Temporarily Unavailable` で応答することで、クローラに通常のページ応答ではないことを伝えることができます。

2.2 系であれば、mod\_rewrite だけで 503 のレスポンスコード指定ができます。以下の例では `/maintenance/` ディレクトリ内であればリライトされませんので、メンテナンスページで用いる画像/CSSファイルはこのディレクトリ内に置くようにします。

    # 503 エラー用の maintenance.html を用意します。
    ErrorDocument 503 /maintenance/index.html
    RewriteEngine on
    RewriteCond %{REQUEST_URI} !^/maintenance/
    RewriteRule ^.*$ - [R=503,L]

`/maintenance/index.html` 自身へのリクエストは 503 とならない点に注意してください。`/maintenance/index.html` へのリンクやサイトマップが存在すればクロールされる可能性はあります。meta タグや `robot.txt` と併用してクロール対象外であることを伝えるようにします。

1.3 系ではこの方法がつかえません。代わりに、動的に 503 ステータスを送出する PHP クリプト等にリライトします。

以下のような `/maintenance/index.php` を設置しておきます。

    <?php

    header('HTTP/1.1 503 Service Temporarily Unavailable');
    include '/path/to/maintenance.html';

`/maintenance/` ディレクトリ以外のURLの場合は `/maintenance/index.php` にリライトします。

    RewriteEngine on
    RewriteCond %{REQUEST_URI} !^/maintenance/
    RewriteRule ^.*$ /maintenance/index.php [L]

## Load Blancing

[mod\_proxy](http://httpd.apache.org/docs/2.2/en/mod/mod_proxy.html) により、httpd 単体でロードバランサを実現できます。

ダウンタイムなしで、更新を行なう運用例です。

* マスタ `http://localhost:8080`
* スタンバイ `http://localhost:8081`

でバックエンドアプリケーションを起動させるとします。

    <VirtualHost *:80>
      ServerName lb.example.net
      <Proxy balancer://tomcat>
        BalancerMember http://localhost:8080
        BalancerMember http://localhost:8081 status=+H
      </Proxy>
      <Proxy *>
        Order Allow,Deny
        Allow From All
      </Proxy>
      ProxyPreserveHost On
      ProxyPass / balancer://tomcat/
      ProxyPassReverse / balancer://tomcat/
    </VirtualHost>

`status=+H` は _hot-standby_ の意味です。通常は使われずに、全てのメンバがダウンしている時にのみ利用されます。

以下の手順で、ダウンタイムなしで切り替えることができます。

* スタンバイ `8081` へ更新アプリケーションをデプロイ＆起動; _バランサから切り離されているため影響なし_
* マスタ `8080` を停止。スタンバイ `8081` に切り替わる
* マスタ `8080` へ更新アプリケーションをデプロイ後＆起動; _バランサから切り離されているため影響なし_
* スタンバイ `8081` を停止。マスタ `8080` に切り替わる

この設定では、スタンバイにいったん切り替わると、マスタが復旧してもスタンバイのままです。スタンバイを停止しない限り、マスタに切り替わりません。一見デメリットのように思えますが、マスタが起動しても自動的に切り替わらないことを生かして、起動後に受け入れテストを実施し、任意のタイミングでマスタに切り替えることができます。

常にマスタ優先で切り替えたい場合は、`BalancerMember` ディレクティブに `retry` オプションを指定します。

      <Proxy balancer://tomcat>
        BalancerMember http://localhost:8080 retry=30
        BalancerMember http://localhost:8081 status=+H retry=0
      </Proxy>

`retry` 秒毎に疎通がチェックされ、マスタの復旧と同時に切り替わります。
