---
layout: page

title: Overview
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Definition of Cipher

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

## Perfect Secrecy

* _Shannon, Claude E. (October 1949). "Communication Theory of Secrecy Systems"_

暗号文から平文の違いを区別できなければ、解読不能な暗号である。

ランダムに生成されるあらゆる暗号キーから、同じ長さの二つの異なるメッセージが、同じ暗号文となる確率が等しければ、どの平文であるかを判別できない。この条件を満たす暗号アルゴリズムは _Perfect secrecy_ を持つと定義される。

<script type="math/tex; mode=display" id="MathJax-Element-cipher_perfect_secrecy">
Pr[E(k, m_0) = c] = Pr[E(k, m_1) = c] \quad \text{for all $m_0, m_1 \in M, |m_0| = |m_1|$} \\
k \gets^{random} K \\
</script>

## One Time Pad (OTP)

一回限りの暗号キーを使って暗号化する方法を _One Time Pad (OTP)_ と呼ぶ。

コンピュータ向けには、メッセージと暗号キーの XOR 演算による暗号化が用いられる。

    m: 01001000 01000101 01001100 01001100 01001111: HELLO
    k: 00100100 01001011 01000101 01011001 00100001: $KEY!
    c: 01101100 00001110 00001001 00010101 01101110: l...n

以下の式により XOR 演算により暗号の定義を満たすことが証明できる。

<script type="math/tex; mode=display" id="MathJax-Element-cipher_otp">
\begin{align}
c := E(k, m) & = k \oplus m \\
D(k, c) & = k \oplus c \\
D(k, E(k, m)) & = k \oplus (k \oplus m) = (k \oplus k) \oplus m = 0 \oplus m = m \\
\end{align}
</script>

* メッセージよりも大きい暗号キーを持たなければならない欠点がある。
* 同じ暗号文を生成できる暗号キーの数は 1 である。一回限りのキーであれば、同じ暗号文となる確率は `1/K` であり _Perfect secrecy_ を持つ。

