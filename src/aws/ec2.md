---
layout: page

title: EC2
---

## EBS ボリュームのサイズアップ

### EC2 Management Console

対象の EC2 インスタンスを Stop します。**Terminate すると EBS Volume が失われますので注意してください。**

以下の手順で EBS Volume を拡張します。

* `EC2 > ELASTIC BLOCK STORE > Volumes` より対象の EBS Volume を選択します。
* 下部のメッセージペインの Attachement: よりデバイス名を確認しておきます。例として `/dev/sda1` とします。
* `Actions > Detach Volume` で対象の EBS Volume を EC2 インスタンスから切り離します。
* `Actions > Create Sanpshot` で対象の EBS Volume のスナップショットを作成します。
* `EC2 > ELASTIC BLOCK STORE > Snapshots` より作成したスナップショットを選択します。
* `Actions > Create Volume` で希望のサイズを指定して EBS Volume を作成します。
* `EC2 > ELASTIC BLOCK STORE > Volumes` より作成された EBS Volume を選択します。
* `Actions > Attach Volume` で作成した EBS Volume を対象の EC2 インスタンスに接続します。デバイス名には事前に確認しておいた `/dev/sda1` を指定します。

対象の EC2 インスタンスを Start します。起動後、`resize2fs` コマンドで論理ボリュームをサイズアップします。

    % resize2fs /dev/sda1
