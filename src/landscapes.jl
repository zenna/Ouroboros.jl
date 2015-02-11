## Optimisation Test Functions
## ===========================

# http://en.wikipedia.org/wiki/Test_functions_for_optimization
rastrigin(x::LA) = 10 * length(x) + sum([xi*xi - 10*cos(2pi*xi) for xi in x])
beale(x::LA) =  (1.5 - x[1] + x[1]x[2])^2 +
                (2.25 - x[1] + x[1]x[2]^2)^2 +
                (2.625 - x[1] + x[1]x[2]^3)^2
sphere(x::LA) = sum([xi^2 for xi in x])
