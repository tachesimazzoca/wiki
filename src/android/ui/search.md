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

## Query Suggestions

Content Provider により、検索クエリの候補表示を行なうことができる。

`searchable[@android:searchSuggestAuthority]` に Content Provider の Authority を指定する。

{% highlight xml %}
<searchable ...
    android:searchSuggestAuthority="net.example.android.search.SuggestionsProvider" />
{% endhighlight %}

検索クエリの入力毎に `ContentProvider#query` が呼ばれるので、適宜、候補文字列への `Cursor` を返せばよい。URI の最後尾パスに、検索クエリがURLエンコードされて渡される。

{% highlight java %}
@Override
public Cursor query(Uri uri, String[] projection, String selection,
                    String[] selectionArgs, String sortOrder) {
    // content://net.example.android.search.SuggestionProvider/(encodedQueryString)?...
    Log.i(TAG, uri.toString());

    String q = uri.getLastPathSegment();
    ...
}
{% endhighlight %}

`searchable[@android:searchSuggestSelection]` に、`ContentProvider#query` の第２引数 `selection` に渡す文字列（WHERE 節等）を指定できる。この場合、検索クエリは、第３引数の `selectionArgs` に渡される。`selection` 文字列をどう使うかは、`ContentProvider#query` メゾッドの実装次第なので、単に `selectionArgs` から検索クエリを受け取るために、ダミーの `android:searchSuggestSelection` を指定する方法もある。

{% highlight xml %}
<searchable ...
    android:searchSuggestAuthority="net.example.android.search.SuggestionsProvider"
    android:searchSuggestSelection=" ? " />
{% endhighlight %}

{% highlight java %}
@Override
public Cursor query(Uri uri, String[] projection, String selection,
                    String[] selectionArgs, String sortOrder) {
    if (1 != selectionArgs.length)
        throw new IllegalArgumentException("The length of selectionArgs must be 1.");
    String q = selectionArgs[0];
    ...
}
{% endhighlight %}

`Cursor` には、主に以下のカラムが必要になる。

* `BasicColumns._ID`: 候補一覧の Adapter から選択するために必要
* `SearchManager.SUGGEST_COLUMN_TEXT_1`: 候補文字列
* `SearchManager.SUGGEST_COLUMN_TEXT_2`: 候補説明文
* `SearchManager.SUGGEST_COLUMN_QUERY`: `Intent.ACTION_SEARCH` の場合、検索クエリとして `SerchManager.QUERY` に渡す文字列

候補選択時に `Intent.ACTION_SEARCH` ではなく、任意の Intent を発行することもできる。

* <http://developer.android.com/guide/topics/search/adding-custom-suggestions.html#IntentForSuggestions>

`Cursor` の各レコードに `SearchManager.SUGGEST_COLUMN_INTENT_*` のカラム値を含めればよい。

* `SearchManager.SUGGEST_COLUMN_INTENT_ACTION`
* `SearchManager.SUGGEST_COLUMN_INTENT_DATA`
* `SearchManager.SUGGEST_COLUMN_INTENT_DATA_ID`
* `SearchManager.SUGGEST_COLUMN_INTENT_EXTRA_DATA`

全ての候補に共通な値は、`SearchableInfo` に含めることもできる。

{% highlight xml %}
<!--
searchSuggestIntentAction: SUGGEST_COLUMN_INTENT_ACTION
searchSuggestIntentData  : SUGGEST_COLUMN_INTENT_DATA
-->
<searchable ...
    android:searchSuggestIntentAction="android.intent.action.VIEW"
    android:searchSuggestIntentData="content://net.example.android.data" />
{% endhighlight %}

## SearchRecentSuggestionsProvider

* <http://developer.android.com/guide/topics/search/adding-recent-query-suggestions.html>

検索クエリの履歴を候補にするなら、`SearchRecentSuggestionsProvider` を継承した Content Provider を使えば良い。

{% highlight java %}
import android.content.SearchRecentSuggestionsProvider;

public class SearchHistoryProvider extends SearchRecentSuggestionsProvider {
    public final static String AUTHORITY = "net.example.android.search.SearchHistoryProvider";
    public final static int MODE = DATABASE_MODE_QUERIES;

    public SearchHistoryProvider() {
        setupSuggestions(AUTHORITY, MODE);
    }
}
{% endhighlight %}

`SearchRecentSuggestionsProvider#query` の実装では、検索クエリを `selectionArgs` から取得するため、`android:searchSuggestSelection` には、ダミー文字列 ` ? ` を指定する。

{% highlight xml %}
<searchable ...
    android:searchSuggestAuthority="net.example.android.search.SearchHistoryProvider"
    android:searchSuggestSelection=" ? " />
{% endhighlight %}

履歴に追加する検索クエリは `SearchRecentSuggestions#saveRecentQuery` を介して登録する。

{% highlight java %}
@Override
public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    ...
    Intent intent  = getIntent();

    if (Intent.ACTION_SEARCH.equals(intent.getAction())) {
        String query = intent.getStringExtra(SearchManager.QUERY);
        SearchRecentSuggestions suggestions = new SearchRecentSuggestions(this,
                SearchHistoryProvider.AUTHORITY, SearchHistoryProvider.MODE);
        suggestions.saveRecentQuery(query, null);
    }
}
{% endhighlight %}

履歴の削除には `SearchRecentSuggestions#clearHistory` を用いる。ユーザのプライバシーのため、アプリケーションでは必ず提供しておくべきである。

