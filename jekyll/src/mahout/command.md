---
layout: page

title: Command
---

## itemsimilarity

アイテムから類似アイテムを抽出します。

    % hadoop fs -rmr inputdir
    % hadoop fs -rmr outputdir
    % hadoop fs -put /path/to/data/* inputdir/.

    % mahout itemsimilarity --input inputdir --output outputdir --similarityClassname SIMILARITY_LOGLIKEHOOD --maxSimilaritiesPerItem 5 --booleanData true

以下の形式で入力データを準備します。

    ユーザID,アイテムID[,評価値]
    ....

**Job-Secific Options:**

<table class="table table-bordered table-striped">
<tr>
  <td><code>--input</code> <code>-i</code></td><td>HDFS入力ディレクトリ</td>
</tr>
<tr>
  <td><code>--output</code> <code>-o</code></td><td>HDFS出力ディレクトリ</td>
</tr>
<tr>
  <td><code>--similarityClassname</code> <code>-s</code></td>
  <td>
    <p>類似判定の計算方法を指定。<a href="https://builds.apache.org/job/Mahout-Quality/javadoc/org/apache/mahout/math/hadoop/similarity/cooccurrence/measures/VectorSimilarityMeasures.html">VectorSimilarityMeasures</a> 参照</p>
    <ul>
      <li><code>SIMILARITY_COOCCURRENCE</code></li>
      <li><code>SIMILARITY_LOGLIKELIHOOD</code></li>
      <li><code>SIMILARITY_TANIMOTO_COEFFICIENT</code></li>
      <li><code>SIMILARITY_CITY_BLOCK</code></li>
      <li><code>SIMILARITY_COSINE</code></li>
      <li><code>SIMILARITY_PEARSON_CORRELATION</code></li>
      <li><code>SIMILARITY_EUCLIDEAN_DISTANCE</code></li>
    </ul>
  </td>
</tr>
<tr>
  <td><code>--maxSimilaritiesPerItem</code> <code>-m</code></td>
  <td>最大類似アイテム数。デフォルトは 100</td>
</tr>
<tr>
  <td><code>--maxPrefsPerUser</code> <code>-mppu</code></td>
  <td>
    <p>評価値の上限。同値に評価値が制限される。デフォルトは 1000</p>
  </td>
</tr>
<tr>
  <td><code>--minPrefsPerUser</code> <code>-mp</code></td>
  <td>
    <p>評価値の下限。同値未満の評価値のデータは無視される。デフォルトは 1</p>
  </td>
</tr>
<tr>
  <td><code>--booleandData</code> <code>-b</code></td>
  <td>
    <p>評価値を持たないデータの場合 <code>true</code> を指定。デフォルトは <code>false</code></p>
  </td>
</tr>
</table>

**org.apache.mahout.cf.taste.hadoop.similarity.item.ItemSimilarityJob**

* [JavaDoc](https://builds.apache.org/job/Mahout-Quality/javadoc/org/apache/mahout/cf/taste/hadoop/similarity/item/ItemSimilarityJob.html)
* [View Source](http://svn.apache.org/viewvc/mahout/trunk/core/src/main/java/org/apache/mahout/cf/taste/hadoop/similarity/item/ItemSimilarityJob.java?view=markup)

