---
layout: page

title: Regularization
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Overfitting

回帰モデルのパラメータが少なすぎると、学習データに大まかにしか一致しない。例えば、線形回帰において、多項式が望ましいケースで、一次式で回帰を行なっても、良い近似値が得られない。

パラメータを増やす事で、学習データに一致するが、ランダムな誤差に過剰に一致する複雑な曲線となり、新規データに対して、良い予測値が得られない。この状態を、過剰適合 _Overfitting_ または 過学習 _Overtraining_ と呼ぶ。

## Cost Function and Gradient

費用関数において、回帰パラメータへのペナルティ値を加えることで、過剰適合を中和することができる。勾配法で用いる偏微分の項にも、ペナルティを加える必要がある。

<script type="math/tex; mode=display" id="MathJax-Element-overfitting_cost">
J(\theta) = J(\theta) + \frac{\lambda}{m} { \sum_{j=1}^{n} {\theta}_{j}^2 } \\
{\partial J(\theta) \over \partial \theta_{j}} = \left( \frac{1}{m} {\sum_{i=1}^{m} (h_{\theta}(X_i) - y_i)X_{i,j} } \right) + \frac{\lambda}{m} {\theta}_{j} \\
</script>

* この例では、回帰パラメータ `θ` の二乗平均を誤差の総和に加えている。つまりパラメータが適合に大きく作用する時に、ペナルティが増えて中和されることになる。
* `λ` はペナルティ強度で、この値が小さいほどペナルティ値が減り、過剰適合となる。
* ペナルティ強度 `λ` が大きすぎると、全ての回帰パラメータが `0` に限りなく近づき、あらゆる入力に対し、費用が同じ値になってしまう。
* 入力値 `X` に作用しないパラメータについては、ペナルティから除外しなければならない。

### Linear Regression

<script type="math/tex; mode=display" id="MathJax-Element-regularization_linear">
J(\theta) = \frac{1}{2m} {\sum_{i=1}^{m} (h_{\theta}(X_i) - y_i)^2 } + \frac{\lambda}{2m} { \sum_{j=1}^{n} {\theta}_{j}^2 } \\
</script>

### Logistic Regression

<script type="math/tex; mode=display" id="MathJax-Element-regularization_logistic">
J(\theta) = \frac{1}{m} {\sum_{i=1}^{m} [ -log(h_{\theta}(X_i))(y_i) - log(1 - h_{\theta}(X_i)) (1 - y_i) ] } + \frac{\lambda}{2m} { \sum_{j=1}^{n} {\theta}_{j}^2 } \\
</script>

## Cross Validation

安易に学習データにフィットさせるだけでは、過剰適合となってしまう。未知のデータに対しても良い予測結果が得られるかを事前検証するには、保有データ全てを学習用に使うのではなく、３分の１程度を、検証/テスト用に割り当てる。

* 例）保有データを、学習用 60% / 検証用 20% / テスト用 20% に分ける。
* 学習用データのみで、候補モデルの回帰パラメータを算出する。
* 候補モデル毎に、学習用と検証用データの予測誤差を算出する。
* 学習用 / 検証用データの双方で、良い結果が得られるモデルを選択する。
* 選択したモデルで、テスト用データを予測し、過剰適合をチェックする。

この方法を、交差検証 _Cross validation_ と呼ぶ。

## Bias and Variance

アルゴリズムが適切でないために、予測が乖離している状態を _High bias_ と呼ぶ。この場合、学習数を増やしても算出方法が根本的に違っているため、誤差が改善しない。

一方で、アルゴリズムが学習データのみに過剰適合し、予測が分散しすぎている状態を _High variance_ と呼ぶ。この場合、未知のデータの予測は乖離する傾向にあるが、_Low bias_ であれば、学習数を増やすことで誤差は改善する。

* パラメータ数
  * パラメータ数が増えるほど、学習データの予測誤差は減る。_High variance_
  * パラメータ数が増えすぎると、検証データの予測誤差は増える傾向にある。_High bias_
* ペナルティ強度
  * ペナルティ強度が増えるほど、学習データの予測誤差は増える。_High bias_
  * ペナルティ強度が弱すぎると、検証データの予測誤差は増える傾向にある。_High variance_
* 学習データ数
  * パラメータが適切であれば、学習データ数が増えるほど、あらゆるデータの予測誤差は減る。_High variance_
  * 予測に有効なパラメータが少なすぎると、学習データ数を増やしてもより良いモデルは得られない。いかなるデータであっても、予測誤差の改善がみられない。_High bias_

