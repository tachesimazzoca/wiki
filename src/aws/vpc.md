---
layout: page

title: VPC
---

## VPC

VPC (Virtual Private Cloud) によりプライベートネットワークを作成できる。

* _VPC > Your VPCs_ を選択
* _Create VPC_ ボタンを押下
* 任意の CIDR Block を指定。範囲は `xxx.xxx.0.0/16` に制限されている。
  * クラスC `192.168.0.0/16` と同じ範囲だが、`10.0.0.0/16` のようにも指定できる。

CIDR Block は、以下のように割り当てて「最大 256 個の Subnet と、Subnet 内で 256 個のIPアドレスを持てる」と考えると管理しやすい。

* VPC: `10.0.0.0/16`
* Subnets: `10.0.(0..255).0/24`

すなわち `256 * 256 = 65536` 個のプライベートIPアドレスを持てることになる。ただし、あくまで仕様上の個数であり、AWS 内で使える数には限りがある。

* `http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Appendix_Limits.html`

VPC 作成後はサイズ変更ができないため、最大の `10.0.0.0/16` を割り当てておくとよい。

### Internet Gateways

VPC はそのままではインターネットとの通信経路が存在しない。Internet Gateway を VPC に紐付ける必要がある。

* _VPC > Internet Gateways_ を選択
* _Create Internet Gateway_ ボタンを押下
* 作成された Internet Gateway を選択
* _Attach to VPC_ ボタンを押下
* 対象の VPC を選択し Internet Gateway と紐付ける

通信経路が確保されただけであり、Elastic IP でグローバル IP アドレスを割り当てるまでは、インターネットからはアクセスはできない。

## Subnets

VPC 内に、EC2 インスタンスと紐付ける Subnet と呼ばれるプライベートアドレス空間を作成する。

* Public Subnet
  * Internet Gateway とのルートを持つサブネット = インターネットにアクセス可
* Private Subnet
  * Internet Gateway とのルートを持たないサブネット = インターネットにアクセス不可

Subnet は以下の手順で作成する。

* _VPC > Subnets_ を選択
* _Create Subnet_ ボタンを押下
* 任意の CIDR Block を指定。範囲は `xxx.xxx.xxx.0/24` に制限されている。

VPC の CIDR Block が `10.0.0.0/16` である場合を例にすると、以下のように Subnet の CIDR Block を割り当てる。

* Subnet1: `10.0.0.0/24`
* Subnet2: `10.0.1.0/24`
* Subnet3: `10.0.2.0/24`
* ...

### Route Tables

Subnet はそのままではインターネットとの通信経路が存在しない。Subnet 毎の Route Table で経路を指定する。

* _VPC > Route Tables_ を選択
* 作成した Subnet の Route Table を選択 `rtb-*`
* _Routes_ タブを選択
* _Edit_ を押下して、Route Table を編集

1 行目の以下のエントリにより、VPC 内のインスタンスが相互接続できるようになる。もちろん変更や削除はできない。

* Destination: VPC の CIDR Block
* Target: `local`

Public Subnet とする場合は、Internet Gateway への経路を追加する。

* Destination: `0.0.0.0/0`
* Target: Internet Gateway `igw-*` を指定

Private Subnet の場合は、サブネット内からインターネットに接続できるように、後述の NAT インスタンスの ID を指定する。

* Destination: `0.0.0.0/0`
* Target: NAT インスタンスのID `i-*` を指定

