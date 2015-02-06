---
layout: page

title: Action Bar
---

## Overview

* <http://developer.android.com/guide/topics/ui/actionbar.html>
* <http://developer.android.com/guide/topics/resources/menu-resource.html>

## Cheat Sheet

### Android 3.0 (API11) or higher

`res/menu/menu_main.xml`

{% highlight xml %}
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:id="@+id/action_search"
          android:icon="@android:drawable/ic_menu_search"
          android:title="Search"
          android:showAsAction="ifRoom" />
</menu>
{% endhighlight %}

`MainActivity.java`

{% highlight java %}
...
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;

public class MainActivity extends Activity {
    ...
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_main, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.action_search:
                // do something ...
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }
}
{% endhighlight %}

### v7 Support Libraries

appcompat-v7 により Android 3.0 (API11) 以前の機種でも、Action Bar が実現できる。

テーマは appcompat-v7 に含まれる `Theme.AppCompat` 系を利用する。

{% highlight xml %}
<style name="AppTheme" parent="Theme.AppCompat.Light.DarkActionBar"></style>
{% endhighlight %}

Menu Resource において、いくつかの属性 `android:showAsAction` などは含まれないため、`app:` 等の独自のXML名前空間を追加して指定する。

{% highlight xml %}
<menu ...
      xmlns:app="http://schemas.android.com/apk/res-auto" >
    <item ...
          app:showAsAction="ifRoom" />
</menu>
{% endhighlight %}

Activity は `android.support.v7.app.ActionBarActivity` を継承する。`ActionBar` は `ActionBarActivity#getSupportActionBar` から取得する。

{% highlight java %}
...
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
...

public class SearchDialogActivity extends ActionBarActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ActionBar actionBar = getSupportActionBar();
        ...
    }
}
{% endhighlight %}

