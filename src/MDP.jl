# A markov decision process
# An MDP is formalised as a procedure which takes some input state $A$
# And reurns some new state S
abstract MDP
immutable StopState{T} end
immutable StartState{T} end

# From an MDP create an empty Program which maps to actions in that MDP
# And takes as input the state type of that MDP
function empty_lambda{T<:MDP}(MDPType::Type{T})
  actionfunc::PrimFunc = action_ts(MDPType)
  missing_args = Any[Missing{M}() for M in actionfunc.argtypes]
  ts = TypedSExpr(actionfunc,missing_args)
  Lambda([Var(:state,state_type(MDPType))],ts)
end


include("MDP/gridworld.jl")
include("MDP/ale.jl")
