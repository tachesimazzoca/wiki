---
layout: page

title: Broadcast
---

## Overview

* <http://developer.android.com/reference/android/content/BroadcastReceiver.html>
* <http://developer.android.com/training/monitoring-device-state/battery-monitoring.html>

## Static vs. Dynamic

BroadcastReceiver は AndroidManifest.xml 内の `<receiver>` 要素を用いて静的に登録する方法と、`Context#registerReceiver` で動的に登録する方法がある。

Static:

{% highlight xml %}
<application>
    ...
    <receiver
        android:name=".ExampleReceiver"
        android:exported="false" >
        <intent-filter android:priority="0" >
            <action android:name="net.example.android.broadcast.EXAMPLE" >
            </action>
        </intent-filter>
    </receiver>
</application>
{% endhighlight %}

Dynamic:

{% highlight java %}
private BroadcastReceiver mReceiver;

protected void onCreate(Bundle savedInstanceState) {
    ...
    mReceiver = new ExampleReceiver();
    IntentFilter ifilter = new IntentFilter("net.example.android.broadcast.EXAMPLE");
    ifilter.setPriority(0);
    registerReceiver(mReceiver, ifilter);
    ...
}

protected void onDestroy() {
    if (null != mReceiver)
        unregisterReceiver(mReceiver);
    super.onDestroy();
}
{% endhighlight %}

動的に登録/解除する場合、ライフサイクルに注意しなければならない。

* `Activity#(onCreate|onDestroy)` の場合は、アクティビティが休止していても、タスクツリー内にあれば解除されない。
* `Activity#(onResume|onPause)` の場合は、アクティビティが休止する際に解除される。`onResume` で登録する場合は、`onPause` で解除しなければならない。

アクティビティで登録を行なった場合は、明示的に解除されていないと、警告とともにアクティビティのライフサイクルで破棄される。

    android.app.IntentReceiverLeaked: .... Are you missing a call unregisterReceiver()?

言い換えると、`Context#getApplicationContext()` で得られる Context から登録を行なった場合は、明示的に解除しなければ、メモリリークを引き起こすことになる。

## Normal vs. Ordered

`sendBroadcast` で送信した場合は、順不同で Receiver に配信される。`sendOrderedBroadcast` で送信した場合は、IntentFilter に指定した priority 値の大きいものから、順番に配信される。

Orderd Broadcast の場合は、`BroadcastReceiver#(get|set)ResultData` により、各レシーバから結果データを受け渡すことができる。

{% highlight java %}
public class ExampleReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        setResultData("Received");
    }
}
{% endhighlight %}

{% highlight java %}
final String action = "net.example.android.broadcast.EXAMPLE";
registerReceiver(new ExampleReceiver(), new IntentFilter(action));
sendOrderedBroadcast(new Intent(action), null,
        new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String data = getResultData();
                ...
            }
        }, null, 0, null, null);
{% endhighlight %}

結果データを得るには、最終結果を受け取るレシーバを登録できる Ordered Broadcast である必要がある。Normal Broadcast で、`(get|set)ResultData` を使うと警告が表示される。

## Context vs. LocalBroadcastManager

* <http://developer.android.com/reference/android/content/BroadcastReceiver.html#Security>
* <http://developer.android.com/reference/android/support/v4/content/LocalBroadcastManager.html>

Broadcast はグローバルに行なわれる。すなわち、外部アプリケーションのレシーバであっても IntentFilter にマッチすれば、配信を受け取ることができる。

* アクション名は、他アプリケーションと衝突がないように、慣例的にパッケージ名を付与したものにする。
* 外部アプリケーションによる受信を許可する場合には、適切なパーミッションを定義する。

レシーバ側からの視点でも、外部アプリケーションからの配信を受けてしまう事になる。静的に登録する場合は `<receiver ... android:exported="false" ...>` で、外部からの配信を受けないようにすることができるが、動的に登録する場合には、このオプションは使えないようである。

Broadcast を自アプリケーション内に限るなら、LocalBroadcastManager を使うことができる。LocalBroadcastManager による送受信は、同一アプリケーション内で閉じており、外部アプリケーションからは守られる。

{% highlight java %}
LocalBroadcastManager mBcast = LocalBroadcastManager.getInstance(getApplicationContext());
mBcast.regsisterReceiver(mReceiver);
...
mBcast.sendBroadcast(new Intent(...));
...
mBrast.unregisterReceiver(mReceiver);
{% endhighlight %}

LocalBroadcastManager には、以下の制限がある。

* 同一アプリケーション内であっても、LocalBroadcastManager で登録したレシーバは、LocalBroadcastManager からの送信のみ受け付ける。Context での送受信とは区別される。
* LocalBroadcastManager では Ordered Broadcast はできない。

## Sticky Broadcast

Sticky Broadcast は、配信後に永続的に残り、配信後に登録したレシーバであっても、最終配信を受信できる。

配信済みであれば `Context#registerReceiver` の戻り値 Intent で最終配信を得られるので、レシーバは `null` でよい。バッテリー残量などシステム情報を得るときに使う。

{% highlight java %}
Intent batteyStatus = registerReceiver(
        null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
int capacity = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
{% endhighlight %}

アプリケーションからは `Context#(send|remove)StickyBroadcast` で配信できる。

* パーミッション `android.permission.BROADCAST_STICKY` を設定する。
* 配信後も永続的に残るので、`removeStickyBroadcast` で破棄する。

Sticky Broadcast は、外部アプリケーションでも制限なく最終配信を得られるため、セキュリティ面での問題が多い。このため API level 21 より、関連する API は非推奨となっている。システムから、グローバルな端末情報等を配信するものとして用い、アプリケーションから配信する必要はない。利用しているアプリケーションがあれば、すみやかに別の方法でアップデートすべきである。

