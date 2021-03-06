//20171016
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
	L_date=ReplaceString("�N", L_date, ";")
	L_date=ReplaceString("��", L_date, ";")
	L_date=RemoveEnding(L_date, "��")
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

function /D fBaumkuchenInt(S_funcLoc, V_rStat, V_rEnd)
	string S_funcLoc
	variable V_rStat, V_rEnd
	svar S_func
	S_func=S_funcLoc
	return 2*pi*integrate1D(fIntegrand_BaumkuchenInt, V_rStat, V_rEnd, 1, -1)
end

function ferrBaumkuchenInt(val)
	variable val
	print "Error: Baumkuchen Integration"
	return nan
end

function /D fIntegrand_BaumkuchenInt(inX)
	variable inX
	Svar S_func
	funcref ferrBaumkuchenInt Fnc_func=$S_func
	return  Fnc_func(inX)*inX
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