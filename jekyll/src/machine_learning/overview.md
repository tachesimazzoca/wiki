---
layout: page

title: Overview
---

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

_Classification problem_ は、`(YES|NO)` や `(A|B|C)` のように区分された値 _Discrete-value_ に分類する問題を指す。

* 過去の対戦成績から、勝敗を予測する
* オーディオデータから、ボーカル曲かどうかを判定する
* 腫瘍の大きさから、良性か悪性かを予測する

_Regression problem_ は、連続値 _Continuous-value_ すなわち、量を求める問題を指す。数は整数値として考えれば、区切られているように感じてしまうが、単に取引上の単位であって、実際には境界のない連続値である。

* 部屋の大きさから、家賃を予測する
* 過去の雨量データから、降水量を予測する
* 過去実績から、売上げを予測する

### Supervised Learning vs. Unsupervised Learning

_Supervised learning_ は、予め正解（分類）が分かっていて、その分類に振り分ける手法になる。

* 真偽 / 勝敗 / 可否
* 性別
* ラベル（重要|通常|スパム）

_Unsupervised learning_ は、正解（分類）自体が定義されていない状態から、分類を抽出していく手法になる。

* 記事内容から、同種の記事を見つける（記事のカテゴリは不定）
* 行動パターンから、似ているユーザ同士を見つける（どのようなユーザかは不定）
* 投薬結果から、同症状を引き起こす患者同士を見つける（どのような副作用を起こすかは不定）

