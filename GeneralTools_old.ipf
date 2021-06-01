//20090210
function /S genSdate(ctrlName)
	string ctrlName
	string L_date=date()
	string /G S_year, S_month, S_date
	variable V_place=0
	L_date=ReplaceString("”N", L_date, ";")
	L_date=ReplaceString("ŒŽ", L_date, ";")
	L_date=RemoveEnding(L_date, "“ú")
	//print L_date
	S_year=StringFromList(0, L_date)
	S_month=StringFromList(1, L_date)
	S_date=StringFromList(2, L_date)
	//print S_year, S_month, S_date
	return L_date
end

function /S Convert2Polar(wv)
	wave /C wv
	duplicate /O wv, $NameOfW,
    /* [out] */ REGISTERWORDA __RPC_FAR *rgRegisterWord,
    /* [out] */ ULONG __RPC_FAR *pcFetched);


void __RPC_STUB IEnumRegisterWordA_Next_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


HRESULT STDMETHODCALLTYPE IEnumRegisterWordA_Reset_Proxy( 
    IEnumRegisterWordA __RPC_FAR * This);


void __RPC_STUB IEnumRegisterWordA_Reset_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBu S_BaseFilename, "")
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
		V_maxAVG=max(V_maxAVG, mean(wv))
		V_minAVG=min(V_minAVG, mean(wv))
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
	return num2str(V_Wmax)+";"+num2str(V_Wmin)+";"+num2str(V_Wsum)+";"+num2str(V_Wavg)
end


function NanEracer(WV)
	wave wv
	variable i, n=dimsize(wv, 0)
	for(i=0; i<n; i+=1)
		if(wv[i])
		else
			wv[i]=(wv[i-1]+wv[i+1])/2
		endif
	endfor
end

function importBinary(S_SrcFilename)
	string S_SrcFilename
	string S_wname=stringfromlist(0, S_SrcFilename, ".")
	GBLoadWave/O/N=w_tmp /T={4,4}/W=1 "G:20100228:BF_001.dat"

end