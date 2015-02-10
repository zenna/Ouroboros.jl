# A markov decision process
# An MDP is formalised as a procedure which takes some input state $A$
# And reurns some new state S
abstract MDP

# An N dimensional Gridowlrd
immutable GridWorld{N} <: MDP
  board::Matrix{Int}
  pos::Vector{Int}
  landscape::Function # An error function on the landscape
  obstacles::Matrix{Int}
end
combinations
permutations
using Iterators
n = 3


collect(p)
collect(imap(c -> Int[c[k]-k+1 for k=1:length(c)],combinations([1:(2n-1)],n)))


collect(combinations([-1,0,1],3))


actions{N}(mdp::GridWorld{N}) = collect(product([[-1,0,1] for i = 1:N]...))

# Is this a valid position
function validpos(pos::Vector{Int}, mdp::GridWorld)
  # Pos is on board
  onboard = true
  for dim in length(pos)
    onboard &= (mdp.board[1,dim] <= pos[dim] <= mdp.board[2,dim])
  end

  # Pos is not in one of the obstacles
  notinob = true
  for ob in mdp.obstacles
    notinob &= (pos != ob)
  end
  onboard & notinob
end

# Only 1 steps allowed
validmove(m::Vector{Int}) = all(i -> -1 <= i <= 1, m)

function act!(mdp::GridWorld, action::Vector{Int})
  newpos = mdp.pos + action
  if validpos(newpos,mdp) && validmove(mdp.pos)
    mdp.pos = newpos
    (newpos, mdp.landscape(newpos))
  else
    (mdp.pos, mdp.landscape(pos))
  end
end

## Example
rastrigin(x::Vector,A) = A * length(x) + sum([xi^2 - A*cos(2pi*xi) for xi in x])
noobs = Array(Int,0,0)
twodrast = GridWorld{2}([0 10;0 10], [0,0], x->rastrigin(x,10), noobs)
act!(twodrast, [0,1])

convertactions(twodrast)[1]
