module Ouroboros

using Window
using Distributions
using Iterators
using Gadfly
import Base: print, rand
import Gadfly: layer

include("MDP.jl")
include("model.jl")
include("ale.jl")
include("sparsesampling.jl")
include("landscapes.jl")

end
