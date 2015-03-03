## Optimisation Test Functions
## ===========================

# http://en.wikipedia.org/wiki/Test_functions_for_optimization

# n = 3
beale(x::LA) =  (1.5 - x[1] + x[1]x[2])^2 +
                (2.25 - x[1] + x[1]x[2]^2)^2 +
                (2.625 - x[1] + x[1]x[2]^3)^2

# n = 4
function powell(x::Vector)
    return (x[1] + 10.0 * x[2])^2 + 5.0 * (x[3] - x[4])^2 +
            (x[2] - 2.0 * x[3])^4 + 10.0 * (x[1] - x[4])^4
end

#  n = n
rastrigin(x::LA) = 10 * length(x) + sum([xi*xi - 10*cos(2pi*xi) for xi in x])
rosenbrock(x::LA) = sum([100(x[i+1] - x[i]^2)^2 + (x[i]-1)^2 for i=1:length(x)-1])
sphere(x::LA) = sum([xi^2 for xi in x])
