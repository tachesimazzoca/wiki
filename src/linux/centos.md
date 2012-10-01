---
layout: page

title: CentOS
---

## CentOS-5.x-i386-netinstall.iso

`/5/isos/i386/CentOS-5.x-i386-netinstall.iso` から最小構成でインストールする例です。

以下のミラーサイトを例に説明します。

<http://ftp.riken.jp/Linux/centos/5/isos/i386/>

旧バージョンは <http://vault.centos.org> にあります。

`netinstall.iso` では、ネット経由でのインストールを行います。

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
<dd><code>ftp.riken.jp</code></dd>
<dd><code>/Linux/centos/5/os/i386</code></dd>
</dl>

ネット経由でインストーライメージがダウンロードされた後、インストーラが起動します。

最小パッケージとするために、以下のオプションを指定します。

* `Desktop GNOME` のチェックを外す
* `Customize later` を選択

インストールが終わったら、インストールCD(ISOイメージ)を取り出したのち再起動して完了です。

