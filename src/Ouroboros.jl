module Ouroboros

using Sigma
using Window
using Distributions
using Iterators
using Gadfly
import Base: print, rand
import Gadfly: layer
import Sigma:call
import Sigma: rand_select

include("MDP.jl")
include("model.jl")
include("sparsesampling.jl")
include("landscapes.jl")
include("transforms.jl")
include("policy.jl")

end
