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

ロジスティック回帰により、二値に分類することができるが、その決定境界 _Decision boundary_ はシグモイド関数による一つの変曲点 `(0. 0.5)` になる。

変曲点が一つであることは、決定境界が必ずしも最適な結果にならないことも意味する。

* `x = [0 10; 0 -10], y = [1; 0]` という学習データを例にする。
* 直感では、決定境界は `(0, -N)..(0, N)` のような、y 軸に沿う直線が考えられる。
* ロジスティック回帰においては、正解値のマージンが少ない `(-10, -1)..(10, 1)` を通る決定境界を与えることもある。

これに対し、_Support vector machine_ は、より最適なマージンをもつ決定境界を見つけようとする。目的関数はロジスティク回帰と似ており、`y = (0|1)` の値に応じてコスト算出アルゴリズムを切り替える。

<script type="math/tex; mode=display" id="MathJax-Element-svm_linear_boundary">
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

* `cost1` 関数は `y = 1` である時のコストを返す。`θ^T x` が 1 以上であればコスト無し 0 となり、そうでなければ 1 から減少するごとにコストが比例して増える。
* `cost0` 関数は `y = 0` である時のコストを返す。`θ^T x` が -1 以下であればコスト無し 0 となり、そうでなければ -1 から増加するごとにコストが比例して増える。
* `C` は定数で、大きくするごとに誤差への感度が上がり、決定境界を正解値にフィットしようとする。小さくすると誤差への感度が下がり、決定境界が正解値から外れることを許容する。
* `θ` の二乗和を取っている項は、ロジスティック回帰でのペナルティ項のように思えるが、_Support vector machine_ においては、役目が反対になる。すなわち `θ` の値を最小にすることが目的になる。

`θ` が小さいほど決定境界のマージンが保たれるとするならば、目的関数を最小化することは

* 決定境界を見つける: `cost` 関数を 0 に近づける。
* 決定境界のマージンを保つ: `θ` を出来る限り最小にする。

この二つが両立するパラメータ `θ` を見つけることになる。

## Vector Inner Product

直角三角形の斜辺の長さは、ピタゴラスの定理により「斜辺の長さ _c_ の二乗は、残りの二辺（底辺 / 高さ） _a, b_ それぞれの二乗の和と等しい」

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

射影 `p` は、ベクトル `u, v` 間の角度が 90 度以上になると、負の値になる。

## Linear Kernel

簡略化のために、二次元に制限して `(θ1, θ2), (x1, x2)` で考えてみる。

`θ^T x` を、ベクトルの内積 `u^T v` に置き換えると、目的関数内の `cost` 関数の条件を以下のように言い換えることができる。

<script type="math/tex; mode=display" id="MathJax-Element-svm_linear_kernel_cost">
\left\{
  \begin{array}{l l}
  \text{cost}_1 ( p \cdot \begin{Vmatrix} u \end{Vmatrix} ) & \ldots & p \cdot \begin{Vmatrix} u \end{Vmatrix} \geq 1 & \text{if $y = 1$} \\
  \text{cost}_0 ( p \cdot \begin{Vmatrix} u \end{Vmatrix} ) & \ldots & p \cdot \begin{Vmatrix} u \end{Vmatrix} \leq -1 & \text{if $y = 0$} \\
  \end{array} \\
\right.
</script>

* `p` は、斜辺ベクトル `x` から、底辺ベクトル `θ` への射影の長さ
* `||u||` は底辺ベクトル `θ` の長さ
* `y = 1` である時、射影 `p` がより大きければ（正の方向に十分な長さがあれば）ベクトル `θ` はより小さくなれる。
* `y = 0` である時、射影 `p` がより小さければ（負の方向に十分な長さがあれば）ベクトル `θ` はより小さくなれる。

決定境界を `(0, 0)` を通過する直線とした時、以下のように視覚化できる。

* ベクトル `x` を直角三角形の斜辺と捉えると、決定境界はその直角三角形の高さに平行な直線となる。
* `cost` 関数への引数 `θ^T x` を、直角三角形の斜辺 `x` と底辺ベクトル `θ` の内積を取ることと考えれば、`θ` は決定境界（直角三角形の高さと平行の直線）に対して、正方向に 90 度の角度を持つベクトルになる。
* ベクトル `x` から、ベクトル `θ` への 射影 `p` の長さは、決定境界と `(x1, x2)` のマージンになる。

決定境界が完全に正解値に分類できているならば、`cost` 関数が 0 となるので、目的関数は以下に簡略化できる。

<script type="math/tex; mode=display" id="MathJax-Element-svm_linear_kernel_theta">
\begin{align}
\min_{\theta} C \cdot 0 + \frac{1}{2} \sum_{j = 1}^{n} \theta_{j}^{2} & = \frac{1}{2} \sum_{j = 1}^{n} \theta_{j}^{2} \\
& = \frac{1}{2} (\theta_1^{2} + \theta_2^{2}) \\
& = \frac{1}{2} \left( \sqrt{ \theta_1^{2} + \theta_2^{2} } \right) ^{2} \\
& = \frac{1}{2} \begin{Vmatrix} \theta \end{Vmatrix} ^{2} \\
\end{align}
</script>

つまり `θ` を最小化しつつ、`cost` 関数が 0 となる条件を満たすには、射影 `p` の長さが十分であることが必要で、このことは _Support vector machine_ が、決定境界を正解値にフィットさせつつ、よりマージンを取ろうとすることに繋がる。

