"""
    eom_henon2(dx, x, p, n)

Equations of motion for a 4D Henon system consisting of two identical
Henon maps, `X` and `Y` with unidirectional forcing from `X` to`Y` [1].

# References

1. Krakovská, A., Jakubík, J., Chvosteková, M., Coufal, D.,
Jajcay, N., & Paluš, M. (2018). Comparison of six methods for the detection of
causality in a bivariate time series. Physical Review E, 97(4), 042207.
"""
function eom_henon2(x, p, n)
    c = p[1]
    x₁, x₂, y₁, y₂ = (x...)
    dx₁ = 1.4 - x₁^2 + 0.3*x₂
    dx₂ = x₁
    dy₁ = 1.4 - (c * x₁ * y₁  +  (1 - c)*y₁^2) + 0.3*y₂
    dy₂ = y₁
    return SVector{4}(dx₁, dx₂, dy₁, dy₂)
end

doc"""
    henon2(u₀, c) -> DiscreteDynamicalSystem

Initialize an instance of a 4D Henon map system consisting of two identical
Henon systems, ``$x$`` and``$y$`` [1]. The subsystems are unidirectionally
coupled . Synchronization occurs when the values of the coupling constant
``$c$ > 0.7`` [2].

The difference equations are:

```math
\begin{aligned}
x_1(t+1) &= 1.4 - x_1^2(t) + 0.3x\_2(t) \\
x_2(t+1) &= x_1(t) \\
y_1(t+1) &= 1.4 - [c*x_1(t)*y_1(t) + (1-c)*y_1^2(t)] + 0.3*y\_2(t)\\
y_2(t+1) &= y_1(t)
\end{aligned}
```

This system was studied in [1] to study the performance of different
causality detection algorithms.

# References
1. Krakovská, A., Jakubík, J., Chvosteková, M., Coufal, D.,
Jajcay, N., & Paluš, M. (2018). Comparison of six methods for the detection of
causality in a bivariate time series. Physical Review E, 97(4), 042207.
"""
function henon2(u₀, c)
    p = [c]
    logistic_system = DiscreteDynamicalSystem(eom_henon2, u₀, p)
    return logistic_system
end

henon2(;u₀ = rand(4), c = 2.0) = henon2(u₀, c)