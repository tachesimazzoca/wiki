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

回帰パラメータが少なすぎると、学習データに大まかにしか一致しない。例えば、線形回帰において、多項式が望ましいケースで、一次式で回帰を行なっても、良い近似値が得られない。

パラメータを増やす事で、学習データには一致するが、分散した正解値に過剰に一致する複雑な曲線となり、新規データに対して、良い予測値が得られない。この状態を、過剰適合 _Overfitting_ または 過学習 _Overtraining_ と呼ぶ。

## Cost Function and Gradient

コスト関数において、回帰パラメータへのペナルティ値を加えることで、過剰適合を中和することができる。最急降下法で用いる偏微分の項にも、ペナルティを加える必要がある。

<script type="math/tex; mode=display" id="MathJax-Element-overfitting_cost">
J(\theta) = J(\theta) + \frac{\lambda}{m} { \sum_{j=1}^{n} {\theta}_{j}^2 } \\
{\partial J(\theta) \over \partial \theta_{j}} = \left( \frac{1}{m} {\sum_{i=1}^{m} (h_{\theta}(x^{(i)}) - y^{(i)})x_{j}^{(i)} } \right) + \frac{\lambda}{m} {\theta}_{j} \\
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

## Cross Validation

未知のデータに対して、良い予測結果が得られるかを事前検証するには、保有データ全てを学習用に使うのではなく、３分の１程度を、検証/テスト用に割り当てる。

* 例）保有データを、学習用 60% / 検証用 20% / テスト用 20% に分ける。
* 学習用データのみで、候補モデルの回帰パラメータを算出する。
* 候補モデル毎に、学習用と検証用データの予測誤差を算出する。
* 学習用 / 検証用データの双方で、良い結果が得られるモデルを選択する。
* 選択したモデルで、テスト用データを予測し、過剰適合をチェックする。

この方法を、交差検証 _Cross validation_ と呼ぶ。

## Bias and Variance

アルゴリズムが適切でないために、予測が乖離している状態を _High bias_ と呼ぶ。この場合、学習数を増やしても算出方法が根本的に違っているため、誤差が改善しない。以下の方法で改善する。

* パラメータを増やす。 `x1 + x2 + x3 + ...`
* パラメータに多項式を用いる。 `x + x^2 + x^3 + ...`
* ペナルティ強度を下げる。

一方で、アルゴリズムが学習データのみに過剰適合し、予測が分散しすぎている状態を _High variance_ と呼ぶ。この場合、未知のデータの予測は乖離する傾向にある。以下の方法で改善する。

* 学習数を増やす。
* パラメータを減らす。
* ペナルティ強度を上げる。

アルゴリズムを見つけるには、まず簡単なパラメータから初めて、学習数により誤差が改善するかを検証する。改善しない場合は、_High bias_ であるので、まずパラメータのみを見直す。_High bias_ の状態で、ペナルティを与えたり、学習数を増やしても改善しない。

## Precision and Recall

_Classification problem_ においては、分類値がレアな場合がある。この場合、検証数に対する正解率で、アルゴリズムの正確性を判断してはならない。

例えば `y = 1 (1 sample), y = 0 (99 samples)` のデータに対して検証を行なうとして、アルゴリズムが単に `0` を返す実装になっていても、`99 / 100 = 0.99` と高い精度で予測できたように錯覚する。

                                      Actual
                  |          1          |          0          |
              ----+---------------------+---------------------+
               1  |  0: true positives  |  0: false positives |
    Predicted ----+---------------------+---------------------+
               0  |  1: false negatives | 99: true negatives  |
              ----+---------------------+---------------------+

       Accuracy: (true positives + true negatives) / (total examples) =  99 / 100 = 0.99
      Precision: true positives / (true positives + false positives)  =   0 /   0 = 0.00
         Recall: true positives / (true positives + false negatives)  =   0 /   1 = 0.00

アルゴリズムの妥当性の判断については、以下を考慮しなければならない。

* 精度 _Precision_
  * `y = 1` と予測したデータのうち、実データが `y = 1` の比率
  * スパムメールであると予測したうち、実際にスパムメールであった比率
* 再現率 _Recall_
  * `y = 1` である実データのうち、`y = 1` と予測できた比率
  * 実際のスパムメールを、スパムメールと予測できた比率

精度と再現率は相容れないため、どちらかを優先できるならば、シグモイド関数の _Threshold_ 値 `0.5` を調整する。

* _Threshold_ 値を増やすほど、確実な場合のみ `y = 1` と予測する。精度は上がるが、再現率は下がる。
  * 無駄に終わった場合のリスクが高いため、取りこぼしを許容する。_（危険を伴う手術 / 不正アカウント停止）_
* _Threshold_ 値を減らすほど、少しでも可能性があれば `y = 1` と予測する。再現率は上がるが、精度は下がる。
  * 無駄になっても、取りこぼしを許容しない。_（初期不良 / 障害検知）_

### F-score

最適なアルゴリズムを比較する際に、精度と再現率の平均 `Presicion + Recall / 2` をとってはならない。例えば、全て `y = 1` と予測するアルゴリズムになっていた場合、再現率に関しては `1.00` になる。

                                      Actual
                  |          1          |          0          |
              ----+---------------------+---------------------+
               1  |  1: true positives  | 99: false positives |
    Predicted ----+---------------------+---------------------+
               0  |  0: false negatives |  0: true negatives  |
              ----+---------------------+---------------------+

       Accuracy: (true positives + true negatives) / (total examples) =   1 / 100 = 0.01
      Precision: true positives / (true positives + false positives)  =   1 / 100 = 0.01
         Recall: true positives / (true positives + false negatives)  =   1 /   1 = 1.00

平均では `(0.01 + 1.00) / 2 = 0.505` となり、50% の正確性があるように思えてしまう。

* `(0.50 + 0.40) / 2 = 0.45000`
* `(0.70 + 0.10) / 2 = 0.40000`
* `(0.01 + 1.00) / 2 = 0.50500`

バランスよく、精度と再現率が高いかを判断するには、_F-score_ を用いる。

<script type="math/tex; mode=display" id="MathJax-Element-fscore">
\scriptsize{ \text{$P =$ Precision, $R =$ Recall} } \\
F_1 = 2 \frac{PR}{P + R}
</script>

* `2 * (0.50 * 0.40) / (0.50 + 0.40) = 0.44444`
* `2 * (0.70 * 0.10) / (0.70 + 0.10) = 0.17500`
* `2 * (0.01 * 1.00) / (0.01 + 1.00) = 0.01980`

