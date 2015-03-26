---
layout: page

title: Clustering
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## K-means Algorithm

_K-means algorithm_ は、教師なし学習 _Unsupervised Learning_ の一つで、正解のないデータから、学習データの分布を頼りに分類を見つけ出すことができる。

* 分類数を `K` とする。
* 学習データの中から、任意の `K` 個のデータを選び、同じ位置に分類の重心 _Centroid_ を置く。
* 学習データ毎に、最も近い重心に紐づける。
* 各重心を、紐づいた学習データの平均位置に移動する。

