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

    isempty(states) && continue
    scores = Float64[score(s_) for s_ in states]
    window(:state, (state,scores))
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
  score(policy) = (mdp = gen_mdp(); s0 = randinit!(mdp); sum(play(mdp,s0,policy)))
  hillclimb(s0,primtransforms,score;args...)
end
