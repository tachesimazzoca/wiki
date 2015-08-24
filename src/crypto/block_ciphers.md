---
layout: page

title: Block Ciphers
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Overview

ブロック暗号 _Block cipher_ は、メッセージを固定長ブロックに分けて、ブロック毎にキーを切り替えて暗号化を行なう。

## DES

_Data Encryption Standard (DES)_ は、IBM により開発され、1976 年に U.S. の連邦規格として採用されたブロック暗号方式である。

* <http://csrc.nist.gov/publications/fips/fips46-3/fips46-3.pdf>

ブロックサイズは 64bits で以下の手順で暗号化する。

* Initial Permuation (IP) に従い、ビットを入れ替え
  * <https://en.wikipedia.org/wiki/DES_supplementary_material#Initial_permutation_.28IP.29>
* Feistel 構造を通して撹拌
* Final Permuation (IP^-1) に従い、ビットを入れ替え
  * <https://en.wikipedia.org/wiki/DES_supplementary_material#Final_permutation_.28IP.E2.88.921.29>
    * Initial Permuation の逆のマッピング

### Feistel Network

DES では、Lucifer 暗号の発明者の _Horst Feistel_ に由来する _Feistel network_ と呼ばれる構造で、各ブロックを暗号化する。

64bits のブロックを、半分 32bits の L/R 二つに分けて、以下の処理を 16 回繰り返す。

* `L(i)` ブロックを、Feistel 関数を通し `R(i)` との XOR を、次の `R(i+1)` とする。
* `R(i)` ブロックを、次の `L(i+1)` とする。

復号は逆順に行なうだけでよい。

### Feistel Function

Feistel 構造内では、以下の Feistel 関数により撹拌される。

* E: 32bits を 48bits に拡張する
  * <https://en.wikipedia.org/wiki/DES_supplementary_material#Expansion_function_.28E.29>
* S-box: 48bits のラウンド鍵との XOR を、6bits 毎に 8 つに分ける
  * 8 つの S-box を通して、6bits ブロックを 4bits に置き換える
  * <https://en.wikipedia.org/wiki/DES_supplementary_material#Substitution_boxes_.28S-boxes.29>
* P: 4 x 8 = 32bits のビットを入れ替える
  * <https://en.wikipedia.org/wiki/DES_supplementary_material#Permutation_.28P.29>

### Key Schedule

DES のキー長は 64bits で、実際には 56bits が使われる。48bits のラウンド鍵が生成される。

* PC-1: 64bits を 56bits に変換する
  * <https://en.wikipedia.org/wiki/DES_supplementary_material#Permuted_choice_1_.28PC-1.29>
* PC-2: 56bits を 48bits に変換する
  * <https://en.wikipedia.org/wiki/DES_supplementary_material#Permuted_choice_2_.28PC-2.29>
  * 各ラウンドごとにビットシフトを行なう。ラウンド毎にシフトするビット数は異なる。
    * <https://en.wikipedia.org/wiki/DES_supplementary_material#Rotations_in_the_key-schedule>

