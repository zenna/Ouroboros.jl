## Combinatorial Stochastic Gradient Descent
## +========================================
using Distributions

function hillclimb(s,transforms::Vector,score::Function;
                    niters = 10, maximize = True)
  for i = 1:niters
    transforms = [rand_select(transforms, s) for i = 1:nhood]
    states = [call(transform, s)]
    scores = [score(s) for s in states]
    statei = rand(Categorical(rand(Dirichlet(scores))))
    s = states[si]
  end
  s
end

function learn{T<:MDP}(gen_mdp::Function, MDPType::Type{T})
  action = action_ts(MDPType) # Get an action typed expression
  state_transforms = state(MDPType)
  score(policy) = (mdp = gen_mdp(); s0 = init!(mdp); play(mdp,s0))
  hillclimb(s0,primtransforms,score)
end

function play(m::MDP,s0 ; niters = 10)
  i = 1
  rewards = Float64[]
  while s != stopstate(MDP) && i < niters
    action = call(policy,s0)
    state,reward = act!(mdp, action)
    push(rewards,reward)
  end
  rewards
end

## Example
## =======
function gen2drast()
  tenboard = [0 0
            10 10]
  noobs = Array(Int,0,0)
  obstacles = [-3 -3 -3 -3 -3 -3
             -5 -4 -3 -2 -1 0]
  GridWorld{2}(tenboard-5, [0,0], x->1-rastrigin(x), obstacles)
end

gw_act(args...) = (@assert validmove([args...]);[args...])
action_ts{N}(::Type{GridWorld{N}}) = PrimFunc(:gw_act,[Missing{Int} for i = 1:N],Vector{Int})
state{N}(::Type{GridWorld{N}}) =
learn(gen2drast, GridWorld{2})