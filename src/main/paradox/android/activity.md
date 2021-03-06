# Activity

## Overview

* <http://developer.android.com/guide/components/activities.html>

## this vs. getApplicationContext

様々な API に Context インターフェイスを渡すことがある。

* <http://developer.android.com/reference/android/content/Context.html>

Activity は Context を継承しているため、アクティビティ自身の `this` を渡しても動作するが、`getApplicationContext` との使い分けを意識する必要がある。

* `this` は、アクティビティのライフサイクルと連動する
* `getApplicationContext` は、アプリケーションのライフサイクルと連動する

単に Context として、アクティビティ自身 `this` を渡すと、受け側のAPIが Context の参照を保持していた場合、アクティビティのライフサイクルで破棄されず、メモリリークを起こしてしまう。かといって、メモリリークを避けるために、一律で `getApplicationContext` を使うべきかというとそうではない。

* <http://developer.android.com/reference/android/content/Context.html#getApplicationContext()>

`registerReceiver` で BroadcastReceiver を登録するシナリオを考えてみると、アクティビティから登録されたレシーバは、明示的に `unregisterReceiver` を行なわなかった場合でも、アクティビティのライフサイクルで破棄されるが、アプリケーションから登録された場合は、明示的に破棄しなければ、いつまでもレシーバは待機しつづけることになる。

## onPause vs. onStop

アクティビティはバックグラウンドに移る際 `onPause` が呼ばれ休止状態に入る。他のアプリケーションによりメモリが不足した場合 `onStop` が呼ばれずにアプリケーションが終了する場合がある。このため、SharedPreference などの永続化処理は `onPause` で行なう必要がある。

しかし HONEYCOMB 以降からは、アプリケーションのプロセスが終了する前には `onStop` が呼ばれることが保証されている。

> Starting with Honeycomb, an application is not in the killable state until its onStop() has returned.

このため、HONEYCOMB 以降のみのサポートであれば、永続化処理は `onStop` で行えばよい。`onPause` は、次のアプリケーションのためにリソースを使うため、このタイミングでコストのかかる処理は好ましくない。

## Cheat Sheet

### Starting another activity

```java
Intent intent = new Intent(this, AnotherActivity.class);
startActivity(intent);
```

### Starting another activity from the chooser

```java
Intent intent = new Intent(Intent.ACTION_SEND);
intent.putExtra(Intent.EXTRA_TEXT, "foo");
intent.setType("text/plain")
Intent chooser = Intent.createChooser(intent, "Share this text via");
if (intent.resolveActivity(getPackageManager()) != null) {
    startActivity(chooser);
}
```

### Receiving an activity result

```java
private final static int REQUEST_CODE_FOO = 1;

private void startAnotherActivity() {
    Intent intent = new Intent(this, AnotherActivity.class);
    startActivityForResult(intent, RESULT_CODE_FOO);
}

...

@Override
public void onActivityResult(int requestCode, int resultCode, Intent data) {
    if (requestCode == REQUEST_CODE_FOO) {
        if (resultCode == RESULT_OK) {
            String txt = data.getStringExtra(Intent.EXTRA_TEXT);
            ...
        }
    }
}
```

`AnotherActivity.class`:

```java
private void done() {
    Intent intent = new Intent();
    intent.putExtra(Intent.EXTRA_TEXT, "foo");
    setResult(RESULT_OK, intent);
    finish();
}
```

### Adding an OnClickListener

You can set the `android:onClick` attribute to the method name of the activity having the corresponding view.

```xml
<Button
    ...
    android:onClick="doSomething" />
```

```java
public void doSomething(View view) {
    ....
}
```

However, if the method name is missing, it causes a runtime error. For more type safety, you would rather use the `View#setOnClickListner` method manually.

```java
import android.view.View;
import android.view.View.OnClickListener;
...

Button button = (Button) findViewById(R.id.button_send);
button.setOnClickListener(new OnClickListener() {
    @Override
    public void onClick(View view) {
        doSomething();
    }
});
```

### Retrieving all activities for the intent

```java
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
...

Intent httpScheme = new Intent(Intent.ACTION_VIEW, Uri.parse("http://example.net"));
PackageManager packageManager = getPackageManager();
List<ResolveInfo> activities = packageManager.queryIntentActivities(httpScheme, 0);
```
