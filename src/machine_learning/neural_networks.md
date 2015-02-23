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

入力とパラメータの内積を、シグモイド関数を通して `0 < a < 1` の範囲に変換するモデルを、 _Sigmoid (Logistic) Activation Function_ と呼ぶ。

<script type="math/tex; mode=display" id="MathJax-Element-logistic_unit">
g(z) = \frac{1}{1 + e^{-z} } \\
h_{\theta}(x) = g({\theta}^{T} x) \\
</script>

バイアス項 _Bias Unit_ として、`x(0) = 1` で固定し、`theta(0)` をオフセット値とする。入力値 `x` を `(0|1)` に制限すると、`theta` の値に応じて AND / OR の論理回路を実現できる。

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

_Activation Function_ を複数レイヤーに定義し、各レイヤーの出力を次のレイヤーへの入力とすることで、より複雑な論理回路を実現できる。

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
\begin{array}{l l}
\text{Input} & \left\{
  \begin{array}{l l}
    x_0 = 1 \\
    x_1 \in \mathbb{R} \\
    x_2 \in \mathbb{R} \\
  \end{array}
\right. \\

\text{Layer1} & \left\{
  \begin{array}{l l}
    {\Theta}^{(1)} \in \mathbb{R}^{3 \times 3} \\
    a^{(2)}_0 = 1 \\
    a^{(2)}_{1} = g({ {\Theta}^{(1)}_{1,0} } x_0 + { {\Theta}^{(1)}_{1,1} } x_1 + { {\Theta}^{(1)}_{1,2} x_2 }) \\
    a^{(2)}_{2} = g({ {\Theta}^{(1)}_{2,0} } x_0 + { {\Theta}^{(1)}_{2,1} } x_1 + { {\Theta}^{(1)}_{2,2} x_2 }) \\
    a^{(2)}_{3} = g({ {\Theta}^{(1)}_{3,0} } x_0 + { {\Theta}^{(1)}_{3,1} } x_1 + { {\Theta}^{(1)}_{3,2} x_2 }) \\
  \end{array}
\right. \\

\text{Layer2} & \left\{
  \begin{array}{l l}
    {\Theta}^{(2)} \in \mathbb{R}^{2 \times 4} \\
    a^{(3)}_0 = 1 \\
    a^{(3)}_{1} = g({\Theta}^{(2)}_{1,0} a^{(2)}_0 + {\Theta}^{(2)}_{1,1} a^{(2)}_1 + {\Theta}^{(2)}_{1,2} a^{(2)}_2 + {\Theta}^{(2)}_{1,3} a^{(2)}_3) \\
    a^{(3)}_{2} = g({\Theta}^{(2)}_{2,0} a^{(2)}_0 + {\Theta}^{(2)}_{2,1} a^{(2)}_1 + {\Theta}^{(2)}_{2,2} a^{(2)}_2 + {\Theta}^{(2)}_{2,3} a^{(2)}_3) \\
  \end{array}
\right. \\

\text{Layer3} & \left\{
  \begin{array}{l l}
    {\Theta}^{(3)} \in \mathbb{R}^{1 \times 3} \\
    a^{(4)}_1 = g({\Theta}^{(3)}_{1,0} a^{(3)}_0 + {\Theta}^{(3)}_{1,1} a^{(3)}_1 + {\Theta}^{(3)}_{1,2} a^{(3)}_2) \\
    h_{\Theta}(x) = a^{(4)}_1 \\
  \end{array}
\right. \\

\end{array}

</script>

* ２つの入力 `x` に、バイアス項として `x(0) = 1` とする。
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
