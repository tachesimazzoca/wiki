---
layout: page

title: Threads
---

## Overview

* <http://developer.android.com/guide/components/processes-and-threads.html>

## UI Thread

Android では、アプリケーション毎に一つのプロセスが作成され、UI Thread と呼ばれる単一のメインスレッドのみが、画面操作のやりとりを行なう。これにより Activity は、複数スレッドからアクセスされることはないため、スレッドセーフである必要はない。Android UI Toolkit `android.(view|widget).*` もスレッドセーフではない。

言い換えると、通信などの時間のかかる処理で、UI Thread をブロックすると、一切の画面操作を受け付けずハングしてしまうことになる。規定の秒数（約５秒）を超えると ["Application Not Responding" (ANR)](http://developer.android.com/training/articles/perf-anr.html>) 警告ダイアログが表示される。

これを避けるためには、別スレッドで処理させることが必要になるが、UI Thread 以外のスレッドから UI Toolkit を直接操作すると、ランタイムエラーにより強制終了する。

UI Thread 外から UI Toolkit にアクセスする場合は、以下の API を用いる。

* [Activity.runOnUiThread(Runnable)](http://developer.android.com/reference/android/app/Activity.html#runOnUiThread\(java.lang.Runnable\))
* [View.post(Runnable)](http://developer.android.com/reference/android/view/View.html#post\(java.lang.Runnable\))
* [View.postDelayed(Runnable, long)](http://developer.android.com/reference/android/view/View.html#postDelayed\(java.lang.Runnable, long\))

{% highlight java %}
public class MainActivity extends Activity {
    ...
    private TextView mTextView;
    ...

    private void waitFor(long msec) {
        try {
            Thread.sleep(msec);
        } catch (Exception e) {
            throw new Error(e);
        }
    }

    // OK: Activity.runOnUiThread(Runnable)
    private void accessInsideUiThread() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                waitFor(5000L);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mTextView.setText("Access inside the UI thread.");
                    }
                });
            }
        }).start();
    }

    // OK: View.post(Runnable)
    private void postToMessageQueue() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                waitFor(5000L);
                mTextView.post(new Runnable() {
                    @Override
                    public void run() {
                        mTextView.setText("Access via MessageQueue");
                    }
                });
            }
        }).start();
    }

    // NG: Do not block the UI thread.
    private void blockUiThread() {
        waitFor(5000L);
        mTextView.setText("This is an incorrect solution.");
    }

    // NG: Do not access the Android UI toolkit from outside the UI thread.
    private void accessOutsideUiThread() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                waitFor(5000L);
                // The application will crash with a runtime exception.
                mTextView.setText("This doesn't work.");
            }
        }).start();
    }
}
{% endhighlight %}

## AsyncTask

AsyncTask により、ワーカースレッドの処理を簡潔に記述することができる。

`MeanTask.java`

{% highlight java %}
public class MeanTask extends AsyncTask<Integer, String, Float> {
    private Listener mListener;

    public interface Listener {
        public void onProgress(String message);
        public void onResult(Float result);
    }

    public MeanTask(Listener listener) {
        mListener = listener;
    }

    @Override
    protected Float doInBackground(Integer... params) {
        int len = params.length;
        int sum = 0;
        for (int i = 0; i < len; i++) {
            publishProgress(String.format(
                    "sum = %d + %d (%d/%d)", sum, params[i], i + 1, len));
            sum += params[i];
        }
        return ((float) sum) / len;
    }

    @Override
    protected void onProgressUpdate(String... progress) {
        mListener.onProgress(progress[0]);
    }

    @Override
    protected void onPostExecute(Float result) {
        mListener.onResult(result);
    }
}
{% endhighlight %}

`MeanTaskClient.java`

{% highlight java %}
MeanTask.Listener listener = new MeanTask.Listener() { ... };
new MeanTask(listener).execute(1, 2, 3, 4);
{% endhighlight %}

AsyncTask 内に Activity への参照を持ちたい時は [WeakReferece](http://developer.android.com/reference/java/lang/ref/WeakReference.html) で持つようにする。直接保持すると、アクティビティのライフサイクルで破棄されず、メモリリークを起こす場合がある。

{% highlight java %}
private WeakReference<MainActivity> mActivityRef;

public SomeAsyncTask(MainActivity activity) {
    mActivityRef = new WeakReference<MainActivity>(activity);
}

@Override
protected void onPostExecute(Bitmap result) {
    MainActivity activity = mActivityRef.get();
    if (null != activity) {
        ...
    }
}
{% endhighlight %}

## Handler

* <https://developer.android.com/training/multiple-threads/communicate-ui.html>

