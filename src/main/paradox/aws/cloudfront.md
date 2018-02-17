# CloudFront

## Origin Settings

### Origin Domain Name ###

S3 Bucket あるいは Web サーバのドメインを指定する。

### Origin Path ###

CloudFront URL のルートディレクトリとみなすサブディレクトリを指定する。

* 同一ドメインで、サブディレクトリで複数の Origin を持つ
* S3 Bucket において、プライベートなファイルが含まれる場合に、CloudFront 用に公開するディレクトリのみを指定

### Origin ID ###

Distribution 内でユニークな Origin ID を指定する。Origin 作成後は変更できない。

### Origin Protocol Policy ###

Distribution と Origin 間の HTTPS のポリシーを選択する。

* HTTP Only
* Match Viewr

Distribution と Viewer 間は _Cache Behavior Settings > Viewer Protocol Policy_ になるので注意。

## Cache Behavior Settings

Distribution 作成時は、すべてのパスに対する `Default(*)` のみ設定できる。Precedence は強制的に最大値となり、一番最後に評価される。

### Path Pattern

Cache Behavior の設定数には 25 個までの制限があるため、多くの設定が当てはまるパターンを `Default(*)` に割り当てる必要がある。

いったんキャッシュされてしまうと、Invalidation で削除するほかないので、`Default(*)` は Forward Headers を All にしてキャッシュしない設定にしておき、明らかにキャッシュ可能なコンテンツを指定していくほうが良い。

Directory Index の機能は持たない。`/pages/*` なら `/pages/` も `/pages/index.html` どちらも Path Pattern にあてはまるが、キャッシュは別になる。

### Origin

Distriibution は、複数の Origin を持てる。Cache Behavior ごとに、どの Origin を使うかを選択できる。　

### Viewr Protocol Policy

Distribution と Viewer 間の HTTPS のポリシーを選択する。HTTP のみの設定はできない。

* HTTP and HTTPS
* Redirect HTTP to HTTPS
* HTTPS Only

Distribution と Origin 間は _Origin Settings > Origin Protocol Policy_ になるので注意。

### HTTP Methods

* GET/HEAD は常にキャッシュ対象となる。
* OPTIONS はキャッシュするかどうか選択できる。
* POST/PUT/PATCH/DELETE はキャッシュされない。

### Forward Headers

* None
    * すべての Viewer からのリクエストヘッダを破棄
* Whitelist
    * Forward するリクエストヘッダ名を指定する。リクエストヘッダ値ごとにキャッシュされる。
* All
    * すべてのリクエストヘッダを Forward する。この場合、リクエストは全てキャッシュされず、Object Caching や TTL の設定はできない。単に Edge Location を経由して Forward するコストがかかるだけなので、この設定が中心なら CloudFront を利用する意味はない。

#### Host

`Host` ヘッダを通しておくと、Origin のホスト名ではなく、Viewer のリクエストした `Host` ヘッダ値、すなわちリクエスト URL のドメイン名がそのまま渡る。VirtualHost や Proxy で `Host` ヘッダ値に応じて切り分けている場合に、CloudFront を通した場合と、そうでない場合で設定を変更せずに済む。

Origin Domain Name はあくまで、サーバへのアドレスであり、それが `Host` ヘッダに渡るかどうかは Forward Headers の設定による。

#### User-Agent

Whiltelist で `User-Agent` ヘッダを指定することはできない。`User-Agent` 値を得たいときは All（キャッシュされない）とする必要がある。

デバイスに応じた以下のヘッダ値が得られるので、デバイス別の出し分けに有効なヘッダを Forward すれば良い。

* `CloudFront-Is-Desktop-Viewer`
* `CloudFront-Is-Mobile-Viewer`
* `CloudFront-Is-SmartTV-Viewer`
* `CloudFront-Is-Tablet-Viewer`

Forward しなければ、これらのヘッダを区別せずキャッシュされてしまうので Origin には渡らないことに注意する。

### Object Caching

* <http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Expiration.html>

デフォルトではキャッシュの有効期限は 24 時間になる。以下の方法で Origin から期限を調整できる。

* Use Origin Cache Headers
    * Origin の返すレスポンスヘッダ `Cache-Control` `Expire` を、そのままキャッシュの有効期限とみなす。
* Customize
    * Origin の返すレスポンスヘッダと予め設定した Minimum TTL / Maximum TTL の条件を元に、キャッシュ方法を変更する。
    * <http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Expiration.html#ExpirationDownloadDist>

### Forward Cookies

* None
    * すべての Viewer からの Cookie を破棄
* Whitelist
    * Forward する Cookie 名を指定する。Cookie 属性 (Path/Expire/etc.) は Forward されない。
    * Whitelist に含まれない Cookie は Forward されず、Origin で参照できない。
    * Set-Cookie ヘッダは Whitelist に含まれるかどうかに関わらず Viewer に渡る。ただし、Set-Cookie ヘッダを出力するページはキャッシュされるべきではない。
* All
    * すべての Cookie を Forward する。

Forward される Cookie について勘違いしやすい点として、それらの Cookie 値があれば Origin に渡るわけではない。Cookie 値に応じてキャッシュが区別されるというだけである。

Cookie にデータそのものが入っている場合には、レスポンス（キャッシュ）を切り分けることができる。

* 利用言語
* フォントサイズやテーマなどのスタイル

ただしキャッシュされてしまうと Origin には渡らない点に注意する。キャッシュされた後に Origin 側で出力を変更しても、キャッシュが切れるまでは、Origin で行なった変更は反映されない。

Cookie がセッションIDなどのキーを保持して、Origin 側でセッションデータを保持する場合には、決してキャッシュしてはならない。同じセッションIDでも、Origin が保持しているセッションデータは同じではないためである。

### Foward Query Strings

URLクエリは Whitelist の指定はできず、Forward するかしないかの設定しかできない。

* Viewer がURLクエリを指定できないわけではない。Viewer のブラウザの履歴やキャッシュのURLとしては区別される。
* Forward しない場合は、URLクエリは Origin には渡らず、キャッシュも同じになる。

## Invalidations

いったん、キャッシュされてしまったコンテンツは Origin からはクリアできない。Invaldiation リクエストを登録して非同期にクリアされるのを待つしかない。

* 同時に処理できるオブジェクト数は 3,000 に制限される。ワイルドカード指定であっても、実際にクリア対象となるオブジェクト数で算出される。
* 1,000 objects / month までは無料だが、それ以上は課金される。
* リクエスト直後にクリアされるわけではない、Distribution の設定変更と同様に、各 Edge location に行き渡るまでに時間がかかる。

## Caveat

* Distribution の設定変更は、全ての Edge Location への反映を伴う。ステータスは _In-Progress_ となり、15 分ほどの時間がかかる。
* 利用にあたって制限がある点に注意する。Cache Behavior や Whitelist の上限はさほど多くない。
    * <http://docs.aws.amazon.com/general/latest/gr/aws_service_limits.html#limits_cloudfront>
* Origin の返す `Cache-Control` ヘッダでキャッシュ期限の調整はできるが、キャッシュが残っているかぎり Origin から応答を返すことはできない（キャッシュ期限の変更はできない）点に注意する。キャッシュされてしまったものは Invalidation が必要になり、変更が行き渡るまでに時間を要する。
    * 最初のうちは Maximum TTL を短くしておき、キャッシュが有効なら TTL を伸ばす。
* `Set-Cookie` を返すコンテンツは、決してキャッシュしてはならない。
    * セッションキーをセットする `Set-Cookie` がキャッシュされた。
        * 同じキャッシュを参照した全ての Viewer が、同じセッションキーを共有
        * 同じログインセッションを共有した場合、別のユーザの情報が見えてしまう
        * サイト自身が Session 固定攻撃を行なうのと同等
    * 利用言語の選択を記憶する `Set-Cookie` がキャッシュされた。
        * キャッシュを参照するたび、キャッシュから返される言語設定に切り替わってしまう。
* HTTP ステータスエラーは 5 分間キャッシュされる。変更するには別途設定を行なう必要がある。
    * <http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/HTTPStatusCodes.html>
* 独自ドメインで SSL を使用する場合は、SSL 証明書が必要なことはもちろん、各 Edge Location 毎に、独自ドメインに対する固有の IP アドレスを AWS に割り当ててもらうことが必要になる。このための別途料金が月額 600 USD ほどかかる。
    * <http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/SecureConnections.html#CNAMEsAndHTTPS>
    * 利用可能な SSL 証明書の制限がある。
    * AWS アカウント毎に最大 2 つまでしか SSL 証明書を登録できない。
