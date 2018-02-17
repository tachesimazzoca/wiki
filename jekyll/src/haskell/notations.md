---
layout: page

title: Notations
---

<table class="table table-bordered">
<tr>
  <th>English</th>
  <th>日本語</th>
  <th></th>
</tr>
<tr>
  <td>type constructor</td>
  <td>
    <ul>
      <li>型コンストラクタ</li>
      <li>型構築子</li>
    </ul>
  </td>
  <td><pre><code>data Maybe a = Nothing | Just a</code></pre></td>
</tr>
<tr>
  <td>data constructor</td>
  <td>
    <ul>
      <li>値コンストラクタ</li>
      <li>データ構築子</li>
    </ul>
  </td>
  <td><pre><code>a = Just 123
b = Nothing</code></pre></td>
</tr>
<tr>
  <td>algebraic data type</td>
  <td>
    <ul>
      <li>代数データ型</li>
      <li>代数的データ型</li>
    </ul>
  </td>
  <td><pre><code>data Tree a
  = EmptyTree
  | Leaf a
  | Node (Tree a) (Tree a)</code></pre></td>
</tr>
<tr>
  <td>type class</td>
  <td>
    <ul>
      <li>型クラス</li>
    </ul>
  </td>
  <td><pre><code>class Monad m where
  (>>=)  :: m a -> (a -> m b) -> m b
  (>>) :: m a -> m b -> m b
  return :: a -> m a
  fail :: String -> m a</code></pre></td>
</tr>
<tr>
  <td>type (parameter|variable)</td>
  <td>
    <ul>
      <li>型パラメータ</li>
      <li>型変数</li>
    </ul>
  </td>
  <td><pre><code>head :: [a] -> a</code></pre></td>
</tr>
<tr>
  <td>curried function</td>
  <td>
    <ul>
      <li>カリー化関数</li>
    </ul>
  </td>
  <td><pre><code>min :: Ord a => a -> a -> a</code></pre></td>
</tr>
<tr>
  <td>partial application</td>
  <td>
    <ul>
      <li>部分適用</li>
    </ul>
  </td>
  <td><pre><code>&gt;&gt;&gt; let limitPoint = min 100
&gt;&gt;&gt; limitPoint 101
100</code></pre></td>
</tr>
<tr>
  <td>higher-order function</td>
  <td>
    <ul>
      <li>高階関数</li>
    </ul>
  </td>
  <td><pre><code>map :: (a -> b) -> [a] -> [b]
map _ [] = []
map f (x:xs) = f x : map f xs</code></pre></td>
</tr>
</table>
