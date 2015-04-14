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

## Content Based Algorithm

商品に対してユーザ評価が与えられたデータセットを持っているとする。このデータを元にユーザの評価を予測したい。

商品の特性が得られていると仮定して、これを学習データの入力 `x` とし、パラメータ `θ` をユーザ特性と考えれば、正解値 `y` をユーザ評価として、以下の目的関数を定義できる。

<script type="math/tex; mode=display" id="MathJax-Element-content_based_cost">
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

<script type="math/tex; mode=display" id="MathJax-Element-content_based_cost_grad">
{\scriptsize \text{$n_{u} = $ number of users}} \\
\min_{\theta^{(1)} \ldots \theta^{(n_{u})}} J(\theta) = \frac{1}{2} \sum_{j = 1}^{n_{u}} \sum_{i;r(i,j) = 1} ((\theta^{(j)})^{T} x^{(i)} - y^{(i, j)})^{2} + \frac{\lambda}{2} \sum_{j = 1}^{n_{u}} \sum_{k = 1}^{n} (\theta_{k}^{(j)})^{2} \\

\begin{align}
\theta_{k}^{(j)} & := \theta_{k}^{(j)} - \alpha (\sum_{i:r(i, j)=1} ((\theta^{(j)})^{T} x^{(i)} - y^{(i, j)}) x_{k}^{(i)}) & \text{(for $k = 0$)} \\
\theta_{k}^{(j)} & := \theta_{k}^{(j)} - \alpha (\sum_{i:r(i, j)=1} ((\theta^{(j)})^{T} x^{(i)} - y^{(i, j)}) x_{k}^{(i)} + \lambda \theta_{k}^{(j)}) & \text{(for $k \ne 0$)} \\
\end{align}
</script>

## Collaborative Filtering Algorithm

_Content based algorithm_ での、商品特性からユーザ特性を見つける場合と逆の発想で、ユーザ特性 `θ` がすでに得られていると仮定すると、商品特性 `x` を予測することができる。

<script type="math/tex; mode=display" id="MathJax-Element-user_based_cost_grad">
{\scriptsize \text{$n_{m} = $ number of items}} \\
\min_{x^{(1)} \ldots x^{(n_{m})}} J(x) = \frac{1}{2} \sum_{i = 1}^{n_{m}} \sum_{i;r(i,j) = 1} ((\theta^{(j)})^{T} x^{(i)} - y^{(i, j)})^{2} + \frac{\lambda}{2} \sum_{i = 1}^{n_{m}} \sum_{k = 1}^{n} (x_{k}^{(i)})^{2} \\
</script>

協調フィルタリング _Collaborative filtering_ では

* 与えられた商品特性から、ユーザ特性を予測する。
* 与えられたユーザ特性から、商品特性を予測する。

この二つの目的関数を同時に最小化していくことで、ユーザ特性と商品特性が互いに協調して最適値に収束する。これにより、予測解だけではなく、予測を導く特性そのものを学習 _Feature learning_ することができる。

ユーザ特性と商品特性の目的関数は、二乗誤差の項は実質同じである。

* ユーザ特性: 全ユーザ `j` のうち、ユーザが評価 `r(i, j) = 1` した商品 `x(i)` の予測評価と実評価 `y` との誤差
* 商品特性: 全商品 `i` のうち、ユーザに評価 `r(i, j) = 1` された商品 `x(i)` の予測評価と実評価 `y` との誤差

このことから、正規化項が異なるだけなので、コスト関数は同一式にまとめることができる。

<script type="math/tex; mode=display" id="MathJax-Element-collaborative_filtering_cost">
J(x, \theta) = \frac{1}{2} \sum_{(i, j);r(i,j) = 1} ((\theta^{(j)})^{T} x^{(i)} - y^{(i, j)})^{2} + \frac{\lambda}{2} \sum_{j = 1}^{n_{n}} \sum_{k = 1}^{n} (\theta_{k}^{(j)})^{2} + \frac{\lambda}{2} \sum_{i = 1}^{n_{m}} \sum_{k = 1}^{n} (x_{k}^{(i)})^{2} \\
</script>

_Gradient descent_ は、`x(i)` と `θ(j)` それぞれに偏微分を取り個別に行なう。

<script type="math/tex; mode=display" id="MathJax-Element-collaborative_filtering_grad">
\begin{align}
x_{k}^{(i)} & := x_{k}^{(i)} - \alpha \frac{\partial J}{\partial x_{k}^{(i)}} & \frac{\partial J}{\partial x_{k}^{(i)}} & = \sum_{j:r(i, j)=1} ((\theta^{(j)})^{T} x^{(i)} - y^{(i, j)}) \theta_{k}^{(j)} + \lambda x_{k}^{(i)} \\
\theta_{k}^{(j)} & := \theta_{k}^{(j)} - \alpha \frac{\partial J}{\partial \theta_{k}^{(j)}} & \frac{\partial J}{\partial \theta_{k}^{(j)}} & = \sum_{i:r(i, j)=1} ((\theta^{(j)})^{T} x^{(i)} - y^{(i, j)}) x_{k}^{(i)} + \lambda \theta_{k}^{(j)} \\
\end{align}
</script>

パラメータ自体を予測するので、切片項に対するパラメータ `x0 = 1, θ0 = 1` は不要である。もしそのような項が必要な時には、アルゴリズム自体でそのように収束する。よって、切片項用の偏微分も必要ない。

これらをふまえて、協調フィルタリングを用いたアルゴリズムを整理すると以下のような手順になる。

1. ニューラルネットワークの場合と同じように、初期値が同一値であると協調動作が起こらない。商品特性 `x` とユーザ特性 `θ` のランダムな極小値で初期化する _(Symmetry breaking)_
2. 勾配法により、最小コストとなる商品特性 `x` とユーザ特性 `θ` を見つける。
3. `θ(j)^T * x(i)` により、商品 `i` に対してユーザ `j` が下す評価（の予測）が得られる。

予測した評価の高いものが、ユーザにとって有意義な商品であろうと言える。さらに得られた特性から、各要素間の類似度も予測することができる。

* 任意の二つの商品 `x` の間の距離 `||x(i) - x(j)||` が小さいほど似ている商品と予測できる。
* 任意の二つのユーザ `θ` の間の距離 `||θ(i) - θ(j)||`  が小さいほど似ているユーザと予測できる。

## Low Rank Matrix Factorization

「商品数 x ユーザ数」のサイズの、ユーザ評価の行列 `Y` を考えてみる。各要素は予測評価値は `θ^T * x` に置き換えて考えてみると、行列 `Y` は

* 商品特性の行列 `X`
* ユーザ特性の行列 `Θ`

の二つの行列の積 `X * Θ^T` である。すなわち、行列 `Y` から全商品特性と全ユーザ特性の行列に分解できる。

<script type="math/tex; mode=display" id="MathJax-Element-low_rank_matrix_factorization">
X = \begin{bmatrix}
(x^{(1)})^{T} \\
\vdots\\
(x^{(n_{m})})^{T} \\
\end{bmatrix},
\Theta = \begin{bmatrix}
(\theta^{(1)})^{T} \\
\vdots\\
(\theta^{(n_{u})})^{T} \\
\end{bmatrix} \\

Y = X \Theta^{T} = \begin{bmatrix}
(\theta^{(1)})^{T}(x^{(1)}) & \ldots & (\theta^{(n_{u})})^{T}(x^{(1)}) \\
\vdots & \ddots & \vdots \\
(\theta^{(1)})^{T}(x^{(n_{m})}) & \ldots & (\theta^{(n_{u})})^{T}(x^{(n_{m})}) \\
\end{bmatrix} \\
</script>

このことから、行列 `Y` に対して、特異値分解 _SVD_ を行なうと、以下のように捉える事ができる。

* `U` は出力の基底となる正規直交ベクトル = ユーザ
* `S` は特異値を対角に持つ行列 = ユーザと商品の関連（例：日用品に対するユーザの趣向 / 商品が日用品である傾向）
* `V` は入力の基底となる正規直交ベクトル = 商品

特異値の対角行列 `S` は、ユーザと商品を結びつけるために、どのような係数があるのかということを示しており、主成分分析 _PCA_ での次元圧縮に見られるように削減可能である。人間が見てどのようなものか判別することはわからないが、何かしらの関連があることを表している。

このことをふまえると、商品に対するユーザの予測評価を得る他に

* 任意の二つの商品特性 `x` の間の距離 `||x(i) - x(j)||` が小さいほど似ている商品
* 任意の二つのユーザ特性 `θ` の間の距離 `||θ(i) - θ(j)||`  が小さいほど似ているユーザ

と予測することもできる。

こう考えると、協調フィルタリングを用いずとも特異値分解で事足りるように思えるが、欠損値（評価のなしの要素）に対してうまく機能しない。ユーザ評価を例にすると、ユーザがすべての商品に対して評価を与えていることはなく、欠損値がほとんどになる。数学的に言い換えると、ユーザ評価の行列 `Y` の階数は低い（低ランク行列）傾向にある。

特異値分解に対し、低ランク行列に対しても機能する _(Low rank) Matrix Factorization = MF_ という手法は、本質的には協調フィルタリングと同じことを行なっている。

