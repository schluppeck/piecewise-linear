# piecewise-linear

<!-- MathJax -->
<script type="text/javascript"
  src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.3/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>

find change in data / transition in piece-wise linear data (KW's thesis corrections)

ds, 2025-06-09

## Idea

use a piecewise linear model to find the change in data at some transition point in t.

1. first idea was to use the function `ischange()` - but it looks like that might not be doing the right thing.
2. second idea is what I have used before: use a piecewise linear model to find the change in data at some transition point in t and fit the data with `lsqcurvefit()` in MATLAB. The estimated transition point is then one of the parameters that is being estimated.

in `pwFunction()` I use the convention `x = [m1, m2, k, c1]` where `m1` and `m2` are the slopes of the two lines, `k` is the transition point and `c1` is the y-intercept of the first line.


$$
y(t) = \begin{cases}
  m_1t+c_1  & t < k  \text{ , where}\, k \text{ is the knot point}   \\
  m_2t + k(m_1-m_2) + c_1 & t \ge k 
\end{cases}
$$

![](./low-noise-case.png)

and with a bit more noise

![](./higer-noise-case.png)

## Notes

The code is in the [github repository `piecewise-linear`](https://github.com/schluppeck/piecewise-linear).

The intercept of the second line segment depends on the parameters of the first  and the gradient of the second. Can figure this out with a bit of algebra.

![](./find-c2-param.png)

## Establishing significance of changes

- use piece-wise linear model to get find a knot point and then look at the two portions to establish regression weights and confidence intervals... that allows you to look at the gradients of the line segments and their CIs to check if they are different -- a good starting point would be: if CIs overlap, then you can't exlude the intepretation that there is **no** change.

![with linear regression](./using_linregress_intervals.png)


- other option is to look at the output from `findchangepts()` and compare the residual error to the variance of the data

![with findchangepts()](./using_findchangepts.png)