---
layout: page

title: Tips
---

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


## Basic認証

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


## メンテナンスモード

Webサイトをメンテナンス状態とする場合、単にページ内容を変更したり、メンテナンスページへリダイレクトする方法ではSEO対策として問題があります。検索エンジンのクローラにとっては、メンテナンス状態であるかの判断はできないため、通常のページ更新があったものとみなされてメンテナンスページが収集されてしまうことになります。

HTTPステータスコードを `503 Service Temporarily Unavailable` で応答することで、クローラに通常のページ応答ではないことを伝えることができます。mod_rewrite + PHP を使って、503 エラーで応答する例です。

    # /maintenance/ ディレクトリ以外のURLの場合は /maintenance/index.php にリライト
    RewriteEngine on
    RewriteCond %{REQUEST_URI} !^/maintenance/
    RewriteRule ^.*$ /maintenance/index.php [L]
    /maintenance/index.php

`/maintenance/index.php` の例です。

    <?php

    header('HTTP/1.1 503 Service Temporarily Unavailable');

    include '/path/to/maintenance.html';


`/maintenance/` ディレクトリ内であればリライトされませんので、メンテナンスページで用いる画像/CSSファイルはこのディレクトリ内に置くようにします。

Apache2.2系であれば、mod_rewrite だけで 503 のレスポンスコード指定ができます。

    # 503 エラー用の maintenance.html を用意します。
    ErrorDocument 503 /maintenance/index.html
    RewriteEngine on
    RewriteCond %{REQUEST_URI} !^/maintenance/
    RewriteRule ^.*$ - [R=503,L]


この場合 `/maintenance/index.html` 自身へのリクエストは 503 となりません。`/maintenance/index.html` へのリンク/サイトマップが存在すればクロールされる可能性はあります。meta タグや `robot.txt` と併用してクロール対象外であることを伝えるようにします。

