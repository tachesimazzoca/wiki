# Probability

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Discrete Probability

ビット数 `n` の有限集合 `U` を以下のように表記する。 `n = 8` の 8bit なら `00000000..11111111` すなわち 256 通りの要素を持つ。

<script type="math/tex; mode=display" id="MathJax-Element-finite_set_u">
\begin{align}
U &= \{0,1\}^n \\
U &= \{0,1\}^8 = \{00000000, 000000001, 00000010, .., 11111111\}
\end{align}
</script>

有限集合 `U` における確率関数を `P` とした時、各要素の確率 `P(x)` の総和を `1` となるように定義する。

<script type="math/tex; mode=display" id="MathJax-Element-function_p">
P: U \to {[0, 1]} \\
\sum_{x \in U} P(x) = 1 \\
U = \{0,1\}^2 = \{00,01,10,11\} \\
P(00) + P(01) + P(10) + P(11) = 1
</script>

### Uniform Distribution

すべての要素が同じ確率である場合 _Uniform distribution_ （一様分布）と呼ぶ。すべての `P(x)` は同じ値で `1/|U|` となる。`|U|` は `U` の要素数を表す。

<script type="math/tex; mode=display" id="MathJax-Element-uniform_distribution">
P(x) = 1/|U| \quad \text{for all $x \in U$} \\
U = \{0,1\}^2 = \{00,01,10,11\} \\
P(00) = P(01) = P(10) = P(11) = 1/|U| = 1/4  \\
</script>

### Point Distribution

一つの要素だけが真となる場合、 _Point distribution_ （点分布）と呼ぶ。当然ながら一つの要素のみ `1` で、それ以外は `0` になる。

<script type="math/tex; mode=display" id="MathJax-Element-point_distribution">
\begin{align}
P(x_0) & = 1 \\
P(x) & = 0 \quad \text{for all $x \neq  x_0$}
\end{align}
</script>

## Events

有限集合のうち、特定条件を満たす補集合を _Event_ （事象）と呼ぶ。その補集合を `A` とした時、その確率を `Pr[A]` と表す。補集合がすべてを含めば `Pr[U] = 1` である。

<script type="math/tex; mode=display" id="MathJax-Element-events">
A \subseteq U \\
Pr[A] = \sum_{x \in A} P(x) \in [0, 1] \\
Pr[U] = 1
</script>

8bit の集合 `U` で、下位 2bit が `11` となる補集合を `A` とした時 _Uniform distribution_ であれば、256 通りのうち、条件を満たすパターン `??????11` は 64 通りなので `64/256 = 1/4` すなわち `Pr[A] = 1/4` となる。

二つの事象の確率 `Pr[A]` と `Pr[B]` の積は、AND 集合の確率 `Pr[A ∩ B]` に等しい。

<script type="math/tex; mode=display" id="MathJax-Element-events_and">
A, B \subseteq U \\
Pr[A \cap B] = Pr[A] \times Pr[B] \\
</script>

二つの事象の確率 `Pr[A]` と `Pr[B]` の和は、OR 集合の確率 `Pr[A ∪ B]` 以上となる。条件の重複がなければ等しい。

<script type="math/tex; mode=display" id="MathJax-Element-events_or">
A, B \subseteq U \\
\begin{align}
Pr[A \cup B] &\leq Pr[A] + Pr[B] \\
Pr[A \cup B] &= Pr[A] + Pr[B] \quad \text{if $A \cap B = \emptyset$}
\end{align}
</script>

## Random Variables

関数 `X` の期待値を `v` とした時、その確率を `Pr[X=v]` と表す。下位 1bit を返す関数を `X` としたとき、`Pr[X=v]` は _Uniform distribution_ となる。

<script type="math/tex; mode=display" id="MathJax-Element-random_variables">
X(y) = LSB(y) \in \{0,1\} \\
X: \{0,1\}^n \to \{0,1\} \\
\begin{align}
Pr[X=0] &= 1/2 \\
Pr[X=1] &= 1/2 \\
\end{align}
</script>

### Uniform Random Variables

有限集合 `U` からランダムに取り出す値を `r` とした時、各要素 `a` となる確率 `Pr[r=a]` がすべて `1/|U|` となるものを _Uniform random variable_ と呼ぶ。`r` は引数をそのまま返す _Identity function_ 恒等関数である。

<script type="math/tex; mode=display" id="MathJax-Element-uniform_random_variables">
r \gets^{R} U \\
Pr[r=a] = 1/|U| \quad \text{for all $a \in U$} \\
r(x) = x \quad \text{for all $x \in U$} \\
</script>

## Birthday Pradox

誕生日が同じ人がいる確率が 50% となるには何人いればよいか？という問題がある。正解は 23 人で直感とは異なることから _Birthday paradox_ と呼ばれる。

`n` 人の中で同じ誕生日の人がいない確率で考える。2 人だけの時に一致しない確率は `364/365` である。`n` が増えるたびに `(365-n+1)/365` と下がっていき、試行回数分の積で求められる。`n = 23` で `0.492...` となり 50% を超える。

<script type="math/tex; mode=display" id="MathJax-Element-birthday_paradox">
P(n) = \frac{364}{365} \cdot \frac{363}{365} \cdot \frac{362}{365} \cdots \frac{365 - n + 1}{365} = \frac{365!}{365^n (365 - n)!} \\
1 - P(23) \approx 0.507
</script>

2 人だけの時に一致しない確率は `364/365` である。自分と一致する確率で考えると、23 人の時は`0.006` とずっと小さいが、23 人分の組み合わせは `253` 通りある。同じように考えてみれば、同じく 50% に近づくことが分かる。

<script type="math/tex; mode=display" id="MathJax-Element-birthday_paradox_combi">
1 - \left(\frac{364}{365}\right)^{23} \approx 0.006 \\
C(n, 2) = \frac{n!}{2!(n - 2)!} = \frac{n (n - 1)}{2} \\
C(23, 2) = \frac{23 \cdot 22}{2} = 253 \\
1 - \left(\frac{364}{365}\right)^{253} \approx 0.500
</script>

有限集合 `U` からランダムに選択して、衝突する確率が 50% を超えるまでの試行数は以下で求められる。

<script type="math/tex; mode=display" id="MathJax-Element-birthday_paradox_formula">
n = 1.2 \cdot |U|^{1/2}
</script>

128bit のハッシュ関数に対し、元メッセージを見つけるまで（原像攻撃）の試行回数の期待値は `2^128` に比例するが、同じハッシュとなる二つのメッセージを見つけるまで（衝突攻撃）の試行回数は、大きく下がり `2^64` に比例する。
