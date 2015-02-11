## Programs
## ========

# A primitive
immutable PrimFunc
  name::Symbol
  argtypes::Vector{DataType}
  rettype::DataType
end

# A Variable for use in Lambdas
type Var
  name::Symbol
  typ::DataType
end
valuetype(v::Var) = v.typ
expr(x::Var) = x.name

# An a Typed SExpression
type TypedSExpr
  head::PrimFunc
  args::Vector
  function TypedSExpr(h,args::Vector)
    # Type check
    @assert all([valuetype(args[i]) == h.argtypes[i] for i = 1:length(args)])
    new(h,args)
  end
end

# A Function, which can be compiled int a Julia function and called
type Lambda
  vars::Vector{Var}
  body::TypedSExpr
  compiled::Bool
  executable::Function
  Lambda(vars::Vector{Var},body::TypedSExpr) = new(vars,body,false)
  Lambda(vars,body,compiled,executable) = new(vars,body,compiled,executable)
end

# Return Julia Expr of Lambda
function expr(λ::Lambda)
  args_tuple = Expr(:tuple,[Expr(:(::),v.name,v.typ) for v in λ.vars]...)
  Expr(:(->),args_tuple,expr(λ.body))
end

# Compile to executable fnuction
function compile!(λ)
  if !λ.compiled λ.executable = eval(expr(λ)) end
  λ.compiled = true
  λ
end

# Call the function with args
function call(λ::Lambda, args...)
  compile!(λ)
  λ.executable(args...)
end

# Set the ith argument of ts to y (and type check)
set(ts::TypedSExpr, i, y) =
  (@assert valuetype(y) == ts.h.argtypes[i]; ts.args[i] = y)

# Value typeof a value is just its value but for a func its its return type
valuetype(x) = typeof(x)
valuetype(x::PrimFunc) = x.rettype
valuetype(x::TypedSExpr) = valuetype(x.head)

immutable Loc
  route::Vector{Int}
end

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
expr(a) = a
expr(a::Missing) = error("cannot compile with missing values")
function expr(ts::TypedSExpr)
  Expr(:call, ts.head.name, [expr(a) for a in ts.args]...)
end


## TODO
## ====

# ## Example
# ## =======
xvar = Var(:x, Int)
c = TypedSExpr(plus,[4,xvar])
l = Lambda([xvar],c)
a = TypedSExpr(plus,[1,2])
b = TypedSExpr(minus,[a,a])
