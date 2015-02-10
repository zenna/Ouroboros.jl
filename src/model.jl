# A generative model for a Markov decision process M
# is a randomized algorithm that, on input of a state-action pair (s, a)
# outputs Rsa and a state s?, where s? is randomly drawn according to the
#transition probabilities Psa(·).

immutable Model
  dada
end

call(m::,s::State, a::Action)