# A generative model for a Markov decision process M
# is a randomized algorithm that, on input of a state-action pair (s, a)
# outputs Rsa and a state s?, where s? is randomly drawn according to the
#transition probabilities Psa(·).

abstract Model

# A cheating model has access to a perfect model of the actual MDP
immutable CheatModel <: Model
  m::MDP
  CheatModel(m) = new(deepcopy(m))
end

function rand(mdp::CheatModel,s,a)
  mdp.m.pos = s
  res = act!(mdp.m,a)
#   @show a,res
  res
end

function call(mdp::CheatModel,s,a)
  @show "gotcha"
  mdp.m.pos = s
  @show "gothere"
  q = act(mdp.m,a)
  @show q
  q
end
