---
layout: page

title: Linear Regression
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Cost Function

* `x` から `y` を導く `m` 個の学習データがあるとする。例) x: 部屋の広さ, y: 家賃
* `y` を予測する関数を `h(x) = a + b * x` とする。
* `h(x) - y` すなわち `(a + b * x) - y` が予測との誤差になる。

各データ毎の誤差の二乗したものの総和を、「二乗誤差」 _Squared error_ と呼ぶ。この値が小さい程、予測との誤差が少ないことになる。この誤差を元に、コスト関数 _Cost Function_ を定義して、最適値を見つけていく。

例として、以下のコスト関数 `J(a, b)` を定義し、学習データ `x = [1; 2; 3], y = [2; 4; 6]` を適用してみる。

<script type="math/tex; mode=display" id="MathJax-Element-hypothesis">
h(x) = a + bx
</script>
<script type="math/tex; mode=display" id="MathJax-Element-mse">
J(a, b) = \frac{1}{2m} {\sum_{i=1}^{m} (h(x^{(i)})-y^{(i)})^2}
</script>
<script type="math/tex; mode=display" id="MathJax-Element-cost_function1">
J(1, 1) = \frac{(2 - 2)^2 + (3 - 4)^2 + (4 - 6)^2}{2 \cdot 3} = 0.83333 \ldots
</script>
<script type="math/tex; mode=display" id="MathJax-Element-cost_function2">
J(0, 2) = \frac{(2 - 2)^2 + (4 - 4)^2 + (6 - 6)^2}{2 \cdot 3} = 0
</script>

`a = 0, b = 2` の時にコストが最小となり、`h(x) = 2 * x` が最適式であることが分かる。この手法を線形回帰 _Linear regression_ と呼ぶ。

この学習データ内では `J(0, 2) = 0` で誤差はないが、今後のあらゆるケースで、誤差なく予測できるわけではない。あくまで学習データ内で誤差がないというだけである。言い替えると、学習データに関しては、誤差なく予測することができる。

* 学習データに含まれない `x = 4` が、必ず `y = h(x) = 2 * 4 = 8` という結果になるわけではない。
* 今後の入力データが、学習データに含まれる `x = 2` であったとしても、必ず `y = h(x) = 2 * 2 = 4` という結果になるわけではない。

## Gradient Decent

ニュートン法 _Newton's method_ により平方根を見つける例をおさらいしてみる。

`x` を平方根、`a` をその二乗としたとき

<script type="math/tex; mode=display" id="MathJax-Element-newtons_method_f">
f(x) = x^2 - a
</script>

を定義する。この関数を `y` 軸においたグラフにおいて、`x` 軸との交点 `(x, f(x) = 0)` の `x` が平方根になる。

この関数を微分した時の導関数 `f'(x)` は、微分の公式

<script type="math/tex; mode=display" id="MathJax-Element-newtons_method_calcu_df_formula">
(x^n)' = nx^{n-1} \\
</script>

より

<script type="math/tex; mode=display" id="MathJax-Element-newtons_method_fd">
f'(x) = (f(x))' = (x^2 - a)' = 2x
</script>

であるので、任意の `(x(i), f(x(i)))` を接点とする接線の傾きは、`f'(x(i)) = 2x(i)` であることがわかる。

直線の方程式は _「底辺 x = 高さ y / 傾き m」_ であるので、この接線の `x` 軸との交点を `x(i+1)` とすると

<script type="math/tex; mode=display" id="MathJax-Element-newtons_method_fd_line">
x_{i+1} = x_{i} - \frac{f(x_{i})}{f'(x_{i})} = x_{i} - \frac{x_{i}^2 - a}{2x_{i}}
</script>

で求められる。この式を繰り返すことで、`x(i)` と `x(i+1)` が限りなく近づき、`x(i)` は `(x, f(x) = 0)` すなわち平方根に収束する。

{% highlight octave %}
octave> x = 1;  % find out sqrt(3) by Newton's Method
octave> x = x - (x^2 - 3) / (2*x)
x =  2
octave> x = x - (x^2 - 3) / (2*x)
x =  1.7500
octave> x = x - (x^2 - 3) / (2*x)
x =  1.7321
octave> x = x - (x^2 - 3) / (2*x)
x =  1.7321
{% endhighlight %}

コスト関数が最小となる式を見つける場合も、微分をとって少しづつ進めていく反復を繰り返し、最適値に収束させていけばよい。方法として、最急降下法 _Gradient descent (Steepest descent method)_ がある。

コスト関数を `J(θ)` とし、そのパラメータを `θ = [θ1; θ2]` とした時、`(θ1, θ2, J(θ))` の三次元グラフを書くと、`J(θ)` 軸で凹凸をもったグラフとなる。すなわち、この凹みの最も深い位置が、最も誤差の少ない最適値になる。

最急降下法では、以下の式でコスト関数のパラメータの更新を繰り返し、最適値に収束させる。

<script type="math/tex; mode=display" id="MathJax-Element-gradient_descent">
J(\theta) = \frac{1}{2m} {\sum_{i=1}^{m} (h_{\theta}(x^{(i)})-y^{(i)})^2} \\
\theta_0 := \theta_0 - \alpha \left( {\partial J(\theta) \over \partial \theta_0} \right) \\
\theta_1 := \theta_1 - \alpha \left( {\partial J(\theta) \over \partial \theta_1} \right) \\
\theta_2 := \theta_2 - \alpha \left( {\partial J(\theta) \over \partial \theta_2} \right) \\
\vdots \\
\theta_n := \theta_n - \alpha \left( {\partial J(\theta) \over \partial \theta_n} \right) \\
</script>

* `θ` は、コスト関数 `J(θ)` のパラメータのベクトル
* パラメータ `θ1, θ2, ...` 毎に、コスト関数 `J(θ)` でのパラメータ自身の偏微分を減らすことで、勾配を下って行く。
* `α` は、どれだけ進むかの割合 _Learning rate_ で、正の数（主に定数）をとる。
* この式を反復して、パラメータ `θ` を更新していく。勾配を下って凹みに向かって収束していくため、`α` が大きすぎなければ `J(θ)` は必ず小さくなる。

いかなる条件であっても、必ず最適値を見つけられるわけではない。

* 複数の凹みがある場合、降下を始めた地点からたどり着く「局所的な最小値」 _Local minimum_ になる。必ずしも「全域の最小値」 _Global minimum_ ではない。
* `α` の値は、固定であっても、勾配を進む割合が一定というわけではない。
* `α` の値は、小さすぎると収束 _Converge_ するまでに時間がかかりすぎてしまう。大きすぎると最小値を通り過ぎて、勾配を上ってしまうことになり、反復するほどに悪い解へと向かう発散 _Diverge_ を引き起こす場合もある。

学習データ `x = [1; 2; 3]; y = [2; 4; 6]` の式 `hθ(x) = θ0 + θ1 * x` を、最急降下法で求めてみる。

入力データ `x` より、先頭列に固定値 `1` を置いた行列 `X` を作成する。

{% highlight octave %}
octave> x = [1; 2; 3];
octave> X = [ones(3, 1), x]
X =

   1   1
   1   2
   1   3

{% endhighlight %}

パラメータ `θ` 用に、ベクトル `theta` を作成する。`X(:,1) = 1` としておいたことで、行列の積 `X * theta` のみで、各入力の `hθ(x) = θ0 + θ1 * x` の解が得られることが分かる。パラメータが増えた時は、`X` の各列と `theta` に追加するだけで良い。

<script type="math/tex; mode=display" id="MathJax-Element-gradient_descent_hypothesis">
x_{0} = 1 \\
h_{\theta}(x) = \theta^T x = \theta_{0}x_{0} + \theta_{1}x_{1} + \ldots + \theta_{n}x_n
</script>

{% highlight octave %}
octave> theta = [2; 3];
octave> X * theta
ans =

    5
    8
   11

{% endhighlight %}

最急降下法により、最適値に収束するまで `theta` を更新していく。

<script type="math/tex; mode=display" id="MathJax-Element-gradient_descent_a">
\theta_{j} := \theta_{j} - \alpha \left( \frac{ \partial J(\theta)}{ \partial \theta_{j}} \right) \\
\frac{ \partial J(\theta)}{ \partial \theta_{j}} = \frac{1}{m} \sum_{i=1}^{m} (h_{\theta}(x^{(i)}) - y^{(i)}) x_{j}^{(i)} \\
</script>

`theta = [1; 1], alpha = 0.1` を初期値として反復していくと、`theta = [0; 2]` すなわち `h(x) = 2 * x` に収束していくことが分かる。　

{% highlight octave %}
octave> x = [1; 2; 3];
octave> y = [2; 4; 6];

octave> m = size(x, 1)          % number of rows
m = 3
octave> X = [ones(m, 1), x];    % input data with intercept term 1
octave> alpha = 0.1;            % learniing rate
octave> theta = [1; 1];         % parameters of hypothesis

octave> X * theta - y           % difference of each output
ans =

   0
  -1
  -2

octave> (X * theta - y)' * X    % difference of each output * each input parameter
ans =

  -3  -8

octave> theta = theta - (((X * theta - y)' * X) .* alpha / m)'
theta =

   1.1000
   1.2667

octave> theta = theta - (((X * theta - y)' * X) .* alpha / m)'
theta =

   1.1367
   1.3889

octave> for i = 1:410, theta = theta - (((X * theta - y)' * X) .* alpha / m)'; end
octave> theta
theta =

   0.0082757
   1.9963595

octave> theta = theta - (((X * theta - y)' * X) .* alpha / m)'
theta =

   0.0081763
   1.9964032

{% endhighlight %}

### Feature Normalization

各パラメータの変動範囲を統一することで、収束時間を短くすることができる。「(値 - 平均値) / 標準偏差」に正規化すると、概ね _-2 < x < 2_ の範囲に収まる。

{% highlight octave %}
octave> X = [45 452000; 24 285000; 53 524000; 35 389000];
octave> m = size(X, 1)
m =  4
octave> X = X - repmat(mean(X), m, 1)
X =

   5.7500e+00   3.9500e+04
  -1.5250e+01  -1.2750e+05
   1.3750e+01   1.1150e+05
  -4.2500e+00  -2.3500e+04

octave> X = X ./ repmat(std(X), m, 1)
X =

   0.45805   0.38983
  -1.21483  -1.25831
   1.09534   1.10041
  -0.33856  -0.23192

{% endhighlight %}

## Normal Equations

最急降下法を用いずに、連立方程式で解を得る方法もある。連立方程式は以下のように行列で表すことができる。

<script type="math/tex; mode=display" id="MathJax-Element-normaleq">
\left\{
  \begin{array}{l l}
ax + by = p \\
cx + dy = q \\
  \end{array}

\quad

\begin{bmatrix}
a & b \\
c & d \\
\end{bmatrix}
\begin{bmatrix}
x \\
y \\
\end{bmatrix}
=
\begin{bmatrix}
p \\
q \\
\end{bmatrix} \\

\begin{bmatrix}
x \\
y \\
\end{bmatrix}
=
\begin{bmatrix}
a & b \\
c & d \\
\end{bmatrix}^{-1}
\begin{bmatrix}
p \\
q \\
\end{bmatrix} \\

\right.
</script>

おなじ要領で、学習データの行列を用いて、連立方程式を解けばよい。

<script type="math/tex; mode=display" id="MathJax-Element-normaleq_matrices">
\theta =
\begin{bmatrix}
\theta_1 \\
\theta_2 \\
\vdots \\
\theta_{m} \\
\end{bmatrix}
,

X =
\begin{bmatrix}
x_{1,1} & x_{1,2} & \ldots & x_{1,n} \\
x_{2,1} & x_{2,2} & \ldots & x_{2,n} \\
\vdots & \vdots & \ddots & \vdots \\
x_{m,1} & x_{m,2} & \ldots & x_{m,n} \\
\end{bmatrix}
,
y =
\begin{bmatrix}
y_1 \\
y_2 \\
\vdots \\
y_{m} \\
\end{bmatrix}
</script>

公式は `X^-1 * y` になるが、逆行列 `X^-1` を求めるには `m = n` の正方行列 _Square matrix_ である必要がある。正方行列でない場合は、疑似逆行列 _Pseudo-inverse matrix_ `(X^T * X)^-1 * X^T` を用いる。疑似逆行列の計算には、_O(n^3)_ のコストがかかってしまうので、パラメータ数が多い場合は最急降下法を使う。

<script type="math/tex; mode=display" id="MathJax-Element-normaleq_matrices_formula">
\begin{align}
\theta & = X^{-1} y\\
\theta & = (X^T X)^{-1} X^T y \\
\end{align}
</script>

{% highlight octave %}
octave> X = [1 1; 1 2; 1 3];
octave> y = [2; 4; 6];

octave> inv(X)
error: inverse: argument must be a square matrix

octave> inv(X' * X) * X'      % pseudo-inverse matrix: [1.3333 0.3333 -0.6666; -0.5 0 0.5]
ans =

   1.3333e+00   3.3333e-01  -6.6667e-01
  -5.0000e-01  -2.2204e-16   5.0000e-01

octave> pinv(X)               % using pinv(x)
ans =

   1.3333e+00   3.3333e-01  -6.6667e-01
  -5.0000e-01  -4.8572e-16   5.0000e-01

octave> inv(X' * X) * X' * X  % identity matrix: [1 0; 0 1]
ans =

   1.0000e+00  -5.3291e-15
  -6.6613e-16   1.0000e+00

octave> inv(X' * X) * X' * y  % solution: [0; 2]
ans =

  -1.0658e-14
   2.0000e+00

{% endhighlight %}

### Non-invertible Matrix

行列が非可逆行列 _Non-invertible matrix (singular/degenerate)_ である場合、解が存在しない（平行グラフである）か、式が重複している（同グラフである）ため、式を満たすあらゆる解が存在する。

<script type="math/tex; mode=display" id="MathJax-Element-normaleq_noninvertible">
\left\{
  \begin{array}{l l}
6x + 2y & = 4 & \cdots y = 2 - 3x \\
3x +  y & = 1 & \cdots y = 1 - 3x \\
  \end{array}
\right.

\\

\left\{
  \begin{array}{l l}
6x + 2y & = 2 & \cdots y = 1 - 3x \\
3x +  y & = 1 & \cdots y = 1 - 3x \\
  \end{array}
\right. \\
</script>

このように非可逆行列になるケースは以下がある。これらは、重複するパラメータを減らすことで解決できる。

* `X = [1 2 4; 2 4 8; 3 6 12]` のように、単に各パラメータが一定率で変化している場合
* 学習データ数 `m` が、パラメータ数 `n` より少ない場合

{% highlight octave %}
octave> X = [6 2; 3 1];
octave> inv(X)
warning: inverse: matrix singular to machine precision, rcond = 0
ans =

   Inf   Inf
   Inf   Inf

octave> X = [1 10 8; 1 23 -8];
octave> inv(X' * X) * X'
warning: inverse: matrix singular to machine precision, rcond = 5.26926e-19
ans =

   0.000000   0.000000
   0.039062   0.039062
   0.078125  -0.031250

{% endhighlight %}

