# Logistic Regression

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript" async
  src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS_HTML">
</script>

## Sigmoid Function

_Classification problem_ において、`(0|1)` の二つの値 _Binomial_ に分類することを考えてみる。

仮説 `h(x)` の範囲を `0 < h(x) < 1` に制限し、境界値 `0.5` を境に `(0|1)` に分類すればよい。シグモイド関数 _Sigmoid (Logistic) function_ により、`(0, 0.5)` に変曲点をもち `(-Inf, Inf) -> (0, 1)` となる関数を実現できる。

<script type="math/tex; mode=display" id="MathJax-Element-sigmoid">
g(z) = \frac{1}{1 + e^{-z}} \\
\lim_{z \to \infty} g(z) = 1 \\
\lim_{z \to -{\infty}} g(z) = 0 \\
</script>

* `z = 0` のときに `1/(1+exp(0)) = 1/(1+1) = 0.5` となる。
* `z >= 0` の場合、分母が指数的に減少し、`1` に限りなく近づく。
* `z < 0` の場合、分母が指数的に増加し、`0` に限りなく近づく。

学習データ入力のベクトルを `x` とし、パラメータを `θ` とすると、`h(x)` は以下のようになる。

<script type="math/tex; mode=display" id="MathJax-Element-sigimoid_hypothesis">
h_{\theta}(x) = g({\theta}_0 + {\theta}_1 x_1 + {\theta}_2 x_2 + ...) \\
h_{\theta}(x) = g({\theta}^T x) = \frac{1}{1 + e^{- { {\theta}^T x } } } \\
</script>

この `h(x)` の最適式を見つけることを、ロジスティック回帰 _Logistic regression_ と呼ぶ。

結果値を `y` とした時、`h(x)` は `y = 1` になる確率であると解釈できる。`y = (1|0)` となる確率を `P(y = 1), P(y = 0)` とした時、`P(y = 1) + P(y = 0) = 1` が成り立つ。

<script type="math/tex; mode=display" id="MathJax-Element-sigmoid_probability">
P(y = 1) + P(y = 0) = 1 \\
h_{\theta}(x) = P(y = 1) = 0.5 \ldots P(y = 0) = 1 - 0.5 = 0.5 \\
h_{\theta}(x) = P(y = 1) = 0.3 \ldots P(y = 0) = 1 - 0.3 = 0.7 \\
</script>

## Cost Function

ロジスティック回帰の場合も、線形回帰と同様にコスト関数を定義し、最急降下法で最適値に収束させれば良い。

ロジスティック回帰での誤差は

* `h(x)` が、期待値 `(0|1)` に近づくほどに `0`
* `h(x)` が、期待値 `(0|1)` から離れるほどに無限大

となればよい。

`(-log(1), -log(0)) = (0, Inf)` であることを利用して、誤差の算出方法を以下のように定義できる。

<script type="math/tex; mode=display" id="MathJax-Element-logistic_function_error_def">
\left\{
  \begin{array}{l l}
  -log(h_{\theta}(x))     & \text{if $y = 1$} \\
  -log(1 - h_{\theta}(x)) & \text{if $y = 0$} \\
  \end{array} \\
\right.
</script>

`y = (0|1)` で式が異なるので、コスト関数は `y` の値によって打ち消す係数 `y, 1-y` をかければよい。最急降下法での偏微分の項は線形回帰と違いはない。

<script type="math/tex; mode=display" id="MathJax-Element-logistic_function_cost">
J(\theta) = \frac{1}{m} {\sum_{i=1}^{m} [ -log(h_{\theta}(x^{(i)}))(y^{(i)}) - log(1 - h_{\theta}(x^{(i)})) (1 - y^{(i)}) ] } \\
\theta_{j} := \theta_{j} - \alpha \left( \frac{\partial}{\partial \theta_{j}} J(\theta) \right) \\
{\partial J(\theta) \over \partial \theta_{j}} = \frac{1}{m} {\sum_{i=1}^{m} (h_{\theta}(x^{(i)}) - y^{(i)})x_{j}^{(i)} } \\
</script>

## Decision Boundary

シグモイド関数を `g(z)` とした時、学習データの入力 `(x1, x2)` を二次元グラフにプロットすると、`z = 0` を境界線として、`y = (1|0)` の領域で区分される。

### Linear Decision Boundary

`z = -2 + x1 + x2` の線形の仮説を例にすると、`z = 0` すなわち `x1 + x2 = 2` を満たす直線が境界線になることが分かる。

<script type="math/tex; mode=display" id="MathJax-Element-decision_boundary_linear">
\theta = \begin{bmatrix}
  -2 \\
  1 \\
  1 \\
\end{bmatrix} \\
h_{\theta}(x) = g(-2 + {\theta}_1 x_1 + {\theta}_2 x_2) \\
z = -2 + x_1 + x_2 = 0 \\
\begin{array}{l l}
y = 1 & x_1 + x_2 > 2 & (0, 3), (1, 2), (2, 1), \ldots \\
y = 0.5 & x_1 + x_2 = 2 & (0, 2), (1, 1), (2, 0), \ldots \\
y = 0 & x_1 + x_2 < 2 & (0, 1), (1, 0) \ldots \\
\end{array}
</script>

直線なので、プロットするには両端の `(x1, x2)` を求めるだけでよい。`x1` に対する `x2` は以下で求められる。

<script type="math/tex; mode=display" id="MathJax-Element-decision_boundary_linear_plotting">
\begin{align}
{\theta}_0 + {\theta}_1 x_1 + {\theta}_1 x_2 & = 0 \\
x_2 & = -{ \frac{1}{ {\theta}_2 } } ( {\theta}_0 + {\theta}_1 x_1 ) \\
\end{align}
</script>

```octave
octave> theta = [-2; 1; 1];
octave> x1 = [0 2];
octave> x2 = (-1 ./ theta(3)) .* (theta(2) .* x1 + theta(1));
octave> plot(x1, x2);
```

### Non-linear Decision Boundary

多項式 _Polynomial_ の場合、`z = -1 + x1^2 + x2^2` を例にすると、`x1^2 + x^2 = 1` を満たす曲線（この場合円形）が境界線になることがわかる。

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

二次元グラフに境界線をプロットするには、`(x1, x2, z)` の `z` 軸を等高線でプロットすればよい。

```octave
n = 50;
x1 = linspace(-2, 2, n);
x2 = linspace(-2, 2, n);
z = zeros(n, n);
for i = 1:n
  for j = 1:n
    z(i, j) = -1 + x1(i).^2 + x2(j).^2
  end
end
contour(x1, x2, z', [0 0]);
```

## Multi-class Classification

３つ以上の複数の値に分類するには、分類ごとにロジスティック回帰を行い、それぞれの分類の回帰パラメータを保持しておく。

`1:4` の分類に振り分けるとして、学習データの正解値のベクトルが `y = [1; 2; 3; 2; 4; 1; 3]` の場合

* `y1 = [1; 0; 0; 0; 0; 1; 0]`
* `y2 = [0; 1; 0; 1; 0; 0; 0]`
* `y3 = [0; 0; 1; 0; 0; 0; 1]`
* `y4 = [0; 0; 0; 0; 1; 0; 0]`

のように各分類ごとに、`(0|1)` の正解に変換して、分類毎に回帰パラメータを抽出する。

予測する際に、`y1, y2, y3, y4` それぞれの分類の回帰パラメータ毎に計算を行ない、最も値が大きい（i.e. 最もフィットする）分類が、予測分類となる。

`costFunction.m`

```octave
function [J, grad] = costFunction(theta, X, y)
  [m, n] = size(X);

  % Apply sigmoid function
  z = X * theta;
  h = 1.0 ./ (1.0 + exp(-z));

  % Create another theta for penalty term
  t = theta;
  t(1) = 0;

  % The regularized cost
  J = sum(-y .* log(h) - (1 .- y) .* log(1 - h)) / m;
  J = J + (t' * t) / (2 * m);

  % The regularized gradient of the cost
  grad = ((h - y)' * X / m)';
  grad = grad + (t ./ m);
end
```

`main.m`

```octave
% Number of labels
%   1: short & skinny
%   2: short & fat
%   3: tall & skinny
%   4: tall & fat
N = 4;

% Training set
X = [1 160 45; 1 160 75; 1 180 63; 1 180 105];
y = [1; 2; 3; 4];

[m, n] = size(X);

% The parameters of each label: N x (n)
Fvec = zeros(N, n);

for c = 1:N
  [fvec] = fminunc(
      @(a)(costFunction(a, X, y == c)),
      zeros(n, 1),
      optimset('GradObj', 'on', 'MaxIter', 100));
  Fvec(c, :) = fvec(:);
end

% Examine new data
Data = [1 175 95; 1 176 62; 1 158 48; 1 163 78];
[p, actual] = max(Data * Fvec', [], 2);
actual % expected [4; 3; 1; 2];
```
