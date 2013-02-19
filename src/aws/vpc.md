---
layout: page

title: VPC
---

## Public Subnet の作成

CIDR Block `10.0.0.0/16` の VPC に `10.0.0.0/24` のアドレス範囲を持つ Public Subnet を作成する例です。

### Your VPCs

* `VPC > Your VPCs` を選択します。
* `Create VPC` ボタンを押下します。
* CIDR Block `10.0.0.0/16` を指定し VPC を作成します。

### Internet Gateways

* `VPC > Internet Gateways` を選択します。
* `Create Internet Gateway` ボタンを押下します。
* 作成された Internet Gateway を選択します。
* `Attache to VPC` ボタンを押下します。
* 対象の VPC を選択し Internet Gateway と紐付けます。

### Subnets

* `VPC > Subnets` を選択します。
* `Create Subnet` ボタンを押下します。
* Public Subnet 用に CIDR Block `10.0.0.0/24` で作成します。

### Route Tables

* `VPC > Route Tables` を選択します。
* 作成した Public Subnet の Route Table を選択します。
* `Routes` タブを選択します。
* Destination `0.0.0.0/0` Target に Internet Gateway (igw-*) を入力し、Add ボタンで追加します。

