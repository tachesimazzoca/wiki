---
layout: page

title: Anomaly Detection
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Normal Distribution

正規（ガウス）分布 _Normal (Gaussian) distribution_ により、平均値を頂点として、データがどのように分散しているか（どのような確率分布を持っているか）を示すことができる。

<script type="math/tex; mode=display" id="MathJax-Element-normal_distribution">
{\scriptsize \text{$\mu = $ the mean of $x$}} \\
{\scriptsize \text{$\sigma^{2} = $ the variance of $x$ ($\sigma =$ standard deviation)}} \\
\begin{align}
p(x; \mu, \sigma^{2}) & = \frac{1}{ \sqrt{ 2 \pi \sigma^{2} } } \exp \left( - \frac{ (x - \mu)^{2} }{ 2 \sigma^{2} } \right) \\
\end{align} \\
</script>

* `μ` は平均値
* `σ` は標準偏差で、`σ^2` で分散度合い（平均値からの距離）を示す。
* 確率関数 `p` をグラフにプロットすると、平均値を頂点として、左右対称のベル上の形状を描く。`σ^2` 値が大きいほど、頂点（平均値である確率）が下がり、勾配がなだらかになり、まんべんなく分布していることを示す。

## Anomaly Detection Algorithm

各パラメータ毎に正規分布から得られた確率値の積として、確率関数 `p` を定義する。

<script type="math/tex; mode=display" id="MathJax-Element-anomaly_detection_algorithm">
\begin{align}
\mu_{j} & = \frac{1}{m} \sum_{i = 1}^{m} x_{j}^{(i)} \\
\sigma_{j}^{2} & = \frac{1}{m} \sum_{i = 1}^{m} (x_{j}^{(i)} - \mu_{j})^{2} \\
p(x) & = p(x_1; \mu_1, \sigma_1^2) \cdot p(x_2; \mu_2, \sigma_2^2) \cdot \ldots \cdot p(x_n; \mu_n, \sigma_n^2) \\
& = \prod_{j = 1}^{n} p(x_{j}; \mu_{j}, \sigma_{j}^{2}) \\
& = \prod_{j = 1}^{n} \frac{1}{ \sqrt{ 2 \pi \sigma_{j}^{2} } } \exp \left( - \frac{ (x_{j} - \mu_{j})^{2} }{ 2 \sigma_{j}^{2} } \right) \\
\end{align} \\
</script>

既知の正常データが 10,000 件、例外データが 20 件あるとすと、以下のように配分すると良い。確率分布を求める学習データは正常データのみである点に注意する。

* 学習データ: 正常データのみの 6,000 件
* 検証データ: 正常データ 2,000 件 / 例外データ 10 件
* テストデータ: 正常データ 2,000 件 / 例外データ 10 件

学習データから、確率関数 `p`（平均値 `μ` と分散度 `σ^2`）を決める。

次に、例外と見なす分岐点（確率）を決める。学習データから得られた確率関数より、検証データの確率値ベクトルを得る。確率値の最小値と最大値の間で、任意のステップ数（1,000 程度）で分岐点を取り出し、分岐点よりも確率値が小さければ、例外であるとみなす。

{% highlight octave %}
% pval: vector of probabilities
s = (max(pval) - min(pval)) / 1000;
for v in min(pval):s:max(pval)
    predictions = (pval < v); % vector of (0:normal|1:anomaly)
    ...
end
{% endhighlight %}

分岐点ごとに、精度 _Precision_ と再現率 _Recall_ を算出し、_F-score_ が最も良い分岐点を採用する。

<script type="math/tex; mode=display" id="MathJax-Element-anomaly_detection_algorithm_fscore">
{\scriptsize \text{$tp = $ true positive, $fp = $ false positive, $fn = $ false negative}} \\
{\scriptsize \text{$P = $ Precision, $R = $ Recall}} \\
P = \frac{tp}{tp + fp} \\
R = \frac{tp}{tp + fn} \\
F_{1} = 2 \frac{PR}{P + R} \\
</script>

* True Positive: 正常データを正常と判定した数（予測成功）
* False Positive: 正常データを例外と判定した数（予測失敗）
* False Negative: 例外データを正常と判定した数（予測失敗）

分岐点が決定したら、テストデータに対して例外を予測し、その精度を確かめる。

