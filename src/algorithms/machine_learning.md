---
layout: page

title: Machine Learning
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Definition

Arthur Samuel (1959) - Machine Learning:

> Field of study that gives computers the ability to learn without being explicitly programmed.

Tom Mitchell (1998) - Well-posed Learning:

> A computer program is said to learn from experience E with respect to some task T
and some performance measure P, if its performance on T, as measured by P, improves with experience E.

スパムメール判定

* E(xperience): メールをスパムとして振り分ける
* T(ask): メールをスパムとして分類する
* P(erformance): 振り分けたメールがスパムである確率

対戦ゲーム

* E(xperience): ゲームをする（次の手を決める）
* T(ask): ゲームに勝つ
* P(erformance): ゲームに勝つ確率

### Classification Problem vs. Regression Problem

_Classification Problem_ は、`(YES|NO)` や `(A|B|C)` のように区分された値 _Discrete-value_ に分類する問題を指す。

* 過去の対戦成績から、勝敗を予測する
* オーディオデータから、ボーカル曲かどうかを判定する
* 腫瘍の大きさから、良性か悪性かを予測する

_Regression Problem_ は、連続値 _Continuous-value_ すなわち、量を求める問題を指す。数は整数値として考えれば、区切られているように感じてしまうが、単に取引上の単位であって、実際には境界のない連続値である。

* 部屋の大きさから、家賃を予測する
* 過去の雨量データから、降水量を予測する
* 過去実績から、売上げを予測する

### Supervised Learning vs. Unsupervised Learning

_Supervised Learning_ は、予め正解（分類）が分かっていて、その分類に振り分ける手法になる。

* 真偽 / 勝敗 / 可否
* 性別
* ラベル（重要|通常|スパム）

_Unupervised Learning_ は、正解（分類）自体が定義されていない状態から、分類を抽出していく手法になる。

* 記事内容から、同種の記事を見つける（記事のカテゴリは不定）
* 行動パターンから、似ているユーザ同士を見つける（どのようなユーザかは不定）
* 投薬結果から、同症状を引き起こす患者同士を見つける（どのような副作用を起こすかは不定）

## Linear Regression

### Cost Function

* `x` から `y` を導く `m` 個の訓練データ _Training Set_ があるとする。例) x: 部屋の広さ, y: 家賃
* `y` を予測する関数を `h(x) = a + b * x` とする。
* `h(x) - y` すなわち `(a + b * x) - y` が予測との誤差になる。

各データ毎の誤差の二乗したものの総和を、「二乗誤差」 _Squared Error_ と呼ぶ。この値が小さい程、予測との誤差が少ないことになる。この値を元に、費用関数 _Cost Function_ を定義して、最適値を見つけていく。

例として、以下の費用関数 `J(a, b)` を定義し、訓練データ `x = [1; 2; 3], y = [2; 4; 6]` を適用してみる。

<script type="math/tex; mode=display" id="MathJax-Element-hypothesis">
h(x) = a + bx
</script>
<script type="math/tex; mode=display" id="MathJax-Element-mse">
J(a, b) = \frac{1}{2m} {\sum_{i=1}^{m} (h(x_i)-y_i)^2}
</script>
<script type="math/tex; mode=display" id="MathJax-Element-cost_function1">
J(1, 1) = \frac{(2 - 2)^2 + (3 - 4)^2 + (4 - 6)^2}{2 \cdot 3} = 0.83333 \ldots
</script>
<script type="math/tex; mode=display" id="MathJax-Element-cost_function2">
J(0, 2) = \frac{(2 - 2)^2 + (4 - 4)^2 + (6 - 6)^2}{2 \cdot 3} = 0
</script>

`a = 0, b = 2` すなわち `h(x) = 2 * x` が、最適な線形回帰モデル _Linear Regression Model_ になる。

この訓練データ内では誤差はないが、今後のあらゆるケースで、誤差なく予測できるわけではない。あくまで訓練データ内で誤差がないというだけである。言い替えると、訓練データに関しては、誤差なく予測することができる。

* 訓練データに含まれない `x = 4` が、必ず `y = h(x) = 2 * 4 = 8` という結果になるわけではない。
* 今後の入力データが、訓練データに含まれる `x = 2` であったとしても、必ず `y = h(x) = 2 * 2 = 4` という結果になるわけではない。

### Gradient Decent

線形回帰モデルを見つけるには、勾配法 _Gradient decent_ を用いることができる。

勾配法は、反復法を用いて解に近づけていく。反復法の一つ、ニュートン法 _Newton's method_ により平方根を見つける例をおさらいしてみる。

`x` を平方根、`a` をその二乗としたとき

<script type="math/tex; mode=display" id="MathJax-Element-newtons_method_f">
f(x) = x^2 - a
</script>

を定義する。この関数を `y` 軸においたグラフにおいて、`x` 軸との交点 `(x, f(x) = 0)` の `x` が平方根になる。

この関数を微分した時の導関数 `f'(x)` は

<script type="math/tex; mode=display" id="MathJax-Element-newtons_method_fd">
(x^n + C)' = nx^{n-1} \\
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

線形回帰モデルの場合にも、同じような反復を繰り返して、最適値に収束させていけばよい。方法として、最急降下法 _Steepest descent method_ がある。

仮説を `h(x) = a + b * x` とし、費用関数を `J(a, b)` とした時、`(a, b, J(a, b))` の三次元グラフを書くと、`J(a, b)` 軸で凹凸をもったグラフとなる。すなわち、この凹みの最も深い位置が、最も誤差の少ない最適値になる。

最急降下法では、以下の式で最適値を目指して勾配を下っていく。

<script type="math/tex; mode=display" id="MathJax-Element-gradient_descent">
X_i := X_i - \alpha \left( {\partial f(X) \over \partial X_i} \right)
</script>

* `X` は n 次元のベクトル
* `α` は、どれだけ進むかの割合 _Learning rate_ で、正の数（主に定数）をとる。
* 偏微分の項 _Derivative term_ である `df(X) / dX(i)` は、費用関数 `f(X)` の最も変化の大きい方向に勾配ベクトルを向ける。
* この式を反復して `X` を更新していく。勾配を下って凹みに向かって収束していくため、`α` が大きすぎなければ `f(X)` は必ず小さくなる。

いかなる条件であっても、必ず最適値を見つけられるわけではない。

* 複数の凹みがある場合、降下を始めた地点からたどり着く「局所的な最小値」 _Local minimum_ になる。必ずしも「全域の最小値」 _Global minimum_ ではない。
* `α` の値は、固定であっても、勾配を進む割合が一定というわけではない。
* `α` の値は、小さすぎると収束 _Converge_ するまでに時間がかかりすぎてしまう。大きすぎると最小値を通り過ぎて、勾配を上ってしまうことになり、反復するほどに悪い解へと向かう発散 _Diverge_ を引き起こす場合もある。

訓練データ `x = [1; 2; 3]; y = [2; 4; 6]` の仮説 `h(x) = a + b * x` を、最急降下法で求めてみる。

入力データ `x` より、先頭列に固定値 `1` を置いた行列 `X` を作成する。

{% highlight octave %}
octave> x = [1; 2; 3];
octave> X = [ones(3, 1), x]
X =

   1   1
   1   2
   1   3

{% endhighlight %}

`h(x) = a + b * x` のパラメータ `a, b` 用に、ベクトル `theta` を作成する。`X(:,1) = 1` としておいたことで、行列の積 `X * theta` のみで、各入力データ行の `h(x)` が得られることが分かる。パラメータが増えた時は、`X` の各列と `theta` に追加するだけで良い。

<script type="math/tex; mode=display" id="MathJax-Element-gradient_descent_hypothesis">
x_{0} = 1 \\
h(x) = \theta^T x = \theta_{0}x_{0} + \theta_{1}x_{1} + \ldots + \theta_{n}x_n
</script>

{% highlight octave %}
octave> theta = [2; 3];
octave> X * theta
ans =

    5
    8
   11

{% endhighlight %}

偏微分の項を 「全データの誤差の総和 x 各パラメータ入力 / データ数」として、仮説の全パラメータに対して、同時に最急降下法を行なっていく。

<script type="math/tex; mode=display" id="MathJax-Element-gradient_descent_a">
\theta_{j} := \theta_{j} - \alpha \left(\frac{1}{m} \sum_{i=1}^{m} (h(X_{i}) - y_{i}) \cdot X_{i,j} \right)
</script>

`theta = [1; 1], alpha = 0.1` として反復していくと、`theta = [0; 2]` すなわち `h(x) = 2 * x` に収束していくことが分かる。　

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

### Normal Equations

勾配法を用いずに、連立方程式で解を得る方法もある。

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
\end{bmatrix}
\right.
</script>
<script type="math/tex; mode=display" id="MathJax-Element-normaleq_matrices">
</script>

