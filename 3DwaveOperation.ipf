#pragma rtGlobals=1		// Use modern global access method.
function DepthROI(S_3Dmatrixname, V_XROI, V_YROI, V_dXROI, V_dYROI)
	string S_3Dmatrixname
	variable V_XROI, V_YROI, V_dXROI, V_dYROI
	wave M_Org=$S_3Dmatrixname
	make /O /N=(dimsize(M_Org, 2)) W_profile
	make /O /N=(V_dXROI/DimDelta(M_Org, 0), V_dYROI/DimDelta(M_Org, 1), dimsize(M_Org, 2)) M_PickOut
	SetScale/I x V_XROI-V_dXROI, V_XROI+V_dXROI , WaveUnits(M_Org, 0), M_PickOut
	SetScale/I y V_YROI-V_dYROI, V_YROI+V_dYROI ,WaveUnits(M_Org, 1), M_PickOut
	SetScale/I z DimOffset(M_Org, 2)-DimDelta(M_Org, 2), DimOffset(M_Org, 2)+DimDelta(M_Org, 2),WaveUnits(M_Org, 3), M_PickOut
	//wavetransform
	//imagetransform getPlane 
	//imagestats 
end

function Avr_2Din3D(ctrlName, S_matrixname, V_Xregion, V_Yregion, F_pixelmode)
//Multi-dimensional Utilities.ipf is required
	string ctrlName, S_matrixname
	variable V_Xregion, V_Yregion, F_pixelmode
	wave M_Org=$S_matrixname
	duplicate /O  M_Org $S_matrixname+"_avr"
	wave M_Orgavr=$S_matrixname+"_avr"
	if(F_pixelmode!=0)
		V_Xregion=x2pntMD(M_Org, 0, V_Xregion)
		V_Yregion=x2pntMD(M_Org, 1, V_Yregion)
	endif
	redimension /E=1 /n=(dimsize(M_Org, 0)-2*V_Xregion, dimsize(M_Org, 1)-2*V_Yregion, dimsize(M_Org, 2)) M_Orgavr
	setscale /P x, DimOffset(M_Org, 0)-V_Xregion, DimDelta(M_Org, 0), WaveUnits(M_Org, 0) M_Orgavr
	setscale /P y, DimOffset(M_Org, 1)-V_Yregion, DimDelta(M_Org, 1), WaveUnits(M_Org, 1) M_Orgavr
	variable i=0, j=0, k=0
	variable V_Xstart, V_Xend, V_Ystart, V_Yend
	
	for(i=V_Xregion; i<dimsize(M_Org, 0)-V_Xregion; i+=1)
		V_Xstart=i-V_Xregion
		V_Xend=i+V_Xregion
		for(j=V_Yregion; j<dimsize(M_Org, 1)-V_Yregion; j+=1)
			V_Ystart=j-V_Yregion
			V_Yend=j+V_Yregion
			for(k=0; k<dimsize(M_Org, 2); k+=1)
				imagestats /M=1/P=(k) /G={V_Xstart ,V_Xend, V_Ystart ,V_Yend } M_Org
				M_Orgavr[i][j][k]=V_max
			endfor
		endfor
	endfor

	//wavescaling("Depthprofiler", L_wavename, F_axis, F_dim)
end