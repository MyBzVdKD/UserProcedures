// Multi-dimensional Utilities
// utilities for dealing with multi-dimensional waves (matrices and the like)

// Multi-dimensional x2pnt
// returns row, column, layer, or chunk index nearest the x,y,z, or t scaling value
Function x2pntMD(w,dim,xyzt)	// xyzt is x val if dim==0, y if dim==1, z if dim==2, t if dim==3
	Wave w
	Variable/D dim,xyzt
	return round( (xyzt - DimOffset(w, dim))/DimDelta(w,dim) )
End

// Multi-dimensional pnt2x
// returns x,y,z, or t scaling value for the given row, column, layer, or chunk index  
Function pnt2xMD(w,dim,pqrs)	// pqrs is p val if dim==0, q if dim==1, r if dim==2, s if dim==3
	Wave w
	Variable/D dim,pqrs 
	return DimOffset(w, dim) + pqrs*DimDelta(w,dim)
End

// Multi-dimensional rightx
// returns x,y,z, or t scaling value for the row, column, layer, or chunk after the last one in the wave 
// for a one-dimensonal wave, rightxMD(w,0) is the same as rightx(w)
Function rightxMD(w,dim)
	Wave w
	Variable/D dim
	return DimOffset(w, dim) + DimSize(w,dim)*DimDelta(w,dim)
End

// Multi-dimensional lastx
// returns x,y,z, or t scaling value for the last row, column, layer, or chunk in the wave 
// for a one-dimensonal wave, lastxMD(w,0) is the same as rightx(w)-deltax(w)
Function lastxMD(w,dim)
	Wave w
	Variable/D dim
	return DimOffset(w, dim) + (DimSize(w,dim)-1)*DimDelta(w,dim)
End
