## Primitive Functions
## ==================
BasicTypes = (Float64, Int, Bool)

# Integer Primitives
plus = PrimFunc(:+,[Int, Int],Int)
minus = PrimFunc(:-,[Int, Int],Int)
times = PrimFunc(:*,[Int, Int], Int)
quotient = PrimFunc(:/,[Int, Int], Float64)

# Float64
plusfloat = PrimFunc(:+,[Float64, Float64],Float64)
minusfloat = PrimFunc(:-,[Float64, Float64],Float64)
timesfloat = PrimFunc(:*,[Float64, Float64], Float64)
quotientfloat = PrimFunc(:/,[Float64, Float64], Float64)

# Bool
and = PrimFunc(:&,[Bool, Bool],Bool)
or = PrimFunc(:|,[Bool, Bool],Bool)
not = PrimFunc(:!,[Bool], Bool)

# if then else
ites = [PrimFunc(:ifelse,[Bool,T,T], T) for T in (Float64,Int,Bool,Array)]

# conversion
int2float = PrimFunc(:float, [Int], Float64)
bool2float = PrimFunc(:float, [Bool], Float64)

float2int = PrimFunc(:int, [Float64], Int)
bool2int = PrimFunc(:int, [Bool], Int)

float2bool = PrimFunc(:bool, [Float64], Bool)
int2bool = PrimFunc(:bool, [Int], Bool)

## Vector Operations
## ================
second(v) = v[2]
rest(v) = v[2:end]

firstprims = [PrimFunc(:first, [Vector{T}], T) for T in BasicTypes]
secondprims = [PrimFunc(:second, [Vector{T}], T) for T in BasicTypes]
lastprims = [PrimFunc(:last, [Vector{T}], T)  for T in BasicTypes]
restprims = [PrimFunc(:rest, [Vector{T}], Vector{T}) for T in BasicTypes]

arithprims =
  vcat(plus,minus,times,quotient,plusfloat,minusfloat,timesfloat,quotientfloat,
     and,or,not,ites,int2float,bool2float,float2int,bool2int,float2bool,int2bool,
     firstprims,secondprims,lastprims,restprims)