## General Procedurs For Learning
## =============================

# Play an MDP with a policy
function play{T<:MDP}(mdp::T,s,policy; niters = 10)
  i = 1
  rewards = Float64[]
  while s != StopState{T} && i < niters
    try
#       print("\n")
#       @show policy
#       @show s
      action = call(policy,s)
      window(:state,policy)
#       @show action
#       @show expr(policy)
      state,reward = act!(mdp, action)
      push!(rewards,reward)
    catch e
#       e.msg != "cannot compile with missing values" && @show e
      isa(e,MethodError) && rethrow(e)
      # If you fail, do a no_action
      state,reward = act!(mdp, no_action(T))
      push!(rewards,reward)
    end
    i += 1
  end
#   @show rewards
  rewards
end

include("learn/hillclimb.jl")
include("learn/VOMM.jl")