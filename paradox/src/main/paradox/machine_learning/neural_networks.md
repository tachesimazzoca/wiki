# Neural Networks

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Sigmoid Activation Function

入力とパラメータの内積を、シグモイド関数を通して `0 < a < 1` の範囲に変換するモデルを、 _Sigmoid (Logistic) activation function_ と呼ぶ。

<script type="math/tex; mode=display" id="MathJax-Element-logistic_unit">
g(z) = \frac{1}{1 + e^{-z} } \\
h_{\theta}(x) = g({\theta}^{T} x) \\
</script>

バイアス項 _Bias unit_ として、`x(0) = 1` で固定し、`theta(0)` をオフセット値とする。入力値 `x` を `(0|1)` に制限すると、`theta` の値に応じて AND / OR の論理回路を実現できる。

```octave
X = [0 0; 0 1; 1 0; 1 1];
X = [ones(length(X), 1), X];         % [1 0 0; 1 0 1; 1 1 0; 1 1 1]

theta1 = [-30; 20; 20];              % AND gate
z1 = X * theta1;                     % [-30; -10; -10; 10]
h1 = sigmoid(z1);                    % [0; 0; 0; 1]

theta2 = [-10; 20; 20];              % OR gate
z2 = X * theta2;                     % [-10; 10; 10; 30]
h2 = sigmoid(z2);                    % [0; 1; 1; 1]
```

## Forward Propagation

_Activation function_ を複数レイヤーに定義し、各レイヤーの出力を次のレイヤーへの入力とすることで、より複雑な論理回路を実現できる。このモデルは、神経回路のシミュレーションを元にしており、ニューラルネットワーク _Neural network_ と呼ばれる。

       L1    |    L2    |    L3    |    L4
    ------------------------------------------
        [+1]-+     [+1]-+     [+1]-+
             |          |          |
      [x(1)]-+->[a2(1)]-+->[a3(1)]-+->[a4(1)]-> h(x)
             |          |          |
      [x(2)]-+->[a2(2)]-+->[a3(2)]-+
             |          |
             +->[a2(3)]-+


<script type="math/tex; mode=display" id="MathJax-Element-neural_network_layer2">
\begin{align}
\text{Input} \quad & \left\{
  \begin{array}{l l}
    x_0 = 1 \\
    x_1 \in \mathbb{R} \\
    x_2 \in \mathbb{R} \\
  \end{array}
\right. \\

\text{Layer1} \quad & \left\{
  \begin{array}{l l}
    {\Theta}^{(1)} \in \mathbb{R}^{3 \times 3} \\
    a^{(2)}_0 = 1 \\
    a^{(2)}_{1} = g({ {\Theta}^{(1)}_{1,0} } x_0 + { {\Theta}^{(1)}_{1,1} } x_1 + { {\Theta}^{(1)}_{1,2} x_2 }) \\
    a^{(2)}_{2} = g({ {\Theta}^{(1)}_{2,0} } x_0 + { {\Theta}^{(1)}_{2,1} } x_1 + { {\Theta}^{(1)}_{2,2} x_2 }) \\
    a^{(2)}_{3} = g({ {\Theta}^{(1)}_{3,0} } x_0 + { {\Theta}^{(1)}_{3,1} } x_1 + { {\Theta}^{(1)}_{3,2} x_2 }) \\
  \end{array}
\right. \\

\text{Layer2} \quad & \left\{
  \begin{array}{l l}
    {\Theta}^{(2)} \in \mathbb{R}^{2 \times 4} \\
    a^{(3)}_0 = 1 \\
    a^{(3)}_{1} = g({\Theta}^{(2)}_{1,0} a^{(2)}_0 + {\Theta}^{(2)}_{1,1} a^{(2)}_1 + {\Theta}^{(2)}_{1,2} a^{(2)}_2 + {\Theta}^{(2)}_{1,3} a^{(2)}_3) \\
    a^{(3)}_{2} = g({\Theta}^{(2)}_{2,0} a^{(2)}_0 + {\Theta}^{(2)}_{2,1} a^{(2)}_1 + {\Theta}^{(2)}_{2,2} a^{(2)}_2 + {\Theta}^{(2)}_{2,3} a^{(2)}_3) \\
  \end{array}
\right. \\

\text{Layer3} \quad & \left\{
  \begin{array}{l l}
    {\Theta}^{(3)} \in \mathbb{R}^{1 \times 3} \\
    a^{(4)}_1 = g({\Theta}^{(3)}_{1,0} a^{(3)}_0 + {\Theta}^{(3)}_{1,1} a^{(3)}_1 + {\Theta}^{(3)}_{1,2} a^{(3)}_2) \\
    h_{\Theta}(x) = a^{(4)}_1 \\
  \end{array}
\right. \\

\end{align}
</script>

* 入力 `x` のバイアス項として `x(0) = 1` とする。
* Layer1: ３つの入力 `x` から、３つの出力 `a2` を算出する。バイアス項として `a2(0) = 1` とする。
* Layer2: Layer1 の４つの出力 `a2` を入力とし、２つの出力 `a3` を算出する。バイアス項として `a3(0) = 1` とする。
* Layer3: Layer2 の３つの出力 `a3` を入力とし、１つの出力 `a4` を算出する。
* 最終レイヤーの出力 `a4(1)` が、予測値 `h(x)` となる。

Layer2 の２入力に NAND / OR ゲート、Layer3 の１入力に AND ゲートを置くことで、XOR ゲートとして機能する。

```octave
Theta1 = [30 -20 -20; -10 20 20];    % [{NAND}; {OR}]
Theta2 = [-30 20 20];                % [{AND}]

X = [0 0; 0 1; 1 0; 1 1];
X = [ones(length(X), 1), X];         % [1 0 0; 1 0 1; 1 1 0; 1 1 1]

z1 = X * Theta1';                    % [30 -10; 10 10; 10 10; -10 30]
a2 = sigmoid(z1);                    % [1 0; 1 1; 1 1; 0 1]
a2 = [ones(length(a2), 1), a2];      % [1 1 0; 1 1 1; 1 1 1; 1 0 1]

z2 = a2 * Theta2';                   % [-10; 10; 10; -10]
a3 = sigmoid(z2);                    % [0; 1; 1; 0]
```

このように、複数レイヤーの入出力を介して、前方に伝播させていく方法を _Forward propagation_ と呼ぶ。

## Multi-class Classification

３つ以上に分類するには、出力レイヤーのユニットを、分類の数だけ用意すればよい。

       L1    |    L2    |    L3    |
    --------------------------------
        [+1]-+     [+1]-+
             |          |
      [x(1)]-+->[a2(1)]-+->[a3(1)]
             |          |
      [x(2)]-+->[a2(2)]-+->[a3(2)]
             |          |
             +->[a2(3)]-+->[a3(3)]
             |          |
             +->[a2(4)]-+

出力レイヤーのベクトルを `a3`、正解値を `y` としたとき、`a3(y)` のフラグが立つと考える。

* `y = 1 if a3 = [1; 0; 0]`
* `y = 2 if a3 = [0; 1; 0]`
* `y = 3 if a3 = [0; 0; 1]`

分類数を `K` とすると、コスト関数は各出力の誤差平均を求めればよい。

<script type="math/tex; mode=display" id="MathJax-Element-backprop_cost">
a = h_{\Theta}(x) \in \mathbb{R}^{K}\\
J(\Theta) = \frac{1}{m} {\sum_{i=1}^{m}} {\sum_{k=1}^{K}} [ -log(a_{k}^{(i)})(y_{k}^{(i)}) - log(1 - a_{k}^{(i)}) (1 - y_{k}^{(i)}) ] \\
</script>

## Cost Function

ニューラルネットワークのコスト関数は、ロジスティック回帰と同様であるが、予測値を求めるには _Forward propagation_ で各レイヤーを通して算出する必要がある。

```octave
Theta1 = [-30 10 10 10; -10 20 20 20; 20 -10 -10 -10; -20 10 10 10];
Theta2 = [10 -20 -20 -10 -10; -10 10 10 0 10; 20 -20 -20 -10 -10];
X = [0 0 0; 0 0 1; 0 1 0; 1 1 1];
m = size(X, 1);

a1 = X;                         % 4 x 3
a1 = [ones(m, 1) a1];           % 4 x 4
z2 = a1 * Theta1';              % 4 x 4
a2 = sigmoid(z2);
a2 = [ones(size(a2, 1), 1) a2]; % 4 x 5
z3 = a2 * Theta2';              % 4 x 3
h = sigmoid(z3);
```

_Regularization_ を行なう場合は、各レイヤーにパラメータがある点に注意する。バイアス項は除外する。

<script type="math/tex; mode=display" id="MathJax-Element-backprop_cost_reg">
J(\Theta) = J(\Theta) + \frac{\lambda}{2m} \sum_{l=1}^{L-1} \sum_{i=1}^{sl} \sum_{j=1}^{sl+1} ({\Theta}_{j,i}^{(l)})^2 \\
{\scriptsize \text{$L = $ the number of layers}} \\
{\scriptsize \text{$sl = $ the number of parameters of the layer $l$}} \\
</script>

```octave
t1 = Theta1;
t2 = Theta2;
t1(:, 1) = 0;
t2(:, 1) = 0;

lambda = 0.1;
J = J + (sum(sum(t1 .^ 2)) + sum(sum(t2 .^ 2))) * lambda / (2 * m);
```

## Sigmoid Gradient Function

ネイピア数 `e` を底とする指数の微分は `(e^x)' = e^x` であることを利用して、シグモイド関数 `g(z)` を微分すると `g'(z) = g(z) * (1 - g(z))` となる。

<script type="math/tex; mode=display" id="MathJax-Element-sigmoid_partial_simplify">
g(z) = \frac{1}{1 + e^{-z}} \\

\begin{align}

& \left\{
\begin{array}{l l}
x = -z \\
u = 1 + e^{x} \\
g'(u) = (u^{-1})' = -1 \cdot u^{-2} = -(1 + e^{-z})^{-2} \\
u' = (1 + e^{x})' = (e^{x})' = (e^{x})'(x)' = (e^{-z})'(-z)' = (e^{-z})(-1) = -e^{-z} \\
\end{array}
\right. \\

\end{align} \\

</script>
<script type="math/tex; mode=display" id="MathJax-Element-sigmoid_gradient">
\begin{align}
g'(z) & = g'(u) \cdot u' = -(1 + e^{-z})^{-2} \cdot -e^{-z}\\
      & = \frac{e^{-z}}{(1 + e^{-z})^2} \\
      & = \frac{1}{1 + e^{-z}} \left( \frac{1 + e^{-z}}{1 + e^{-z}} - \frac{1}{1 + e^{-z}} \right) \\
      & = \frac{1}{1 + e^{-z}} \left( 1 - \frac{1}{1 + e^{-z}} \right) \\
      & = g(z)(1 - g(z)) \\
g'(0) & = g(0)(1 - g(0)) = 0.5 \cdot 0.5 = 0.25 \\
\end{align} \\
</script>

## Backpropagation

ニューラルネットワークの各ユニットのパラメータ（ニューロンの重み）を求めるには、ロジスティック回帰と同様に最急降下法を用いる。各ユニットの偏微分を求めるためには、最終出力の誤差から各レイヤーを逆に伝播して算出する必要がある。この方法を、誤差逆伝播法 _Backpropagation_ と呼ぶ。

出力レイヤーの誤差は、予測値ベクトルから正解値ベクトルを引いたものになる。

<script type="math/tex; mode=display" id="MathJax-Element-backprop_error_output">
\delta^{(L)}_{k} = a^{(L)}_{k} - y_{k}\\
</script>

中間レイヤーの誤差は以下の式で求められる。各パラメータ自身が次のレイヤーに伝播させてしまった誤差を算出すると考えればよい。バイアス項は含めなくてよい。

<script type="math/tex; mode=display" id="MathJax-Element-backprop_error_hidden">
\delta^{(l)} = ({\Theta}^{(l)})^{T} \delta^{(l+1)} .* g'(z^{(l)}) \quad {\scriptsize \text{(Remove $\delta^{(l)}_0$)}} \\

\left\{
  \begin{array}{l l}
    \delta^{(l)}_1 = ({\Theta}^{(l)}_{1,1} \delta^{(l+1)}_{1} + {\Theta}^{(l)}_{2,1} \delta^{(l+1)}_{2} + {\Theta}^{(l)}_{3,1} \delta^{(l+1)}_{3} \ldots) \cdot g'(z^{(l)}_1) \\
    \delta^{(l)}_2 = ({\Theta}^{(l)}_{1,2} \delta^{(l+1)}_{1} + {\Theta}^{(l)}_{2,2} \delta^{(l+1)}_{2} + {\Theta}^{(l)}_{3,2} \delta^{(l+1)}_{3} \ldots) \cdot g'(z^{(l)}_2) \\
    \delta^{(l)}_3 = ({\Theta}^{(l)}_{1,3} \delta^{(l+1)}_{1} + {\Theta}^{(l)}_{2,3} \delta^{(l+1)}_{2} + {\Theta}^{(l)}_{3,3} \delta^{(l+1)}_{3} \ldots) \cdot g'(z^{(l)}_3) \\
  \end{array} \\
\right. \\
</script>

入力レイヤーの誤差は存在しないので算出する必要はない。

ユニットの入力 `a(l)` に、直後のレイヤーの誤差を掛け合わせたものが、各パラメータの偏微分となる。

<script type="math/tex; mode=display" id="MathJax-Element-backprop_grad">
\Delta^{(l)} = \Delta^{(l)} + \delta^{(l+1)}(a^{(l)})^{T} \\
\frac{\partial}{\partial \Theta^{(l)}_{i,j}} J(\Theta) = D^{(l)}_{i,j} = a^{(l)}_{j} \delta^{(l+1)}_{i} = \frac{1}{m} \Delta^{(l)}_{i,j} \\
</script>

_Regularization_ を行なう場合は、各パラメータ毎にペナルティを与えればよい。コスト関数と同様に、バイアス項は除外する。

<script type="math/tex; mode=display" id="MathJax-Element-backprop_grad_reg">
D^{(l)}_{i,j} = D^{(l)}_{i,j} + \frac{\lambda}{m} \Theta^{(l)}_{i,j} \\
</script>

### Numerical Gradient

_Backpropagation_ を正しく行なえているかどうかは、一つのパラメータのみ極小値で増減させて、二つのコスト関数を適用した差分が _Backpropagation_ で得た偏微分とほぼ相違ないこと（1e-9 以下が目安）をチェックすればよい。

<script type="math/tex; mode=display" id="MathJax-Element-grad_checking">
\frac{\partial}{\partial \theta_1} J(\theta) \approx \frac{ J(\theta_1 + \epsilon, \theta_2, \theta_3, \ldots, \theta_n) - J(\theta_1 - \epsilon, \theta_2 , \theta_3, \ldots, \theta_n) }{2 \epsilon} \\
\frac{\partial}{\partial \theta_2} J(\theta) \approx \frac{ J(\theta_1, \theta_2 + \epsilon, \theta_3, \ldots, \theta_n) - J(\theta_1, \theta_2 - \epsilon, \theta_3, \ldots, \theta_n) }{2 \epsilon} \\
\ldots \\
\frac{\partial}{\partial \theta_n} J(\theta) \approx \frac{ J(\theta_1, \theta_2, \theta_3, \ldots, \theta_n + \epsilon) - J(\theta_1, \theta_2, \theta_3, \ldots, \theta_n - \epsilon) }{2 \epsilon} \\
</script>

```octave
function grad = numericalGradient(J, theta)
  m = length(theta);
  grad = zeros(m, 1);

  E = 0.01; % epsilon;
  for i = 1:m
    theta1 = theta; theta1(i) = theta1(i) + E;
    theta2 = theta; theta2(i) = theta2(i) - E;
    grad(i) = (J(theta1) - J(theta2)) / (2 * E);
  end
end
```

すべてのパラメータに対してコスト関数を適用するため、非常に処理時間がかかる。あくまで _Backpropagation_ が正しくおこなえているかのチェックのみで、実際の学習処理に含めてはならない。

### Symmetry Breaking

ニューラルネットワークにおいては、レイヤーの出力として、次のレイヤーの各ユニットへ同じ入力が与えられる。このため入力に対するパラメータ（重み）が同じ値の場合、同一レイヤー内の全てのユニットの出力が同じ値になってしまう。

* 初期パラメータを全て 0 にすると、バイアス項のみが伝播する。
* 初期パラメータを全て 1 にすると、全てのユニットの出力が、前ユニット出力の総和のシグモイド値になる。

このため _Backpropagation_ を開始する際の初期パラメータは、ランダムである必要がある。`-ε .. ε` の範囲でランダムに設定するとよい。

```octave
E = 0.01 % epsilon
Theta1 = rand(3, 4) * (2 * E) - E; % initialize to 3 x 4 random matrix
Theta2 = rand(3, 5) * (2 * E) - E; % initialize to 3 x 5 random matrix
```
