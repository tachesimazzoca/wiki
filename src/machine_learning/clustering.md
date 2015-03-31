---
layout: page

title: Clustering
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Overview

クラスタリング _Clustering_ は、教師なし学習 _Unsupervised Learning_ の一つで、サンプルデータのメンバー間の類似性を見つけて、部分集合に振り分ける。サンプル毎にどの分類になるかの解答は必要としない。

## K-means Algorithm

サンプルデータを、`K` 個のクラスタ _Cluster_ に振り分けるとする。

<script type="math/tex; mode=display" id="MathJax-Element-k_means_step1">
{\scriptsize \text{$K = $ number of clusters}} \\
{\scriptsize \text{$n = $ number of features}} \\
{\scriptsize \text{$m = $ number of examples}} \\
x^{(i)} = x^{(1)},x^{(2)}, \ldots,x^{(m)} \in \mathbb{R}^{n} \\
</script>

任意の `K` 個の重心 _Centroid_ を置く。各重心はサンプルと同サイズ（パラメータ数） `n` のベクトルになる。

<script type="math/tex; mode=display" id="MathJax-Element-k_means_step2">
{\scriptsize \text{$\mu = $ cluster centroids}} \\
\left\{ \mu_{1},\mu_{2}, \ldots,\mu_{K} \right\} = \mu_k  \in \mathbb{R}^{n}\\
</script>

各サンプル `x(i)` 毎に、最も距離が近い重心に紐づける。

<script type="math/tex; mode=display" id="MathJax-Element-k_means_step3">
{\scriptsize \text{$c = $ index of cluster to each example}} \\
c^{(i)} := \text{$j$ that minimizes} \begin{Vmatrix}
x^{(i)} - \mu_{j}
\end{Vmatrix}^{2}
</script>

<script type="math/tex; mode=display" id="MathJax-Element-k_means_step4_ex">
{\scriptsize \text{$C = $ set of examples that are assigned to each centroid}} \\
\text{ex. $c = $} \left\{ 2, 1, 1, 3, 3, 2, 1, 2 \right\} \\
\begin{align}
C_{1} & = \left\{ x^{(2)}, x^{(3)}, x^{(7)} \right\} \\
C_{2} & = \left\{ x^{(1)}, x^{(6)}, x^{(8)} \right\} \\
C_{3} & = \left\{ x^{(4)}, x^{(5)} \right\} \\
\end{align}
</script>

重心を、紐づいたサンプルの平均ベクトルに移動する。

<script type="math/tex; mode=display" id="MathJax-Element-k_means_step4">
\mu_{k} := \frac{1}{ \begin{vmatrix} C_k \end{vmatrix} } { \sum_{i \in C_k} x^{(i)} } \\
</script>

この重心移動を安定するまで繰り返す。

* プログラムに誤りがなければ、重心の移動範囲は必ず小さくなる。
* 一つも割り振られない重心が出てきた場合は、取り除くか、新たに初期化しなおせばよい。

### Cost Function

収束した重心に対しての全データの距離の平均値をコスト関数として定義できる。

<script type="math/tex; mode=display" id="MathJax-Element-k_means_cost">
J(c, \mu) = \frac{1}{m} \sum_{i = 1}^{m} \begin{Vmatrix}
x^{(i)} - \mu_{c(i)}
\end{Vmatrix}^{2}
</script>

この値が小さい程、分類形状の歪み具合 _Distortion_ が少なくなるので、最適化（バランス良く振り分けられたかどうか）の目安になる。

### Random Initialization

アルゴリズムの性質上、重心の初期値が重複していたり偏っていたりすると、_Local optima_ に収束しやすい。

* `X = [0,0; 0,2; 0,10; 0,12]` を、二つのクラスタに分けるとする。
* 期待される最終の重心は `centroids = [0,1; 0;11]`
* 初期値 `centroids = [0,0; 0,0]` の場合、`[0,6; 0,0]` に収束してしまう。
  * `c = [1; 1; 1; 1], centroids = [(0/4),(24/4); 0,0] = [0,6; 0,0]`

このため、重心の初期値は、学習データからランダムに選択したユニークなサンプルと同値に置く。

* 初期値 `centroids = [0,0; 0,2]` の場合、期待値 `[0,1; 0,11]` に収束する。
  * `c = [1; 2; 2; 2], centroids = [(0/1),(0/1); (0/3),(24/3)] = [0,0; 0,8]`
  * `c = [1; 1; 2; 2], centroids = [(0/2),(2/2); (0/2),(22/2)] = [0,1; 0,11]`

いくつかの初期値で試し、最適な重心を見つけることも重要になる。分類完了後にコスト `J(c, mu)` を計算し、最も小さいコストになる結果（初期値）を採用する。

### Elbow Method

_K-means algorithm_ では、初めに重心数 `K` を決めなければいけない。サンプルデータに適した重心数を見つけるには、_Elbow method_ が使える。

`K` を x 軸、コスト関数 `J(c, mu)` を y 軸にプロットすると、`K = 1` を最大として、ある時点の `K` を境に、目立ってコスト値が下がらなくなる。この肘 _Elbow_ の支点のように見える `K` が、最適な重心数になる。

もちろん、利用用途によりクラスタ数の範囲が決まっているのであれば、常に最適値を取るという訳ではない。

未開の場所に食事店を出すとして「並 / 大盛 / 特盛」のような `K = 3` のバリエーションが有効かを判断したい時、近辺住民の行動データから計測した最適なクラスタ数が `K = 5` であっても、バリエーションを増やすことが良いかは状況次第である。
