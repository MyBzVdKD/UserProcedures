#pragma rtGlobals=1	// Use modern global access method.
function /S TwoPoints(S_wn, V_dist)
	string S_wn
	variable V_dist
	wave wv=$S_wn
	make /O /N=(dimsize(wv, 0)*2) $S_wn+"_"+num2str(V_dist)
	wave W_two=$S_wn+"_"+num2str(V_dist)
	setscale /I x, (leftx(wv)*2), (rightx(wv)*2), W_two
	//variable V_shiftP=V_dist/2/deltax(wv)
	//W_two[]=wv[p-V_shiftP]+wv[p+V_shiftP]
	W_two[]=wv(pnt2x(W_two, p)-V_dist/2)+wv(pnt2x(W_two, p)+V_dist/2)
	
	return S_wn+"_"+num2str(V_dist)
end

function TwoPointsSeparation(W_src)
	wave W_src
	variable V_delt, n, i
	V_delt=deltax(W_src)
	n=numpnts(W_src)
	for(i=0; i<n; i+=1)
		wave W_two=$TwoPoints(NameOfWave(W_src), V_delt*i)
		wavestats /Q W_two
		if(abs(V_maxloc)>deltax(W_src))
			return V_delt*i
		endif
	endfor
	return nan
end
