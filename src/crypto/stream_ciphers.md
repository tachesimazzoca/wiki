---
layout: page

title: Stream Ciphers
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Pseudo Random Generators

_One Time Pad (OTP)_ では、メッセージよりも大きい暗号キーを持つ必要がある。保有キーから無限長の暗号キーを生成する _Pseudo Random Generator (PRG)_ を用いることで、保有キーのサイズを小さくできる。

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

## Many Time Pad Attack

暗号キーは再利用されてはならない。同じキーの XOR 演算で作成された暗号文が二つあれば、暗号文の XOR により、平文の XOR に変換できる。

<script type="math/tex; mode=display" id="MathJax-Element-attack_on_ttp">
\begin{align}
C_1 & := m_1 \oplus k_0 \\
C_2 & := m_2 \oplus k_0 \\
\end{align} \\
C_1 \oplus C_2 = m_1 \oplus m_2
</script>

二つの平文の XOR から分解するのは困難に思えるが、元メッセージが英文で成り立っている場合、スペースと `[a-zA-z]` の XOR を候補とすることができる。スペースが交錯するサンプルを集めて単語から推測し、XOR で逆算することでキーを抽出できる。

サーバとクライアント間で同じ暗号キーを使った場合も、双方の通信の XOR により、平文のリクエストとレスポンスの XOR を得られる。サーバとクライアントで異なるキーが必要である。

* WindowsNT MS-PPTP は、サーバとクライアント間で同じ PRG キーを使うため安全ではない。

キー生成のヒントになる情報も（何番目のキーであるか？等）通信に含めてはならない。同じヒントである暗号文は、同じ暗号キーを使った暗号文である。

* 802.11b WEP は 24bit のフレーム番号をキー生成に使うため安全ではない。16Mフレーム毎に同じ PRG キーが用いられる。

## RC4

* <https://en.wikipedia.org/wiki/RC4>

256個の 0-255 の順列である 256bytes の状態配列 `S` を元に、キーを生成する。

* _Key-scheduling Algorithm (KSA)_
  * 5-16byte 程度のシードを与えて、初期の状態配列 `S` を生成する。
* _Pseudo Random Generation Algorithm (PRGA)_
   * 1byte 毎に、状態配列 `S` の要素を入れ替えながら、キー生成を行なう。

SSL/TLS や 802.11b WEP で用いられているが、以下の欠点がある。

* キーストリームの 2byte 目が 0 となる確率が 2/256 であり、識別攻撃が可能
* WEP のように、何番目に生成されたキーであるかがわかれば、Two time pad 攻撃で平文を復元可能

## LFSR

_Linear Feedback Shift Register (LFSR)_ は、タップと呼ばれる任意の数ビットの XOR 出力を先頭ビットとし、ビットシフトを繰り返すレジスタを指す。DVD や Bluetooth のハードウェア用の PRG としても用いられている。

レジスタの初期シードが同じであれば、必ず同じ状態になるため、初期シードが小さいと総当たりで復元可能である。

DVD に用いられている _Content Scrambling System (CSS)_ のシードは、40bit(5byte) と非常に小さい。PRG アルゴリズムは以下のようになる。

* LFSR17: `1 || 16bit(seed[0..1])` を初期シードとする 17bit LFSR 出力から 8bit を抽出
* LFSR25: `1 || 24bit(seed[2..4])` を初期シードとする 25bit LFSR 出力から 8bit を抽出
* 二つの LFSR を可算し下位 8bit をキーとする。 `(LFSR17 + LFSR25) mod 256`
* 1byte 毎に繰り返す

元データの先頭バイトが予測できれば、LFSR17 の初期状態を `2^17` 回の総当たりで試し、キーストリームの引き算で対応する LFSR25 を算出して、LFSR ペアの候補を取り出すことができる。候補を試し、二つの LFSR の初期状態がわかれば、以降のバイトは復元可能となる。

