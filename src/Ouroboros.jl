module Ouroboros

using Sigma
using Lens
using Distributions
using Iterators
using Gadfly
import Base: show, showcompact, print
import Base: print, rand
import Gadfly: layer
import Sigma:call, rand_select

if VERSION < v"0.4.0-dev"
    using Docile
end

include("common.jl")
include("typedsexpr.jl")

include("MDP.jl")
include("model.jl")
include("landscapes.jl")
include("lambda.jl")

include("functions/primarith.jl")
include("functions/primprogram.jl")
include("functions/complexprogram.jl")
include("vis.jl")

include("optimization/hillclimb.jl")
include("learn.jl")

# Planners
include("planners/sparsesampling.jl")
# include("planners/abstractss.jl")

end
