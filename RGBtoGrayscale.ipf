#pragma rtGlobals=1		// Use modern global access method.

// rgbMatrix should be "direct color" wave (3 planes, first is red, second green, third blue),
// such as as 24-bit image loaded by LoadPICT or TIFF.

function /Wave RGB2Gray(SWN_rgbMatrix, F_kill)
	String SWN_rgbMatrix
	variable F_kill
	Prompt SWN_rgbMatrix, "rgb matrix:",popup,WaveList("!*Gray",";","")
	wave W_rgbMatrix=$SWN_rgbMatrix
	String SWN_luminance= SWN_rgbMatrix+"Gray"
	
	Variable V_rows=DimSize(W_rgbMatrix,0)
	Variable V_columns=DimSize(W_rgbMatrix,1)
	Variable V_planes=DimSize(W_rgbMatrix,2)
	Variable F_valid = (V_rows > 0) * (V_columns > 0) * (V_planes == 3)
	if(  !F_valid )
		Abort "Expected matrix wave with R, G, and B planes."
	endif
	
	Duplicate/O W_rgbMatrix $SWN_luminance
	
	Redimension/D/N=(-1,-1,0,0)	$SWN_luminance // remove planes and chunks
	// Coefficients from "Graphics Gems", RGB to Y (I and Q discarded)
	wave W_luminance=$SWN_luminance
	multithread W_luminance =0.299*W_rgbMatrix[p][q][0] + 0.587*W_rgbMatrix[p][q][1] + 0.114*W_rgbMatrix[p][q][2]
	if(F_kill)
		killwaves W_rgbMatrix
	endif
	//Print "output is "+luminance
	//Display;AppendImage $luminance;SetAxis/A/R left
	return W_luminance
End

function multiRGB2Glay(SMN_images, V_nStat, V_nEnd, V_nInc, SMN_dest, V_StatDest, V_IncDest, F_kill)
	string SMN_images
	variable V_nStat, V_nEnd, V_nInc
	string SMN_dest
	variable V_StatDest, V_IncDest
	variable F_kill
	variable i
	for(i=0; V_nStat+i*V_nInc<=V_nEnd; i+=1)
		wave W_tmp=RGB2Gray(SMN_images+num2str(V_nStat+i*V_nInc), F_kill)
		duplicate /O W_tmp, $SMN_dest+num2str(V_StatDest+i*V_IncDest)
		if(F_kill)
			killwaves W_tmp
			killwaves $SMN_images+num2str(V_nStat+i*V_nInc)
		endif
	endfor
end
"r", 0, 10, 1, "M_incBeam", 0, 5)