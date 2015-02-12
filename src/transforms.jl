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

function findnode(ts::TypedSExpr, l::Loc)
  now = ts
  for i in l.route[1:end]
    now = now.args[i]
  end
  deepcopy(now)
end

randr(::Type{Int64}) = rand(DiscreteUniform(0,100))
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

# No Type Parameters so Need to Create all the functions
rand_selectprims = [T => PrimFunc(:rand_select, [Vector{T}], T)
                    for T in (Int, Float64, Bool, TypedSExpr, Loc)]

## Complex Program Transforms
## ================================
# Fill in Random Missing Values
progvar = Var(:program,Lambda)
r1 = TypedSExpr(bodyprim,[progvar])
r2 = TypedSExpr(missingprim, [r1])
r3 = TypedSExpr(rand_selectprims[Loc],[r2])
r4 = TypedSExpr(randeditprim, [r1,r3])
randfillcmplx = Lambda([progvar],r4)
