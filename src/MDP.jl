# A markov decision process
# An MDP is formalised as a procedure which takes some input state $A$
# And reurns some new state S
abstract MDP
immutable StopState{T} end

include("MDP/gridworld.jl")
include("MDP/ale.jl")
