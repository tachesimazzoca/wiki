---
layout: page

title: Principle Component Analysis
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Overview

計測対象のデータによっては、相関のない似た成分が含まれることがある。例えば画像識別を行なうとして、ある程度の形状が判断できればよいならば、わずかな色の違いは不要な情報である。これらの成分は、ひとまとめにして学習したほうが効率的である。

主成分分析 _Principle Component Analysis (PCA)_ により、相関のない成分を見つけ出し、次元数を圧縮することができる。

* ２次元データ `(x1, x2)` から１次元データ `z1` に圧縮するとする。
* 各 `(x1, x2)` からの射影 _Projection_ への距離が、最も小さくなるベクトル `u` を見つける。
* u の射影の `x1` 軸が `z1` になる。

線形回帰と似ているが、誤差の捉え方が異なる。線形回帰の誤差 `h(x) - y` は正解軸 `y` に対して平行に計るが、_PCA_ は射影に対しての誤差、ベクトル `u` を底辺、`x` を斜辺とした、直角三角形の高さを計る。

## Covariance Matrix

_PCA_ では、学習データの共分散行列 _Covariance matrix_ を利用する。

<script type="math/tex; mode=display" id="MathJax-Element-pca_sigma">
\Sigma = \frac{1}{m} \sum_{i = 1}^{n} {(x^{(i)})(x^{(i)})^{T}} \\
\Sigma \in \mathbb{R}^{n \times n}
</script>

`Σ` は、学習データ `x` の各要素を交差させて平均をとった `n` の平方行列になる。各要素の相関関係を調べるために、この共分散行列により各要素を交差させて、分散度合いを計ると考えればよい。

## Singular Value Decomposition

特異値分解 _Singular value decomposition_ では、行列を３つの行列に分解する。

<script type="math/tex; mode=display" id="MathJax-Element-pca_svd">
M = U \Sigma V^{T}
</script>

* `U` は出力の基底となる正規直交ベクトル
* `V` は入力の基底となる正規直交ベクトル
* `Σ` は特異値を対角に持つ行列

MATLAB 互換であれば `svd` 関数が提供されている。分解した `[U, S, V]` を得ることができる。

{% highlight octave %}
octave> [U, S, V] = svd(magic(3));
octave> U * S * V'
ans =

   8.00000   1.00000   6.00000
   3.00000   5.00000   7.00000
   4.00000   9.00000   2.00000

{% endhighlight %}

## PCA Algorithm

学習データ `X` のパラメータ数 `n` から、`k` に圧縮したいとする。

{% highlight octave %}
X = [1 5 1 3; 2 8 2 4; 3 6 3 8; 4 5 4 7];

% number of examples and features
[m, n] = size(X);
% number of eigenvectors
k = 3;
{% endhighlight %}

学習データはあらかじめ、_Feature normalization_ を行い、要素のスケールを揃えておく。

{% highlight octave %}
% -1.16190  -0.70711  -1.16190  -1.05021
% -0.38730   1.41421  -0.38730  -0.63013
%  0.38730   0.00000   0.38730   1.05021
%  1.16190  -0.70711   1.16190   0.63013
X = X - repmat(mean(X), m, 1);
X = X ./ repmat(std(X), m, 1);
{% endhighlight %}

学習データ `X` の共分散行列 `Sigma` を得て、特異値分解する。

{% highlight octave %}
Sigma = (X' * X) ./ m;
[U, S, V] = svd(Sigma);
{% endhighlight %}

得られた `U` から圧縮パラメータ数 `k` 分の列を取り出し、学習データ `X` との積をとることで、圧縮された学習データが得られる。

{% highlight octave %}
% -0.577740  -0.110058  -0.392560
%  0.170136  -0.985083   0.025784
% -0.577740  -0.110058  -0.392560
% -0.550896  -0.073387   0.831341
Ureduce = U(:, 1:k);

%  1.800799   1.029382   0.020913
%  1.035258  -1.261625  -0.183311
% -1.026072  -0.162322   0.569007
% -1.809985   0.394565  -0.406609
Z = X * Ureduce;
{% endhighlight %}

完全ではないが、圧縮前の学習データに復元するには、逆の行列演算を行なえば良い。

{% highlight octave %}
Xapprox = Z * Ureduce';

% 1.9722e-31   6.0397e-31   4.9304e-32   4.9304e-32
% 0.0000e+00   1.2326e-30   0.0000e+00   1.2326e-32
% 1.5099e-31   1.3271e-33   1.2326e-32   0.0000e+00
% 0.0000e+00   1.9722e-31   1.9722e-31   1.2326e-32
Xdiff = (X - Xapprox) .^ 2;
{% endhighlight %}
