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

_Cipher_ 暗号は、メッセージを暗号文に変換する「暗号関数」と、暗号文を元メッセージに復元する「復号関数」のペアで成り立つ。

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
X_{n+1} := A \cdot (X_n + B) \bmod M \\
A = 3, B = 5, M = 13 \\
\begin{align}
X_0 & := 8 \\
X_1 & := 3 \cdot (X_0 + 5) \bmod 13 = 3 \\
X_2 & := 3 \cdot (X_1 + 5) \bmod 13 = 1 \\
X_3 & := 3 \cdot (X_2 + 5) \bmod 13 = 8 \\
X_4 & := 3 \cdot (X_3 + 5) \bmod 13 = 3 \\
X_5 & := 1 \\
\ldots
\end{align}
</script>

glibc の `random()` 関数等は、この LCG のアルゴリズムを用いているため、決して暗号化のために用いてはならない。

