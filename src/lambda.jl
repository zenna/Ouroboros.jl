## Programs
## ========

# A Variable for use in Lambdas
type Var
  name::Symbol
  typ::DataType
end
valuetype(v::Var) = v.typ
expr(x::Var) = x.name
string(v::Var) = "$(v.name)::$(v.typ)"
print(io::IO, v::Var) = print(io::IO, string(v))
show(io::IO, v::Var) = print(io::IO, string(v))
showcompact(io::IO, v::Var) = print(string(v))

# A Function, which can be compiled int a Julia function and called
type Lambda
  name::Symbol
  vars::Vector{Var}
  body::TypedSExpr
  compiled::Bool
  executable::Function
  Lambda(vars::Vector{Var},body::TypedSExpr) =
    new(:anon,vars,body,false)
  Lambda(name::Symbol, vars::Vector{Var},body::TypedSExpr) =
    new(name, vars,body,false)
  Lambda(name,vars,body,compiled,executable) =
    new(name,vars,body,compiled,executable)
end

function print(io::IO, l::Lambda)
  println(l.name,"\n")
  println("vars = $(l.vars)")
  println(expr(l))
  println("compiled = $(l.compiled)")
end
show(io::IO,l::Lambda) = (print(io,l.name); print(io,expr(l)))
showcompact(io::IO,l::Lambda) = print(io,l.name)

# Return Julia Expr of Lambda
function expr(λ::Lambda)
  args_tuple = Expr(:tuple,[Expr(:(::),v.name,v.typ) for v in λ.vars]...)
  Expr(:(->),args_tuple,expr(λ.body))
end

# Compile to executable fnuction
function compile!(λ::Lambda)
  if !λ.compiled λ.executable = eval(expr(λ)) end
  λ.compiled = true
  λ
end

# Call the function with args
function call(λ::Lambda, args...)
  compile!(λ)
  λ.executable(args...)
end

immutable Loc
  route::Vector{Int}
end
