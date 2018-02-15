# Material Design

## v7 Support Libraries

* <http://android-developers.blogspot.jp/2014/10/appcompat-v21-material-design-for-pre.html>

v7 Support Libraries r21 を使うことで、Android 5.0 以前の端末にも、Material Design を適用することができる。

* `Theme.AppCompat` : 黒地に白文字
* `Theme.AppCompat.Light` : 白地に黒文字

のいずれかをベースに、スタイルを定義していく。

[Color Palette](https://developer.android.com/training/material/theme.html#ColorPalette) にも対応しているので、[Material Design の Color ガイドライン](http://www.google.com/design/spec/style/color.html) を参考に、Color Palette の属性を指定すると良い。

```xml
<!-- Material.Light.DarkActionBar (Blue Gray) -->
<style name="AppTheme" parent="Theme.AppCompat.Light">
    <item name="colorPrimary">#37474F</item>
    <item name="colorPrimaryDark">#263238</item>
    <!--
    <item name="colorAccent">@color/accent_material_light</item>
    -->
</style>
```

* `colorPrimary`: Action Bar の背景色
* `colorPrimaryDark`: Status Bar の背景色（Android 5.0 以降のみ）
* `colorAccent`: チェックボックス等のアクセント色

### Use Toolbar as an Action Bar

`android.support.v7.widget.Toolbar` という Widget が追加されている。

* Action Bar
* 単体のツールバー

として使うことができる。

Action Bar として使うには、`Theme.AppCompat(.Light).NoActionBar` のテーマを使い、Action Bar を無効にする。

```xml
<style name="AppTheme" parent="Theme.AppCompat.Light.NoActionBar">
    ...
</style>
```

Toolbar は、単なる ViewGroup なので、レイアウトファイルに View として定義する。

```xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    ... >
    <android.support.v7.widget.Toolbar
            android:id="@+id/toolbar"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:background="?attr/colorPrimary"
            android:minHeight="?attr/actionBarSize"
            app:popupTheme="@style/Theme.AppCompat.Light"
            app:theme="@style/ThemeOverlay.AppCompat.Dark.ActionBar"
            app:title="@string/app_name" />
</LinearLayout>
```

Toolbar を `Activity#setSupportActionBar` にセットすれば、Action Bar として機能し、同様のコールバックがそのまま使える。

```java
@Override
protected void onCreate(Bundle savedInstanceState) {
    ...
    Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
    setSupportActionBar(toolbar);
}
```

#### app:theme

Toolbar のテーマ `app:theme` には、以下のいずれかを指定する。

* `ThemeOverlay.AppCompat.Dark.ActionBar`: 透明地に白文字
* `ThemeOverlay.AppCompat.ActionBar`: 透明地に黒文字

いずれも背景色が透明なので、変更するには、`android:background` を指定する。ガイドラインに沿って、Color Palette の属性 `colorPrimary` を指定するとよい。

Toolbar のテーマを継承して `android:background` を指定してしまうと、内包するポップアップメニューの背景も変更されてしまう。以下の方法は誤りである。

```xml
<!-- NG: This overrides android:background of app:popupTheme. -->
<style name="AppTheme.Toolbar" parent="ThemeOverlay.AppCompat.Dark.ActionBar">
    <item name="android:background">?attr/colorPrimary</item>
    ...
</style>
```

Toolbar のテーマ内ではなく、View の `android:background` で指定する。

```xml
<!-- OK: -->
<android.support.v7.widget.Toolbar
        ...
        android:background="?attr/colorPrimary"
        android:theme="ThemeOverlay.AppCompat.Dark.ActionBar"
        ... />
```

#### app:popupTheme

Toolbar 内のポップアップメニューのテーマを変更するには `app:popupTheme` を指定する。Toolbar のテーマと連動しているが、Material Design では、メインのテーマに合わせているケースが多い。

