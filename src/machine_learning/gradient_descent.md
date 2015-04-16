---
layout: page

title: Gradient Descent
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Batch Gradient Descent

最急降下法において、パラメータの偏微分を求める際に、全ての学習データから算出する方法を、バッチ最急降下法 _Batch Gradient Descent_ と呼ぶ。

この方法は、概ね最短距離で収束するが、学習データ数 `m` でパラメータ数 `n` とした場合、一回の偏微分の算出に `m * n` の計算量が必要になる。この計算量を収束するまで反復するため、学習データ数 `m` が大きくなるにつれ、無視できないコストになる。

<script type="math/tex; mode=display" id="MathJax-Element-batch_grad">
J(\theta) = \frac{1}{2m} {\sum_{i=1}^{m} (h_{\theta}(x^{(i)})-y^{(i)})^2} \\
\frac{\partial}{\partial \theta_{j}} J(\theta) = \frac{1}{m} \sum_{i=1}^{m} (h_{\theta}(x^{(i)}) - y^{(i)}) x_{j}^{(i)} \\
\theta_{j} := \theta_{j} - \alpha \left( \frac{ \partial}{ \partial \theta_{j}} J(\theta) \right) \\
</script>

## Stochastic Gradient Descent

一つのコスト関数で、すべての学習データから誤差平均を求めるのではなく、一つの学習データごとのコスト関数に分けて誤差を求めた後に、それらの平均を取るのも結果的には同じである。

<script type="math/tex; mode=display" id="MathJax-Element-stochasitc_cost">
\text{cost$(\theta, (x^{(i)}, y^{(i)}))$} = \frac{1}{2} (h_{\theta}(x^{(i)}) - y^{(i)})^{2} \\
J(\theta) = \frac{1}{m} \sum_{i=1}^{m} \text{cost$(\theta, (x^{(i)}, y^{(i)}))$} \\
</script>

一つの学習データごとのコスト関数の偏微分は、同データからの誤差のみで求められるので、計算量はパラメータ数 `n` に収まる。

<script type="math/tex; mode=display" id="MathJax-Element-stochasitc_grad">
\frac{\partial}{\partial \theta_{j}} \text{cost$(\theta, (x^{(i)}, y^{(i)}))$} = (h_{\theta}(x^{(i)}) - y^{(i)}) x_{j}^{(i)} \\
\theta_{j} := \theta_{j} - \alpha \left( \frac{\partial}{\partial \theta_{j}} \text{cost$(\theta, (x^{(i)}, y^{(i)}))$} \right) \\
</script>

一回のパラメータ更新の際に、すべての学習データからの偏微分ではなく、一つの学習データのみから偏微分を求めるようにすれば、全ての学習データに渡って反復した場合でも、`m * n` の計算量に収まる。

バッチ最急降下法のように最短距離は進まず、遠回りをしながら収束するが、やがて移動範囲は狭まり収束する。この方法を、確率的最急降下法 _Stochastic gradient descent_ よ呼ぶ。

{% highlight octave %}
m = 100000;
n = 4;

% Training set X in m x n
X = repmat(randperm(100)', m / 100, 1);
X = [repmat(randperm(100)', m / 100, 1), X];
X = [repmat(randperm(100)', m / 100, 1), X];
X = [ones(m, 1), X];
X = X(randperm(m), :); % Shuffle X
% h(x) = 1 + x1 * 2 + x2 * 3 + x3 * 4
y = 1 + (X(:, 2) .* 2) + (X(:, 3) .* 3) + (X(:, 4) .* 4);

% Batch gradient descent
fprintf('Press enter to run batch gradient descent.\n');
pause;
alpha = 0.00005;
theta = ones(n, 1);
for i = 1:10000
  theta = theta - (((X * theta - y)' * X) .* alpha / m)';
end
theta

% Stochastic gradient descent
fprintf('Press enter to run stochastic gradient descent. It can be much faster.\n');
pause;
alpha = 0.00005;
theta = ones(n, 1);
for i = 1:m
  df = (X(i, :) * theta) - y(i);
  theta = theta - (X(i, :) .* df .* alpha)';
end
theta
{% endhighlight %}

* 学習データは事前にシャッフルしておく。何かしらでソートされていると、片寄った動きになりうまく収束しない。
* ある程度のデータ量であれば、学習データを一度走査するだけで、十分に良い結果が得られる。収束する余地があれば、もう一度繰り返せば良い。
