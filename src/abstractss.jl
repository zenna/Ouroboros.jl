## Abstract Sparse Sampling
## =======================
actions_rv{N}(mdp::GridWorld{N}) =
  PureRandArray(RandVar{Int}[discreteuniform(-1,1) for i = 1:N])

actions_rv(mdp,s) = actions_rv(mdp)

# Abstract Sparse Sampling
function ass{M<:MDP}(depth, nsamples, γ, model::Model, mdp::M, s0)
  options = a_estimate_q(depth, nsamples, γ, model, mdp, s0)
end

function a_estimate_q(depth, nsamples, γ, model::Model, mdp, state)
  if depth == 0
    return [0.0]
  end

  states = Any[]; rewards = Any[]
  for i = 1:depth
    action = actions_rv(mdp,state)
    state,reward = call(model, state, action)
    @show "got"
    push!(states, state)
    push!(rewards, reward)
  end
  states,rewards
end

## Example
## =======
tenboard = [0 0
            10 10]
noobs = Array(Int,0,0)
obstacles = [-3 -3 -3 -3 -3 -3
             -5 -4 -3 -2 -1 0]

sphere2d = GridWorld{2}(tenboard-5, [0,0], x->1-sphere(x), obstacles)
gen_model = CheatModel(sphere2d)
s0 = init!(sphere2d)
states,rewards = ass(3,1,0.5,gen_model,sphere2d,s0)

states
# history = play(4, 1, 0.5, gen_model, rast2d, 10)
# h_layer = layer(x=[h[1][1] for h in history], y=[h[1][2] for h in history], Geom.path())
# plot(h_layer,layer(rast2d))

# as = actions_rv(rast2d)
# @which as + [1,2]
