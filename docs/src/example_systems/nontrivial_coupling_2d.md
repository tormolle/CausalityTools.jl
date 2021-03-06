# Synthetic coupled dynamical systems

## A nontrivially coupled 2D system

For this example, we'll consider set of two nontrivially coupled maps, given by
the difference equations

```math
\begin{aligned}
x(t+1) &= p_2 + p_3 x(t-2) + \dfrac{p_4 - p_5 y(t-3)}{1 + e^{-p_6 y(t-3)}} + \xi_1(t) \\
y(t+1) &= p_1 y(t) + \xi_2(t).
\end{aligned}
```

Here, ``\xi_{1,2}(t)`` are two independent normally distributed noise processes
with zero mean and standard deviations ``\sigma_1`` and ``\sigma_2``. The
``\xi_{1,2}(t)`` terms represent dynamical noise.


## Where has the system been used?
Iterate a 2d discrete system with nonlinear, nontrivial coupling. This system
is from [Péguin-Feissolle & Teräsvirta (1999)](https://www.amse-aixmarseille.fr/sites/default/files/_dt/greqam/99a42.pdf), and
was also studied in [Chávez et al. (2003)](https://www.sciencedirect.com/science/article/pii/S0165027002003679).

The version implemented here allows for tweaking the parameters of the equations.

## Create an iterator of the system

```@setup nontrivial_2d
using CausalityTools
using DynamicalSystems
using Plots
using Statistics
using StaticArrays
using Distributions
```

We first define the equations of motion.

```@example nontrivial_2d
function eom_nontrivial_2d(u, p, n)
    n = n + 10
    O = zeros(Float64, n + 3, 2)
    x, y = (u...,)
    p₁, p₂, p₃, p₄, p₅, p₆, σ₁, σ₂ = (p...,)

    # Propagate initial condition to the three first time steps.
    for i = 1:3
        O[i, 1] = x
        O[i, 2] = y
    end
    for i = 4:n
        y1 = O[i-1, 2]
        x2 = O[i-2, 1]
        y3 = O[i-3, 2]

        ξ₁ = rand(Normal(0, σ₁))
        ξ₂ = rand(Normal(0, σ₂))
        ynew = p₁*y1 + ξ₁
        xnew = p₂ + p₃*x2 + (p₄ - p₅*y3)/(1 + exp(-p₆*y3)) + ξ₂
        O[i, 1] = xnew
        O[i, 2] = ynew
    end
    O = O[10+3:end-10, :]
    O[:, 1] .= O[:, 1] .- mean(O[:, 1])
    O[:, 2] .= O[:, 2] .- mean(O[:, 2])
    O[:, 1] .= O[:, 1] ./ std(O[:, 1])
    O[:, 2] .= O[:, 2] ./ std(O[:, 2])
    return Dataset(O)
end
nothing #hide
```

To make things easier to use, we create function that generates a
DiscreteDynamicalSystem instance for value of the parameters.


```@example nontrivial_2d
function nontrivial_2d(;uᵢ = rand(2), n::Int = 100,
        σ₁ = 0.1, σ₂ = 0.1,
        p₁ = 0.7, p₂ = 0.1, p₃ = 0.4,
        p₄ = 2.4, p₅ = 0.9, p₆ = 4)
    p = [p₁, p₂, p₃, p₄, p₅, p₆, σ₁, σ₂]
    eom_nontrivial_2d(uᵢ, p, n)
end
nothing #hide
```

An example of the system is:

```@example nontrivial_2d
orbit = nontrivial_2d(n = 100)
x, y = orbit[:, 1], orbit[:, 2]
plot(x, label = "x", lc = :black)
plot!(y, label = "y", lc = :red)
xlabel!("Time step"); ylabel!("Value")
savefig("nontrivial_2d.svg") #hide
nothing #hide
```

![](nontrivial_2d.svg)

## Predefined system
This system is predefined in `CausalityTools.Systems`, and can be initialized using the `nontrivial_pegiun` function.

## References

Péguin-Feissolle, A., & Teräsvirta, T. (1999). A General Framework for
Testing the Granger Noncausaality Hypothesis. Universites d’Aix-Marseille II
et III. [https://www.amse-aixmarseille.fr/sites/default/files/_dt/greqam/99a42.pdf](https://www.amse-aixmarseille.fr/sites/default/files/_dt/greqam/99a42.pdf)

Chávez, M., Martinerie, J., & Le Van Quyen, M. (2003). Statistical
assessment of nonlinear causality: application to epileptic EEG signals.
Journal of Neuroscience Methods, 124(2), 113–128.
doi:10.1016/s0165-0270(02)00367-9
[https://www.sciencedirect.com/science/article/pii/S0165027002003679](https://www.sciencedirect.com/science/article/pii/S0165027002003679)
