---
layout: page

title: EC2
---

## Root Device Volume

### EBS vs. Instance Store

#### EBS-backed

* EBS ボリュームをルートデバイスとして起動する。
* インスタンスの _Stop_ ができる。この場合は EBS ボリュームは破棄されない。
* _Terminate_ では、デフォルトの `DeleteOnTermination: True` なら EBS ボリュームが破棄される。
* `DeleteOnTermination` は EC2 Management Console からは、インスタンス作成時にしか指定できない。AWS CLI を使えば、起動中でも変更できる。
* 永続データは持てるが、Instance store と比較して、I/O 性能に劣る。
* EBS はネットワークを介するため、スループットはそのトラフィックに依存する。性能がでない場合は、_EBS-optimized_ で帯域を確保する必要がある。
* 永続データを持てるためデータベースサーバに適している。

#### Instance Store-backed 

* S3 上の AMI から EC2 インスタンス上のルートデバイスにコピーして起動する。
* インスタンスの _Stop_ はできない。
* _Terminate_ 時に EC2 上のディスクの全ての内容が破棄される。
* 永続データは持てないが、EBS よりは I/O 性能が優れている。
* 永続データを持たない中継サーバやアプリケーションサーバに適している。

### Resizing EBS Volumes

EC2 にマウントした EBS ボリュームの容量を拡張する場合、一旦インスタンスを _Stop_ する必要がある。

* 対象の EC2 インスタンスを _Stop_
* _EC2 > ELASTIC BLOCK STORE > Volumes_ より対象の EBS Volume を選択
* 下部のメッセージペインの _Attachement:_ よりデバイス名を確認しておく。例）`/dev/sda1`
* _Actions > Detach Volume_ で対象の EBS Volume を EC2 インスタンスから切り離す
* _Actions > Create Sanpshot_ で対象の EBS Volume のスナップショットを作成
* _EC2 > ELASTIC BLOCK STORE > Snapshots_ より作成したスナップショットを選択
* _Actions > Create Volume_ で希望のサイズを指定して EBS Volume を作成
* _EC2 > ELASTIC BLOCK STORE > Volumes_ より作成された EBS Volume を選択
* _Actions > Attach Volume_ で作成した EBS Volume を対象の EC2 インスタンスに接続する。デバイス名には事前に確認しておいた `/dev/sda1` を指定
* 対象の EC2 インスタンスを _Start_

起動後に `resize2fs` コマンドで論理ボリュームを拡張する。デバイス名は Management Console 上の表示が `/dev/sda1` の場合、`/dev/xfda1` のシンボリックリンクの場合がある。

    % df
    Filesystem     1K-blocks     Used Available Use% Mounted on
    /dev/xvda1     ...
    ...
    
    % ls -l /dev/sda1
    lrwxrwxrwx 1 ...  /dev/sda1 -> xvda1
    
    % resize2fs /dev/xfda1


