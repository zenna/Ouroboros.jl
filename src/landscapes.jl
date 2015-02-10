rastrigin(x::Vector) = 10 * length(x) + sum([xi^2 - 10*cos(2pi*xi) for xi in x])
