---
layout: page

title: Logistic Regression
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Sigmoid Function

_Classification Problem_ において、`(0|1)` の二つの値 _Binomial_ に分類することを考えてみる。

仮説 `h(x)` の範囲を `0 < h(x) < 1` に制限し、境界値 `0.5` を境に `(0|1)` に分類すればよい。シグモイド関数 _Sigmoid (Logistic) Function_ により、`(0, 0.5)` に変曲点をもち、`(-Inf, Inf) -> (0, 1)` となる関数を実現できる。

<script type="math/tex; mode=display" id="MathJax-Element-sigmoid">
g(z) = \frac{1}{1 + e^{-z}} \\
\lim_{z \to \infty} g(z) = 1 \\
\lim_{z \to -{\infty}} g(z) = 0 \\
</script>

* `z = 0` のときに `1/(1+exp(0)) = 1/(1+1) = 0.5` となる。
* `z >= 0` の場合、分母が指数的に減少し、`1` に限りなく近づく。
* `z < 0` の場合、分母が指数的に増加し、`0` に限りなく近づく。

訓練データ入力のベクトルを `x` とし、パラメータを `θ` とすると、シグモイド関数による `h(x)` は以下のようになる。

<script type="math/tex; mode=display" id="MathJax-Element-sigimoid_hypothesis">
h_{\theta}(x) = g({\theta}_0 + {\theta}_1 x_1 + {\theta}_2 x_2 + ...) \\
h_{\theta}(x) = g({\theta}^T x) = \frac{1}{1 + e^{- { {\theta}^T x } } } \\
</script>

結果値を `y` とした時、`h(x)` は `y = 1` になる確率であると解釈できる。`y = (1|0)` となる確率を `P(y = 1), P(y = 0)` とした時、`P(y = 1) + P(y = 0) = 1` が成り立つ。

<script type="math/tex; mode=display" id="MathJax-Element-sigmoid_probability">
P(y = 1) + P(y = 0) = 1 \\
h_{\theta}(x) = P(y = 1) = 0.5 \ldots P(y = 0) = 1 - 0.5 = 0.5 \\
h_{\theta}(x) = P(y = 1) = 0.3 \ldots P(y = 0) = 1 - 0.3 = 0.7 \\
</script>

## Decision Boundary

シグモイド関数を `g(z)` とした時、訓練データの入力をグラフにプロットすると、`z = 0` を境界線として、`y = (1|0)` の領域で区分される。

入力が二つ `x1, x2` の訓練データで、`z = -2 + x1 + x2` の線形の仮説を例にすると、`x1 + x2 = 2` を満たす直線が境界線になることが分かる。

<script type="math/tex; mode=display" id="MathJax-Element-decision_boundary_linear">
\theta = \begin{bmatrix}
  -2 \\
  1 \\
  1 \\
\end{bmatrix} \\
h_{\theta}(x) = g(-2 + {\theta}_1 x_1 + {\theta}_2 x_2) \\
z = -2 + x_1 + x_2 = 0 \\
\begin{array}{l l}
y = 1 & x_1 + x_2 > 2 & (-1, 4), (0, 3), (1, 2), (2, 1), \ldots \\
y = 0.5 & x_1 + x_2 = 2 & (-1, 3), (0, 2), (1, 1), (2, 0), \ldots \\
y = 0 & x_1 + x_2 < 2 & (-1, 2), (0, 1), (1, 0), (2, -1), \ldots \\
\end{array}
</script>

多項式 _Polynomial_ の場合も同様である。`z = -1 + x1^2 + x2^2` を例にすると、`x1^2 + x^2 = 1` を満たす曲線（この場合円形）が境界線になることがわかる。

<script type="math/tex; mode=display" id="MathJax-Element-decision_boundary_nonlinear">
\theta = \begin{bmatrix}
  -1 \\
  0 \\
  0 \\
  1 \\
  0 \\
  1 \\
\end{bmatrix} \\
h_{\theta}(x) = g(-1 + {\theta}_1 x_1 + {\theta}_2 x_2 + {\theta}_3 x_{1}^2 + {\theta}_4 x_{1} x_{2} + {\theta}_5 x_{2}^2) \\
z = -1 + x_{1}^2 + x_{2}^2 = 0 \\
\begin{array}{l l}
y = 1 & x_{1}^2 + x_{2}^2 > 1 & (-2, 0), (0, -2), (2, 0), (0, 2), \ldots \\
y = 0.5 & x_{1}^2 + x_{2}^2 = 1 & (-1, 0), (0, -1), (1, 0), (0, 1), \ldots \\
y = 0 & x_{1}^2 + x_{2}^2 < 1 & (-0.5, 0), (0, -0.5), (0.5, 0), (0, 0.5), \ldots \\
\end{array}
</script>

## Cost Function

シグモイド（ロジスティック）関数のパラメータ `θ` を求めることを、ロジスティック回帰 _Logistic Regression_ と呼ぶ。線形回帰 _Linear Regression_ と同様に、費用関数 _Cost Function_ を定義し、勾配法 _Gradient decent_ で、費用が最小となるパラメータを見つけ出せば良い。

ロジスティック回帰での誤差は

* 仮説 `h(x)` が、期待値 `(0|1)` に近づくほどに `0`
* 仮説 `h(x)` が、期待値 `(0|1)` から離れるほどに無限大

となればよい。

`(-log(1), -log(0)) = (0, Inf)` であることを利用して、誤差の算出を以下のように定義できる。

<script type="math/tex; mode=display" id="MathJax-Element-logistic_function_error_def">
\left\{
  \begin{array}{l l}
  -log(h_{\theta}(x))     & \text{if $y = 1$} \\
  -log(1 - h_{\theta}(x)) & \text{if $y = 0$} \\
  \end{array} \\
\right.
</script>

`y = (0|1)` で式が異なるので、`y` の値によって打ち消す係数 `y, 1-y` をかければよい。誤差平均をもとにした費用関数と、勾配法 _Gradient decent_ で用いる偏微分の項は以下になる。

<script type="math/tex; mode=display" id="MathJax-Element-logistic_function_cost">
J(\theta) = \frac{1}{m} {\sum_{i=1}^{m} [ -log(h_{\theta}(X_i))(y_i) - log(1 - h_{\theta}(X_i)) (1 - y_i) ] } \\
{\partial J(\theta) \over \partial \theta_{j}} = \frac{1}{m} {\sum_{i=1}^{m} (h_{\theta}(X_i) - y_i)X_{i,j} } \\
\theta_{j} := \theta_{j} - \alpha \left(\frac{1}{m} \sum_{i=1}^{m} (h_{\theta}(X_{i}) - y_{i}) X_{i,j} \right) \\
</script>

