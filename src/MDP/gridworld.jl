# An N dimensional Gridowlrd
type GridWorld{N} <: MDP
  board::Matrix{Int}
  pos::LA{Int,1}
  landscape::Function # An error function on the landscape
  obstacles::Matrix{Int}
end

randinit!{N}(gw::GridWorld{N}) =
  [rand(DiscreteUniform(gw.board[1,i],gw.board[2,i])) for i = 1:N]

randinit!{N}(gw::GridWorld{N}) = (gw.pos = vec(gw.board[1,:]'); gw.pos)
init!{N}(gw::GridWorld{N}) = (gw.pos = vec(gw.board[1,:]'); gw.pos)

gw_act(args...) = Int[args...] # Maybe easier for program to gen integer input
action_ts{N}(::Type{GridWorld{N}}) = PrimFunc(:gw_act,[Int for i = 1:N],Vector{Int})
state_type{N}(::Type{GridWorld{N}}) = Vector{Int}
no_action{N}(::Type{GridWorld{N}}) = zeros(Int,N)

# Is this a valid position
function validpos(pos::LA{Int,1}, mdp::GridWorld)
  # Pos is on board
  onboard = true
  for dim = 1:length(pos)
    onboard &= (mdp.board[1,dim] <= pos[dim]) & (pos[dim] <= mdp.board[2,dim])
  end

  # Pos is not in one of the obstacles
  notinob = true
  for i = 1:size(mdp.obstacles)[2]
    notinob &= !(pos == mdp.obstacles[:,i])
  end
  onboard & notinob
end

# Possible Actions from an mdp
actions{N}(mdp::GridWorld{N}) = [[p...] for p in product([[-1,0,1] for i = 1:N]...)]
actions{N}(mdp::GridWorld{N}, state) = actions(mdp)

# Only 1 steps allowed
validmove(m::LA{Int,1}) = all(i -> (-1 <= i) & (i <= 1), m)

function act!(mdp::GridWorld, action::Vector{Int})
  newpos = mdp.pos + action
  if validpos(newpos,mdp) && validmove(action)
    mdp.pos = newpos
    (newpos, mdp.landscape(newpos))
  else
    (mdp.pos, mdp.landscape(mdp.pos))
  end
end

# Function act for use with Sigma-baed model
function act(mdp::GridWorld, action)
  newpos = mdp.pos + action
  reward = ifelse(validpos(newpos, mdp) & validmove(action),
                mdp.landscape(newpos),
                mdp.landscape(mdp.pos))
  pos1 = ifelse(validpos(newpos, mdp) & validmove(action),
                newpos[1],mdp.pos[1])
  pos2 = ifelse(validpos(newpos, mdp) & validmove(action),
                newpos[2],mdp.pos[2])
  PureRandArray([pos1,pos2]),reward
end

function layer(mdp::GridWorld)
  layer(z = (x,y)->mdp.landscape([x,y]),
       x = mdp.board[1,1]:mdp.board[2,1],
       y = mdp.board[1,2]:mdp.board[2,2],
       Geom.contour)
end

## Generators
function gen2drand()
  tenboard = [0   0
            100 100]
  noobs = Array(Int,0,0)
  obstacles = [-3 -3 -3 -3 -3 -3
             -5 -4 -3 -2 -1 0]
  landscape = rand_select([rastrigin,sphere,beale])
  GridWorld{2}(tenboard, [0,0], x->1-landscape(x), noobs)
end

function gen2drast()
  tenboard = [0 0
            10 10]
  noobs = Array(Int,0,0)
  obstacles = [-3 -3 -3 -3 -3 -3
             -5 -4 -3 -2 -1 0]
  GridWorld{2}(tenboard-5, [0,0], x->1-rastrigin(x), obstacles)
end
