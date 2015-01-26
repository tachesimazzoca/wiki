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

### Linear Regression Model

* `x` から `y` を導く `m` 個の訓練データ _Training Set_ があるとする。例) x: 部屋の広さ, y: 家賃
* `y` を予測する関数を `h(x) = a + b * x` とする。
* `x(i), y(i)` を各データとした時、`h(x(i)) - y(i)` すなわち `(a + b * x(i)) - y(i)` が予測誤差になる。
* これらの誤差の二乗したものの平均値を、「平均二乗誤差」 _Mean Squared Error (MSE)_ と呼ぶ。
* _MSE_ が最小となる `a, b` が最適値になる。

<script type="math/tex; mode=display" id="MathJax-Element-hypothesis">
h(x) = \theta_{0} + \theta_{1}{x} 
</script>

<script type="math/tex; mode=display" id="MathJax-Element-mse">
\textrm{MSE} = \frac{1}{m} {\sum_{i=1}^{m} (h(x_i)-y_i)^2}
</script>

_MSE_ が最小となる予測関数を見つけることができたとしても、あらゆる入力から、誤差がない予測が可能なわけではない。あくまで保有データ内で、予測関数が見つけられたというだけである。言い替えると、保有データに関しては、誤差なく予測することができる。

{% highlight scala %}
def mse(data: Seq[(Int, Int)], h: Int => Int): Double = {
  val se = data map { case (x, y) =>
    math.pow(h(x) - y, 2)
  }
  se.sum / data.size
}

val data = Seq((1, 2), (2, 4), (3, 6))

// h(x) = a + b * x, if a = 1, b = 1
println(mse(data, x => (1 + 1 * x))) // (0^2 + (-1)^2 + (-2)^2) / 3 = 1.666

// h(x) = a + b * x, if a = 0, b = 2
println(mse(data, x => (0 + 2 * x))) // (0^2 + 0^2 + 0^2) / 3 = 0
{% endhighlight %}

`[(1, 2), (2, 4), (3, 6)]` という訓練データを例にすると、`a = 0, b = 2` すなわち `h(x) = 2 * x` が線形回帰モデルになる。このモデルは訓練データ内では誤差はないが、今後のあらゆるケースで、誤差なく予測できるわけではない。

* 訓練データに含まれない `x = 4` が、必ず `y = h(x) = 2 * 4 = 8` という結果になるわけではない。
* 訓練データに含まれる `x = 2` であっても、必ず `y = h(x) = 2 * 2 = 4` という結果になるわけではない。

### Gradient Decent Algorithm

線形回帰モデルを見つけるには、勾配法 _Gradient decent_ を用いることができる。

勾配法は、反復法を用いて解に近づけていく。反復法の一つ、ニュートン法 _Newton's method_ により平方根を見つける例をおさらいしてみる。

`x` を平方根、`a` をその二乗としたとき

    x * x - a = 0

が成り立つ。これを展開すると、`x = (x + a / x) / 2` が得られる。

    x * x - a = 0
    x * x = a
    x = a / x
    2x - x = a / x
    2x = x + (a / x)
    x = (x + (a / x)) / 2

近似値からこの式の代入を繰り返し、誤差が十分に小さくなるまで反復すれば、平方根が得られる。

    # sqrt(3)
    x := (x + (3 / x)) / 2
    x := (1.5 + (3 / 1.5)) / 2 = 1.7500
    x := (1.7500 + (3 / 1.7500)) / 2 = 1.7321
    x := (1.7321 + (3 / 1.7321)) / 2 = 1.7320

線形回帰モデルの場合にも、同じような反復を繰り返して、最適値に収束させていけばよい。方法として、最急降下法 _Steepest descent method_ がある。

仮説を `h(x) = a + b * x` とし、誤差を求める関数を `J(a, b)` とした時、`(a, b, J(a, b))` の三次元グラフを書くと、`J(a, b)` 軸で凹凸をもったグラフとなる。すなわち、この凹みの最も深い位置が、最も誤差の少ない最適値になる。

最急降下法では、以下の式で最適値を目指して勾配を下っていく。

<script type="math/tex; mode=display" id="MathJax-Element-gradient_descent">
X_i := X_i - \alpha ({\partial \over \partial X_i}{f(X)})
</script>

* `X` は n 次元のベクトル
* `α` は、どれだけ進むかの割合 _Learning rate_ で、正の数（主に定数）をとる。
* `f(X)` は誤差を求める関数で、その微分項 _Derivative term_ である `d * f(X) / d * X(i)` は、`f(X)` の最も変化の大きい方向に勾配ベクトルを向ける。
* この式を反復して `X` を更新していく。勾配を下って凹みに向かって収束していくため、`α` が大きすぎなければ `f(X)` は必ず小さくなる。

いかなる条件であっても、必ず最適値を見つけられるわけではない。

* 複数の凹みがある場合、降下を始めた地点からたどり着く「局所的な最小値」 _Local minimum_ になる。必ずしも「全域の最小値」 _Global minimum_ ではない。
* `α` の値は、固定であっても、勾配を進む割合が一定というわけではない。
* `α` の値は、小さすぎると収束 _Converge_ するまでに時間がかかりすぎてしまう。大きすぎると最小値を通り過ぎて、勾配を上ってしまうことになり、反復するほどに悪い解へと向かう発散 _Diverge_ を引き起こす場合もある。

訓練データ `[(1, 2), (2, 4), (3, 6)]` の仮説 `h(x) = a + b * x` の `a, b` を、最急降下法で求める例を示す。

<script type="math/tex; mode=display" id="MathJax-Element-gradient_descent_hypothesis">
h(x) = \theta_{0} + \theta_{1}{x} 
</script>
<script type="math/tex; mode=display" id="MathJax-Element-gradient_descent_a">
\theta_0 := \theta_0 - \alpha \left(\frac{1}{m} \sum_{i=1}^{m} (h(x_i) - y_i) \right)
</script>
<script type="math/tex; mode=display" id="MathJax-Element-gradient_descent_b">
\theta_1 := \theta_1 - \alpha \left(\frac{1}{m} \sum_{i=1}^{m} (h(x_i) - y_i) \cdot x_i \right)
</script>

`a = 1, b = 1, α = 0.1` として、この式を同時に更新していくと、`a = 0, b = 2` に収束することがわかる。

    a := 1 - 0.1 * (
      (
        ((1 + 1 * 1) - 2) +
        ((1 + 1 * 2) - 4) +
        ((1 + 1 * 3) - 6)
      ) / 3
    ) = 1.1000
    b := 1 - 0.1 * (
      (
        ((1 + 1 * 1) - 2) * 1 +
        ((1 + 1 * 2) - 4) * 2 +
        ((1 + 1 * 3) - 6) * 3
      ) / 3
    ) = 1.2666

    a := 1.1000 - 0.1 * (
      (
        ((1.1 + 1.2666 * 1) - 2) +
        ((1.1 + 1.2666 * 2) - 4) +
        ((1.1 + 1.2666 * 3) - 6)
      ) / 3
    ) = 1.1366
    b := 1.2666 - 0.1 * (
      (
        ((1.1 + 1.2666 * 1) - 2) * 1 +
        ((1.1 + 1.2666 * 2) - 4) * 2 +
        ((1.1 + 1.2666 * 3) - 6) * 3
      ) / 3
    ) = 1.3888

    a := 1.1366 - 0.1 * ... = 1.1452
    b := 1.1388 - 0.1 * ... = 1.4467

    ... repeated after 413 times

    a := 0.0082 - 0.1 * ... = 0.0081
    b := 1.9963 - 0.1 * ... = 1.9964

