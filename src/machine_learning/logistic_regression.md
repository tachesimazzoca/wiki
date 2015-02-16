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

仮説 `h(x)` の範囲を `0 < h(x) < 1` に制限し、境界値 `0.5` を境に `(0|1)` に分類すればよい。シグモイド関数 _Sigmoid (Logistic) Function_ により、`(0, 0.5)` に変曲点をもち、`(-∞, ∞) -> (0, 1)` となる関数を実現できる。 

<script type="math/tex; mode=display" id="MathJax-Element-sigmoid">
g(z) = \frac{1}{1 + e^{-z}} \\
\lim_{z \to \infty} g(z) = 1 \\
\lim_{z \to -{\infty}} g(z) = 0 \\
</script>

訓練データ入力のベクトルを `x` とし、パラメータを `θ` とすると、シグモイド関数による `h(x)` は以下のようになる。

<script type="math/tex; mode=display" id="MathJax-Element-sigimoid_hypothesis">
h_{\theta}(x) = g({\theta}_0 + {\theta}_1 x_1 + {\theta}_2 x_2 + ...) \\
h_{\theta}(x) = g({\theta}^T x) = \frac{1}{1 + e^{- { {\theta}^T x } } } \\
</script>

結果値を `y` とした時、`h(x)` は `y = 1` になる確率であると解釈できる。`y = (1|0)` となる確率を `P(y = 1), P(y = 0)` とした時、以下の式が成り立つ。

<script type="math/tex; mode=display" id="MathJax-Element-sigmoid_probability">
P(y = 1) + P(y = 0) = 1 \\
h_{\theta}(x) = P(y = 1) = 0.5 \ldots P(y = 0) = 1 - 0.5 = 0.5 \\
h_{\theta}(x) = P(y = 1) = 0.3 \ldots P(y = 0) = 1 - 0.3 = 0.7 \\
</script>

