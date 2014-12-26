---
layout: page

title: Preferences
---

## Overview

* <http://developer.android.com/guide/topics/ui/settings.html>

## PreferenceActivity

[PreferenceActivity](http://developer.android.com/reference/android/preference/PreferenceActivity.html) を用いることで、設定画面 XML 定義のみで、[SharedPrefecences](http://developer.android.com/reference/android/content/SharedPreferences.html) への読み書きを行なうことができる。

`res/xml/prefs_settings.xml`:

{% highlight xml %}
<?xml version="1.0" encoding="utf-8"?>
<PreferenceScreen xmlns:android="http://schemas.android.com/apk/res/android">
    <PreferenceCategory
        android:key="pref_general"
        android:persistent="false"
        android:title="General">
        <CheckBoxPreference
            android:key="pref_enabled"
            android:title="Enabled" />
        <EditTextPreference
            android:key="pref_username"
            android:title="Username" />
    </PreferenceCategory>
</PreferenceScreen>
{% endhighlight %}

* `android:key` の値をキーとして SharedPreferences に読み書きされる。
* 保存しないキーには `android:persistent="false"` を指定する。

`PreferenceActivity#onCreate` 内で、`PreferenceActivity#addPreferencesFromResource` を用いて、XML リソースを読み込むだけでよい。

{% highlight java %}
public class SettingsActivity extends PreferenceActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        addPreferencesFromResource(R.xml.prefs_settings);
    }
}
{% endhighlight %}

全ての Android バージョンに対応しているが、サポートライブラリ v4-appcompat 用の PreferenceActivity は提供されていない。PreferenceActivity は、内部的にビュー全体を組み立てるため、v7-appcompat のテーマ `Theme.Appcompat` 等で利用した場合には、アクションバーが表示されない。

## PreferenceFragment

Android 3.0 以降であれば [PreferenceFragment](http://developer.android.com/reference/android/preference/PreferenceFragment.html) を用いて Preference UI を利用することができる。

{% highlight java %}
public class SettingsFragment extends PreferenceFragment {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        addPreferencesFromResource(R.xml.prefs_settings);
    }
}
{% endhighlight %}

v4-appcompat の [FragmentActivity](http://developer.android.com/reference/android/support/v4/app/FragmentActivity.html) では、`android.support.v4.app.(Fragment|FragmentManager)` を使う必要があるが、サポートライブラリ v4-appcompat 用の PreferenceFragment は提供されていない。

Material Design のために、v7-appcompat の ActionBarActivity を使っている等の理由で、Android 3.0 以降のみのサポートであれば、あえて FragmentManager を使うこともできるが、`FragmentManager#addToBackStack` が正しく動作しない。

{% highlight java %}
// The back stack doesn't work in v4 FragmentActivity.
getFragmentManager().beginTransaction()
        .replace(android.R.id.content, new SettingsFragment())
        .addToBackStack(null)
        .commit();
{% endhighlight %}

`Activity#onBackPressed` で強制的に `FragmentManager#popBackStack` を呼ぶ方法があるが、PreferenceFragment を使う場合は、Appcompat は使わないほうがよいだろう。

{% highlight java %}
@Override
public void onBackPressed() {
    FragmentManager manager = getFragmentManager();
    if (manager.getBackStackEntryCount() > 0) {
        manager.popBackStack();
        return;
    }
    super.onBackPressed();
}
{% endhighlight %}

## Nested Preference Screen

Preference UI を複数階層に置きたい場合は、PreferenceScreen 要素を入れ子にすればよい。PreferenceScreen のタイトルがリンクになり、子の PreferenceScreen ごとに UI が作成される。

{% highlight xml %}
<?xml version="1.0" encoding="utf-8"?>
<PreferenceScreen xmlns:android="http://schemas.android.com/apk/res/android">
    <EditTextPreference
        android:key="pref_parent"
        android:title="Parent" />
    <PreferenceScreen
        android:persistent="false"
        android:title="Children" />
      <EditTextPreference
          android:key="pref_child"
          android:title="Child" />
    </PreferenceScreen>
</PreferenceScreen>
{% endhighlight %}

Intent を用いて、任意のアクティビティを起動することもできるので、extra 値に設定カテゴリのキーを指定して、リソースを切り替える方法もある。カテゴリ階層ごとに Activity を作ってもよい。

`res/xml/pref_settings.xml`:

{% highlight xml %}
<?xml version="1.0" encoding="utf-8"?>
<PreferenceScreen xmlns:android="http://schemas.android.com/apk/res/android">
    <EditTextPreference
        android:key="pref_parent"
        android:title="Parent" />
    <Preference
        android:persistent="false"
        android:title="Children">
        <intent
            android:targetClass="net.example.android.SettingsActivity"
            android:targetPackage="net.example.android">
            <!-- A key of the nested preference -->
            <extra android:name="category" android:value="children" />
        </intent>
    </Preference>
</PreferenceScreen>
{% endhighlight %}

`res/xml/pref_settings_children.xml`:

{% highlight xml %}
<?xml version="1.0" encoding="utf-8"?>
<PreferenceScreen xmlns:android="http://schemas.android.com/apk/res/android">
    <EditTextPreference
        android:key="pref_child"
        android:title="Child" />
</PreferenceScreen>
{% endhighlight %}

{% highlight java %}
public class SettingsActivity extends PreferenceActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        String category = getIntent().getStringExtra("category");
        if ("children".equlas(category)) {
            addPreferencesFromResource(R.xml.prefs_settings_children);
        } else {
            addPreferencesFromResource(R.xml.prefs_settings);
        }
    }
}
{% endhighlight %}

## Preference Headers

画面幅がある場合、設定カテゴリの一覧と設定コンテンツの二つのペインに切り替えたい場合がある。

PreferenceFragment を用いて、ヘッダ部とコンテンツ部に分ければよいが、シンプルなタイトルのみのヘッダであれば、PreferenceActivity だけで実現できる。

* <http://developer.android.com/guide/topics/ui/settings.html#PreferenceHeaders>

ヘッダ部の XML リソースを定義して、各カテゴリごとに、どの PreferenceFragment を使うか設定すればよい。

`res/xml/prefs_headers.xml`:

{% highlight xml %}
<preference-headers xmlns:android="http://schemas.android.com/apk/res/android">
    <header
        android:fragment="net.example.android.GeneralPreferenceFragment"
        android:title="General" />
    <header
        android:fragment="net.example.android.AdvancedPreferenceFragment"
        android:title="Advanced" />
</preference-headers>
{% endhighlight %}

`PreferenceActivity#onBuildHeaders` 内で、`PreferenceActivity#loadHeadersFromResource` を用いて、この XML を読み込むだけでよい。Android 4.4 以降の場合は、`PreferenceActivity#isValidFragment` も実装する必要がある。

{% highlight java %}
public class SettingsActivity extends PreferenceActivity {
    ...
    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    @Override
    public void onBuildHeaders(List<Header> target) {
        loadHeadersFromResource(R.xml.prefs_headers, target);
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    @Override
    protected boolean isValidFragment(String fragmentName) {
        // Subclasses should override this method and verify
        // that the given fragment is valid. If the SDK version
        // is older than KITKAT, the default implementation
        // always returns true.
        return true;
    }
}
{% endhighlight %}

Android 3.0 以前の場合は、このヘッダは使えない。別途ヘッダのみの PreferenceScreen を作成し、Intent により UI を切り替える。

`res/xml/prefs_headers_legacy.xml`:

{% highlight xml %}
<PreferenceScreen xmlns:android="http://schemas.android.com/apk/res/android">
    <Preference android:title="General">
        <intent
            android:targetClass="net.example.android.SettingsActivity"
            android:targetPackage="net.example.android">
            <extra android:name="category" android:value="general" />
        </intent>
    </Preference>
    <Preference android:title="Advanced">
        <intent
            android:targetClass="net.example.android.SettingsActivity"
            android:targetPackage="net.example.android">
            <extra android:name="category" android:value="advanced" />
        </intent>
    </Preference>
</PreferenceScreen>
{% endhighlight %}

{% highlight java %}
public class SettingsActivity extends PreferenceActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.HONEYCOMB) {
            String category = getIntent().getStringExtra("category");
            int prefId = R.xml.prefs_headers_legacy;
            if (null != category) {
                if ("general".equals(category)) {
                    prefId = R.xml.prefs_settings_general;
                } else if ("advanced".equals(category)) {
                    prefId = R.xml.prefs_settings_advanced;
                }
            }
            addPreferencesFromResource(prefId);
        }
    }
}
{% endhighlight %}

