## Policy Learning
## ========================================

# Nudge Values so they're valid Dirichlet parameters
nudge(v::Vector{Float64};ϵ = 1E-1) = v-minimum(v) + ϵ

# Combinatorial Stochastic Gradient Descent
function hillclimb(state,alltransforms::Vector,score::Function;
                    niters = 10, maximize = true, nhood = 3,args...)

  ntransformsuccess = 0
  ntransforms = 0
  for i = 1:niters
    @show i
    transforms = [rand_select(alltransforms) for i = 1:nhood]
    states = Any[state] # May want to stay in current state

    # Try A bunch of program transformations to policy
    for transform in transforms
      try # Transform might fail
        s = call(transform, state)
        push!(states,s)
        ntransformsuccess += 1
        ntransforms += 1
        window(:transforms,(i,transformnames[transform]))
      catch e
        ntransforms += 1
#         print("Transform error",e)
#         println("Transform Failed")
      end
    end
    window(:state, state)

    isempty(states) && continue
    scores = Float64[score(s_) for s_ in states]
    j = rand(Categorical(rand(Dirichlet(nudge(scores)))))
    state = states[j]
    print("\n")
  end
  println("Successful transformations",ntransformsuccess/ntransforms)
  state
end

# Learn a policy using hill climbing
function learn{T<:MDP}(gen_mdp::Function, primtransforms::Vector{Lambda},
                       MDPType::Type{T};args...)
  s0 = empty_lambda(MDPType) #Creates an empty policy of right type
  score(policy) = (mdp = gen_mdp(); s0 = init!(mdp); sum(play(mdp,s0,policy)))
  hillclimb(s0,primtransforms,score;args...)
end

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
gw_act(args...) = Int[args...]
action_ts{N}(::Type{GridWorld{N}}) = PrimFunc(:gw_act,[Int for i = 1:N],Vector{Int})
state_type{N}(::Type{GridWorld{N}}) = Vector{Int}
no_action{N}(::Type{GridWorld{N}}) = zeros(Int,N)

allprimtransforms = [randaddf, randfillcmplx, randrmnodecmplx, randaddstatecmplx]
transformnames = [randaddf=>"randaddf", randfillcmplx=>"randfillcmplx",
                  randrmnodecmplx=>"randrmnodecmplx", randaddstatecmplx=>"randaddstatecmplx"]
bestpolicy = learn(gen2drast, allprimtransforms, GridWorld{2};niters = 100)

benchlearn() = learn(gen2drast, allprimtransforms, GridWorld{2};niters = 100)
bench = quickbench(benchlearn,[:state])

# allis = Vector[]
# for t in ["randaddf", "randfillcmplx", "randrmnodecmplx", "randaddstatecmplx"]
#   is = Int[]
#   for i = 1:100
#     a = quickbench(benchlearn,[:transforms])
#     data  = a[2][:transforms]
#     histdata = [d[1] for d in filter(k->k[2] == t,data)]
#     push!(is,histdata...)
#   end
#   push!(allis,is)
#   plot(x = is, Geom.histogram)
# end

plot(x = allis[1], Geom.histogram)

@show bestpolicy
# locs = missing(bestpolicy.body)
# findnode(bestpolicy.body,locs[1])

# arithprims = PrimFunc[plus,firstprims[2],secondprims[2],minus]
# # q = empty_lambda(GridWorld{2})
# # q = call(randfillcmplx, q)
game = gen2drast()
s0 = init!(game)
@show play(game,s0,bestpolicy)
# # @show q
# # @show q2
# # applynode(randfprim,Int)

# # applynode(randf,Missing{Int}())
