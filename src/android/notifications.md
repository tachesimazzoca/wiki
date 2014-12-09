---
layout: page

title: Notifications
---

## Overview

* <http://developer.android.com/guide/topics/ui/notifiers/notifications.html>

## Usage

{% highlight java %}
final NOTIFICATION_ID = 1;

NotificationCompat.Builder builder = new NotificationCompat.Builder(
        getApplicationContext())
        .setAutoCancel(true)
        .setSmallIcon(android.R.drawable.stat_sys_warning)
        .setContentTitle("Notification Title")
        .setContentText("Here is a notification text.");
((NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE))
        .notify(NOTIFICATION_ID, builder.build());
{% endhighlight %}

## TaskStackBuilder

* <http://developer.android.com/guide/components/tasks-and-back-stack.html>

通知をタップした際のアクションは `NotificationCompat.Builder#setContentIntent(PendingIntent)` で設定する。

Launcher から起動して、順に履歴に積んでいく場合とは異なり、Notification Bar から子アクティビティを起動すると、遷移が不自然になってしまう。親アクティビティからの遷移が必要な場合は、新規に [TaskStackBuilder](http://developer.android.com/reference/android/app/TaskStackBuilder.html) を使って履歴を組み直すようにする。

{% highlight java %}
Context context = getApplicadtionContext();
TaskStackBuilder stackBuilder = TaskStackBuilder.create(context);
// ParentActivity > SubActivity
stackBuilder.addNextIntent(new Intent(context, MainActivity.class));
stackBuilder.addNextIntent(new Intent(context, SubActivity.class)));
contentIntent = stackBuilder.getPendingIntent(0, PendingIntent.FLAG_UPDATE_CURRENT);
NotificationCompat.Builder builder = new NotificationCompat.Builder(
        getApplicationContext())
        .setContentIntent(contentIntent)
        ...
{% endhighlight %}

`AndroidManifest.xml` 内で `android:parentActivityName` を指定していれば、`TaskStackBuilder#setParentStack` を使って組み直す事も出来る。

{% highlight xml %}
<activity
    android:name=".SubActivity"
    android:parentActivityName=".MainActivity" />
{% endhighlight %}

{% highlight java %}
stackBuilder.setParentStack(SubActivity.class);
stackBuilder.addNextIntent(new Intent(context, SubActivity.class)));
{% endhighlight %}

対象アクティビティが単独で成立するのであれば、Intent のフラグを指定するだけでもよい。

{% highlight java %}
Intent intent = new Intent(this, MainActivity.class);
intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
contentIntent = PendingIntent.getActivity(
        context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
{% endhighlight %}

* `FLAG_ACTIVITY_SINGLE_TOP`
  * 対象アクティビティが最終履歴（Back Stack 先頭）であれば、アクティブにするのみで履歴に新規追加しない。
* `FLAG_ACTIVITY_CLEAR_TOP`
  * 対象アクティビティが履歴にあれば、それを最終履歴（Back Stack 先頭）にして、以降の履歴を削除する。

