---
layout: page

title: CentOS
---

## CentOS-5.8-x86_64-netinstall.iso

* <http://vault.centos.org/>

`/5.8/isos/x86_64/CentOS-5.8-x86_64-netinstall.iso` から最小構成でインストールする例です。

<dl>
<dt>Choose a language</dt>
<dd>English</dd>
<dt>Keybord Type</dt>
<dd>jp106 または利用しているキーボードを選択</dd>
<dt>Installation Method</dt>
<dd>FTP</dd>
<dt>Configure TCP/IP</dt>
<dd>IPv6 が不要なら <code>Enable IPv6 Support</code> をオフにします。</dd>
<dt>FTP Setup</dt>
<dd><code>vault.centos.org</code></dd>
<dd><code>/5.8/os/x86_64</code></dd>
</dl>

ネット経由でインストーライメージがダウンロードされた後、インストーラが起動します。

最小パッケージとするために、以下のオプションを指定します。

* `Desktop GNOME` のチェックを外す
* `Customize later` を選択

インストールが終わったら、インストールCD(ISOイメージ)を取り出したのち再起動して完了です。

