---
layout: page

title: VirtualBox マネージャー
---

## ネットワーク

デフォルトでは、1つのネットワークアダプタに NAT が割り当てられているだけです。このため、ゲストOSから外部ネットワークへ接続できますが、ホストOSからゲストOSへつないだり、複数ゲストOS間で通信ができません。

VirtualBox では複数のネットワークアダプタを持てますので、VirtualBox マネージャーから仮想マシンを選択し

    設定 > ネットワーク

で設定します。


### Host Only Network

Host Only Network は、ホストOSがルータとなる仮想LAN内にゲストOSを接続します。ローカルマシン上に開発環境を構築するケースで有効です。以下のように NAT と組み合わせて設定する方法が実用的です。

<table class="table table-bordered table-striped">
<tr>
  <th>アダプタ</th><th>割り当て</th><th>説明</th>
</tr>
<tr>
  <td>アダプタ1(eth0)</td><td>NAT</td><td>ゲストOSから外部ネットワークに接続</td>
</tr>
<tr>
  <td>アダプタ2(eth1)</td><td>Host Only Network</td><td>ホストOS内でLAN構築。同LAN内にゲストOSを接続</td>
</tr>
</table>

ホストOSからゲストOS間、複数ゲストOS間は `eth1` を介してアクセスするようにします。

