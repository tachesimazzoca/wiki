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

入力とパラメータの内積をシグモイド関数を通して `0 < a < 1` に収めるモデルを、 _Sigmoid (Logistic) Activation Function_ と呼ぶ。

<script type="math/tex; mode=display" id="MathJax-Element-logistic_unit">
g(z) = \frac{1}{1 + e^{-z} } \\
h(x) = g({\theta}^{T} x) \\
</script>

バイアス項 _Bias Unit_ として、`x(0) = 1` で固定し、`theta(0)` をオフセット値とする。入力値 `x` を `(0|1)` に制限すると、論理回路を実現できる。

`theta = [-30; 20; 20]` とした場合、AND ゲートとして機能することがわかる。

{% highlight octave %}
theta = [-30; 20; 20];
x = [1 0 0; 1 0 1; 1 1 0; 1 1 1];
z = x * theta % expected [-30; -10; -10; 10]
sigmoid(z) % expected [0; 0; 0; 1]
{% endhighlight %}

`theta = [-10; 20; 20]` とした場合、OR ゲートとして機能することがわかる。

{% highlight octave %}
theta = [-10; 20; 20];
x = [1 0 0; 1 0 1; 1 1 0; 1 1 1];
z = x * theta % expected [-10; 10; 10; 30]
sigmoid(z) % expected [0; 1; 1; 1]
{% endhighlight %}

## Forward Propagation

_Activation Function_ を複数レイヤーに定義し、各レイヤーの出力を次のレイヤーへの入力とすることで、より複雑な論理回路を実現できる。

<script type="math/tex; mode=display" id="MathJax-Element-neural_network_layer2">
\begin{array}{l l}
\text{Layer1: ${\Theta}^{(1)} \in \mathbb{R}^{3 \times 3}$} & \left\{
  \begin{array}{l l}
    \text{input: $x$, output: $a^{(2)}$} \\
    a^{(2)}_0 = 1 \\
    a^{(2)}_{1} = g({ {\Theta}^{(1)}_{1,0} } x_0 + { {\Theta}^{(1)}_{1,1} } x_1 + { {\Theta}^{(1)}_{1,2} x_2 }) \\
    a^{(2)}_{2} = g({ {\Theta}^{(1)}_{2,0} } x_0 + { {\Theta}^{(1)}_{2,1} } x_1 + { {\Theta}^{(1)}_{2,2} x_2 }) \\
    a^{(2)}_{3} = g({ {\Theta}^{(1)}_{3,0} } x_0 + { {\Theta}^{(1)}_{3,1} } x_1 + { {\Theta}^{(1)}_{3,2} x_2 }) \\
  \end{array}
\right. \\

\text{Layer2: ${\Theta}^{(2)} \in \mathbb{R}^{2 \times 4}$} & \left\{
  \begin{array}{l l}
    \text{input: $a^{(2)}$, output: $a^{(3)}$} \\
    a^{(3)}_0 = 1 \\
    a^{(3)}_{1} = g({\Theta}^{(2)}_{1,0} a^{(2)}_0 + {\Theta}^{(2)}_{1,1} a^{(2)}_1 + {\Theta}^{(2)}_{1,2} a^{(2)}_2 + {\Theta}^{(2)}_{1,3} a^{(2)}_3) \\
    a^{(3)}_{2} = g({\Theta}^{(2)}_{2,0} a^{(2)}_0 + {\Theta}^{(2)}_{2,1} a^{(2)}_1 + {\Theta}^{(2)}_{2,2} a^{(2)}_2 + {\Theta}^{(2)}_{2,3} a^{(2)}_3) \\
  \end{array}
\right. \\

\text{Layer3: ${\Theta}^{(3)} \in \mathbb{R}^{1 \times 3}$} & \left\{
  \begin{array}{l l}
    \text{input: $a^{(3)}$, output: $a^{(4)}$} \\
    a^{(4)}_1 = g({\Theta}^{(3)}_{1,0} a^{(3)}_0 + {\Theta}^{(3)}_{1,1} a^{(3)}_1 + {\Theta}^{(3)}_{1,2} a^{(3)}_2) \\
    h_{\Theta}(x) = a^{(4)}_1 \\
  \end{array}
\right. \\

\end{array}

</script>

* ２つの入力 `x` に、バイアス項として `x(0) = 1` を加える。
* Layer1: ３つの入力 `x` から、３つの出力 `a2` を算出する。バイアス項として `a2(0) = 1` を加える。
* Layer2: Layer1 の４つの出力 `a2` を入力とし、２つの出力 `a3` を算出する。バイアス項として `a3(0) = 1` を加える。
* Layer3: Layer2 の３つの出力 `a3` を入力とし、１つの出力 `a4` を算出する。
* 最終レイヤーの出力 `a4(1)` が、そのまま予測値 `h(x)` となる。

