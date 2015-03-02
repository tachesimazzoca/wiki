---
layout: page

title: Neural Networks
---

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

{% highlight octave %}
X = [0 0; 0 1; 1 0; 1 1];
X = [ones(length(X), 1), X];         % [1 0 0; 1 0 1; 1 1 0; 1 1 1]

theta1 = [-30; 20; 20];              % AND gate
z1 = X * theta1;                     % [-30; -10; -10; 10]
h1 = sigmoid(z1);                    % [0; 0; 0; 1]

theta2 = [-10; 20; 20];              % OR gate
z2 = X * theta2;                     % [-10; 10; 10; 30]
h2 = sigmoid(z2);                    % [0; 1; 1; 1]
{% endhighlight %}

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

{% highlight octave %}
Theta1 = [30 -20 -20; -10 20 20];    % [{NAND}; {OR}]
Theta2 = [-30 20 20];                % [{AND}]

X = [0 0; 0 1; 1 0; 1 1];
X = [ones(length(X), 1), X];         % [1 0 0; 1 0 1; 1 1 0; 1 1 1]

z1 = X * Theta1';                    % [30 -10; 10 10; 10 10; -10 30]
a2 = sigmoid(z1);                    % [1 0; 1 1; 1 1; 0 1]
a2 = [ones(length(a2), 1), a2];      % [1 1 0; 1 1 1; 1 1 1; 1 0 1]

z2 = a2 * Theta2';                   % [-10; 10; 10; -10]
a3 = sigmoid(z2);                    % [0; 1; 1; 0]
{% endhighlight %}

このように、複数レイヤーの入出力を介して、前方に伝播させていく方法を _Forward propagation_ と呼ぶ。

## Multi-class Classification

３つ以上に分類するには、最終レイヤーのユニットを、分類の数だけ用意すればよい。

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

最終レイヤーのベクトルを `a3`、正解値を `y` としたとき、`a3(y)` のフラグが立つと考える。

* `y = 1 if a3 = [1; 0; 0]`
* `y = 2 if a3 = [0; 1; 0]`
* `y = 3 if a3 = [0; 0; 1]`

分類数を `K` とすると、費用関数は各出力の誤差平均を求めればよい。

<script type="math/tex; mode=display" id="MathJax-Element-backprop_cost">
a = h_{\Theta}(x) \in \mathbb{R}^{K}\\
J(\Theta) = \frac{1}{m} {\sum_{i=1}^{m}} {\sum_{k=1}^{K}} [ -log(a_{i,k})(y_{i,k}) - log(1 - a_{i,k}) (1 - y_{i,k}) ] \\
</script>

## Backpropagation

ニューラルネットワークの費用関数は、ロジスティック回帰と同じであるが、予測値を求めるには _Forward propagation_ で各レイヤーを通して算出する必要がある。

{% highlight octave %}
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
{% endhighlight %}

_Regularization_ を行なう場合は、各レイヤーにパラメータがある点に注意する。バイアス項は除外する。

<script type="math/tex; mode=display" id="MathJax-Element-backprop_cost_reg">
\text{$L = $ the number of the layers} \\
\text{$sl = $ the number of parameters of the layer $l$} \\
J(\Theta) = J(\Theta) + \frac{\lambda}{2m} \sum_{l=1}^{L-1} \sum_{i=1}^{sl} \sum_{j=1}^{sl+1} ({\Theta}_{j,i}^{(l)})^2 \\
</script>

{% highlight octave %}
t1 = Theta1;
t2 = Theta2;
t1(:, 1) = 0;
t2(:, 1) = 0;

lambda = 0.1;
J = J + (sum(sum(t1 .^ 2)) + sum(sum(t2 .^ 2))) * lambda / (2 * m);
{% endhighlight %}

ニューラルネットワークの各ユニットのパラメータを求めるには、勾配法を用いる。各ユニットの偏微分の項を求めるためには、最終出力の誤差から各レイヤーを逆に伝播して算出する必要がある。この方法を、誤差逆伝播法 _Backpropagation_ と呼ぶ。

ネイピア数 `e` を底とする指数の微分は `(e^x)' = e^x` であることを利用して、シグモイド関数 `g(z)` を微分すると `g'(z) = g(z) * (1 - g(z))` となる。

<script type="math/tex; mode=display" id="MathJax-Element-sigmoid_partial_simplify">
g(z) = \frac{1}{1 + e^{-z}} \\

\begin{align}

& \left\{
\begin{array}{l l}
u = 1 + e^{-z} \\
g'(u) = (u^{-1})' = -1 \cdot u^{-2} = -(1 + e^{-z})^{-2} \\
\end{array}
\right. \\

& \left\{
\begin{array}{l l}
x = -z \\
u' = (1 + e^{-z})' = (e^{-z})' = (e^{x})'(x)' = (e^{x})(-1) = -e^{-z} \\
\end{array}
\right. \\

\end{align} \\

</script>
<script type="math/tex; mode=display" id="MathJax-Element-sigmoid_partial">
\begin{align}
g'(z) & = g'(u) \cdot u' = -(1 + e^{-z})^{-2} \cdot -e^{-z}\\
      & = \frac{e^{-z}}{(1 + e^{-z})^2} \\
      & = \frac{1}{1 + e^{-z}} \left( \frac{1 + e^{-z}}{1 + e^{-z}} - \frac{1}{1 + e^{-z}} \right) \\
      & = \frac{1}{1 + e^{-z}} \left( 1 - \frac{1}{1 + e^{-z}} \right) \\
      & = g(z)(1 - g(z)) \\
\end{align} \\
</script>

