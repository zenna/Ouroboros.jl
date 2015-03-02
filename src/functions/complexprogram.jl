## Complex Program Transforms
## ==========================

# Fill in Random Missing Values
progvar = Var(:program,Lambda)
loc = Var(:loc, Loc)

## Add a random node to any missing node
begin
  local r1 = TypedSExpr(bodyprim,[progvar])
  local r2 = TypedSExpr(missingprim, [r1])
  local r3 = TypedSExpr(rand_selectprims[Loc],[r2])
  local r4 = TypedSExpr(randeditprim, [r1,r3])

  local r5 = TypedSExpr(varsprim,[progvar])
  local r6 = TypedSExpr(lambdaprim, [r5,r4])
  randfillcmplx = Lambda(:randfillcmplx,[progvar],r6)
end

export randfillcmplx
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
  updatecmplx = Lambda(:updatecmplx,[progvar,loc,f], nout)
end

export updatecmplx

## Randomly add primitive function to the node
begin
  local n1 = TypedSExpr(bodyprim,[progvar])
  local n2 = TypedSExpr(missingprim, [n1])
  local n3 = TypedSExpr(rand_selectprims[Loc],[n2])
  local n4 = TypedSExpr(genapplyprim([updatecmplx,progvar,n3,randfprim]),
                        [updatecmplx,progvar,n3,randfprim])
  randaddf = Lambda(:randaddf,[progvar], n4)
end

## Randomly remove a subtree
begin
  local n1 = TypedSExpr(bodyprim,[progvar])
  local n2 = TypedSExpr(alllocs_norootprim, [n1])
  local n3 = TypedSExpr(rand_selectprims[Loc],[n2])
  local n4 = TypedSExpr(genapplyprim([updatecmplx,progvar,n3,genmissingprim]),
                        [updatecmplx,progvar,n3,genmissingprim])
  randrmnodecmplx = Lambda(:randrmnodecmplx,[progvar], n4)
end

export randrmnodecmplx

## Update State Functions
begin
  local f = Var(:f, PrimFunc)
  local n1 = TypedSExpr(bodyprim,[progvar])
  local n2 = TypedSExpr(valuetypeprim,[progvar])
  local n3 = TypedSExpr(missingtypedprim, [n1,n2])
  local n4 = TypedSExpr(gentypedsexprprim, [f])
  local n5 = TypedSExpr(rand_selectprims[Loc], [n3])
  local n6 = TypedSExpr(editnodeprim,[n1,n5,n4])
  local n7 = TypedSExpr(varsprim,[progvar])
  local nout = TypedSExpr(lambdaprim,[n7,n6])
  randaddcmplex = Lambda(:randaddcmplex,[progvar,f], nout)
end

## All Primitive Transformations
begin
  primtransformers = Lambda[]
  for p in arithprims
    n1 = TypedSExpr(genapplyprim([randaddcmplex,progvar,p]),
                    [randaddcmplex,progvar,p])
    nout = Lambda(symbol("lambda_$(p.name)"),[progvar],n1)
    push!(primtransformers,nout)
  end
end

export primtransformers
