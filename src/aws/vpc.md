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

### NAT Instance

* `http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_NAT_Instance.html`

Internet Gateway との経路を持たないサブネットは、インターネットに接続できない。パッケージのダウンロードなどでサブネット内からインターネットへのアクセスは必要になる。

この場合は、Public サブネット内に、Private サブネットからの通信を外部ネットワークに中継する NAT インスタンスを立てる。

Public AMI で `ami-vpc-nat` の名前で提供されているが、単に `rc.local` の起動スクリプトで IP マスカレードを設定しているのみなので、任意のインスタンスを NAT インスタンスとしたい場合は、同様のスクリプトを置けばよい。

* <https://gist.github.com/tachesimazzoca/6392900b3941d6de4665>

`eth0` の MAC アドレスを取得する。

    ETH0_MAC=`/sbin/ifconfig  | /bin/grep eth0 | awk '{print tolower($5)}' | grep '^[0-9a-f]\{2\}\(:[0-9a-f]\{2\}\)\{5\}$'`

MAC アドレスから Amazon 提供の Instance Metadata を使って、CIDR Block を得る。

    VPC_CIDR_URI="http://169.254.169.254/latest/meta-data/network/interfaces/macs/${ETH0_MAC}/vpc-ipv4-cidr-block"
    ...
    VPC_CIDR_RANGE=`curl --retry 3 --retry-delay 0 --silent --fail ${VPC_CIDR_URI}`

* Instance Metadata: `http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2-instance-metadata.html`

取得した CIDR を送信元にして、IP マスカレードを設定する。

    echo 1 >  /proc/sys/net/ipv4/ip_forward && \
       echo 0 >  /proc/sys/net/ipv4/conf/eth0/send_redirects && \
       /sbin/iptables -t nat -A POSTROUTING -o eth0 -s ${VPC_CIDR_RANGE} -j MASQUERADE

## Security Groups

SecurityGroup は、EC2-Classic と VPC では異なる。

* EC2-Classic
  * EC2 インスタンスに対して Security Group を割り当てる。
  * 異なる EC2 イスタンス間で、同一の Security Group を共有できる。
  * 起動時に EC2 インスタンスに割り当てた Security Group は変更できない。
* VPC
  * VPC 内で Security Group を定義する。
  * 異なる VPC 間で、Security Group を共有できない。
  * VPC 内に定義された Security Group から EC2 インスタンスに割り当てる。
  * EC2 インスタンス起動後も、割り当てる Security Group を変更できる。

このため VPC では、サーバの役割に応じて、SSH / Web などのポート別で Security Group を作っておくとよい。

