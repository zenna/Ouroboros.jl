## Complex Program Transforms
## ================================
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

## Randomly add primitive function to the node
begin
  local n1 = TypedSExpr(bodyprim,[progvar])
  local n2 = TypedSExpr(missingprim, [n1])
  local n3 = TypedSExpr(rand_selectprims[Loc],[n2])
  local n4 = TypedSExpr(genapplyprim([updatecmplx,progvar,n3,randfprim]),
                        [updatecmplx,progvar,n3,randfprim])
  randaddf = Lambda([progvar], n4)
end

## Randomly remove a subtree
begin
  local n1 = TypedSExpr(bodyprim,[progvar])
  local n2 = TypedSExpr(alllocs_norootprim, [n1])
  local n3 = TypedSExpr(rand_selectprims[Loc],[n2])
  local n4 = TypedSExpr(genapplyprim([updatecmplx,progvar,n3,genmissingprim]),
                        [updatecmplx,progvar,n3,genmissingprim])
  randrmnodecmplx = Lambda([progvar], n4)
end

## Add State Functions
begin
  n1 = TypedSExpr(bodyprim,[progvar])
  n2 = TypedSExpr(varsprim,[progvar])
  n3 = TypedSExpr(rand_selectprims[Var],[n2])
  n6 = TypedSExpr(vartypeprim,[n3])
  n4 = TypedSExpr(missingtypedprim, [n1,n6])
  n5 = TypedSExpr(rand_selectprims[Loc],[n4])
  n7 = TypedSExpr(editnodeprim,[n1,n5,n3])
  n8 = TypedSExpr(lambdaprim, [n2,n7])
  randaddstatecmplx = Lambda([progvar], n8)
end