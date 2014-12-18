---
layout: page

title: Storage
---

## Shared Preferences

* <http://developer.android.com/guide/topics/data/data-storage.html#pref>

アプリケーション固有の設定を記録しておくには、Key-Value ストアの [SharedPreferences](http://developer.android.com/reference/android/content/SharedPreferences.html) を用いるとよい。保存可能な値はプリミティブ型 _boolean / int / long float / String_ に限る。

{% highlight java %}
private static final String PREF_NAME = "settings";

protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    ...
    SharedPreferences settings = getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
    String foo = settings.getString("foo");
}

...

protected void onStop() {
    SharedPreferences settings = getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
    SharedPreferences.Editor editor = settings.edit();
    settings.putString("foo", "bar");
    ...
    super.onStop();
}
{% endhighlight %}

SharedPreferences の読み書きには、それなりのコストがかかるため、ユーザ操作ごとに更新してはならない。更新タイミングは、HONEYCOMB 以降のみのサポートなら `Activity#onStop` でよい。それ以前のバージョンでは、`onStop` が呼ばれない場合があるため `onPause` で保存する。

## Internal Storage

Internal Storage には、アプリケーション固有のファイルを保存する。アプリケーションを介する読み書きのみで、ユーザ自身がファイルを操作することはできない。アプリケーションのアンインストールにより削除される。

* [Context#opneFileOutput](http://developer.android.com/reference/android/content/Context.html#openFileOutput\(java.lang.String, int\))
* [Context#openFileInput](http://developer.android.com/reference/android/content/Context.html#openFileInput\(java.lang.String\))

により、得られるファイルストリームに対し読み書きすれば良い。

キャッシュなどの一時ファイルは [Context#getCacheDir](http://developer.android.com/reference/android/content/Context.html#getCacheDir\(\)) により得られるディレクトリ以下に保存する。このディレクトリ内のファイルは、容量が足りなくなった時などの必要時に応じて削除される。

## External Storage

External Storage には、ユーザ自身が操作可能なファイル（写真 / 動画 / ダウンロードファイル 等）を保存する。

取り外し可能な、SDカードなどのリムーバブルストレージのみを指すわけではない。端末内部にも仮想デバイスとして External Storage が提供される。

[Environment.getExternalStorageDirectory](http://developer.android.com/reference/android/os/Environment.html#getExternalStorageDirectory\(\)) により External Storage のディレクトリが得られる。`(READ|WRITE)_EXTERNAL_STORAGE` のパーミッションを持っていれば、このディレクトリ以下の全てのファイルにアクセスできる。

{% highlight xml %}
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
{% endhighlight %}

Internal Storage とは異なり、アプリケーション外から全てのファイル操作が可能である。

* 外部アプリケーションから、ファイル読み書きが可能
* USBデバイスとして、ユーザ自身がファイルを操作することが可能

このため、漏洩 / 改変されると問題のあるデータ（ポイント/認証トークン/パスワード等）を保存してはならない。セキュリティ的には問題がないデータであっても、改変されてはならないアプリケーション固有のデータは Internal Storage を使う。

### Public Directory

[Environment.getExternalStoragePublicDirectory](http://developer.android.com/reference/android/os/Environment.html#getExternalStoragePublicDirectory\(java.lang.String\)) により、ファイル種別毎の共有ディレクトリを取得できる。

{% highlight java %}
File path = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES);
{% endhighlight %}

システムが、ファイル種別毎に区分けしたディレクトリであって、保存するファイル種別の制限はない。アプリケーション自身でハンドリングを行なう必要がある。

### Application Directory

[Context#getExternalFilesDir](http://developer.android.com/reference/android/content/Context.html#getExternalFilesDir\(java.lang.String\)) により、アプリケーション用の保存ディレクトリを取得できる。

このディレクトリはアプリケーションのアンインストールとともに削除される。写真などの共有データや購入コンテンツを保存してはならない。Internal Strage に収まりきらない、漏洩や改変があっても問題ないファイルを保存し、アンインストールとともに削除されるべきファイルを保存する。

他アプリケーションとのファイル名衝突がないように、システムによりアプリケーション用に区分けされたディレクトリであって、External Storage へのパーミッションを持つアプリケーションはアクセス可能である点に注意する。

Android 4.4 (API19) 以降では、自身のパッケージのディレクトリであれば、パーミッションを持たなくてもアクセスできる。Public Directory へのアクセスが不要なら `maxSdkVersion` を指定しておくとよい。

{% highlight xml %}
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
                     android:maxSdkVersion="18" />
{% endhighlight %}

API19 以降の端末のみで動作確認すると、パーミッションの追加を忘れてしまいがちなので注意する。

### Error Handling

External Storage がリムーバブルである場合、マウントされていなければ利用可能できない。

* [Context#getExternalFilesDir](http://developer.android.com/reference/android/content/Context.html#getExternalFilesDir\(java.lang.String\)) は、アクセスできない場合には `null` が返る。
* [Environment#getExternalStorageState](http://developer.android.com/reference/android/os/Environment.html#getExternalStorageState\(\)) でマウント状態を取得できる。

`ACTION_MEDIA_(MOUNTED|REMOVED)` の Broadcast が送信されるので、レシーバを登録しておくこともできる。

* <http://developer.android.com/reference/android/os/Environment.html#getExternalStorageDirectory()>

## Multi User

Android 4.2 よりマルチユーザに対応している。Internal Storage および、端末内部の External Storage には、ユーザID毎のディレクトリが作成され、利用ユーザごとのアプリケーションデータが作成されることになる。

* Internal Storage: `/data/user/(ユーザID)`
* External Storage: `/storage/emulated/(ユーザID)`

External Storage がリムーバブルの場合には、マルチユーザとはならない。

アプリケーション側では、シングル/マルチユーザの違いは意識せず API を介してディレクトリを取得すればよい。ディレクトリ名は端末により異なるので、直接ファイルパスを指定してはならない。

エミュレータではシングルユーザに制限されている。Android 4.2(API17) 系のエミュレータであれば、`adb shell` を介して `fw.max_users` で最大ユーザ数を指定することで、マルチユーザを利用することができる。

    $ adb shell
    root@generic:/ # pm get-max-users
    Maximum supported users: 1
    root@generic:/ # setprop fw.max_users 8
    root@generic:/ # pm get-max-users
    Maximum supported users: 8

