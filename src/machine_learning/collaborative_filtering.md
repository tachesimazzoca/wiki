---
layout: page

title: Collaborative Filtering
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Optimization Algorithm

商品に対してユーザ評価が与えられたデータセットを持っているとする。

商品の特性が得られていると仮定して、これを学習データの入力 `x` とし、パラメータ `θ` をユーザ特性と考えれば、正解値 `y` をユーザ評価として、以下の目的関数を定義できる。

<script type="math/tex; mode=display" id="MathJax-Element-content_based_recommendation">
{\scriptsize \text{$n = $ number of features}} \\
{\scriptsize \text{$x = $ items, $\theta = $ users}} \\
{\scriptsize \text{$r = $ whether or not each user has rated}} \\
{\scriptsize \text{$y = $ rating given by users}} \\

\min_{\theta^{(j)}} \frac{1}{2} \sum_{i;r(i,j) = 1} ((\theta^{(j)})^{T} x^{(i)} - y^{(i, j)})^{2} + \frac{\lambda}{2} \sum_{k = 1}^{n} (\theta_{k}^{(j)})^{2} \\
</script>

* `x`: 商品特性（すでに得られていると仮定する）
* `θ`: ユーザ特性
* `r(i, j) = (0|1)`: ユーザ `j` が商品 `i` を評価したかどうか？ 評価なしと未評価は異なる。
* `y`: 商品 `i` に対する、ユーザ `j` の評価

すべての商品ではなく、ユーザが評価を行なった商品 `r(i, j) = 1` のみコストを取る点に注意する。

すべてのユーザに対して適用するコスト関数は、以下のようになる。

<script type="math/tex; mode=display" id="MathJax-Element-content_based_recommendation_cost_grad">
{\scriptsize \text{$n_{u} = $ number of users}} \\
\min_{\theta^{(1)} \ldots \theta^{(n_{u})}} J(\theta) = \frac{1}{2} \sum_{j = 1}^{n_{u}} \sum_{i;r(i,j) = 1} ((\theta^{(j)})^{T} x^{(i)} - y^{(i, j)})^{2} + \frac{\lambda}{2} \sum_{j = 1}^{n_{u}} \sum_{k = 1}^{n} (\theta_{k}^{(j)})^{2} \\

\begin{align}
\theta_{k}^{(j)} & := \theta_{k}^{(j)} - \alpha (\sum_{i:r(i, j)=1} ((\theta^{(j)})^{T} x^{(i)} - y^{(i, j)}) x_{k}^{(i)}) & \text{(for $k = 0$)} \\
\theta_{k}^{(j)} & := \theta_{k}^{(j)} - \alpha (\sum_{i:r(i, j)=1} ((\theta^{(j)})^{T} x^{(i)} - y^{(i, j)}) x_{k}^{(i)} + \lambda (\theta_{k}^{(j)})) & \text{(for $k \ne 0$)} \\
\end{align}
</script>

