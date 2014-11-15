---
layout: page

title: Activity
---

## Overview

* <http://developer.android.com/guide/components/activities.html>

## Cheat Sheet

### Starting another activity

{% highlight java %}
Intent intent = new Intent(this, AnotherActivity.class);
startActivity(intent);
{% endhighlight %}

### Starting another activity from the chooser

{% highlight java %}
Intent intent = new Intent(Intent.ACTION_SEND);
intent.putExtra(Intent.EXTRA_TEXT, "foo");
intent.setType("text/plain")
Intent chooser = Intent.createChooser(intent, "Share this text via");
if (intent.resolveActivity(getPackageManager()) != null) {
    startActivity(chooser);
}
{% endhighlight %}

### Receiving an activity result

{% highlight java %}
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
{% endhighlight %}

`AnotherActivity.class`:

{% highlight java %}
private void done() {
    Intent intent = new Intent();
    intent.putExtra(Intent.EXTRA_TEXT, "foo");
    setResult(RESULT_OK, intent);
    finish();
}
{% endhighlight %}

### Adding an OnClickListener

You can set the `android:onClick` attribute to the method name of the activity having the corresponding view.

{% highlight xml %}
<Button
    ...
    android:onClick="doSomething" />
{% endhighlight %}

However, if the method name is missing, it causes a runtime error. For more type safety, you would rather use the `View#setOnClickListner` method manually.

{% highlight java %}
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
{% endhighlight %}

### Retrieving all activities for the intent

{% highlight java %}
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
...

Intent httpScheme = new Intent(Intent.ACTION_VIEW, Uri.parse("http://example.net"));
PackageManager packageManager = getPackageManager();
List<ResolveInfo> activities = packageManager.queryIntentActivities(httpScheme, 0);
{% endhighlight %}

