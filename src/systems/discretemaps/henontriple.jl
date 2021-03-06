"""
    eom_henon_triple(x, p, n) -> Function

Iterate a 3D discrete system consisting of coupled Henon maps where the coupling
is x1 -> x2 -> x3 [1]. This version allows for tweaking the parameters of the
equations.

The difference equations are:

```math
\\begin{aligned}
x_1(t+1) &= a - x_1(t)^2 + b x_1(t-2) \\
x_2(t+1) &= a - c x_1(t) x_2(t)- (1 - c) x_2(t)^2 + b x_2(t-1) \\
x_3(t+1) &= c x_2(t) x_3(t) - (1 - c) x_3(t)^2 + b x_3(t-1)
\\end{aligned}
```

Here ``c`` is the coupling constant. The system becomes completely synchronized
for ``c >= 0.7``.

# References
1. Papana, A., Kyrtsou, C., Kugiumtzis, D., & Diks, C. (2013). Simulation study of
direct causality measures in multivariate time series. Entropy, 15(7), 2635–2661.
"""
function eom_henon_triple(u, p, n)
    O = zeros(Float64, n + 3, 3)
    x₁, x₂, x₃ = (u...,)
    a, b, c = (p...,)

    # Propagate initial condition to the three first time steps.
    for i = 1:3
        O[i, 1] = x₁
        O[i, 2] = x₂
        O[i, 3] = x₃
    end
    for i = 4:n+3
        x₁1 = O[i-1, 1]
        x₁2 = O[i-2, 1]
        x₂1 = O[i-1, 2]
        x₂2 = O[i-2, 2]
        x₃1 = O[i-1, 3]
        x₃2 = O[i-2, 3]

        x₁new = a - x₁1^2 + b*x₁2
        x₂new = a - c*x₁1*x₂1 - (1 - c)*x₂1^2 + b*x₂2
        x₃new = a - c*x₂1*x₃1 - (1 - c)*x₃1^2 + b*x₃2

        O[i, 1] = x₁new
        O[i, 2] = x₂new
        O[i, 3] = x₃new
    end

    return O[4:end, :]
end


function henon_triple(uᵢ, a, b, c, noise_frac, n::Int, n_transient::Int)
    p = [a, b, c]
    o = eom_henon_triple(uᵢ, p, n + n_transient)

    # Observational noise
    if noise_frac > 1e-8
        # Add observational noise equal to a fraction of `noise_frac` of the
        # standard deviation along each coordinate axis.
        σ₁ = std(o[:, 1])
        σ₂ = std(o[:, 2])
        σ₃ = std(o[:, 3])
        η₁ = rand(Normal(0, σ₁*noise_frac), n + n_transient)
        η₂ = rand(Normal(0, σ₂*noise_frac), n + n_transient)
        η₃ = rand(Normal(0, σ₃*noise_frac), n + n_transient)

        for i = 1:3
            o[:, 1] = o[:, 1] .+ η₁
            o[:, 2] = o[:, 2] .+ η₂
            o[:, 3] = o[:, 3] .+ η₃
        end
    end
    x, y, z = o[n_transient+1:end, 1], o[n_transient+1:end, 2], o[n_transient+1:end, 3]
    return Dataset(x, y, z)
end


"""
    henon_triple(x, p, n) -> Function

Iterate a 3D discrete system consisting of coupled Henon maps where the coupling
is x1 -> x2 -> x3 [1]. This version allows for tweaking the parameters of the
equations.

The difference equations are:

```math
\\begin{aligned}
x_1(t+1) &= a - x_1(t)^2 + b x_1(t-2) \\
x_2(t+1) &= a - c x_1(t) x_2(t)- (1 - c) x_2(t)^2 + b x_2(t-1) \\
x_3(t+1) &= c x_2(t) x_3(t) - (1 - c) x_3(t)^2 + b x_3(t-1)
\\end{aligned}
```

Here ``c`` is the coupling constant. The system becomes completely synchronized
for ``c >= 0.7``.

# References
1. Papana, A., Kyrtsou, C., Kugiumtzis, D., & Diks, C. (2013). Simulation study of
direct causality measures in multivariate time series. Entropy, 15(7), 2635–2661.
"""
function henon_triple(;uᵢ = rand(3), a = 1.4, b = 0.3, c = 0.0,
        noise_frac = 0, n::Int = 100, n_transient::Int = 100)
    henon_triple(uᵢ, a, b, c, noise_frac, n, n_transient)
end
