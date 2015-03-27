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

## K-means Algorithm

_K-means algorithm_ は、教師なし学習 _Unsupervised Learning_ の一つで、正解のないデータから、学習データの分布を頼りに分類を見つけ出すことができる。

サンプルデータを、`K` 個の分類 _Cluster_ に分けるとする。

<script type="math/tex; mode=display" id="MathJax-Element-k_means_step1">
{\scriptsize \text{$K = $ number of clusters}} \\
{\scriptsize \text{$n = $ number of features}} \\
{\scriptsize \text{$m = $ number of examples}} \\
x^{(i)} = x^{(1)},x^{(2)}, \ldots,x^{(m)} \in \mathbb{R}^{n} \\
</script>

任意の `K` 個の重心 _Centroid_ を置く。各重心はサンプルと同サイズ `n` のベクトルになる。

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

### Random Initialization

アルゴリズムの性質上、重心の初期値が重複していたり、偏っていたりすると _Local optima_ に収束しやすい。

* `X = [0,0; 0,2; 0,10; 0,12]` を、二つのクラスタに分けるとする。
* 期待される最終の重心は `centroids = [0,1; 0;11]`
* 初期値 `centroids = [0,0; 0,0]` の場合、`[0,6; 0,0]` に収束してしまう。
  * `c = [1; 1; 1; 1], centroids = [(0/4),(24/4); 0,0] = [0,6; 0,0]`

このため、重心の初期値は、学習データからランダムに選択したユニークなサンプルと同値に置くとよい。

* 初期値 `centroids = [0,0; 0,2]` の場合、期待値 `[0,1; 0,11]` に収束する。
  * `c = [1; 2; 2; 2], centroids = [(0/1),(0/1); (0/3),(24/3)] = [0,0; 0,8]`
  * `c = [1; 1; 2; 2], centroids = [(0/2),(2/2); (0/2),(22/2)] = [0,1; 0,11]`

いくつかの初期値を試し、同じ重心に収束するかどうか検証することも有効である。

