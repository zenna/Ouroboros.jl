## Combinatorial Stochastic Gradient Descent
## +========================================
using Distributions
import Sigma: rand_select

# Nudge Values so they're valid Dirichlet parameters
nudge(v::Vector{Float64};ϵ = 1E-1) = v-minimum(v) + ϵ

function hillclimb(state,transforms::Vector,score::Function;
                    niters = 10, maximize = true, nhood = 3)
  for i = 1:niters
    @show i, state
    transforms = [rand_select(transforms) for i = 1:nhood]
    states = Any[state]
    for transform in transforms
      try # Transform might fail
        s = call(transform, state)
        push!(states,s)
      catch
        println("Transform Failed")
      end
    end

    isempty(states) && continue
    scores = Float64[score(s_) for s_ in states]
    @show scores
    j = rand(Categorical(rand(Dirichlet(nudge(scores)))))
    state = states[j]
    print("\n")
  end
  state
end

function learn{T<:MDP}(gen_mdp::Function, primtransforms::Vector, MDPType::Type{T})
  s0 = empty_lambda(MDPType) #Creates an empty policy of right type
  score(policy) = (mdp = gen_mdp(); s0 = init!(mdp); sum(play(mdp,s0,policy)))
  hillclimb(s0,primtransforms,score)
end

function empty_lambda{T<:MDP}(MDPType::Type{T})
  actionfunc::PrimFunc = action_ts(MDPType)
  missing_args = Any[Missing{M}() for M in actionfunc.argtypes]
  ts = TypedSExpr(actionfunc,missing_args)
  Lambda([Var(:state,state_type(MDPType))],ts)
end

function play{T<:MDP}(mdp::T,s,policy; niters = 10)
  i = 1
  rewards = Float64[]
  while s != StopState{T} && i < niters
    try
      action = call(policy,s)
      state,reward = act!(mdp, action)
      push!(rewards,reward)
    catch e
      @show e
      push!(rewards,0.0)
    end
    i += 1
  end
  @show rewards
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

## TODO: MOVE TO GRIDWORLD WHEN STABLE
# gw_act(args...) = (@assert validmove([args...]);[args...])
gw_act(args...) = [args...]
action_ts{N}(::Type{GridWorld{N}}) = PrimFunc(:gw_act,[Int for i = 1:N],Vector{Int})
state_type{N}(::Type{GridWorld{N}}) = Vector{Int}

allprimtransforms = [randfillcmplx]
l = learn(gen2drast, allprimtransforms, GridWorld{2})

# q = empty_lambda(GridWorld{2})
# q = call(randfillcmplx, q)
game = gen2drast()
s0 = init!(game)
play(game,s0,q)
# q2
# @show q
# @show q2