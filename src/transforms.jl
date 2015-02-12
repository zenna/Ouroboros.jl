## Primitive Transformations to Programs Themselves
## ================================================

# Missing
missing(ts::TypedSExpr) = walk(n->ismissing(n),ts)
missing(ts::TypedSExpr,t::DataType) = walk(n->valuetype(n)==t && ismissing(n),ts)
# Maps an TypedSExpr to the id of all the missing nodes
missingprim = PrimFunc(:missing,[TypedSExpr], Vector{Loc})
missingtypedprim = PrimFunc(:missing, [TypedSExpr,DataType], Vector{Loc})
genmissingprim = PrimFunc(:genmissing,[Any],Any)


# Get the TypedSExpr from a lambda
body(λ::Lambda) = λ.body
bodyprim = PrimFunc(:body, [Lambda], TypedSExpr)

# Primitivs on Vars
vars(λ::Lambda) = λ.vars
varsprim = PrimFunc(:vars, [Lambda], Vector{Var})
vartype(v::Var) = v.typ
vartypeprim = PrimFunc(:vartype, [Var], DataType)

# Find a node in an tsexpr
function findnode(ts::TypedSExpr, l::Loc)
  now = ts
  for i in l.route[1:end]
    now = now.args[i]
  end
  deepcopy(now)
end

findnodeprim = PrimFunc(:findnode, [TypedSExpr, Loc], Any)

# Random Edits
randr(::Type{Int64}) = rand(DiscreteUniform(-1,1))
randr(::Type{Float64}) = rand(Uniform(0,100))

function randedit(ts::TypedSExpr, l::Loc)
  T = valuetype(findnode(ts,l))
  editnode(ts,l,randr(T))
end

randeditprim = PrimFunc(:randedit,[TypedSExpr, Loc], TypedSExpr)

# Edit: replace position l in loc with y
function editnode(ts::TypedSExpr, l::Loc, y)
  newts = deepcopy(ts)
  now = newts
  for i in l.route[1:end-1]
    now = now.args[i]
  end
  @assert isa(now, TypedSExpr)
  set(now,l.route[end],y)
  newts
end

editnodeprim = PrimFunc(:editnode, [TypedSExpr, Loc, Any], TypedSExpr)

applynode(f::Function, args...) = apply(f,args)
applynode(p::PrimFunc, args...) = apply(eval(p.name),args)
applynodeprim = PrimFunc(:applynode, [PrimFunc, Any], Any)
genapplyprim(args) = PrimFunc(:applynode, map(valuetype,args),Any)

# No Type Parameters so Need to Create all the functions
rand_selectprims = [T => PrimFunc(:rand_select, [Vector{T}], T)
                    for T in (Int, Float64, Bool, TypedSExpr, Loc,Var)]

lambarize(vars::Vector{Var}, ts::TypedSExpr) = Lambda(vars,ts)
lambdaprim = PrimFunc(:Lambda, [Vector{Var},TypedSExpr],Lambda)

# Randomly select a function of the same type as value
function randf(node::Any)
  vt = valuetype(node)
  shortlist = filter(i->valuetype(i) == vt, arithprims)
  childless(rand_select(shortlist))
end

randfprim = PrimFunc(:randf,[Any],Any)

# Randomly select a function of the same type as value
function genmissing(node)
  vt = valuetype(node)
  Missing{vt}()
end


