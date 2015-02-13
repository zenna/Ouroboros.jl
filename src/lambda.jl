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

typecheck(T1::DataType, T2::DataType) = (T1 == Any) || (T2 == Any) || (T1 == T2)

# An a Typed SExpression
type TypedSExpr
  head::PrimFunc
  args::Vector{Any}
  function TypedSExpr(h,args::Vector)
    # Type check
    @assert(all([typecheck(valuetype(args[i]),h.argtypes[i]) for i = 1:length(args)]),
            [(valuetype(args[i]),h.argtypes[i]) for i = 1:length(args)])
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
function set(ts::TypedSExpr, i, y)
  @assert valuetype(y) == ts.head.argtypes[i] "$(valuetype(y)) != $(ts.head.argtypes[i])"
  ts.args[i] = y
end

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

# Create from a primitive type an SExpr of appropriate type with all kids missing
childless(p::PrimFunc) = TypedSExpr(p,[Missing{T}() for T in p.argtypes])

# SExprPrimitives
# recursively walk over ts and return node ids where p(node) is true
function walk(p::Function, ts::TypedSExpr)
  locs = Loc[]
  tovisit = Array((Vector{Int},Any),0); push!(tovisit,(Int[],ts))
  while !isempty(tovisit) # Depth First Search
    loc, now = shift!(tovisit)
#     @show now
#     @show p(now)
    p(now) && push!(locs, Loc(loc))
    if isa(now, TypedSExpr)
       # Number args for loc tracking
      iargs = [(vcat(loc,i),now.args[i]) for i=1:length(now.args)]
      push!(tovisit,iargs...)
    end
  end
  locs
end



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
