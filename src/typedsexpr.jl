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

# Set the ith argument of ts to y (and type check)
function set(ts::TypedSExpr, i, y)
  @assert valuetype(y) == ts.head.argtypes[i] "$(valuetype(y)) != $(ts.head.argtypes[i])"
  ts.args[i] = y
end

valuetype(x::TypedSExpr) = valuetype(x.head)

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


# An SExpr may have missing children, but they must be typed, right!
immutable Missing{T} end
valuetype{T}(x::Missing{T}) = T
ismissing(x) = isa(x, Missing)
nmissing(x::TypedSExpr) = count(a->ismissing(a),x.args)

## Compilation
## ===========
# Compile an sexpression into an julia expression
expr(a) = a
function expr(ts::TypedSExpr)
  Expr(:call, ts.head.name, [expr(a) for a in ts.args]...)
end
