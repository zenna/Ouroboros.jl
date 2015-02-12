## Policy Learning
## ========================================

# Nudge Values so they're valid Dirichlet parameters
nudge(v::Vector{Float64};ϵ = 1E-1) = v-minimum(v) + ϵ

# Combinatorial Stochastic Gradient Descent
function hillclimb(state,transforms::Vector,score::Function;
                    niters = 10, maximize = true, nhood = 3)
  for i = 1:niters
    @show i, state
    transforms = [rand_select(transforms) for i = 1:nhood]
    states = Any[state] # May want to stay in current state

    # Try A bunch of program transformations to policy
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
    # play returns -Inf when exception thrown
    # replace these values with the minimum values of everything else
    @show scores
    if all(isinf,scores) # All policies failed worked so just choose uniformly
      scores = zeros(length(scores))
    else
      minscore = minimum(filter(sc->!isinf(sc),scores))
      scores = [score == -Inf ? minscore : score for score in scores]
      @show scores
      j = rand(Categorical(rand(Dirichlet(nudge(scores)))))
      state = states[j]
      print("\n")
    end
  end
  state
end

# Learn a policy using hill climbing
function learn{T<:MDP}(gen_mdp::Function, primtransforms::Vector, MDPType::Type{T})
  s0 = empty_lambda(MDPType) #Creates an empty policy of right type
  score(policy) = (mdp = gen_mdp(); s0 = init!(mdp); sum(play(mdp,s0,policy)))
  hillclimb(s0,primtransforms,score)
end

# Play an MDP with a policy
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
      # If you fail, do a no_action
      state,reward = act!(mdp, no_action(T))
      push!(rewards,reward)
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
no_action{N}(::Type{GridWorld{N}}) = zeros(Int,N)

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