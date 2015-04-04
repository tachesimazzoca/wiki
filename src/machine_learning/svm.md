---
layout: page

title: Support Vector Machine
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Decision Boundary

ロジスティック回帰により、二値に分類することができるが、その決定境界 _Decision boundary_ はシグモイド関数により `(0. 0.5)` の一つの変曲点になる。

変曲点が一つであることは、その条件さえ満たせば良いので、決定境界が必ずしも最適な結果にならないことを意味する。

* `h(0, 10) = 1` `h(0, -10) = 0` という学習データを例にする。
* 直感では、決定境界は `(0, -N)..(0, N)` のような、y 軸に沿う境界線が考えられる。
* しかし、ロジスティック回帰においては、マージンが少ない `(-10, -1)..(10, 1)` を通る決定境界を与えることもある。

これに対し、_Support vector machine_ は、より最適なマージンをもつ決定境界を見つけようとする。ロジスティック回帰と似た目的関数を用いる。

<script type="math/tex; mode=display" id="MathJax-Element-svm_hyphothesis">
\min_{\theta} C \sum_{i = 1}^{m} \begin{bmatrix}
  y^{(i)} \text{cost}_{1}(\theta^{T} x^{(i)}) + (1 - y^{(i)}) \text{cost}_{0}(\theta^{T} x^{(i)})
\end{bmatrix} + \frac{1}{2} \sum_{j = 1}^{n} \theta_{j}^{2}  \\

\left\{
  \begin{array}{l l}
  \text{cost}_1 (\theta^{T} x) & \ldots & \theta^{T} x^{(i)} \geq 1 & \text{if $y = 1$} \\
  \text{cost}_0 (\theta^{T} x) & \ldots & \theta^{T} x^{(i)} \leq -1 & \text{if $y = 0$} \\
  \end{array} \\
\right.
</script>

* `cost1` 関数は `y = 1` である時のコストを返す。`θ^T x` が 1 以上であればコスト無し 0 となり、そうでなければ 1 から離れる（減少する）ごとにコストが比例して増える。
* `cost0` 関数は `y = 0` である時のコストを返す。`θ^T x` が -1 以下であればコスト無し 0 となり、そうでなければ 1 から離れる（増加する）ごとにコストが比例して増える。
* `C` は定数で、大きくするごとに誤差への感度が上がり、境界線はより正解値にフィットしようとする。小さくすると誤差への感度が下がり、境界線は正解値にフィットするよりも、マージンを取ることを優先する。
* `θ^2` の総和を取っている項は、ロジスティック回帰での正規化項のように思えるが、_Support vector machine_ においては、役目が反対になる。すなわち `θ` の値を最小にすることが目的になる。

`θ^2` を出来る限り最小にしつつ（境界線のマージンを保ちつつ）、`cost(θ^T x)` の値も 0 に近い（正しく分類できる）、パラメータ `θ` を見つけることになる。

## Vector Inner Product

直角三角形の斜辺の長さは、ピタゴラスの定理「斜辺の長さ _c_ の二乗は、残りの二辺（底辺 / 高さ） _a, b_ それぞれの二乗の和と等しい」ことより以下の式で求めることができる。

<script type="math/tex; mode=display" id="MathJax-Element-pythagrean_theorem">
a^2 + b^2 = c^2 \\
c = \sqrt{a^2 + b^2} \\
</script>

直角三角形の斜辺は、ベクトルに置き換えるとその距離に等しく、ノルム _Norm_ という表記 `||u||` で表す。

<script type="math/tex; mode=display" id="MathJax-Element-norm">
u = \begin{bmatrix}
3 \\
5 \\
\end{bmatrix} \\

\begin{Vmatrix} u \end{Vmatrix} = \sqrt{ u_1^{2} + u_2^{2} } = \sqrt{ 3^2 + 5^2 } = \sqrt{ 31 } = 5.5678
</script>

ベクトルの内積 _Vector inner product_ は、以下の公式がなりたつ。

<script type="math/tex; mode=display" id="MathJax-Element-vector_inner_product">
\vec{u} \cdot \vec{v} = u^{T}v = \begin{Vmatrix}u\end{Vmatrix} \cdot \begin{Vmatrix}v\end{Vmatrix} \cos \theta \\
</script>

すなわち、ベクトル `v` から、ベクトル `u` への射影 _Projection_ を `p` とすると

* ベクトル `v` の距離は、直角三角形の斜辺
* 射影 `p` の距離は、直角三角形の底辺 `||v||cosθ`

と考えることができる。

<script type="math/tex; mode=display" id="MathJax-Element-vector_projection">
\begin{align}
u^{T}v & = p \cdot \begin{Vmatrix}u\end{Vmatrix} \\
u_1 v_1 + u_2 v_2  & = p \cdot \sqrt{u_1^{2} + u_2^{2}} \\
\end{align}
</script>

