# Logarithms

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({ tex2jax: { inlineMath: [['$','$'], ["\\(","\\)"]] } });
</script>
<script type="text/javascript"
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML">
</script>

## Definition

* <http://en.wikipedia.org/wiki/Logarithm>

> The logarithm of a positive real number *x* with respect to base *b*, a positive real number not equal to 1, is the exponent by which *b* must be raised to yield *x*. In other words, the logarithm of *x* to base *b* is the solution *y* to the equation.

<script type="math/tex; mode=display" id="MathJax-Element-1-1">
x = b^y \quad y = \log_{b}x \quad x = b^{\log_{b}x}
</script>

If any base *b* is equal to the anti-logarithm, the logarithm is always *1*.

<script type="math/tex; mode=display" id="MathJax-Element-1-2">
\log_{b}b = 1 \quad \log_{2}2 = 1 \quad 2^1 = 2
</script>

If the anti-logarithm is *1*, the logarithm is always *0*.

<script type="math/tex; mode=display" id="MathJax-Element-1-3">
\log_{b}1 = 0 \quad \log_{2}1 = 0 \quad \log_{10}1 = 0
</script>

## Formula

<script type="math/tex; mode=display" id="MathJax-Element-2-1">
\begin{align}
\log_{b}(xy) = \log_{b}x + \log_{b}y \quad \dots \quad \log_{2}16
  & = \log_{2}(4\cdot4) = \log_{2}4 + \log_{2}4 = 2 + 2 = 4 \\
  & = \log_{2}(2\cdot8) = \log_{2}2 + \log_{2}8 = 1 + 3 = 4 \tag{1}
\end{align}
</script>

<script type="math/tex; mode=display" id="MathJax-Element-2-2">
\begin{align}
\log_{b}\left(\frac{x}{y}\right) = \log_{b}x - \log_{b}y \quad \dots \quad \log_{2}16
  & = \log_{2}\left(\frac{32}{2}\right) = \log_{2}32 - \log_{2}2 = 5 - 1 = 4 \\
  & = \log_{2}\left(\frac{64}{4}\right) = \log_{2}64 - \log_{2}4 = 6 - 2 = 4 \tag{2}
\end{align}
</script>

<script type="math/tex; mode=display" id="MathJax-Element-2-3">
\begin{align}
\log_{b}{x^p} = p\log_{b}x \quad \dots \quad \log_{2}64
 & = \log_{2}{2^6} = 6 \log_{2}2 = 6 \cdot 1 = 6 \\
 & = \log_{2}{4^3} = 3 \log_{2}4 = 3 \cdot 2 = 6 \tag{3}
\end{align}
</script>

<script type="math/tex; mode=display" id="MathJax-Element-2-4">
\begin{align}
\log_{b}\sqrt[p]{x} = \frac{\log_{b}x}{p} \quad \dots \quad
  & \log_{10}\sqrt{10000} = \frac{\log_{10}10000}{2} = \frac{4}{2} = 2 \\
  & \log_{10}\sqrt{1000} = \frac{\log_{10}1000}{2} = \frac{3}{2} = 1.5 \\
  & \log_{2}\sqrt[3]{64} = \frac{\log_{2}64}{3} = \frac{6}{3} = 2 \tag{4}
\end{align}
</script>

1. **Product**: The logarithm of a product is the sum of the logarithms of the numbers being multiplied.
2. **Quotient**: The logarithm of the ratio of two numbers is the difference of the logarithms.
3. **Power**: The logarithm of the p-th power of a number is p times the logarithm of the number itself.
4. **Root**: The logarithm of a p-th root is the logarithm of the number divided by p.

### Change of base

The logarithm can be computed from the logarithms of *x* and *b* with respect to an arbitrary base *k*.

<script type="math/tex; mode=display" id="MathJax-Element-2-5-1">
\log_{b}x = \frac{\log_{k}x}{\log_{k}b}
 = \frac{\log_{e}x}{\log_{e}b}
 = \frac{\log_{10}x}{\log_{10}b} = \dots
</script>

<script type="math/tex; mode=display" id="MathJax-Element-2-5-2">
\begin{align}
\log_{8}64 & = \frac{\log_{8}64}{\log_{8}8} = \frac{2}{1} = 2 \\
  & = \frac{\log_{2}64}{\log_{2}8} = \frac{6}{3} = 2
\end{align}
</script>

Given a number x and its logarithm logb(x) to an unknown base b, the base is given by:

<script type="math/tex; mode=display" id="MathJax-Element-2-5-3">
\begin{align}
& b = x^\frac{1}{\log_{b}(x)} \\
& 10 = 100^\frac{1}{\log_{10}100} = 100^\frac{1}{2} = \sqrt{100} \\
& 2 = 64^\frac{1}{\log_{2}64} = 64^\frac{1}{6} = \sqrt[6]{64} = \sqrt{4}
\end{align}
</script>

## Exercises

### Q.1

<p>Solve the exponential equation. <script type="math/tex" id="MathJax-Element-3-1-1">2^x = 3^{x-1}</script>:</p>

<script type="math/tex; mode=display" id="MathJax-Element-3-1-2">
\begin{align}
\log_{2}(2^x) & = \log_{2}(3^{x-1}) \\
x\log_{2}2 & = (x-1)\log_{2}3 \\
x & = x\log_{2}3-\log_{2}3 \\
x\log_{2}3-x & = \log_{2}3 \\
x(\log_{2}3-1) & = \log_{2}3 \\
\\
x & = \frac{a}{a-1} \quad \dots \quad a = \log_{2}3, \quad a \neq 1 \\
\end{align}
</script>

### Q.2

<p>Plot running time <em>T(N)</em> vs. input size <em>N</em> using log-log scale. <script type="math/tex" id="MathJax-Element-3-2-1">\log_{2}(T(N)) = b\log_{2}N + c</script>:</p>

<script type="math/tex; mode=display" id="MathJax-Element-3-2-2">
\begin{align}
\log_{2}(T(N)) & = b\log_{2}N + c \\
\log_{2}(T(N)) & = \log_{2}{N^b} + c \\
2^{\log_{2}(T(N))} & = 2^{\log_{2}{N^b} + c} \\
T(N) & = 2^{\log_{2}{N^b}} \cdot 2^c \\
T(N) & = {N^b} \cdot 2^c \\
\\
T(N) & = aN^b \quad \dots \quad a = 2^c
\end{align}
</script>
