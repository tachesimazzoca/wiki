# Block Ciphers

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Overview

ブロック暗号 _Block cipher_ は、メッセージを固定長ブロックに分けて、ブロック毎にキーを切り替えて暗号化を行なう。

## Pseudo Random Function (PRF)

_Pseudo Random Function (PRF)_ は、以下の二つの関数集合から成り立つ。

1. 入力 `X` から出力 `Y` に変換する関数 (Deterministic function) の集合 `Funs[X,Y]`
2. `Funs[X,Y]` の関数集合のうち、キー `K` により導かれる関数集合 `S = { F(k,.), k in K }`

キーによりどの関数が決まり、その関数は決定的であるので、復号が可能になる。言い換えると、入力 `x` から、どの関数が使われたかを区別できなければ、セキュアな PRF である。

## Pseudo Random Permutation (PRP)

## DES

_Data Encryption Standard (DES)_ は、IBM により開発され、1976 年に U.S. の連邦規格として採用された共通鍵暗号方式である。

* <http://csrc.nist.gov/publications/fips/fips46-3/fips46-3.pdf>

ブロックサイズは 64bits で以下の手順で暗号化する。

* Initial Permuation (IP) に従い、ビットを入れ替え
    * <https://en.wikipedia.org/wiki/DES_supplementary_material#Initial_permutation_.28IP.29>
* Feistel 構造を通して撹拌
* Final Permuation (IP^-1) に従い、ビットを入れ替え
    * <https://en.wikipedia.org/wiki/DES_supplementary_material#Final_permutation_.28IP.E2.88.921.29>
        * Initial Permuation の逆のマッピング

### Key Schedule

DES のキー長は 64bits で、実際には 56bits が使われる。48bits のラウンド鍵が生成される。

* PC-1: 64bits を 56bits に変換する
    * <https://en.wikipedia.org/wiki/DES_supplementary_material#Permuted_choice_1_.28PC-1.29>
* PC-2: 56bits を 48bits に変換する
    * <https://en.wikipedia.org/wiki/DES_supplementary_material#Permuted_choice_2_.28PC-2.29>
    * 各ラウンドごとにビットシフトを行なう。ラウンド毎にシフトするビット数は異なる。
        * <https://en.wikipedia.org/wiki/DES_supplementary_material#Rotations_in_the_key-schedule>

### Feistel Network

DES では、Lucifer 暗号の発明者の _Horst Feistel_ に由来する _Feistel network_ と呼ばれる構造で、各ブロックを暗号化する。

64bits のブロックを、半分 32bits の L/R 二つに分けて、以下の処理を 16 回繰り返す。

* `L(i)` ブロックを、Feistel 関数を通し `R(i)` との XOR を、次の `R(i+1)` とする。
* `R(i)` ブロックを、次の `L(i+1)` とする。

復号は逆順に行なうだけでよい。

### Feistel Function

Feistel network では、Feistel 関数により各ブロックが撹拌される。

* E: 32bits を 48bits に拡張する
    * <https://en.wikipedia.org/wiki/DES_supplementary_material#Expansion_function_.28E.29>
* S-box: 48bits のラウンド鍵との XOR を、6bits 毎に 8 つに分ける
    * 8 つの S-box を通して、6bits ブロックを 4bits に置き換える
    * <https://en.wikipedia.org/wiki/DES_supplementary_material#Substitution_boxes_.28S-boxes.29>
* P: 4 x 8 = 32bits のビットを入れ替える
    * <https://en.wikipedia.org/wiki/DES_supplementary_material#Permutation_.28P.29>

## AES

_Advanced Encryption Standard (AES)_ は、DES の後継として、新たに U.S. の暗号規格として採用された共通鍵暗号方式である。

ブロックサイズは 128bits で、Feistel 構造ではなく、Substitution-permutation Network (SPN) 構造を用いる。入力を 4x4 = 16 bytes の行列として扱い、ビットの撹拌と 128bits のラウンド鍵との XOR を繰り返して暗号化する。

### Key Schedule

* <https://en.wikipedia.org/wiki/Rijndael_key_schedule>

AES のキーサイズは、128/192/256 bits を選択できる。サイズに応じて SPN 構造での撹拌サイクル数が異なる。

* AES-128: 128bits keys / 10 cycles
* AES-192: 192bits keys / 12 cycles
* AES-256: 256bits keys / 14 cycles

撹拌サイクル数 + 1 回の 128bits(16bytes) のラウンド鍵が生成される。AES-128 の場合、合計で 16 x 11 = 176 bytes の鍵が生成される。

### Substitution Permutation Network

* Initial round
    * ラウンド鍵 `k(0)` と XOR
* Rounds
    * SubBytes: Rijndael S-box に従い 4x4 の全バイトを入れ替える
        * <https://en.wikipedia.org/wiki/Rijndael_S-box>
    * ShiftRows: 各行を行番号分左へシフト
        * <https://en.wikipedia.org/wiki/Advanced_Encryption_Standard#The_ShiftRows_step>
    * MixColumns: Rijndael mix columns に従い、各列を変換する
        * <https://en.wikipedia.org/wiki/Rijndael_mix_columns>
        * <https://en.wikipedia.org/wiki/Advanced_Encryption_Standard#The_MixColumns_step>
    * ラウンド鍵 `k(i)` と XOR
* Final round
    * SubBytes
    * ShiftRows
    * ラウンド鍵 `k(n)` と XOR
