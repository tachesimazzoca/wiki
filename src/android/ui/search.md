---
layout: page

title: Search
---

## Overview

* <http://developer.android.com/guide/topics/search/index.html>

## Search Dialog

Android は、システム共通の検索ダイアログを持っている。`AndroidManifest.xml` 内で、このダイアログを利用するアクティビティを指定する。

{% highlight xml %}
<activity android:name=".SearchableActivity" >
    <intent-filter>
        <action android:name="android.intent.action.SEARCH" />
    </intent-filter>
    <meta-data android:name="android.app.searchable"
               android:resource="@xml/searchable" />
</activity>
{% endhighlight %}

* `<intent-filter>` に `Intent.ACTION_SEARCH` を加える。
* `meta-data[@android:name="android.app.searchable"]` に、検索ダイアログの設定を記述したXMLリソースを指定する。

### SearchableInfo

検索ダイアログの設定は XML リソースから行なう。

* <http://developer.android.com/guide/topics/search/searchable-config.html>

`res/xml/searchable.xml`:

{% highlight xml %}
<?xml version="1.0" encoding="utf-8"?>
<searchable xmlns:android="http://schemas.android.com/apk/res/android"
    android:label="@string/app_name"
    android:hint="@string/searchable_hint">
</searchable>
{% endhighlight %}

* `android:label` のみが必須の属性になる。Global Search で表示されるアプリケーション名を指定する。
* `android:hint` に検索クエリ未入力時のヒント文字列を指定する。
* これらの二つの属性値は `@string` リソースからでないと認識されないバグがある。リテラル文字列で指定しても有効にならない。

この設定ファイルを元に `SearchableInfo` オブジェクトが生成される。アプリケーションからは `SearchManager` から取得できる。

{% highlight xml %}
SearchManager searchManager = (SearchManager) getSystemService(Context.SEARCH_SERVICE);
SearchableInfo searchableInfo = searchManager.getSearchableInfo(getComponentName());
{% endhighlight %}

`SearchableInfo` は XML リソースからの生成のみに限られ、ランタイム時に動的に生成することはできない。

### onSearchRequested

ボタンやメニューのフックとして、`Activity#onSearchRequested` を呼ぶ事で検索ダイアログが表示される。検索操作により、`Intent.ACTION_SEARCH` が、アクティビティに送信される。

検索毎に、新たなアクティビティが生成され Back Stack に積まれて行くので、起動中のアクティビティに送信するには `android:launchMode="singleTop"` を指定する。ただし、Back Stack から検索履歴を辿ることはできなくなる。

{% highlight xml %}
<activity android:name=".SearchableActivity"
          android:launchMode="singleTop">
{% endhighlight %}

検索クエリ文字列は、キー名 `SearchManager.QUERY` の Extra から取得する。

{% highlight java %}
@Override
public void onCreate(Bundle savedInstanceState) {
    ...
    handleIntent(getIntent());
}

@Override
protected void onNewIntent(Intent intent) {
    setIntent(intent);
    handleIntent(intent);
}

private void handleIntent(Intent intent) {
    if (Intent.ACTION_SEARCH.equals(intent.getAction())) {
        String q = intent.getStringExtra(SearchManager.QUERY);
        ...
    }
}
{% endhighlight %}

`android:launchMode="single"` の場合、アクティビティは生成済みのため `Activity#onNewIntent` で Intent を取得する。

### startSearch

検索クエリ以外の追加情報を渡したい時は、`Activity#onSearchRequested` をオーバーライドする。`Activity#startSearch` を介して、Bundle で追加情報を登録する。

{% highlight java %}
@Override
public boolean onSearchRequested() {
    Bundle appData = new Bundle();
    appData.putBoolean(SearchableActivity.SEARCH_OPTION_FOO, true);
    startSearch(null, false, appData, false);
    return true;
}
{% endhighlight %}

`Intent#getBundleExtra` より、キー名 `SearchManager.APP_DATA` で取得する。

{% highlight java %}
Bundle appData = getIntent().getBundleExtra(SearchManager.APP_DATA);
if (appData != null) {
    boolean foo = appData.getBoolean(SearchableActivity.SEARCH_OPTION_FOO);
    ...
}
{% endhighlight %}

### android.app.default_searchable

検索ダイアログのみ利用し、`Intent.ACTION_SEARCH` を受け取る検索処理は、他のアクティビティに受け渡すこともできる。`meta-data[@android:name="android.app.default_searchable"]` に、受け渡し先のアクティビティを指定すればよい。

{% highlight xml %}
<activity android:name=".MainActivity">
    <meta-data android:name="android.app.default_searchable"
               android:value=".SearchableActivity" />
</activity>
{% endhighlight %}

## SearchView Widget

Android 3.0 (API11) 以上であれば、Widget の `android.widget.SearchView` を使うことができる。

* <http://developer.android.com/reference/android/widget/SearchView.html>

Action Bar 内で利用する場合は、`android:actionVewClass` で、クラス名を指定する。

{% highlight xml %}
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:id="@+id/action_search"
          ...
          android:actionViewClass="android.widget.SearchView" />
</menu>
{% endhighlight %}

`SearchView` に対し、`SearchableInfo` をセットするだけでよい。`Activity#onSearchRequested` は検索ダイアログを起動するハンドラなので、 Widget 利用時に呼ぶ必要はない。

{% highlight java %}
@Override
public boolean onCreateOptionsMenu(Menu menu) {
    MenuInflater inflater = getMenuInflater();
    inflater.inflate(R.menu.menu_main, menu);

    SearchManager searchManager = (SearchManager) getSystemService(Context.SEARCH_SERVICE);
    SearchView searchView = (SearchView) menu.findItem(R.id.action_search).getActionView();
    searchView.setSearchableInfo(searchManager.getSearchableInfo(getComponentName()));
    searchView.setIconified(false);

    return super.onCreateOptionsMenu(menu);
}
{% endhighlight %}

appcompat-v7 では、`android.support.v7.widget.SearchView` を指定する。

{% highlight xml %}
<menu ...
      xmlns:app="http://schemas.android.com/apk/res-auto">
    <item android:id="@+id/action_search"
          ...
          app:actionViewClass="android.support.v7.widget.SearchView" />
</menu>
{% endhighlight %}

`SearchView` は、`android.support.v4.view.MenuItemCompat` を使って取得する。

{% highlight java %}
// Use the static method MenuItemCompat#getActionView, instead
SearchView searchView = (SearchView) MenuItemCompat.getActionView(
    menu.findItem(R.id.action_search));
{% endhighlight %}

