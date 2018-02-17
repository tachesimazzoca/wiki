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

AsyncTask により、別スレッドの処理を簡潔に記述することができる。

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

Android では、スレッド毎に [MessageQueue](http://developer.android.com/reference/android/os/MessageQueue.html) を持ち、[Looper](http://developer.android.com/reference/android/os/Looper.html) が順番に送信されたメッセージをキューから取り出し、処理を行なっている。

[Handler](http://developer.android.com/reference/android/os/Handler.html) により、このキューにメッセージを送信することができる。

{% highlight java %}
handler = new Handler() {
    @Override
    public void handleMessage(Message msg) {
        switch (msg.what) {
        case MESSAGE_PROGRESS:
            mProgressBar.setProgress((Integer) msg.obj);
            break;
        default:
            break;
        }
    }
}

new Thread(new Runnable() {
    @Override
    public void run() {
        handler.post(new Runnable() {
            @Override
            public void run () {
                mProgressBar.setVisibility(View.VISIBLE);
            }
        });

        for (int n = 1; n <= 100; n++) {
            Message msg = handler.obtainMessage(MESSAGE_PROGRESS, n);
            handler.sendMessage(msg);
        }
    }
}).start();
{% endhighlight %}

以下の２つのオブジェクトを送信することができる。

* [Runnable](http://developer.android.com/reference/java/lang/Runnable.html)
  * `Handler#post` により MessageQueue に、Runnable オブジェクトがプールされる。
  * Looper は `Runnable#run` を実行する。
* [Message](http://developer.android.com/reference/android/os/Message.html)
  * `Handler#obtainMessage` で、Handler に関連づけられた Message オブジェクトを作成する。
  * `Handler#sendMessage` により MessageQueue に、Message オブジェクトがプールされる。
  * Looper は、Message に紐づけられている Handler を介して `Handler#handleMessage` を実行する。

複数スレッドからのメッセージを、単一スレッド上の MessageQueue に集めて Looper で処理を行なうので、同一 Looper を使う限り、スレッドセーフである必要がなく、不要な同期処理を避けることができる。

Handler は、必ず一つの Looper を持つ。コンストラクタで指定しない場合は、同一スレッドに存在する Looper が使われる。Looper が存在しない場合や、同一スレッドで複数 Looper を扱うとエラーになる。

UI Thread 内では、すでに Looper は割り当てられており、UI Thread 内で Looper を指定せずに Handler を作成した場合、UI Thread 上の Looper で実行されることになる。`Runnable#run` や `Handler#handleMessage` の中で UI Thread をブロックするような長時間の処理は行なってはならない。また、MessageQueue を圧迫しないように、メッセージ送信数も最小限にすべきである。

UI Thread の Looper は `Looper.getMainLooper` で得られる。以下は `Acitivity#runOnUiThread` と同じことである。

{% highlight java %}
final Handler hander = new Handler(Looper.getMainLooper());
handler.post(new Runnable() { ... });
{% endhighlight %}

別スレッドの Handler を作成する場合は、以下のようになる。

{% highlight java %}
public class LooperThread extends Thread {
    public Hander handler;
    ...
    @Override
    public void run() {
        Looper.prepare();
        handler = new Handler() {
            ...
        }
        Looper.loop();
    }
}

final LooperThread looperThread = new LooperThread(...);
looperThread.start();

looperThread.handler.post(new Runnable() { ... });
{% endhighlight %}

