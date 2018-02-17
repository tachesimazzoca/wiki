# Support Vector Machine

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## vs. Sigmoid Function

ロジスティック回帰により、二値に分類することができるが、その決定境界 _Decision boundary_ はシグモイド関数による一つの変曲点 `(0. 0.5)` になる。

変曲点が一つであることは、決定境界が必ずしも最適な結果にならないことも意味する。

* `x = [0 10; 0 -10], y = [1; 0]` という学習データを例にする。
* 直感では、決定境界は `(0, -N)..(0, N)` のような、y 軸に沿う直線が考えられる。
* ロジスティック回帰においては、正解値のマージンが少ない `(-10, -1)..(10, 1)` を通る決定境界を与えることもある。

これに対し、_SVM (Support Vector Machine)_ は、より最適なマージンをもつ決定境界を見つけようとする。目的関数はロジスティク回帰と似ており、`y = (0|1)` の値に応じてコスト算出アルゴリズムを切り替える。

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
* `θ` の二乗和を取っている項は、ロジスティック回帰でのペナルティ項のように思えるが、_SVM_ においては、役目が反対になる。すなわち `θ` の値を最小にすることが目的になる。

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

\| u \| = \sqrt{ u_1^{2} + u_2^{2} } = \sqrt{ 3^2 + 5^2 } = \sqrt{ 31 } = 5.5678
</script>

ベクトルの内積 _Vector inner product_ は、以下の公式がなりたつ。

<script type="math/tex; mode=display" id="MathJax-Element-vector_inner_product">
\vec{u} \cdot \vec{v} = u^{T}v = \| u \| \cdot \| v \| \cos \theta \\
</script>

すなわち、ベクトル `v` から、ベクトル `u` への射影 _Projection_ を `p` とすると

* ベクトル `v` の距離は、直角三角形の斜辺
* 射影 `p` の距離は、直角三角形の底辺 `||v|| cosθ`

である。

<script type="math/tex; mode=display" id="MathJax-Element-vector_projection">
\begin{align}
u^{T}v & = p \cdot \| u \| \\
u_1 v_1 + u_2 v_2  & = p \cdot \sqrt{u_1^{2} + u_2^{2}} \\
\end{align}
</script>

射影 `p` は、ベクトル `u, v` 間の角度が 90 度以上になると、負の値になる。

## Linear Decision Boundary

_SVM_ が、どのように決定境界のマージンを確保するかは、ベクトルの内積の公式からイメージできる。

簡略化のために、二次元に制限して `(θ1, θ2), (x1, x2)` 、線形の決定境界 _Linear decision boundary_ を持つケースで考えてみる。`θ^T x` を、ベクトルの内積 `u^T v` に置き換えると、目的関数内の `cost` 関数の条件を以下のように言い換えることができる。

<script type="math/tex; mode=display" id="MathJax-Element-svm_linear_kernel_cost">
\theta^{T} x = u^{T}v = p \cdot \| u \| \\
\left\{
  \begin{array}{l l}
  \text{cost}_1 ( p \cdot \| u \| ) & \ldots & p \cdot \| u \| \geq 1 & \text{if $y = 1$} \\
  \text{cost}_0 ( p \cdot \| u \| ) & \ldots & p \cdot \| u \| \leq -1 & \text{if $y = 0$} \\
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
& = \frac{1}{2} \| \theta \| ^{2} \\
\end{align}
</script>

つまり `θ` を最小化しつつ、`cost` 関数が 0 となる条件を満たすには、射影 `p` の長さが十分であることが必要で、このことは _SVM_ が、決定境界を正解値にフィットさせつつ、よりマージンを取ろうとすることに繋がる。

## Gaussian Kernel

二値間の類似度を計る関数を _Kernel (Similarity) function_ と呼ぶ。一つに、ガウス関数 _Gaussian Function (Kernel)_ がある。

<script type="math/tex; mode=display" id="MathJax-Element-svm_gaussian_function">
\text{similarity} (a, b) = K_{gaussian} (a, b) = \exp \left( - \frac{ \| a - b \|^{2} }{2 \sigma^{2}} \right) \\
</script>

* `| a - b |` が小さいほど（類似度が高いほど）1
* `| a - b |` が大きいほど（類似度が低いほど）0
* `σ` により、類似度の曖昧さを調整する。この値を増やすほど勾配（類似度への感度）がなだらかになり、減らすほど勾配が急激になる。

## Non-linear Decision Boundary

決定境界が直線でない場合、一般式に高次の多項式のパラメータを取る方法があるが、どのような項を追加すればよいかということは直感的に判断が難しい。また画像ピクセルのように入力が多すぎる場合、計算量も高くつく。

学習データの入力に対して、多項式のパラメータを取るのではなく、いったん学習データ間の類似度データに変換し、それに対して線形パラメータを取る方法がある。

<script type="math/tex; mode=display" id="MathJax-Element-svm_similarity">
\begin{array}{l l}
x \in \mathbb{R}^{m} & {\scriptsize \text{$m = $ number of examples}} \\
f \in \mathbb{R}^{m \times n} & {\scriptsize \text{$n = $ number of features $(n = m)$}} \\
\end{array} \\
f_{1}^{(i)} = \text{similarity} (x^{(i)}, x^{(1)}) \\
f_{2}^{(i)} = \text{similarity} (x^{(i)}, x^{(2)}) \\
\vdots \\
f_{n}^{(i)} = \text{similarity} (x^{(i)}, x^{(n)}) \\
h_{\theta}(f) = \theta^{T} f = \theta_0 + \theta_1 f_1 + \theta_2 f_2 + \ldots + \theta_{n} f_n \\
</script>

* 学習データの入力 `x` を交差させた類似度を持つデータ `f` を作成する。
* 類似度データ `f` のパラメータ数 `n` は、学習データ数 `m` に等しく、大きさ `m` の正方行列になる。

_SVM_ においても、類似度データからコストを取れば、非線形の決定境界 _Non-linear decison boundary_ に対してもマージンを調整できる。_Kernel function_ にガウス関数を用いると以下のようになる。

<script type="math/tex; mode=display" id="MathJax-Element-svm_non_linear_boundary">
f_{j}^{(i)} = \text{similarity} (x(i), x(j)) = \exp \left( - \frac{ \| x^{(i)} - x^{(j)} \|^{2} }{2 \sigma^{2}} \right) = \exp \left( - \frac{ \sum_{k = 1}^{n} ( x_k^{(i)} - x_k^{(j)} )^{2} }{2 \sigma^{2}} \right) \\
\min_{\theta} C \sum_{i = 1}^{m} \begin{bmatrix}
  y^{(i)} \text{cost}_{1}(\theta^{T} f^{(i)}) + (1 - y^{(i)}) \text{cost}_{0}(\theta^{T} f^{(i)})
\end{bmatrix} + \frac{1}{2} \sum_{j = 1}^{n} \theta_{j}^{2}  \\
</script>

* 類似度データ `f` に変換する前に、学習データの入力 `x` は _Feature scaling_ を行なっておく必要がある。
* 目的関数は、学習データの入力 `x` からではなく、類似度データ `f` から取る。
* パラメータ数 `n` は、学習データ数 `m` に等しい `n = m`
* `C` と `σ` の役目は反対になる。
    * Increase `C`: 予測誤差に対する感度を上げ、マージンを許容しない。 _Low bias / High variance_
    * Decrease `C`: 予測誤差に対する感度を下げ、マージンを許容する。 _High bias / Low variance_
    * Increase `σ`: 類似度に対する感度を下げ、マージンを許容する。 _High bias / Low variance_
    * Decrease `σ`: 類似度に対する感度を上げ、マージンを許容しない。 _Low bias / High variance_

## vs. Logistic Regression / Neural Network

_Kernel_ を用いた _SVM_ が万能のように思えるが、必ずしもそうではない。

* パラメータ数 `n` が十分に得られている（i.e. 学習データ数よりも大きい）なら、ロジスティック回帰か、_Kernel_ なしの _SVM_ を用いればよく、あえて _Kernel function_ を介す必要はない。
* パラメータ数 `n` が少ないのであれば、_Kernel_ を用いた _SVM_ を用いることを検討できるが、類似データ作成の処理時間は学習データ数 `m` に対して _O(N^2)_ で増加し、一般式のパラメータ数も `m` になる。これらがインパクトを与える場合には選択できない。この場合は、パラメータ数 `n` を増やして、ロジスティック回帰か、_Kernel_ なしの _SVM_ を用いる。
* ニューラルネットワークは、複雑なケースにもうまくフィットするが、学習処理においては、各ユニットへ伝播を繰り返すため、総じて時間がかかる。画像認識 / 音声認識など入力ソースからパラメータを見つけることが直感的に捉えづらい場合には、潤沢なリソースをかけて学習させる価値はあるが、テキスト/数値データなどの単純な入力に際しては、最初に選択すべきではない。
