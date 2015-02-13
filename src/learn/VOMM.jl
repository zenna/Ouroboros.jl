## Variable Order Markov Chain for Model
## =====================================

# That is, we we consider a set of actions as T and we're looking for the
# conditional probability of a transformation t given a a sequence of previous
# transformations
typealias StateNStop{T} Vector{(Union(T,StopState{T}),Float64)}

type MarkovModel{T}
  transitions::Dict{Union(T,StartState{T}),StateNStop{T}}
end

# Generate a uniformly markov model where:
# start -> all other states = 1/n
# state -> all states + stop = 1/n+1
function uniform_mm{T}(states::Vector{T})
  transitions = Dict{Union(T,StartState{T}),StateNStop{T}}()
  n = length(states)
  [transitions[state] = StateNStop{T}[] for state in vcat(StartState{T}(),states)]

  # From start -> all other states (except stop)
  for state in states push!(transitions[StartState{T}()],(state,1/n)) end

  # From all states to all other states including stop
  for from in states, to in vcat(StopState{T}(),states)
    push!(transitions[from],(to,1/(n+1)))
  end
  MarkovModel{T}(transitions)
end

function rand_select{T}(x::Vector{(T,Float64)})
  probs::Vector{Float64} = [v[2] for v in x]
  Distributions.pnormalize!(probs)
  i = rand(Categorical(probs))
  x[i][1]::T
end

function rand{T}(m::MarkovModel{T};maxiters = 100)
  states = T[]
  state = StartState{T}()
  for i = 1:maxiters
    proposals = m.transitions[state]
    state = rand_select(proposals)
    state == StopState{T}() && break
    push!(states,state)
  end
  states
end

# Apply all these transforms to the state in sequence f3(f2(f1(s))) ...
# Return resulting transformed state and the set of failed transformations
function applytransforms(transforms::Vector{Lambda}, state::Lambda)
  # Record successful transforms to reward them to strengthen relevant markov edges
  succ_transforms = Lambda[]
  for i = 1:length(transforms)
    try
      state = call(transforms[i],state)
      push!(succ_transforms,transforms[i])
    catch
    end
  end
  state, succ_transforms
end

# Given a set of chains and associated scores
# updates transitions modifies the transition probabilities
# such that high reward chains are more likely
function update_transitions!(mm::MarkovModel,chain_scores)
  allscores::Vector{Float64} = [s[2] for s in chain_scores]
  minscore = minimum(allscores)
  translation = minscore < 0 ? abs(minscore) : minscore
  total = maximum(allscores) - minscore
  total == 0 && return mm
  for (chain,score) in chain_scores
    percinc = (score + translation) / total
    percinc /= 100
    @assert 0.0 <= percinc <= 1.0
    @assert isa(chain,Vector) typeof(chain),chain
    for i = 1:length(chain)-1
      from = chain[i]
      to::Lambda = chain[i+1]
      outedges = mm.transitions[from]
      i = findfirst(t->t[1] == to, outedges)
      i == 0 && error("No Link Exists")
#       mm.transitions[from] = (outedges[i][1],outedges[i][2]*(1+percinc))
      mm.transitions[from][i] = (outedges[i][1],outedges[i][2]*(1+percinc))
    end
  end
  mm
end

# Learning in the markov model is
function learnmarkvov{T<:MDP}(gen_mdp::Function, mm::MarkovModel{Lambda},
                               MDPType::Type{T};nepisodes = 10, ntrials = 10)
  state = empty_lambda(MDPType)
  score(policy) = (mdp = gen_mdp(); s0 = randinit!(mdp); sum(play(mdp,s0,policy)))
  for j = 1:nepisodes
    # Gather statistics from a number of runs
#     state_scores = Array((Vector{Lambda},Float64),0)
    state_scores = Any[]

    for i = 1:ntrials # Test ntrials before modifying MarkovModel
      transform_chain = rand(mm)
      state, succ_transforms = applytransforms(transform_chain, state)
#       window(:state, state)
      output = score(state)
      push!(state_scores,(succ_transforms,output))
    end
    @show [s[2] for s in state_scores]
    update_transitions!(mm,state_scores)
  end
  mm
end

## Printing
## ========
import Base.show
function show(x::MarkovModel)
  for from in keys(x.transitions)
    if from == StartState{Lambda}()
      print("start->")
    else
      print(transformnames[from],"->")
    end
    for to in x.transitions[from]
      if to[1] == StopState{Lambda}()
        print("stop")
      else
        print(transformnames[to[1]])
      end
      print(to[2]," ")
    end
    print("\n")
  end
end

# Learning in the markov model is
function assessMM{T<:MDP}(gen_mdp::Function, mm::MarkovModel{Lambda},
                               MDPType::Type{T}; ntrials = 10)
  state = empty_lambda(MDPType)
  score(policy) = (mdp = gen_mdp(); s0 = randinit!(mdp); sum(play(mdp,s0,policy)))
  scores = Float64[]
  for i = 1:ntrials # Test ntrials before modifying MarkovModel
    transform_chain = rand(mm)
    state, succ_transforms = applytransforms(transform_chain, state)
#     window(:state, state)
    push!(scores,score(state))
  end
  maximum(scores)
end




act!(gen2drand(),[0,1])

## Example
## =======
# primtransforms_mm = uniform_mm(allprimtransforms)
# # [transformnames[transform] for transform in rand(u)]
# q = quickbench(()->learnmarkvov(gen2drast,uniform_mm(allprimtransforms),GridWorld{2};
#                                nepisodes=4,ntrials=100),[:state])

# uniquepolicies = unique(q[2][:state])
# [@show i,quickplay(uniquepolicies[i]) for i = 1:length(uniquepolicies)]
# showme(uniquepolicies[end])
# @show quickplay(uniquepolicies[end])
