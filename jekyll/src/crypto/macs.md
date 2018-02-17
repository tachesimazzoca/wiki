---
layout: page

title: Message Authentication Code
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Overview

メッセージ通信において、悪意を持った攻撃者は、通信内容を傍受することに加えて、通信内容を改ざんすることが可能である。傍受された通信内容を解読されないように暗号化するのと同じく、受け取った内容が第三者により改ざんされていないことを検出する仕組みが必要になる。

_Message Authentication Code (MAC)_ は、メッセージの改ざんがないことを検出するアルゴリズムを指す。

<script type="math/tex; mode=display" id="MathJax-Element-mac_algorithm">
t \gets S(k, m) \\
(0, 1) \gets V(k, m, t) \\
</script>

* Signing: キーとメッセージからタグを作成するアルゴリズム `S(k, m)`
* Verification: キーとメッセージとタグから、改ざんされていないことを検査するアルゴリズム `V(k, m ,t)`

攻撃者は、通信内容からメッセージとタグ `(m, t)` を得ること _Chosen message attack_ ができ、これらとは別の組み合わせを見つけること _Existential forgery_ を目指す。

* 得られたメッセージとタグ `(m, t)` とは別の正規タグ `(m, t')` を見つける
* 得られたメッセージとタグ `(m, t)` と同じタグを生成できる別のメッセージ `(m', t)` を見つける

同じタグとなる別のメッセージを見つけることができたとしても、意味のあるメッセージを選択できるわけではないが、改ざん検出という観点では破綻している。

## CBC-MAC (Cipher Block Chaining MAC)

_Encrypted Cipher Block Chaining (ECBC)_

## NMAC (Nested MAC)

## CMAC (Cihper-based MAC)

## PMAC (Parallel MAC)

### Carter-Wegman MAC

## HMAC (Hash-based MAC)

## Timing Attacks on Verification

