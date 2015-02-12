## Transformations to Programs Themselves
## ======================================

# Missing
missing(ts::TypedSExpr) = walk(n->ismissing(n),ts)
missing(ts::TypedSExpr,t::DataType) = walk(n->valuetype(n)==t && ismissing(n),ts)
# Maps an TypedSExpr to the id of all the missing nodes
missingprim = PrimFunc(:missing,[TypedSExpr, DataType], Vector{Loc})

# Get the TypedSExpr from a lambda
body(λ::Lambda) = λ.body
bodyprim = PrimFunc(:body, [Lambda], TypedSExpr)

#
vars(λ::Lambda) = λ.vars
varsprim = PrimFunc(:vars, [Lambda], Vector{Var})

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
                    for T in (Int, Float64, Bool, TypedSExpr, Loc)]

lambarize(vars::Vector{Var}, ts::TypedSExpr) = Lambda(vars,ts)
lambdaprim = PrimFunc(:Lambda, [Vector{Var},TypedSExpr],Lambda)

## Complex Program Transforms
## ================================
# Fill in Random Missing Values
progvar = Var(:program,Lambda)
loc = Var(:loc, Loc)

begin
  r1 = TypedSExpr(bodyprim,[progvar])
  r2 = TypedSExpr(missingprim, [r1])
  r3 = TypedSExpr(rand_selectprims[Loc],[r2])
  r4 = TypedSExpr(randeditprim, [r1,r3])

  r5 = TypedSExpr(varsprim,[progvar])
  r6 = TypedSExpr(lambdaprim, [r5,r4])
  randfillcmplx = Lambda([progvar],r6)
end

## Update complex is a complex function which
# extracts an element at location loc from a tree
# maps it through f, and then replaces that location
# in the tree.
begin
  local f = Var(:f, PrimFunc)
  local n1 = TypedSExpr(bodyprim,[progvar])
  local n2 = TypedSExpr(findnodeprim,[n1,loc])
  local n3 = TypedSExpr(applynodeprim,[f,n2])
  local n4 = TypedSExpr(editnodeprim,[n1,loc,n3])
  local n5 = TypedSExpr(varsprim,[progvar])
  local nout = TypedSExpr(lambdaprim, [n5,n4])
  updatecmplx = Lambda([progvar,loc,f], nout)
end

# Create from a primitive type an SExpr of appropriate type with all kids missing
childless(p::PrimFunc) = TypedSExpr(p,[Missing{T}() for T in p.argtypes])

# Randomly select a function of the same type as value
function randf(ts::Any)
  vt = valuetype(ts)
  shortlist = filter(i->valuetype(i) == vt, arithprims)
  childless(rand_select(shortlist))
end

randfprim = PrimFunc(:randf,[Any],Any)

## Randomly add primitive function to the node
begin
  local n1 = TypedSExpr(bodyprim,[progvar])
  local n2 = TypedSExpr(missingprim, [n1])
  local n3 = TypedSExpr(rand_selectprims[Loc],[n2])
  local n4 = TypedSExpr(genapplyprim([updatecmplx,progvar,n3,randfprim]),
                        [updatecmplx,progvar,n3,randfprim])
  randaddf = Lambda([progvar], n4)
end

@show (expr(randaddf),100)
