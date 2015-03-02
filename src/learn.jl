## General Procedurs For Learning
## =============================

@doc """
Play an MDP with a policy
Iteratively 1) get action from policy in state 2) act 3) update state
""" ->
function play{T<:MDP}(mdp::T,s,policy; niters = 10)
  i = 1
  rewards = Float64[]
  while s != StopState{T} && i < niters
    try
      lens(:pre_action, policy=policy, state=s)
      action = call(policy,s)
      state,reward = act!(mdp, action)
      lens(:post_action, state=state, reward=reward)
      push!(rewards,reward)
    catch e
#       rethrow(e)
#       isa(e, MethodError) && rethrow(e)
      # If you fail, do a no_action
      state,reward = act!(mdp, no_action(T))
      push!(rewards,reward)
    end
    i += 1
  end
  rewards
end

include("learn/hillclimb.jl")
include("learn/markovmodel.jl")
