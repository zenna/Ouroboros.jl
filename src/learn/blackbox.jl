## Policy Learning by Black Box Optimization
## =========================================

@doc """
Uses Black Box Optimization to learn a policy.

Policies are scored based on how well they perform when used to act in an mdp.
Neighbour policies are created by transforming a policy with one of primitive
transformations.

- `gen_mdp` should be a nullary function that constructs an mdp
- `MDPType` should be the type of the constructed mdp
- `primtransforms` are program transformations used to modify a policy
""" ->
function bblearn{T<:MDP}(gen_mdp::Function, primtransforms::Vector{Lambda},
                       MDPType::Type{T}; blackbox::Function = hillclimb, args...)
  s0 = empty_lambda(MDPType) #Creates an empty policy of right type
  score(policy) = (mdp = gen_mdp(); s0 = randinit!(mdp); sum(play(mdp,s0,policy)))
  blackbox(s0,primtransforms,score;args...)
end
