//20200727//20220721
Function /S num2strD(num)
	variable /D num
	string sval
	sprintf sval, "%g" num
	return sval
end

Function /D str2numD(sval)
	string sval
	variable /D num
	sscanf sval, "%f",  num
	return num
end

function /S genSdate(ctrlName)
	string ctrlName
	string L_date=date()
	string /G S_year, S_month, S_date
	variable V_place=0
	L_date=ReplaceString("年", L_date, ";")
	L_date=ReplaceString("月", L_date, ";")
	L_date=RemoveEnding(L_date, "日")
	//print L_date
	S_year=StringFromList(0, L_date)
	S_month=StringFromList(1, L_date)
	S_date=StringFromList(2, L_date)
	//print S_year, S_month, S_date
	return L_date
end


function /S Convert2Polar(wv)
	wave /C wv
	duplicate /O wv, $NameOfWave(wv)+"_Pol"
	wave /C wvPol=$NameOfWave(wv)+"_Pol"
	variable V_threshold=1e-7
	wvPol=r2polar(wv)
	wv=cmplx(sign(real(wv))*real(wv), sign(real(wv))*imag(wv))
	wv=cmplx(real(wv), imag(wv)*sign(imag(wv))*(1-(abs(imag(wv))<V_threshold)))
	wv=cmplx(real(wv), mod(imag(wv), 2*pi))
	return NameOfWave(wvPol)
end

function /S BaseNameGenerator(ctrlName, V_wavelength)
	string ctrlName
	variable V_wavelength
	String  S_BaseFilename=genSdate("RetardationDataAquisition")
	S_BaseFilename=ReplaceString(";", S_BaseFilename, "")
	S_BaseFilename="D"+S_BaseFilename+"_"+num2str(V_wavelength)+"nm_"
	return S_BaseFilename
end

function/S PorM(Val)
	variable Val
	return SelectString((1+sign(Val))/2,"-","+")
end 

function shift(wv, p_start, p_stop, V_val)
	wave wv
	variable  p_start, p_stop, V_val
	variable i
	for(i=p_start; i<=p_stop; i+=1)
		wv[i]+=V_val
	endfor
end

function YorN(ctrlName, S_message, S_submessage)
	string ctrlName, S_message, S_submessage
	string S_YesOrNo
	Prompt S_YesOrNo, S_submessage, popup "Yes; No"
	doprompt S_message, S_YesOrNo
	if(abs(cmpstr( S_YesOrNo, "Yes")))
		return 0
	else
		return 1
	endif
end

function MakeWavesFromList(L_Wavenames, L_nPoints, F_complex)
	String L_Wavenames, L_nPoints
	variable F_complex
	variable V_nWaves=ItemsInList(L_Wavenames)
	variable V_nDim=ItemsInList(L_nPoints)
	variable V_nRow=str2num(StringFromList(0, L_nPoints))
	variable V_nColumn=str2num(StringFromList(1, L_nPoints))
	variable V_nLayer=str2num(StringFromList(2, L_nPoints))
	variable V_nChank=str2num(StringFromList(3, L_nPoints))
	variable i_wave, i_dim
	for(i_wave=0; i_wave<V_nWaves; i_wave+=1)
		if(F_complex)
			make /C/O/D/N=(V_nRow,V_nColumn,V_nLayer,V_nChank) $StringFromList(i_wave, L_Wavenames)
		else
			make /O/D/N=(V_nRow,V_nColumn,V_nLayer,V_nChank) $StringFromList(i_wave, L_Wavenames)
		endif
	endfor
end

function SetScaleWavesFromList(L_Wavenames, V_dim, L_start, L_EndorStep, L_Unit, F_inclusive)
	String L_Wavenames
	variable V_dim
	string L_start, L_EndorStep, L_Unit
	variable F_inclusive
	variable V_nWaves=ItemsInList(L_Wavenames)
	variable V_nDim=V_dim
	variable i_wave, i_dim
	for(i_wave=0; i_wave<V_nWaves; i_wave+=1)
		for(i_dim=0; i_dim<V_nDim; i_dim+=1)
		switch(i_dim)
			case 0://Row
				if(F_inclusive)
					SetScale /I x, str2num(StringFromList(i_dim, L_start)), str2num(StringFromList(i_dim, L_EndorStep)), StringFromList(i_dim, L_Unit), $StringFromList(i_wave, L_Wavenames)
				else
					SetScale /P x, str2num(StringFromList(i_dim, L_start)), str2num(StringFromList(i_dim, L_EndorStep)), StringFromList(i_dim, L_Unit), $StringFromList(i_wave, L_Wavenames)
				endif
				break
			case 1://Column
				if(F_inclusive)
					SetScale /I y, str2num(StringFromList(i_dim, L_start)), str2num(StringFromList(i_dim, L_EndorStep)), StringFromList(i_dim, L_Unit), $StringFromList(i_wave, L_Wavenames)
				else
					SetScale /P y, str2num(StringFromList(i_dim, L_start)), str2num(StringFromList(i_dim, L_EndorStep)), StringFromList(i_dim, L_Unit), $StringFromList(i_wave, L_Wavenames)
				endif
				break
			case 2://Layer
				if(F_inclusive)
					SetScale /I z, str2num(StringFromList(i_dim, L_start)), str2num(StringFromList(i_dim, L_EndorStep)), StringFromList(i_dim, L_Unit), $StringFromList(i_wave, L_Wavenames)
				else
					SetScale /P z, str2num(StringFromList(i_dim, L_start)), str2num(StringFromList(i_dim, L_EndorStep)), StringFromList(i_dim, L_Unit), $StringFromList(i_wave, L_Wavenames)
				endif
				break
			case 3://Chank
				if(F_inclusive)
					SetScale /I t, str2num(StringFromList(i_dim, L_start)), str2num(StringFromList(i_dim, L_EndorStep)), StringFromList(i_dim, L_Unit), $StringFromList(i_wave, L_Wavenames)
				else
					SetScale /P t, str2num(StringFromList(i_dim, L_start)), str2num(StringFromList(i_dim, L_EndorStep)), StringFromList(i_dim, L_Unit), $StringFromList(i_wave, L_Wavenames)
				endif
				break
			default:
		endswitch
		endfor
	endfor
end

function CopyScaleWavesFromList(S_srcwavename, L_Wavenames, F_inclusive)
	String S_srcwavename, L_Wavenames
	variable F_inclusive
	variable V_nWaves=ItemsInList(L_Wavenames)
	variable i_wave
	for(i_wave=0; i_wave<V_nWaves; i_wave+=1)
		if(F_inclusive)
			CopyScales /I $S_srcwavename, $StringFromList(i_wave, L_Wavenames)
		else
			CopyScales /P $S_srcwavename, $StringFromList(i_wave, L_Wavenames)
		endif
	endfor
end

function Reconst3DtoVector(L_XYZ_Src, S_Vector_Dist, F_complex)
	string L_XYZ_Src, S_Vector_Dist
	variable F_complex
	variable i
	for(i=0; i<3; i+=1)
		if(F_complex)
			wave /C W_Src_C=$StringFromList(i, L_XYZ_Src)
			wave /C W_Vector_Dist_C=$S_Vector_Dist
			W_Vector_Dist_C[][][i][]=W_Src_C[p][q][s]
		else
			wave W_Src=$StringFromList(i, L_XYZ_Src)
			wave W_Vector_Dist=$S_Vector_Dist
			W_Vector_Dist[][][i][]=W_Src[p][q][s]
		endif
	
	endfor
end


function OffsetCmp(L_wv)
	string L_wv
	variable n=itemsinlist(L_wv)
	variable V_maxAVG=-inf
	variable V_minAVG=inf
	variable i
	for(i=0; i<n; i+=1)
		wave wv=$StringFromList(i, L_wv)
		variable V_mean=mean(wv)
		V_maxAVG=max(V_maxAVG, V_mean)
		V_minAVG=min(V_minAVG, V_mean)
	endfor
	variable V_meanAVG=(V_maxAVG+V_minAVG)/2
	for(i=0; i<n; i+=1)
		wave wv=$StringFromList(i, L_wv)
		wv*=V_meanAVG/mean(wv)
	endfor
	return V_meanAVG
end

function /S AvgedWave(L_wv, S_wvAvg)
	string L_wv
	string S_wvAvg
	duplicate /O $StringFromList(1, L_wv), $S_wvAvg
	wave W_avg=$S_wvAvg
	W_avg=0
	variable n=itemsinlist(L_wv)
	variable i
	for(i=0; i<n; i+=1)
		wave wv=$StringFromList(i, L_wv)
		W_avg+=wv
	endfor
	W_avg/=n
		print n
	return S_wvAvg

end

Function GetConfig(S_WN_config, V_No)
	string S_WN_config
	variable V_No
	wave W_config=$S_WN_config
	return W_config[V_No]
end

function /D x2pnt_MD(wname, F_dim, val)
	string wname
	variable F_dim, val
	wave wv=$wname
	return (val - DimOffset(wv, F_dim))/DimDelta(wv,F_dim)
end

function /D pnt2x_MD(wname, F_dim, val)
	string wname
	variable F_dim, val
	wave wv=$wname
	return DimOffset(wv, F_dim) + val *DimDelta(wv, F_dim)
end

function /S GetWaveStats_Wave(wv)
	wave wv
	wavestats /W /Q wv
	string S_wname="SW_"+nameofwave(wv)
	duplicate /O M_WaveStats, $S_wname
	return S_wname
end


function /S AddStrWN(wv, S_AddStr)
	wave wv
	string S_AddStr
	duplicate /O /D wv, $nameofwave(wv)+S_AddStr
	return nameofwave(wv)+S_AddStr
end

function /T SaveAllWaves(F_format, S_Pass, S_WaveMatchStr, S_WaveList_Option)
	//F_format=1: igor bin
	//              2: igor text
	//              3: del text
	variable F_format
	string S_Pass, S_WaveMatchStr, S_WaveList_Option
	NewPath /O DataFolder S_Pass
	string L_wavelist=WaveList(S_WaveMatchStr, ";", S_WaveList_Option)
	variable V_n=ItemsInList(L_wavelist)
	print V_n, "waves"
	string S_wname
	variable i
	for(i=0; i<V_n; i+=1)
		//print i
		S_wname=StringFromList(i, L_wavelist)
		switch(F_format)
			case 1://igor bin
				Save/A=0/C/O /P=DataFolder $S_wname as S_wname+".ibw"
				break
			case 2://igor text
				Save/A=0/T /P=DataFolder $S_wname as S_wname+".itx"
				break
			case 3://del text
				Save/A=0/J/W /P=DataFolder $S_wname as S_wname+".txt"
				break
			default:
		endswitch
	endfor
	return S_Pass
end


function /T MaxMinSumAvgOfWaveList(L_wavelist)
	string L_wavelist
	variable V_n=itemsinlist(L_wavelist)
	variable i, V_Wmax, V_Wmin, V_Wsum, V_Wavg
	V_Wmax=-inf
	V_Wmin=inf
	V_Wsum=0
	V_Wavg=0
	for(i=0; i<V_n; i+=1)
		wavestats /Q $StringFromList(i, L_wavelist)
		//print i ,StringFromList(i, L_wavelist)
		//print V_max, V_min
		if(V_min<V_Wmin)
			V_Wmin=V_min
		endif
		if(V_max>V_Wmax)
			V_Wmax=V_max
		endif
		V_Wsum+=V_sum
		V_Wavg+=V_avg
	endfor
	V_Wavg/=V_n
	//print V_Wmax, V_Wmin
	return num2strD(V_Wmax)+";"+num2strD(V_Wmin)+";"+num2strD(V_Wsum)+";"+num2strD(V_Wavg)
end


function NanEracer(WV, F_print)
	wave wv
	variable F_print//1->print the result
	variable /D i, n=dimsize(wv, 0)
	variable V_n=0
	variable V_f=0
	for(i=0; i<n; i+=1)
		if(wv[i])
		else
			wv[i]=(wv[i-1]+wv[i+1])/2
			if(wv[i])
				V_n+=1
			else
				V_f+=1
			endif
			
		endif
	endfor
	if(F_print)
	print "Eraced: ",V_n,"Failer: ",V_f
	endif
	return V_f
end

function /S NormAwithB(W_A, W_B)
	wave W_A, W_B
	wavestats /Q /M=1 W_B
	string S_wname=nameofwave(W_A)+"_Nrm"
	duplicate /O /D W_A, $S_wname
	wave W_A_Nrm=$S_wname
	W_A_Nrm/=V_max
	return S_wname
end

function OverWriteCfg(S_wavename, I_config, V_value)
	string S_wavename
	variable I_config, V_value
	wave W_config=$S_wavename
	if(numtype(V_value))
		V_value=W_config[I_config]
	else
		W_config[I_config]=V_value
	endif
	return V_value
end

function GetCfg(S_wavename, I_config)
	string S_wavename
	variable I_config
	wave W_config=$S_wavename
	return W_config[I_config]
end

function /S GetCfg_2DS(S_CfgName, V_R, V_C)
	string S_CfgName
	variable V_R, V_C
	wave /T W_config=$S_CfgName
	return W_config[V_R][V_C]
end
	
function /S OverWriteCfg_2DS(S_CfgName, V_R, V_C, S_Val)
	string S_CfgName
	variable V_R, V_C
	string S_Val
	wave /T W_config=$S_CfgName
	W_config[V_R][V_C]=S_Val
	return W_config[V_R][V_C]
end


function /T AddStr_Wavename(wv, S_prefix, F_suffix)
	wave wv
	string S_prefix, F_suffix
	string S_wn=S_prefix+nameofwave(wv)+F_suffix
	rename wv, $S_wn
	return S_wn
end

function AddStr_Wavename_L(L_WN, S_prefix, F_suffix)
	string L_WN, S_prefix, F_suffix
	variable n=itemsinlist(L_WN)
	variable i
	for(i=0; i<n; i+=1)
		AddStr_Wavename($StringFromList(i, L_WN), S_prefix, F_suffix)
	endfor
end

function printWMSetVariableAction(sva)
	struct WMSetVariableAction &sva
	print "ctrlName",sva.ctrlName
	print "win",sva.win
	print "eventCod",sva.eventCode
	print "eventMod",sva.eventMod
	print "userData",sva.userData
	//print "blockRee",sva.blockReentry
	print "isStr",sva.isStr
	print "dval",sva.dval
	print "sval",sva.sval
	print "vName",sva.vName
	print "svwave",sva.svwave
	print "rowindex",sva.rowindex
	print "rowlabel",sva.rowlabel
	print "colindex",sva.colindex
	print "collabel",sva.collabel
end

function /D Gconst_func(V_x, V_Xend)
	variable V_x, V_Xend
	if(V_x<V_Xend/2)
		return 2/V_Xend^2*V_x
	elseif(V_x<V_Xend)
		return -2/V_Xend^2*(V_x-V_Xend)^2
	else
		return 1
	endif
end

function EdgeCnt(W_wave, V_diff)
	wave W_wave
	variable V_diff
	variable n=numpnts(W_wave)
	variable i
	variable V_val=0
	for(i=0; i<n; i+=1)
		//if(abs(W_wave[i]-W_wave[i+1])!=V_diff&&abs(W_wave[i]-W_wave[i+1])!=0)
			if(-(W_wave[i]-W_wave[i+1])>=V_diff)
			//print i, W_wave[i]-W_wave[i+1]
			V_val+=1
		endif
	endfor
	return V_val
end

function EdgeCnt_dulation(W_wave, V_diff)
	wave W_wave
	variable V_diff
	make/D/O/n=200000 W_distance
	variable n=numpnts(W_wave)
	variable i, j
	j=0
	variable V_val=0
	for(i=0; i<n; i+=1)
		if(abs(W_wave[i]-W_wave[i+1])>V_diff)
			W_distance[j]=pnt2x(W_wave, i)-V_val
			V_val=pnt2x(W_wave, i)
			j+=1
		endif
	endfor
end

function EdgeCnt_shape(W_wave, V_diff, V_sh)
	wave W_wave
	variable V_diff, V_sh
	variable n=numpnts(W_wave)
	variable i
	variable j=0
	variable V_val=0
	for(i=0; i<n; i+=1)
		if((W_wave[i]-W_wave[i+1])>=V_diff)
			V_val+=1
			if(V_val==V_sh+1)
				DeletePoints i, numpnts(W_wave)-1, W_wave
			endif
			j=i
		endif
	endfor
end

function Reduction(V_devided, V_devide, F_output)
	variable V_devided, V_devide, F_output
	variable COPY_V_devided = abs(V_devided), COPY_V_devide = abs(V_devide)
	variable V_CommonDivisor, V_residue, V_residue2, V_AnsDevided, V_AnsDevide


	if(COPY_V_devide >= COPY_V_devided)
		V_CommonDivisor = COPY_V_devided+1
		V_residue = mod(COPY_V_devide, V_CommonDivisor)
		V_residue2 = mod(COPY_V_devided, V_CommonDivisor)
		do
			V_CommonDivisor -= 1
			V_residue = mod(COPY_V_devide, V_CommonDivisor)
			V_residue2 = mod(COPY_V_devided, V_CommonDivisor)
		while((V_residue != 0) || (V_residue2 != 0))
	else
		V_CommonDivisor = COPY_V_devide
		V_residue = mod(COPY_V_devide, V_CommonDivisor)
		V_residue2 = mod(COPY_V_devided, V_CommonDivisor)
		do
			V_CommonDivisor -= 1
			V_residue = mod(COPY_V_devide, V_CommonDivisor)
			V_residue2 = mod(COPY_V_devided, V_CommonDivisor)
		while((V_residue != 0) || (V_residue2 != 0))
	endif
	if(((V_devided > 0) && (V_devide > 0)) || ((V_devided < 0) && (V_devide < 0)))
		V_AnsDevided = COPY_V_devided / V_CommonDivisor
		V_AnsDevide = COPY_V_devide / V_CommonDivisor
	else
		V_AnsDevided = -1*COPY_V_devided / V_CommonDivisor
		V_AnsDevide = COPY_V_devide / V_CommonDivisor
	endif

	if(F_output)
		return V_AnsDevide
	else
		return V_AnsDevided
	endif
end

threadsafe function /D fBaumkuchenInt(S_funcLoc, V_rStat, V_rEnd)//string /G S_func
	string S_funcLoc
	variable V_rStat, V_rEnd
	svar S_func
	S_func=S_funcLoc
	return 2*pi*integrate1D(fIntegrand_BaumkuchenInt, V_rStat, V_rEnd, 1, -1)
end

threadsafe function /D fBaumkuchenInt2(S_funcLoc, V_rStat, V_rEnd, pWave)//string /G S_func
	string S_funcLoc
	variable V_rStat, V_rEnd
	Wave pWave
	svar S_func
	S_func=S_funcLoc
	return 2*pi*integrate1D(fIntegrand_BaumkuchenInt2, V_rStat, V_rEnd, 1, -1, pWave)
end

threadsafe function ferrBaumkuchenInt(val)
	variable val
	print "Error: Baumkuchen Integration"
	return nan
end

threadsafe function ferrBaumkuchenInt2(pWave, inX)
	Wave pWave
	Variable inX
	print "Error: Baumkuchen Integration"
	return nan
end

threadsafe function /D fIntegrand_BaumkuchenInt(inX)
	variable inX
	Svar S_func
	funcref ferrBaumkuchenInt Fnc_func=$S_func
	return  Fnc_func(inX)*inX
end

threadsafe function /D fIntegrand_BaumkuchenInt2(pWave, inX)
	Wave pWave
	Variable inX
	Svar S_func
	funcref ferrBaumkuchenInt2 Fnc_func=$S_func
	return  Fnc_func(pWave, inX)*inX
end

function /S Rad2Pi(V_rad, F_style)
	variable V_rad , F_style
	//F_style
	//0: 2/3 \F'Symbol'p
	//1: 2 \F'Symbol'p\F]0 /3
 	variable V_Pimod=mod(V_rad, pi)
 	variable p_dev
 	if(V_rad ==0)
		return "0"
	elseif(V_rad/pi==1)
		return "\F'Symbol'p"
	elseif(V_Pimod==0)
		return num2str(V_rad/pi)+"\F'Symbol'p"
	elseif(V_rad/pi<1)
		for(p_dev=2;p_dev<100 ; p_dev+=1)
			if(mod(V_rad, pi/p_dev))
			else
				if(V_rad/(pi/p_dev)>1)
					if(F_style)
						return num2str(V_rad/(pi/p_dev))+"/"+num2str(p_dev)+" \F'Symbol'p"
					else
						return num2str(V_rad/(pi/p_dev))+"\F'Symbol'p\F]0/"+num2str(p_dev)					
					endif
				else
					if(F_style)
						return "1/"+num2str(p_dev)+" \F'Symbol'p"
					else	
						return " \F'Symbol'p\F]0/"+num2str(p_dev)
					endif
				endif
			endif
		endfor
	endif
	return ""
end

function makenote(ctrlName, S_wavename)
	string ctrlName, S_wavename
	wave WV=$S_wavename
	Nvar X_amplitude, Y_amplitude, X_pixels, Y_pixels
	Nvar F_PiezoMode, F_VscanMode, F_TwoWay, F_PintScan, F_lines, Z_step, Z_upper, Z_Lower, V_resolution
	note /K WV, date()+"\r"
	note /NOCR WV, "[imagesize]\r"
	note /NOCR WV, "X	:"+num2str(X_amplitude*2*(1+9*F_piezomode))+" um\r"
	note /NOCR WV, "Y	:"+num2str(Y_amplitude*2*(1+9*F_piezomode))+" um\r"
	if(dimsize(WV, 2))
		note /NOCR WV, "Z	:"+num2str(Z_Upper-Z_Lower)+" um\r"
		note /NOCR WV, num2str(X_pixels+1)+" pixels - "+num2str(Y_pixels+1)+" pixels"
	endif
	if (dimsize(WV, 2))
		note /NOCR WV, num2str((Z_Upper-Z_Lower)/Z_step+1)+" pixels"
	endif
		note /NOCR WV, "\r"
	if(dimsize(WV, 2))
		Nvar F_PiezoZScan, F_ObjectiveLocked
		note /NOCR WV, "[ZscanMode]\r"
		note /NOCR WV, "ZscanResolution:	"+num2str(Z_step)+"um\r"
		note /NOCR WV, "ZscanRange:	from"+num2str(Z_Lower)+" to "+num2str(Z_upper)+"um\r"
		if(F_ObjectiveLocked)
			note /NOCR WV, "Minimum resolution	:0.005 um/bit (12bit)\r"
		else
			note /NOCR WV, "Minimum resolution	:"+num2str(V_resolution)+" um/step\r"
		endif
		if(F_PiezoZScan)
			if(F_ObjectiveLocked)
				note /NOCR WV, "PiezoDrive\r"
			else
				note /NOCR WV, "ObvectiveDrives With Piezo\r"
			endif
		else
			if(F_ObjectiveLocked)
				note /NOCR WV, "NoDriving...\r"
			else
				note /NOCR WV, "Objective Drive\r"
			endif
		endif
	endif
	
	if(dimsize(WV, 3))
		Nvar V_ImageThreshold
		note /NOCR WV, "[4-D matrix]\r"
		note /NOCR WV, "Sreshold of retio image	:"+num2str(V_ImageThreshold)+"\r"
		note /NOCR WV, "M_4D[x][y][z][0]	:LP00\r"
		note /NOCR WV, "M_4D[x][y][z][1]	:LP90\r"
		note /NOCR WV, "M_4D[x][y][z][2]	:RP\r"
		note /NOCR WV, "M_4D[x][y][z][3]	:LP00/LP90\r"
		note /NOCR WV, "M_4D[x][y][z][4]	:RP/LP90\r"
		note /NOCR WV, "M_4D[x][y][z][5]	:RP/LP00\r"
		note /NOCR WV, "M_4D[x][y][z][6]	:(RP-LP)/(RP+LP)\r"
	endif
		note /NOCR WV,  "[ScanConfig]\r"
	
	if(F_PiezoMode)
		note /NOCR WV,  "Piezo-Scan\r"
	else
		note /NOCR WV,  "Galvano-Scan\r"
	endif
	if(F_VscanMode)
		note /NOCR WV,  "Vertical-Scanning\r"
	else
		note /NOCR WV,  "Horizontal-Scanning\r"
	endif
	if(F_TwoWay)
		note /NOCR WV,  "Two-Way\r"
	else
		note /NOCR WV,  "One-Way\r"
	endif
	
	if(F_PintScan)
		note /NOCR WV,  "Point-Scan\r"
	else
		note /NOCR WV,  "Line-Scan\r"
	endif

	if(F_lines)
		note /NOCR WV,  "Update per Lines\r"
	else
		note /NOCR WV,  "Updata per Plane\r"
	endif
	
end

Function wavescaling(ctrlName, L_wavename, F_axis, F_dim)
	string ctrlName, L_wavename
	variable F_axis, F_dim
	string S_wavename
	variable i
	NVAR F_PiezoMode=F_PiezoMode
	NVAR X_amplitude, Y_amplitude
	NVAR X_Offset, Y_Offset
	NVAR Z_Upper=Z_Upper
	NVAR Z_Lower=Z_Lower
	NVAR Z_step=Z_step
	NVAR F_piezoZscan
	string S_dim
//	wave WV=$S_wavename
	for(i=0; i<ItemsInList(L_wavename); i+=1)
		S_wavename=StringFromList(i, L_wavename)
		switch(F_axis)
			case 0:
				S_dim="x"
				break
			case 1:
				S_dim="y"
				break
			case 2:
				S_dim="z"
				break
			default:
				print "BadParameter"
				return 0
		endswitch
		switch(F_dim)
			case 0:
				if(F_PiezoMode)
					Execute "SetScale /I  "+S_dim+" -X_amplitude*1e-5, X_amplitude*1e-5,\"m\", "+S_wavename
				else
					Execute "SetScale /I  "+S_dim+" -X_amplitude, X_amplitude,\"V\", "+S_wavename
				endif
				break
			case 1:
				if(F_PiezoMode)
					Execute "SetScale /I  "+S_dim+" -Y_amplitude*1e-5, -Y_amplitude*1e-5,\"m\", "+S_wavename
				else
					Execute "SetScale /I  "+S_dim+" -Y_amplitude, -Y_amplitude,\"V\", "+S_wavename
				endif
				break
			case 2:
					Execute "SetScale /I "+S_dim+" Z_Lower*1e-6, Z_Upper*1e-6,\"m\", "+S_wavename
				break
			default:
				print "BadParameter"
		endswitch
	endfor
end

Function OpenMultiFiles()
    Variable aa
    String fileFilters = "Image Files (*.jpg,*.jpeg,*.png):.jpg,.jpeg,.png;"
    fileFilters += "All Files:.*;"
    OPEN/D/R/MULT=1/F=fileFilters aa
    
    String FilePaths
    FilePaths = S_fileName
    
    If(Strlen(FilePaths)!=0)
        Variable NumOfPath
        NumOfPath = ItemsInList(FilePaths, "\r")

        String Path
        Variable i
        For (i=0; i<NumOfPath; i+=1)
            Path = StringFromList(i, FilePaths, "\r")
            ImageLoad/T=jpeg/O/G Path
        EndFor
    EndIf

End

Function makePolData(W_input)
	wave W_input
	string S_waqvename_dir=nameofwave(W_input)+"_1D_dir"
	string S_waqvename_rad=nameofwave(W_input)+"_1D_rad"
	string S_waqvename_val=nameofwave(W_input)+"_1D_val"
	variable V_nX=DimSize(W_input,0)
	variable V_nY=DimSize(W_input,1)
	make /O/D/n=(V_nX*V_nY)  $S_waqvename_dir, $S_waqvename_rad, $S_waqvename_val
	wave W_dir=$S_waqvename_dir
	wave W_rad=$S_waqvename_rad
	wave W_val=$S_waqvename_val
	multithread W_val=W_input[mod(p, V_nX)][trunc(p/V_nX)]
	multithread W_dir=IndexToScale(W_input, mod(p, V_nX), 0)
	multithread W_rad=IndexToScale(W_input, trunc(p/V_nX), 1)
end

Function Waiting(n, V_time_microsec)
	//recommended
	//n=50000(>1sec)

	variable n, V_time_microsec
	variable i=-1, V_CurrTime, F_TimerNo, F_TimerNo2
	do
		i+=1
	while(stopMSTimer(i))
	F_TimerNo2=startMSTimer
	do
	F_TimerNo=startMSTimer
			for(i=0; i<n; i+=1)
			endfor
		V_CurrTime+=stopMSTimer(F_TimerNo)
	while(V_CurrTime<V_time_microsec)
	//print V_CurrTime
	return stopMSTimer(F_TimerNo2)
end

threadsafe function /wave ExtractPartialMatrix(M_srcWave, S_MN_destWave, V_Ps, V_Pe, V_Qs, V_Qe, V_Rs, V_Re, V_Ss, V_Se)
	wave M_srcWave
	string S_MN_destWave
	variable V_Ps, V_Pe, V_Qs, V_Qe, V_Rs, V_Re, V_Ss, V_Se
	duplicate /O M_srcWave, $S_MN_destWave
	wave M_destWave=$S_MN_destWave
	redimension /N=(V_Pe-V_Ps , V_Qe-V_Qs , V_Re-V_Rs, , V_Se-V_Se) M_destWave
	setscale /P x IndexToScale(M_srcWave, V_Ps, 0), dimDelta(M_srcWave, 0), WaveUnits(M_srcWave, 0) M_destWave
	setscale /P y IndexToScale(M_srcWave, V_Qs, 1), dimDelta(M_srcWave, 1), WaveUnits(M_srcWave, 1) M_destWave
	setscale /P z IndexToScale(M_srcWave, V_Rs, 2), dimDelta(M_srcWave, 2), WaveUnits(M_srcWave, 2) M_destWave
	setscale /P t IndexToScale(M_srcWave, V_Ss, 3), dimDelta(M_srcWave, 3), WaveUnits(M_srcWave, 3) M_destWave
	M_destWave[][][][]=M_srcWave[p+V_Ps][q+V_Qs][r+V_Rs][t+V_Ss]
end


function extractBeamValue(M_src, V_p, V_q, F_min)
	wave M_src
	variable V_p, V_q, F_min
	imagetransform /BEAM={(V_p),(V_q)} getBeam M_src
	wave W_Beam
	wavestats /Q/P W_Beam
	if(F_min)
		if(V_minloc!=-1)
			return V_minloc 
		endif
		return nan
	elseif(V_maxloc==-1)
		return nan
	else
		return V_maxloc
	endif
end

function /Wave Findvalues(W_Src, V_findV, V_tol)
	wave W_Src
	variable V_findV, V_Tol
	variable V_n=1000
	make /Free /n=(V_n) W_Findvalues
	variable i, V_value=0
	for(i=0;V_value!=-1; i+=1)
		Findvalue /Z/S=(V_value+1)/T=(V_Tol)/V=(V_findV) W_Src
		W_Findvalues[i]=V_value
		//print i, V_value
	endfor
	Redimension /n=(i-1)  W_Findvalues
	return W_Findvalues
end

function FindvaluesN(W_Src, V_tol)
	wave W_Src
	variable V_Tol
	nvar V_findV
	variable i, V_value=0
	for(i=0;V_value!=-1; i+=1)
	//print i
		Findvalue /Z/S=(V_value+1)/T=(V_Tol)/V=(V_findV) W_Src
	endfor
	return i-1
end

function FindvaluesN2(W_Src, V_findV, V_tol)
	wave W_Src
	variable V_findV, V_Tol
	variable i, V_value=0
	for(i=0;V_value!=-1; i+=1)
	//print i
		Findvalue /Z/S=(V_value+1)/T=(V_Tol)/V=(V_findV) W_Src
	endfor
	return i-1
end

function FindOptTolerance(W_Src, V_findVal, V_nValues, V_iniTol)
	wave W_Src
	variable V_findVal, V_nValues, V_iniTol
	nvar V_findV=V_findVal
	FindRoots /Q/Z=(V_nValues) FindvaluesN, W_Src
	//print V_numRoots
	//print V_Root,V_YatRoot, V_Root2, V_YatRoot2
	if(V_flag)
		return V_iniTol
	else
		return V_Root
	endif
end

function /wave getParamImages(S_matchStr,V_startP ,V_endP, V_startQ ,V_endQ, F_param)
	string S_matchStr
	variable V_startP ,V_endP, V_startQ ,V_endQ, F_param
	string L_wlist= WaveList(S_matchStr, ";", "" )//	ex WaveList("M_down*_crs", ";", "" )
	variable V_n=itemsInList(L_wlist)
	variable V_n_a=itemsInList(S_matchStr, "*")
	print V_n, V_n_a
	make /O/D/n=(V_n) W_res, W_res_x
	string S_tmp, S_baseWN, S_suffix
	variable i, j, k
	for(i=0;i<V_n;i+=1)
		string S_wave=stringfromlist(i, L_wlist)
		wave W_wave=$S_wave
		imagestats /G={V_startP ,V_endP, V_startQ ,V_endQ} W_wave
		for(j=0,S_baseWN="";j<V_n_a;j+=1)
			S_tmp=stringfromlist(j, S_matchStr,"*")
			S_baseWN+=S_tmp
			S_wave=ReplaceString(S_tmp, S_wave, "")
		endfor
		W_res_x[i]=str2num(S_wave)
		switch(F_param)	// numeric switch
			case 0:	// execute if case matches expression
				W_res[i]=V_avg
				S_suffix="_avg"
				print i, nameofwave(W_wave), V_avg, str2num(S_wave)
				break		// exit from switch
			case 1:	// execute if case matches expression
				W_res[i]=V_sdev
				S_suffix="_sdev"
				print i, nameofwave(W_wave), V_sdev, str2num(S_wave)
				break
			case 2:	// execute if case matches expression
				W_res[i]=V_avg-V_max
				S_suffix="_max"
				print i, nameofwave(W_wave), V_avg-V_max, str2num(S_wave)
				break
			case 3:	// execute if case matches expression
				W_res[i]=V_avg-V_min
				S_suffix="_min"
				print i, nameofwave(W_wave), V_avg-V_min, str2num(S_wave)
				break
			default:			// optional default expression executed
				W_res[i]=nan		// when no case matches
		endswitch
		
	endfor
	sort W_res_x, W_res, W_res_x
	duplicate /O W_res, $S_baseWN+S_suffix
	duplicate /O W_res_x, $S_baseWN+S_suffix+"_x"
	killwaves W_res, W_res_x
	return $S_baseWN
end

function /wave WaveStats_Waves(L_waves, WN_param, F_param)
	string L_waves, WN_param
	variable F_param
	duplicate /O $StringFromList(0, L_waves), $WN_param
	wave W_param=$WN_param
	W_param=WaveStats_Wave_p(L_waves, p, F_param)
	return W_param
end

threadsafe function WaveStats_Wave_p(L_waves, V_p, F_param)
	string L_waves
	variable V_p, F_param
	variable V_nWaves=ItemsInList(L_waves)
	make /O/D/n=(V_nWaves) W_data

	variable i
	for(i=0;i< V_nWaves;i+=1)
		//print StringFromList(i, L_waves)
		wave W_tmp=$StringFromList(i, L_waves)
		W_data[i]=W_tmp[V_p]
	endfor
	wavestats /Q W_data
	//print V_sdev
	switch(F_param)	// numeric switch
		case 0:	//V_avg
			return V_avg
			break
		case 1:	//V_sdev
			return V_sdev
			break
		case 2:	//V_max
			return V_max
			break
		case 3:	//V_min
			return V_min
			break
		default:
			return 0
	endswitch
	
end

function ZapPeriodFilename()
	string L_waves=WaveList("*.*", ";", "")
	variable V_nWaves=itemsinlist(L_waves)
	variable i, j, V_nPeriod
	String WN_NewWave=""
	String WN_OldWave
	for(i=0;i<V_nWaves;i+=1)
		WN_OldWave= StringFromList(i, L_waves)
		V_nPeriod=itemsinlist(StringFromList(i, L_waves), ".")
		print V_nPeriod
		WN_NewWave=""
		for(j=0;j<V_nPeriod;j+=1)
			WN_NewWave+=StringFromList(j, WN_OldWave, ".")
		endfor
		print V_nPeriod,WN_OldWave, "->", WN_NewWave
		rename $WN_OldWave, $WN_NewWave
	endfor
end

function ReplaceString_Filename(S_Old, S_New)
	string S_Old, S_New
	string L_waves=WaveList("*"+S_Old+"*", ";", "")
	variable V_nWaves=itemsinlist(L_waves)
	print V_nWaves
	variable i, j, V_nPeriod
	String WN_NewWave=""
	String WN_OldWave
	for(i=0;i<V_nWaves;i+=1)
		WN_OldWave= StringFromList(i, L_waves)
		V_nPeriod=itemsinlist(StringFromList(i, L_waves), S_Old)
		//print V_nPeriod
		WN_NewWave=ReplaceString(S_Old, WN_OldWave, S_New)
		print V_nPeriod,WN_OldWave, "->", WN_NewWave
		rename $WN_OldWave, $WN_NewWave
	endfor
end

function SortMatrixCol(M_src, V_ColPnt, F_RevSort)
	wave M_src
	variable V_ColPnt, F_RevSort
	duplicate /FREE M_src, W_sortkey
	Redimension/N=(-1,0) W_sortkey
	W_sortkey[]=M_src[p][V_ColPnt]

	if(F_RevSort)//big -> small
		SortColumns /R keyWaves=W_sortkey,sortWaves=M_src
	else//small -> big
		SortColumns keyWaves=W_sortkey,sortWaves=M_src
	endif
	
end

function ScaleBarGen(M_Src, V_length, F_pos, F_text)
	wave M_Src
	variable V_length, F_pos, F_text
	//F_pos
	//0: right-lower
	//1: left-lower
	//V_length: in meters
	variable V_offsetCoef=0.1
	variable V_nx=dimsize(M_Src, 0)
	variable V_ny=dimsize(M_Src, 1)
	variable V_dx=DimDelta(M_Src, 0)
	variable V_dy=DimDelta(M_Src, 1)
//	SetDrawEnv xcoord= top,ycoord= left,textrgb= (65535,65535,65535);DelayUpdate
	SetDrawEnv  xcoord= top, ycoord= left,linefgc= (65535,65535,65535),linethick= 5.00
	variable V_widthx=V_nx*V_dx
	variable V_widthy=V_ny*V_dy	
	variable V_offsetx=V_widthx*V_offsetCoef
	variable V_offsety=V_widthy*V_offsetCoef
	variable V_x1, V_x2, V_y1, V_y2
	switch(F_pos)
		case 0:
			V_x2=V_widthx-V_offsetx
			V_x1=V_widthx-V_offsetx-V_length
			V_y1=V_widthy-V_offsety
			V_y2=V_widthy-V_offsety
			break
		case 1:
			V_x2=V_offsetx+V_length
			V_x1=V_offsetx
			V_y1=V_widthy-V_offsety
			V_y2=V_widthy-V_offsety
			break
		default:	
			
	endswitch
	
	DrawLine V_x1, V_y1, V_x2, V_y2
	
	variable V_x3, V_y3
	V_x3=(V_x1+V_x2)/2
	V_y3=(V_y1+V_y2)/2
	SetDrawEnv xcoord= top,ycoord= left,textxjust=1, textrgb= (65535,65535,65535)
	SetDrawEnv fname= "メイリオ",fsize= 15;
	DrawText V_x3,V_y3,num2str(V_length)+waveunits(M_Src, 0)	

end


function MIP2wave(W_src, S_unitx, S_unity)
	wave W_src
	string S_unitx, S_unity
	DeletePoints/M=1 0,2, W_src
	SetScale/P x W_src[0][1],W_src[1][1]-W_src[0][1],S_unitx, W_src
	SetScale d 0,0,S_unity, W_src
	DeletePoints/M=1 1,1, W_src
	Redimension/N=-1 W_src
end

function /Wave findpeaksPosNeg(W_src, SWN_peakList, V_box, V_StatX, V_EndX, F_integerP, F_Pos, F_Neg)
	wave W_src
	string SWN_peakList
	variable V_box, , V_StatX, V_EndX, F_integerP, F_Pos, F_Neg
	duplicate /Free W_src, W_srcAbs
	make /O/n=(1, 5)$SWN_peakList
	wave W_peakList=$SWN_peakList
	SetDimLabel 1, 0, PeakPosP, W_peakList
	SetDimLabel 1, 1, PeakPosX, W_peakList
	SetDimLabel 1, 2, peakVal, W_peakList
	SetDimLabel 1, 3, PeakWidth, W_peakList
	SetDimLabel 1, 4, TrailingEdgeLoc, W_peakList
	//R: peakNo, L: 0:PeakPosP. 1: PeakPosX, 2: peakVal, 3:PeakWidth, 4: TrailingEdgeLoc
	
	//variable V_n=numpnts(W_src)
	variable i=0
	variable V_flag
	variable V_StatP
	variable V_EndP=ScaleToIndex(W_src, V_EndX, 0)
	if(F_Pos)
		for(V_StatP=ScaleToIndex(W_src, V_StatX, 0);V_flag==0;)
			FindPeak /R=[V_StatP, V_EndP]/Q/P/B=(V_box) W_srcAbs
			//print V_StatP, V_EndP
			if(V_flag==0)
				W_peakList[i][0]=V_PeakLoc
				if(F_integerP)
					W_peakList[i][1]=IndexToScale(W_src, V_PeakLoc, 0)
				else
					W_peakList[i][1]=DimOffset(W_src,0) + V_PeakLoc*DimDelta(W_src,0)//IndexToScale(W_src, V_PeakLoc, 0)
				endif
				W_peakList[i][2]=W_src[V_PeakLoc]
				W_peakList[i][3]=V_PeakWidth
				W_peakList[i][4]=V_TrailingEdgeLoc	
				InsertPoints/M=0 i+1,1, W_peakList	
				i+=1;V_StatP=V_PeakLoc+1
			endif
		endfor
	endif
	if(F_Neg)
		for(V_StatP=ScaleToIndex(W_src, V_StatX, 0),V_flag=0;V_flag==0;)
			FindPeak /R=[V_StatP, V_EndP]/Q/P/B=(V_box)/N W_srcAbs
		//	print V_StartP
			if(V_flag==0)
				W_peakList[i][0]=V_PeakLoc
				if(F_integerP)
					W_peakList[i][1]=IndexToScale(W_src, V_PeakLoc, 0)
				else
					W_peakList[i][1]=DimOffset(W_src,0) + V_PeakLoc*DimDelta(W_src,0)//IndexToScale(W_src, V_PeakLoc, 0)
				endif
				W_peakList[i][2]=W_src[V_PeakLoc]
				W_peakList[i][3]=V_PeakWidth
				W_peakList[i][4]=V_TrailingEdgeLoc	
				InsertPoints/M=0 i+1,1, W_peakList	
				i+=1;V_StatP=V_PeakLoc+1
	
			endif
		endfor
	endif
	DeletePoints i,1, W_peakList
	SortMatrixCol2(W_peakList, 0, 0, 2, 0.1)
	//SortMatrixCol(W_peakList, 0, 0, -1, 0.1)
	//print i
	return W_peakList
end

function SortMatrixCol2(M_src, F_sortkey, F_RevSort, F_ZapSimilar, V_percent)
	wave M_src
	variable F_sortkey, F_RevSort, F_ZapSimilar, V_percent
	duplicate /free/O M_src, W_sortkey
	Redimension/N=(-1,0) W_sortkey
	W_sortkey[]=M_src[p][F_sortkey]//W_PeakInfo[p][1]*W_PeakInfo[p][2]
	
	if(F_RevSort)//big -> small
		SortColumns /R keyWaves=W_sortkey,sortWaves=M_src
	else//small -> big
		SortColumns keyWaves=W_sortkey,sortWaves=M_src
	endif
	//end
	if(F_ZapSimilar!=-1)//Colum No for marge
	variable V_nR=DimSize(M_src, 0)
	variable V_nC=DimSize(M_src, 1)
	//print V_nR, V_nC
	variable i, j
	wavestats/Q/RMD=[][2] M_src
	variable V_VariationRange=V_max-V_min
	variable V_Sval, V_Eval
	for(i=1,V_Sval=0,V_Eval=1;i<=V_nR;i+=1)
		//print i, V_sval, V_Eval, V_VariationRange*V_percent*0.01,abs(M_src[V_Sval][F_ZapSimilar]-M_src[i][F_ZapSimilar])
		if(V_VariationRange*V_percent*0.01<abs(M_src[V_Sval][F_ZapSimilar]-M_src[i][F_ZapSimilar])||i==V_nR)
			if(i-V_Sval!=1)
			 	//print "2"
			 	//print V_Sval,V_Eval
				for(j=0;j<V_nC;j+=1)
					wavestats /Q/RMD=[V_Sval,V_Eval][j] M_src
					//print M_src[V_Eval][j], M_src[V_Sval][j] ,V_avg
					M_src[V_Sval][j]=V_avg
					//print V_Sval,j
				endfor
				DeletePoints V_Sval+1, V_Eval-V_Sval, M_src
				i-=V_Eval-V_Sval
				V_nR-=V_Eval-V_Sval
				V_Sval=i+1//;print i
			else
				//print 1
				V_Sval=i
				V_Eval=i+1
			endif		
		else
			//print 3
			V_Eval=i
		endif
	endfor
	endif
end

Function/S NumToHex4(num)
    Variable num            // 16bit valeur
 
    String text
    sprintf text, "%4x", num
    return text
End
 
Function HighBitDec4(num)
    variable num
    variable a
    String text = NumToHex4(num) 
    String high = text[0,1]
    sscanf high, "%x",a
    return a
End

Function LowBitDec4(num)
    variable num
    variable a
    String text = NumToHex4(num) 
    String low = text[2,3]
    sscanf low, "%x",a
    return a
End

function /S TWave2List_2Dcolumn(W_src, V_colNo, F_rev)
	wave /T W_src
	variable V_colNo
	variable F_rev
	variable V_n=dimsize(W_src, 0)
	string L_dest=""
	variable i
	if(F_rev)
		for(i=0;i<V_n;i+=1)
			print i
			L_dest=AddListItem(W_src[i][V_colNo], L_dest)
		endfor	
	else
		for(i=V_n-1;i>=0;i-=1)
			L_dest=AddListItem(W_src[i][V_colNo], L_dest)
		endfor
	endif
	return L_dest
end

function /S Wave2List_2Dcolumn(W_src, V_colNo, F_rev)
	wave W_src
	variable V_colNo
	variable F_rev
	variable V_n=dimsize(W_src, 0)
	string L_dest=""
	variable i
	if(F_rev)
		for(i=0;i<V_n;i+=1)
			print i
			L_dest=AddListItem(num2str(W_src[i][V_colNo]), L_dest)
		endfor	
	else
		for(i=V_n-1;i>=0;i-=1)
			L_dest=AddListItem(num2str(W_src[i][V_colNo]), L_dest)
		endfor
	endif
	return L_dest
end
