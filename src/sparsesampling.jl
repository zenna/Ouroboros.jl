## Vanilla Sparse Sampling
## =======================

# Do sparse sampling with model
function ss{M<:MDP}(depth, nsamples, γ, model::Model, mdp::M, s0)
  options::Vector = estimate_q(depth, nsamples, γ, model, mdp, s0)
  m,i = findmax(options) # TODO: WHat if there are many maxes
  @show options,i
  actions(mdp, s0)[i]
end

function estimate_q(depth, nsamples, γ, model::Model, mdp, state)
  if depth == 0
    return [0.0]
  end

  all_actions = actions(mdp,state)
  Qs = Float64[]
  for a in all_actions
#     println("Depth: $depth - action $a")
    states_rewards = [rand(model, state, a) for i = 1:nsamples]
    reward = γ/nsamples * sum([sr[2] for sr in states_rewards])
    v_values = [estimate_v(depth - 1, nsamples, γ, model, mdp, state)]
    push!(Qs, reward + γ/nsamples * sum(v_values))
  end
  Qs
end

function estimate_v(depth, nsamples, γ, model::Model, mdp, state)
  qsamples = estimate_q(depth, nsamples, γ, model, mdp, state)
  maximum(qsamples)
end

function play(depth, nsamples, γ, model, mdp::MDP, nsteps::Int)
  history = Any[]
  s = init!(mdp)
  push!(history,(s,0,0))
  for i = 1:nsteps
    action = ss(depth, nsamples, γ, model, mdp, s)
    s,r = act!(mdp, action)
    push!(history,(s,r))
  end
  history
end