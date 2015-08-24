---
layout: page

title: Ciphers
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Definition

暗号 _Cipher_ は、メッセージを暗号文に変換する「暗号関数」と、暗号文を元メッセージに復元する「復号関数」のペアで成り立つ。

* E (Encrypt): 暗号関数
* D (Decrypt): 復号関数
* K (Key): 暗号キー
* M (Message): メッセージ
* C (Cipher): 暗号文

を定義すると、以下の式がなりたつ。

<script type="math/tex; mode=display" id="MathJax-Element-cipher_definition">
E: K \times M \to C \\
D: K \times C \to M \\
D(k, E(k, m)) = m \quad \text{for all $k \in K, m \in M$} \\
</script>

## Information Theoretic Security

* _Shannon, Claude E. (October 1949). "Communication Theory of Secrecy Systems"_

暗号文から平文の違いを区別できなければ、解読不能な暗号である。

ランダムに生成されるあらゆる暗号キーから、同じ長さの二つの異なるメッセージが、同じ暗号文となる確率が等しければ、どの平文であるかを判別できない。この条件を満たす暗号アルゴリズムは _Perfect secrecy_ を持つと定義される。

<script type="math/tex; mode=display" id="MathJax-Element-cipher_perfect_secrecy">
Pr[E(k, m_0) = c] = Pr[E(k, m_1) = c] \quad \text{for all $m_0, m_1 \in M, |m_0| = |m_1|$} \\
k \gets^{random} K \\
</script>

## The One Time Pad

一回限りの暗号キーを使って暗号化する方法を _One Time Pad (OTP)_ と呼ぶ。

メッセージと暗号キーの XOR 演算で暗号化する方法がある。

    m: 01001000 01000101 01001100 01001100 01001111: HELLO
    k: 00100100 01001011 01000101 01011001 00100001: $KEY!
    c: 01101100 00001110 00001001 00010101 01101110: l...n

以下の式により XOR 演算だけで、暗号の定義を満たすことが証明できる。

<script type="math/tex; mode=display" id="MathJax-Element-cipher_otp">
\begin{align}
c := E(k, m) & = k \oplus m \\
D(k, c) & = k \oplus c \\
D(k, E(k, m)) & = k \oplus (k \oplus m) = (k \oplus k) \oplus m = 0 \oplus m = m \\
\end{align}
</script>

* 高速だが、メッセージよりも大きい暗号キーを持たなければならない欠点がある。
* 同じ暗号文を生成できる暗号キーの数は 1 である。一回限りのキーであれば、同じ暗号文となる確率は `1/K` であり _Perfect secrecy_ を持つ。

## Stream Ciphers

### Pseudo Random Generators

OTP では、メッセージよりも大きい暗号キーを持つ必要がある。保有キーから無限長の暗号キーを生成する _Pseudo Random Generator (PRG)_ を用いることで、保有キーのサイズを小さくできる。

OTP とは異なり、保有キーの利用が１度限りであっても、PRG のアルゴリズムが予測可能であれば _Perfect secrecy_ は持たない。例えば、単に保有キーを繰り返すだけのアルゴリズムであるとする。平文のヘッダ部が決まっており、保有キーがそのサイズ以下であると、暗号キーを特定できることが分かる。

    (The header block of PT is always 1111 1111)
    KEY                 : 0110 1001
    PRG-KEY             : 0110 1001 0110 1001 0110 1001 0110
    Plain Text          : 1111 1111 0110 0101 1101 0111 1011
    Cipher Text         : 1001 0110 0000 1100 1011 1110 1101
    Predictable Header  : 1111 1111 ???? ???? ???? ???? ????
    Predictable KEY     : 0110 1001                          : m = c ^ k = 10010110 ^ 11111111
    Predictable PRG-KEY : 0110 1001|0110 1001|0110 1001|0110 ....
    Revealed PT         : 1111 1111 0110 0101 1101 0111 1011

たとえランダムであっても、乱数生成に周期性があると同様に予測可能である。_Linear Congruential Generator (LCG)_ のアルゴリズムでは周期性がある。

<script type="math/tex; mode=display" id="MathJax-Element-cipher_lcg">
X_{n+1} := (A \cdot X_n + B) \bmod M \\
A = 3, B = 5, M = 13 \\
\begin{align}
X_0 & := 8 \\
X_1 & := (3 \cdot X_0 + 5) \bmod 13 = 3 \\
X_2 & := (3 \cdot X_1 + 5) \bmod 13 = 1 \\
X_3 & := (3 \cdot X_2 + 5) \bmod 13 = 8 \\
X_4 & := (3 \cdot X_3 + 5) \bmod 13 = 3 \\
X_5 & := 1 \\
\ldots
\end{align}
</script>

glibc の `random()` 関数等は、この LCG のアルゴリズムを用いているため、決して暗号化のために用いてはならない。

### Attacks on Stream Ciphers

暗号キーは再利用されてはならない。同じキーの XOR 演算で作成された暗号文が二つあれば、暗号文の XOR により、平文の XOR に変換できる。

<script type="math/tex; mode=display" id="MathJax-Element-attack_on_ttp">
\begin{align}
C_1 & := m_1 \oplus k_0 \\
C_2 & := m_2 \oplus k_0 \\
\end{align} \\
C_1 \oplus C_2 = m_1 \oplus m_2
</script>

サーバとクライアント間で同じ暗号キーを使った場合も、双方の通信の XOR により、平文のリクエストとレスポンスの XOR を得られる。サーバとクライアントで異なるキーが必要である。

* WindowsNT MS-PPTP は、サーバとクライアント間で同じ PRG キーを使うため安全ではない。

キー生成のヒントになる情報も（何番目のキーであるか？等）通信に含めてはならない。同じヒントである暗号文は、同じ暗号キーを使った暗号文である。

* 802.11b WEP は 24bit のフレーム番号をキー生成に使うため安全ではない。16Mフレーム毎に同じ PRG キーが用いられる。

### RC4

* <https://en.wikipedia.org/wiki/RC4>

256個の 0-255 の順列である 256bytes の状態配列 `S` を元に、キーを生成する。

* _Key-scheduling Algorithm (KSA)_
  * 5-16byte 程度のシードを与えて、初期の状態配列 `S` を生成する。
* _Pseudo Random Generation Algorithm (PRGA)_
   * 1byte 毎に、状態配列 `S` の要素を入れ替えながら、キー生成を行なう。

SSL/TLS や 802.11b WEP で用いられているが、以下の欠点がある。

* キーストリームの 2byte 目が 0 となる確率が 2/256 であり、識別攻撃が可能
* WEP のように、何番目に生成されたキーであるかがわかれば、Two time pad 攻撃で平文を復元可能

### LFSR

_Linear Feedback Shift Register (LFSR)_ は、タップと呼ばれる任意の数ビットの XOR 出力を先頭ビットとし、ビットシフトを繰り返すレジスタを指す。DVD や Bluetooth のハードウェア用の PRG としても用いられている。

レジスタの初期シードが同じであれば、必ず同じ状態になるため、初期シードが小さいと総当たりで復元可能である。

DVD に用いられている _Content Scrambling System (CSS)_ のシードは、40bit(5byte) と非常に小さい。PRG アルゴリズムは以下のようになる。

* LFSR17: `1 || 16bit(seed[0..1])` を初期シードとする 17bit LFSR 出力から 8bit を抽出
* LFSR25: `1 || 24bit(seed[2..4])` を初期シードとする 25bit LFSR 出力から 8bit を抽出
* 二つの LFSR を可算し下位 8bit をキーとする。 `(LFSR17 + LFSR25) mod 256`
* 1byte 毎に繰り返す

元データの先頭バイトが予測できれば、LFSR17 の初期状態を `2^17` 回の総当たりで試し、キーストリームの引き算で対応する LFSR25 を算出して、LFSR ペアの候補を取り出すことができる。候補を試し、二つの LFSR の初期状態がわかれば、以降のバイトは復元可能となる。

## Block Ciphers

ブロック暗号 _Block cipher_ は、メッセージを固定長ブロックに分けて、ブロック毎にキーを切り替えて暗号化を行なう。

### DES

_Data Encryption Standard (DES)_ は、IBM により開発され、1976 年に U.S. の連邦規格として採用されたブロック暗号方式である。

* <http://csrc.nist.gov/publications/fips/fips46-3/fips46-3.pdf>

ブロックサイズは 64bits で以下の手順で暗号化する。

* Initial Permuation (IP) に従い、ビットを入れ替え
  * <https://en.wikipedia.org/wiki/DES_supplementary_material#Initial_permutation_.28IP.29>
* Feistel 構造を通して撹拌
* Final Permuation (IP^-1) に従い、ビットを入れ替え
  * <https://en.wikipedia.org/wiki/DES_supplementary_material#Final_permutation_.28IP.E2.88.921.29>
    * Initial Permuation の逆のマッピング

#### Feistel Network

DES では、Lucifer 暗号の発明者の _Horst Feistel_ に由来する _Feistel network_ と呼ばれる構造で、各ブロックを暗号化する。

64bits のブロックを、半分 32bits の L/R 二つに分けて、以下の処理を 16 回繰り返す。

* `L(i)` ブロックを、Feistel 関数を通し `R(i)` との XOR を、次の `R(i+1)` とする。
* `R(i)` ブロックを、次の `L(i+1)` とする。

復号は逆順に行なうだけでよい。

#### Feistel Function

Feistel 構造内では、以下の Feistel 関数により撹拌される。

* E: 32bits を 48bits に拡張する
  * <https://en.wikipedia.org/wiki/DES_supplementary_material#Expansion_function_.28E.29>
* S-box: 48bits のラウンド鍵との XOR を、6bits 毎に 8 つに分ける
  * 8 つの S-box を通して、6bits ブロックを 4bits に置き換える
  * <https://en.wikipedia.org/wiki/DES_supplementary_material#Substitution_boxes_.28S-boxes.29>
* P: 4 x 8 = 32bits のビットを入れ替える
  * <https://en.wikipedia.org/wiki/DES_supplementary_material#Permutation_.28P.29>

#### Key Schedule

DES のキー長は 64bits で、実際には 56bits が使われる。48bits のラウンド鍵が生成される。

* PC-1: 64bits を 56bits に変換する
  * <https://en.wikipedia.org/wiki/DES_supplementary_material#Permuted_choice_1_.28PC-1.29>
* PC-2: 56bits を 48bits に変換する
  * <https://en.wikipedia.org/wiki/DES_supplementary_material#Permuted_choice_2_.28PC-2.29>
  * 各ラウンドごとにビットシフトを行なう。ラウンド毎にシフトするビット数は異なる。
    * <https://en.wikipedia.org/wiki/DES_supplementary_material#Rotations_in_the_key-schedule>

