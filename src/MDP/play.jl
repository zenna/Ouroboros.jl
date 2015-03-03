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
      lens(:post_action, state=state, reward=reward)
      push!(rewards,reward)
    end
    i += 1
  end
  lens(:end_play, rewards)
  rewards
end

function quickplay{T<:MDP}(mdp::T,policy; args...)
  s0 = randinit!(mdp)
  play(mdp,s0,policy;args...)
end

quickplay(gen_mdp::Function, policy; args...) =
  quickplay(gen_mdp(),policy;args...)
