# Regularization

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Overfitting

回帰パラメータが少なすぎると、学習データに大まかにしか一致しない。例えば、線形回帰において、多項式が望ましいケースで、一次式で回帰を行なっても、良い近似値が得られない。

パラメータを増やす事で、学習データには一致するが、分散した正解値に過剰に一致する複雑な曲線となり、新規データに対して、良い予測値が得られない。この状態を、過剰適合 _Overfitting_ または 過学習 _Overtraining_ と呼ぶ。

## Cost Function and Gradient

コスト関数において、回帰パラメータへのペナルティ値を加えることで、過剰適合を中和することができる。最急降下法で用いる偏微分の項にも、ペナルティを加える必要がある。

<script type="math/tex; mode=display" id="MathJax-Element-overfitting_cost">
J(\theta) = J(\theta) + \frac{\lambda}{m} { \sum_{j=1}^{n} {\theta}_{j}^2 } \\
\frac{\partial}{\partial \theta_{j}} J(\theta) = \left( \frac{1}{m} {\sum_{i=1}^{m} (h_{\theta}(x^{(i)}) - y^{(i)})x_{j}^{(i)} } \right) + \frac{\lambda}{m} {\theta}_{j} \\
</script>

* この例では、回帰パラメータ `θ` の二乗平均を誤差の総和に加えている。つまりパラメータが適合に大きく作用する時に、ペナルティが増えて中和されることになる。
* `λ` はペナルティ強度で、この値が小さいほどペナルティ値が減り、過剰適合となる。
* ペナルティ強度 `λ` が大きすぎると、全ての回帰パラメータが `0` に限りなく近づき、あらゆる入力に対し、コストが同じ値になってしまう。
* 入力値 `X` に作用しないパラメータについては、ペナルティから除外しなければならない。

### Linear Regression

<script type="math/tex; mode=display" id="MathJax-Element-regularization_linear">
J(\theta) = \frac{1}{2m} {\sum_{i=1}^{m} (h_{\theta}(x^{(i)}) - y^{(i)})^2 } + \frac{\lambda}{2m} { \sum_{j=1}^{n} {\theta}_{j}^2 } \\
</script>

### Logistic Regression

<script type="math/tex; mode=display" id="MathJax-Element-regularization_logistic">
J(\theta) = \frac{1}{m} {\sum_{i=1}^{m} [ -log(h_{\theta}(x^{(i)}))(y^{(i)}) - log(1 - h_{\theta}(x^{(i)})) (1 - y^{(i)}) ] } + \frac{\lambda}{2m} { \sum_{j=1}^{n} {\theta}_{j}^2 } \\
</script>
