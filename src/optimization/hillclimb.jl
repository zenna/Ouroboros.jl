
@doc "Nudge `v` to be valid Dirichlet parameters" ->
nudge(v::Vector{Float64};ϵ = 1E-1) = v-minimum(v) + ϵ

@doc """
  Does heuristic optimization over objects of arbitrary type.
  Starting with an initial state, `hillclimb` samples a *neighbourhood* of
  candidate new states by applying a transform sampled form `alltransforms`
  to the curent state.  States in the neighbourhood are scored with a Real
  valued function `score`, and a better (higher score) new state from the
  neighbourhood becomes the current state.

  - `state` initial state
  - `alltransforms` functions from state -> state for local search

  Keyword args

  - `niters` max number of score/transform iterations
  - `nhood` number of candidates in neighbourhood
""" ->
# Combinatorial Stochastic Gradient Descent
function hillclimb(state, alltransforms::Vector, score::Function;
                    niters = 10, nhood = 3, args...)

  ntransformsuccess = 0
  ntransforms = 0
  for i = 1:niters
    println("Hill climb iter: $i")
    transforms = [rand_select(alltransforms) for i = 1:nhood]
    states = Any[state] # May want to stay in current state

    # Try a bunch of program transformations to policy
    for transform in transforms
      try # Transform might fail
        lens(:pre_transform, i=i, transform=transform, state=state)
        s = call(transform, state)
        push!(states,s)
        ntransformsuccess += 1
        ntransforms += 1
        lens(:post_transform,  i=i, transform=transform, state=state)
      catch e
        lens(:transform_error, e)
        ntransforms += 1
      end
    end

    # If all transforms failed then no neighbour states to score
    isempty(states) && continue
    scores = Float64[score(s_) for s_ in states]
    j = rand(Categorical(rand(Dirichlet(nudge(scores)))))
    lens(:state_transition, s0=state, s1=states[j], scores=scores)
    state = states[j]
  end
  println("Successful transformations",ntransformsuccess/ntransforms)
  state
end