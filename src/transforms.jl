## Programs
## ========

immutable PrimFunc
  name::Symbol
  argtypes::Vector{DataType}
  rettype::DataType
end

type Lambda
  vars::Vector{Var}
  body::TypedSExpr
  λ::Function
end

type TypedSExpr
  head::PrimFunc
  args::Vector
  function TypedSExpr(h,args)
    # Type check
    @assert all([valuetype(args[i]) == h.argtypes[i] for i = 1:length(args)])
    new(h,args)
  end
end

set(ts::TypedSExpr, i, y) =
  (@assert valuetype(y) == ts.h.argtypes[i]; ts.args[i] = y)

# Value typeof a value is just its value but for a func its its return type
valuetype(x) = typeof(x)
valuetype(x::PrimFunc) = x.rettype
valuetype(x::TypedSExpr) = valuetype(x.head)

immutable Loc
  route::Vector{Int}
end

# function find(ts::TypedSExpr, l::loc)
#   isempty(l) && return ts # Root location
#   child = ts
#   for i = 1:length(l.route)
#     child = child.args[l[i]]
#   end
#   return child
# end

# An SExpr may have missing children, but they must be typed, right!
immutable Missing{T} end
valuetype{T}(x::Missing{T}) = T
ismissing(x) = isa(x, Missing)
nmissing(x::TypedSExpr) = count(a->ismissing(a),x.args)

## Primitive Functions
## ==================

# Integer Primitives
plus = PrimFunc(:+,[Int, Int],Int)
minus = PrimFunc(:-,[Int, Int],Int)
times = PrimFunc(:*,[Int, Int], Int)

# SExprPrimitives
# recursively walk over ts and return node ids where p(node) is true
function walk(p::Function, ts::TypedSExpr)
  locs = Loc[]
  tovisit = Array((Vector{Int},Any),0); push!(tovisit,(Int[],ts))
  while !isempty(tovisit) # Depth First Search
    loc, now = shift!(tovisit)
    p(now) && push!(locs, Loc(loc))
    if isa(now, TypedSExpr)
       # Number args for loc tracking
      iargs = [(vcat(loc,i),now.args[i]) for i=1:length(now.args)]
      push!(tovisit,iargs...)
    end
  end
  locs
end

# Missing
missing(ts::TypedSExpr,t::DataType) = walk(n->valuetype(n)==t && ismissing(n),ts)
# Maps an TypedSExpr to the id of all the missing nodes
missingprim = PrimFunc(:missing,[TypedSExpr, DataType], Vector{Loc})

# Edit: replace position l in loc with y
function editnode(ts::TypedSExpr, l::Loc, y)
  newts = deepcopy(ts)
  now = newts
  for i in l.route[1:end-1]
    now = now.args[i]
  end
  @assert isa(now, TypedSExpr)
  set(now,l,y)
  newts
end

editnodeprim = PrimFunc(:editnode, [TypedSExpr, Loc, Any], TypedSExpr)

root(ts::TypedSExpr) = Loc([])
rootprim = PrimFunc(:root, [TypedSExpr], Loc)

## Compilation
## ===========
# Compile an sexpression into an executable lambda
compile(a) = a
compile(a::Missing) = error("cannot compile with missing values")
function compile(ts::TypedSExpr)
  Expr(:call, ts.head.name, [compile(a) for a in ts.args]...)
end


## TODO
## ====

# ## Example
# ## =======
c = TypedSExpr(plus,[Missing{Int}(),2])
a = TypedSExpr(plus,[1,2])
b = TypedSExpr(minus,[a,a])
