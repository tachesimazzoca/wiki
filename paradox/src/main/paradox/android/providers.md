# Content Providers

## Overview

* <http://developer.android.com/guide/topics/providers/content-providers.html>

Content Provider は以下の特徴を持つ。

* 異なるアプリケーションに対して、適切なパーミッションを持つデータアクセスを提供できる。
* `ContentResolver` を介した URI 形式でのメッセージ通信により、非同期にデータアクセスを行なう。
* 各アプリケーションにデータの更新を通知できる。

## Content URI

データアクセスは URI のメッセージ通信で行なう。URI から、どの Provider 宛のものかを特定するために、Authority と呼ばれる名前空間を定義する。慣習的に各アプリケーションのパッケージ名に続ける。

`AndroidManifest.xml` に `<provider>` として登録しておく。

```xml
<application ...>
    <provider android:name=".TodoProvider"
              android:authorities="net.example.android.provider.TodoProvider" />
</application>
```

Provider は `content://(authority)` の後に続けて、各 URI を定義する。クライアントは `ContentResolver` を介して、 URI を送信してデータアクセスを行なう。直接 Provider にアクセスすることはできない。

```java
Uri uri = Uri.parse("content://net.example.android.provider.TodoProvider/tasks");
Cursor cursor = getContentResolver().query(uri, null, null, null, null);
```

### ContentUris

* <http://developer.android.com/reference/android/content/ContentUris.html>

パス名の最後尾に Long 型の ID を指定する URI の場合、Long / String 型に相互に変換する定型処理がある。このために `ContentUris` というユーティリティクラスが提供されている。

```java
final Uri CONTENT_URI = Uri.parse("content://net.example.android.provider.TodoProvider/tasks");
long id = 1234;
Uri newUri = ContentUris.withAppendId(uri, id);
assert "content://net.example.android.provider.TodoProvider/tasks/1234".equals(newUri.toString());
assert id == ContentUris.parseId(newUri);
```

## ContentProvider

* <http://developer.android.com/reference/android/content/ContentProvider.html>

独自の Content Provider を作るには `ContentProvider` を継承する。

```java
public class TodoProvider extends ContentProvider {
    @Override
    public boolean onCreate() {
        return true;
    }

    @Override
    public Cursor query(Uri uri, String[] projection, String selection,
                        String[] selectionArgs, String sortOrder) {
        Cursor cursor;
        ...
        cursor.setNotificationUri(getContext().getContentResolver(), uri);
        return cursor;
    }

    @Override
    public String getType(Uri uri) {
        return null;
    }

    @Override
    public Uri insert(Uri uri, ContentValues contentValues) {
        long id;
        ...
        if (id > 0) {
            Uri newUri = ContentUris.withAppendedId(uri, id);
            getContext().getContentResolver().notifyChange(newUri, null);
            return newUri;
        } else {
            throw new SQLException("Failed to insert " + contentValues);
        }
    }

    @Override
    public int delete(Uri uri, String selection, String[] selectionArgs) {
        int n; // the number of rows affected
        ...
        getContext().getContentResolver().notifyChange(uri, null);
        return n;
    }

    @Override
    public int update(Uri uri, ContentValues contentValues,
                      String selection, String[] selectionArgs) {
        int n; // the number of rows affected
        long id = ContentUris.parseId(uri);
        ...
        getContext().getContentResolver().notifyChange(uri, null);
        return n;
    }
}
```

* `query` では `Loader` を介してデータを監視しているクライアントのために、`Cursor#setNotificationUri` で通知URIをセットしておく。
* `(insert|update|delete)` では `Loader` を介してデータを監視しているクライアントのために、`ContentResolver#notifyChange` で変更を通知する。

### UriMatcher

* <http://developer.android.com/reference/android/content/UriMatcher.html>

URI のパターンマッチのために、`UriMatcher` が提供されている。

```java
private static final UriMatcher mUriMatcher = new UriMatcher(UriMatcher.NO_MATCH);

private static final int URI_TASKS = 1;
private static final int URI_TASKS_ID = 2;
private static final int URI_TASK_LABELS = 3;
private static final int URI_TASK_LABELS_NAME = 4;

static {
    // content://(authority)/tasks
    sUriMatcher.addURI("tasks", URI_TASKS);

    // content://(authority)/tasks/123
    sUriMatcher.addURI("tasks/#", URI_TASKS_ID);

    // content://(authority)/tasks/123/labels
    sUriMatcher.addURI("tasks/#/labels", URI_TASK_LABELS);

    // content://(authority)/tasks/123/labels/foo
    sUriMatcher.addURI("tasks/#/labels/*", URI_TASK_LABELS_NAME);
}

@Override
public Cursor query(Uri uri, String[] projection, String selection,
                    String[] selectionArgs, String sortOrder) {
    switch (sUriMatcher.match(uri)) {
        case URI_TASKS:
            ...
            break;
        ...
        default:
            ...
    }
}

...
```
