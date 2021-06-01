Window AVASE_Generator() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(165,97,665,296) as "AVASE_Generator"
	ShowTools/A
	SetDrawLayer UserBack
	PopupMenu AVASE_DataFormat,pos={9,33},size={274,20},proc=PM_DataFormat,title="DataFormat"
	PopupMenu AVASE_DataFormat,mode=3,popvalue="3: θ, r, Z, Vθ,Vr (Scalar&Vector)",value= #"\"1: θ, r, Z (Scalar);2: θ, r, Vθ,Vr (Vector);3: θ, r, Z, Vθ,Vr (Scalar&Vector)\""
	PopupMenu AVASE_Pop_Cordinate,pos={9,9},size={163,20},proc=PM_AVASE_Coordinate,title="Cordinate"
	PopupMenu AVASE_Pop_Cordinate,mode=2,popvalue="2: Cylindorical",value= #"\"1: Orthogonal;2: Cylindorical\""
	PopupMenu AVASE_Pop_Wave1,pos={9,56},size={119,20},disable=2,proc=PM_AVASE_WaveSelect,title="Column1"
	PopupMenu AVASE_Pop_Wave1,mode=3,popvalue="WY_int",value= #"WaveList(\"*\",\";\",\"DIMS:1\")+\";_none_\""
	PopupMenu AVASE_Pop_Wave2,pos={10,81},size={119,20},disable=2,proc=PM_AVASE_WaveSelect,title="Column2"
	PopupMenu AVASE_Pop_Wave2,mode=3,popvalue="WY_int",value= #"WaveList(\"*\",\";\",\"DIMS:1\")+\";_none_\""
	PopupMenu AVASE_Pop_Wave3,pos={10,107},size={119,20},disable=2,proc=PM_AVASE_WaveSelect,title="Column3"
	PopupMenu AVASE_Pop_Wave3,mode=3,popvalue="WY_int",value= #"WaveList(\"*\",\";\",\"DIMS:1\")+\";_none_\""
	PopupMenu AVASE_Pop_Wave4,pos={9,134},size={119,20},disable=2,proc=PM_AVASE_WaveSelect,title="Column4"
	PopupMenu AVASE_Pop_Wave4,mode=3,popvalue="WY_int",value= #"WaveList(\"*\",\";\",\"DIMS:1\")+\";_none_\""
	PopupMenu AVASE_Pop_Wave5,pos={9,159},size={119,20},disable=2,proc=PM_AVASE_WaveSelect,title="Column5"
	PopupMenu AVASE_Pop_Wave5,mode=3,popvalue="WY_int",value= #"WaveList(\"*\",\";\",\"DIMS:1\")+\";_none_\""
	PopupMenu AVASE_DataFormat,pos={9,33},size={179,20},proc=PM_DataFormat,title="DataFormat"
	PopupMenu AVASE_DataFormat,mode=3,popvalue="3: θ, r, Z, Vθ,Vr (Scalar&Vector)",value= #"\"1: θ, r, Z (Scalar);2: θ, r, Vθ,Vr (Vector);3: θ, r, Z, Vθ,Vr (Scalar&Vector)\""
	CheckBox Header,pos={402,29},size={54,14},disable=2,title="Header",value= 0
	SetVariable OutputWavename,pos={294,6},size={184,16},title="OutputWave"
	SetVariable OutputWavename,value= Cfg_AVASWgenerator[9]
	Button Export,pos={426,162},size={50,20},proc=B_AVASE_GenerateWave,title="Esport"
	Button Export,labelBack=(65535,65535,65535),fColor=(65280,48896,48896)
	PopupMenu AVASE_2Dwave3,pos={252,115},size={233,20},proc=PM_AVASE_2DWaveSelect,title="2Dwave3"
	PopupMenu AVASE_2Dwave3,mode=172,popvalue="M_dir_dAzm0_dPol10_X_aSLM",value= #"WaveList(\"*\",\";\",\"DIMS:2\")+\";_none_\""
	PopupMenu AVASE_2Dwave4,pos={251,91},size={233,20},proc=PM_AVASE_2DWaveSelect,title="2Dwave4"
	PopupMenu AVASE_2Dwave4,mode=203,popvalue="M_dir_dAzm0_dPol50_Y_aSLM",value= #"WaveList(\"*\",\";\",\"DIMS:2\")+\";_none_\""
	PopupMenu AVASE_2Dwave5,pos={251,65},size={236,20},proc=PM_AVASE_2DWaveSelect,title="2Dwave3"
	PopupMenu AVASE_2Dwave5,mode=238,popvalue="M_dir_dAzm0_dPol90_X_lgSLM",value= #"WaveList(\"*\",\";\",\"DIMS:2\")+\";_none_\""
	CheckBox AVASE_2Dwave,pos={156,79},size={58,14},proc=CB_AVASE_2DWave,title="2Dwave"
	CheckBox AVASE_2Dwave,value= 1
	ValDisplay Npoints,pos={293,28},size={93,14},title="N points"
	ValDisplay Npoints,limits={0,0,0},barmisc={0,1000}
	ValDisplay Npoints,value= #"str2num(Cfg_AVASWgenerator[10])"
	CheckBox SwapXY,pos={156,59},size={59,14},disable=2,proc=C_SwapXY,title="SwapXY"
	CheckBox SwapXY,value= 0
EndMacro

Function /S AVASEGenerator_GetConfig(V_No)
	variable V_No
	wave /T W_config=$"Cfg_AVASWgenerator"
	return W_config[V_No]
end

Function /S AVASEGenerator_OverWriteConfig(V_No, S_Val)
	variable V_No
	string S_Val
	wave /T W_config=$"Cfg_AVASWgenerator"
	W_config[V_No]=S_Val
end

Function PM_AVASE_Coordinate(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	variable I_config=0
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			break
	endswitch
	AVASEGenerator_OverWriteConfig(I_config, num2str(popNum))
	switch( popNum )
		case 1: // Orthogonal
			PopupMenu AVASE_DataFormat win=AVASE_Generator, value="1: X, Y, Z (Scalar);2: X, Y, U, V (Vector);3: X, Y, Z, U, V (Scalar&Vector)"
			break
		case 2: // Cylindrical
			PopupMenu AVASE_DataFormat win=AVASE_Generator, value="1: θ, r, Z (Scalar);2: θ, r, Vθ,Vr (Vector);3: θ, r, Z, Vθ,Vr (Scalar&Vector)"
			break
	endswitch
	AVASE_consistentCheck(AVASEGenerator_GetConfig(8))
	AVASE_makewave()
	return 0
End


Function PM_AVASE_WaveSelect(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	variable I_config
	string S_InputPM_BaseName="AVASE_Pop_Wave"
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			break
	endswitch
	string ctrlName=pa.ctrlName
	variable V_wavenumber=str2num(ReplaceString(S_InputPM_BaseName, ctrlName, ""))
	I_config=V_wavenumber+1
	AVASEGenerator_OverWriteConfig(I_config, popStr)
	AVASE_DataFormat_WaveListGen("PM_AVASE_WaveSelect")
	variable V_pnts=AVASE_consistentCheck(AVASEGenerator_GetConfig(8))
	AVASEGenerator_OverWriteConfig(10, num2str(V_pnts))
	AVASE_makewave()
	return 0
End

function AVASE_makewave()
	string S_distWN=AVASEGenerator_GetConfig(9)
	make /O /D /N=(str2num(AVASEGenerator_GetConfig(10)), str2num(AVASEGenerator_GetConfig(11))) $S_distWN
	wave W_dist=$S_distWN
	W_dist=0
	string L_wlist=AVASEGenerator_GetConfig(8)
	variable V_n=ItemsInList(L_wlist)
	variable i
	for(i=0; i<V_n; i+=1)
		wave W_src=$StringFromList(i, L_wlist)
		//print nameofwave(W_src)
		W_dist[][i]=W_src[p]
	endfor
end

function AVASE_consistentCheck(L_wlist)
	string L_wlist
	variable I_config=1
	variable V_n=ItemsInList(L_wlist)
	variable i, V_p
	string S_wn
	for(i=0; i<V_n; I+=1)
		S_wn=StringFromList(i, L_wlist)
		//print i, S_wn,numpnts($S_wn)
		wavestats /Q $S_wn
		//print V_npnts
		if(V_numNans||V_numINFs)
			print "Column",i+1, "error: INF of NAN (AVASE_consistentCheck)"
			return -1
		endif
		if(i>=1 && V_p!=V_npnts)
			print "Column",i+1, "error: different V_npnts (AVASE_consistentCheck)"
			return -1
		else
			V_p=V_npnts
		endif
		if(i==0&&(V_max>=2*pi||V_min<0)&&str2num(AVASEGenerator_GetConfig(0))==2)
			print "Column",i+1, "Warning: Azumuth angle in cylindrical coordinate is 0-2*pi (AVASE_consistentCheck)"
		endif
	endfor
	//AVASEGenerator_OverWriteConfig(I_config, num2str(popNum))
	return V_npnts
end

function AVASE_consistentCheck2D(L_wlist)
	string L_wlist
	variable I_config=1
	variable V_n=ItemsInList(L_wlist)
	variable i, V_p, V_px, V_py
	string S_wn
	for(i=0; i<V_n; I+=1)
		S_wn=StringFromList(i, L_wlist)
		//print i, S_wn,numpnts($S_wn)
		wavestats /Q $S_wn
		//print V_npnts
		if(V_numNans||V_numINFs)
			print "Column",i+1, "error: INF of NAN (AVASE_consistentCheck)"
			return -1
		endif
		
		if(i>=1 && (V_p!=V_npnts || V_px!=dimsize($S_wn, 0) || V_py!=dimsize($S_wn, 1)))
			print "Column",i+1, "error: different V_npnts (AVASE_consistentCheck)"
			return -1
		else
			V_p=V_npnts
			V_px=dimsize($S_wn, 0)
			V_py=dimsize($S_wn, 1)
		endif
		if(i==0&&(V_max>=2*pi||V_min<0)&&str2num(AVASEGenerator_GetConfig(0))==2)
			print "Column",i+1, "Warning: Azumuth angle in cylindrical coordinate is 0-2*pi (AVASE_consistentCheck)"
		endif
	endfor
	//AVASEGenerator_OverWriteConfig(I_config, num2str(popNum))
	AVASEGenerator_OverWriteConfig(18, num2str(V_px))
	AVASEGenerator_OverWriteConfig(19, num2str(V_py))
	return V_npnts
end

Function PM_DataFormat(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	variable I_config=1
	string S_wavelist
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			break
	endswitch
	AVASEGenerator_OverWriteConfig(I_config, num2str(popNum))
	AVASEGenerator_OverWriteConfig(11, num2str(popNum+2))
	AVASE_DataFormat_WaveListGen("PM_DataFormat")
	AVASE_consistentCheck(AVASEGenerator_GetConfig(8))
	AVASE_makewave()
	return 0
End

function AVASE_DataFormat_WaveListGen(ctrlName)
	string ctrlName
	variable I_config=1
	variable F_Dataformat=str2num(AVASEGenerator_GetConfig(I_config))
	string S_InputPM_BaseName="AVASE_Pop_Wave"
	string S_WvPopuplist, S_waveList, S_2DwaveList
	
	I_config=7
	switch(F_Dataformat)
		case 1:
			PopupMenu AVASE_Pop_Wave1 win=AVASE_Generator, disable=0
			PopupMenu AVASE_Pop_Wave2 win=AVASE_Generator, disable=0
			PopupMenu AVASE_Pop_Wave3 win=AVASE_Generator, disable=0
			PopupMenu AVASE_Pop_Wave4 win=AVASE_Generator, disable=1
			PopupMenu AVASE_Pop_Wave5 win=AVASE_Generator, disable=1
			PopupMenu AVASE_2Dwave3 win=AVASE_Generator, disable=0
			PopupMenu AVASE_2Dwave4 win=AVASE_Generator, disable=1
			PopupMenu AVASE_2Dwave5 win=AVASE_Generator, disable=1
			S_WvPopuplist=S_InputPM_BaseName+"1;"+S_InputPM_BaseName+"2;"+S_InputPM_BaseName+"3"
			S_waveList=AVASEGenerator_GetConfig(2)+";"+AVASEGenerator_GetConfig(3)+";"+AVASEGenerator_GetConfig(4)
			S_2DwaveList=AVASEGenerator_GetConfig(13)
			break
		case 2:
			PopupMenu AVASE_Pop_Wave1 win=AVASE_Generator, disable=0
			PopupMenu AVASE_Pop_Wave2 win=AVASE_Generator, disable=0
			PopupMenu AVASE_Pop_Wave3 win=AVASE_Generator, disable=1
			PopupMenu AVASE_Pop_Wave4 win=AVASE_Generator, disable=0
			PopupMenu AVASE_Pop_Wave5 win=AVASE_Generator, disable=0
			PopupMenu AVASE_2Dwave3 win=AVASE_Generator, disable=1
			PopupMenu AVASE_2Dwave4 win=AVASE_Generator, disable=0
			PopupMenu AVASE_2Dwave5 win=AVASE_Generator, disable=0
			S_WvPopuplist=S_InputPM_BaseName+"1;"+S_InputPM_BaseName+"2;"+S_InputPM_BaseName+"4;"+S_InputPM_BaseName+"5"
			S_waveList=AVASEGenerator_GetConfig(2)+";"+AVASEGenerator_GetConfig(3)+";"+AVASEGenerator_GetConfig(5)+";"+AVASEGenerator_GetConfig(6)
			S_2DwaveList=AVASEGenerator_GetConfig(14)+";"+AVASEGenerator_GetConfig(15)
			break
		case 3:
			PopupMenu AVASE_Pop_Wave1 win=AVASE_Generator, disable=0
			PopupMenu AVASE_Pop_Wave2 win=AVASE_Generator, disable=0
			PopupMenu AVASE_Pop_Wave3 win=AVASE_Generator, disable=0
			PopupMenu AVASE_Pop_Wave4 win=AVASE_Generator, disable=0
			PopupMenu AVASE_Pop_Wave5 win=AVASE_Generator, disable=0
			PopupMenu AVASE_2Dwave3 win=AVASE_Generator, disable=0
			PopupMenu AVASE_2Dwave4 win=AVASE_Generator, disable=0
			PopupMenu AVASE_2Dwave5 win=AVASE_Generator, disable=0
			S_WvPopuplist=S_InputPM_BaseName+"1;"+S_InputPM_BaseName+"2;"+S_InputPM_BaseName+"3;"+S_InputPM_BaseName+"4;"+S_InputPM_BaseName+"5"
			S_waveList=AVASEGenerator_GetConfig(2)+";"+AVASEGenerator_GetConfig(3)+";"+AVASEGenerator_GetConfig(4)+";"+AVASEGenerator_GetConfig(5)+";"+AVASEGenerator_GetConfig(6)
			S_2DwaveList=AVASEGenerator_GetConfig(13)+";"+AVASEGenerator_GetConfig(14)+";"+AVASEGenerator_GetConfig(15)
			break
		default:
			print "error n PM_DataFormat"+ctrlName
	endswitch
	if(str2num(AVASEGenerator_GetConfig(12)))//2D or not
		PopupMenu AVASE_Pop_Wave1 win=AVASE_Generator, disable=2
		PopupMenu AVASE_Pop_Wave2 win=AVASE_Generator, disable=2
		PopupMenu AVASE_Pop_Wave3 win=AVASE_Generator, disable=2
		PopupMenu AVASE_Pop_Wave4 win=AVASE_Generator, disable=2
		PopupMenu AVASE_Pop_Wave5 win=AVASE_Generator, disable=2
	else
		PopupMenu AVASE_2Dwave3 win=AVASE_Generator, disable=1
		PopupMenu AVASE_2Dwave4 win=AVASE_Generator, disable=1
		PopupMenu AVASE_2Dwave5 win=AVASE_Generator, disable=1
	endif
	
	AVASEGenerator_OverWriteConfig(I_config, S_WvPopuplist)
	AVASEGenerator_OverWriteConfig(I_config+1, S_waveList)
	AVASEGenerator_OverWriteConfig(16, S_2DwaveList)
end

Function B_AVASE_GenerateWave(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch( ba.eventCode )
		case 2: // mouse up
			AVASE_makewave()
			break
	endswitch

	return 0
End


Function B_AVASE_GenerateFile(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			break
	endswitch

	return 0
End

Function CB_AVASE_2DWave(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			AVASEGenerator_OverWriteConfig(12, num2str(checked))
			AVASE_DataFormat_WaveListGen("CB_AVASE_2DWave")
			break
	endswitch
	variable i
	if(checked)
		for(i=0;i<5;i+=1)
			//PopupMenu AVASE_Pop_Wave1 win=AVASE_Generator,  mode=4
		endfor
	endif
	
	
	return 0
End

Function PM_AVASE_2DWaveSelect(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	variable I_config
	string S_InputPM_BaseName="AVASE_2Dwave"
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			break
	endswitch
	string ctrlName=pa.ctrlName
	variable V_wavenumber=str2num(ReplaceString(S_InputPM_BaseName, ctrlName, ""))
	I_config=V_wavenumber+10
	AVASEGenerator_OverWriteConfig(I_config, popStr)
	AVASE_DataFormat_WaveListGen("PM_AVASE_2DWaveSelect")
	variable V_pnts=AVASE_consistentCheck2D(AVASEGenerator_GetConfig(16))
	//variable V_=dimsize(AVASEGenerator_GetConfig(16), 0)
	//AVASEGenerator_OverWriteConfig(17, popStr)
	AVASEGenerator_OverWriteConfig(10, num2str(V_pnts))
	make /O /D /N=(V_pnts) W_tmp1,W_tmp2,W_tmp3,W_tmp4,W_tmp5
	wave W_tmp2D=$AVASEGenerator_GetConfig(13)
	W_tmp1=pnt2x(W_tmp2D, p)
	variable F_swapXY=str2num(AVASEGenerator_GetConfig(17))
	variable V_Xpnts=str2num(AVASEGenerator_GetConfig(18))
	variable V_Ypnts=str2num(AVASEGenerator_GetConfig(19))
	//F_swapXY
	W_tmp1=0
	W_tmp2=0
	//W_tmp1=sawtooth(p/V_Xpnts*2*pi)*V_Xpnts
	//W_tmp2=sawtooth(p/V_Ypnts*2*pi)*V_Ypnts
	W_tmp1=DimOffset(W_tmp2D, 0) + (sawtooth(p/V_Xpnts*2*pi)*V_Xpnts *DimDelta(W_tmp2D,0))
	W_tmp2=DimOffset(W_tmp2D, 1) + (sawtooth(p/V_Ypnts*2*pi)*V_Ypnts *DimDelta(W_tmp2D,1))
	//W_tmp1=DimOffset(W_tmp2D, 0) + (sawtooth(p/V_Xpnts*2*pi)*V_Xpnts *DimDelta(W_tmp2D,0))
	//W_tmp2=DimOffset(W_tmp2D, 1) + (sawtooth(p/V_Ypnts*2*pi)*V_Ypnts *DimDelta(W_tmp2D,1))
	W_tmp1/=360/pi/2
	
	wave Wtmp2D_3=$AVASEGenerator_GetConfig(13)
	wave Wtmp2D_4=$AVASEGenerator_GetConfig(14)
	wave Wtmp2D_5=$AVASEGenerator_GetConfig(15)
	W_tmp3=Wtmp2D_3[sawtooth(p/V_Xpnts*2*pi)*V_Xpnts][sawtooth(p/V_Ypnts*2*pi)*V_Ypnts]
	W_tmp4= Wtmp2D_4[sawtooth(p/V_Xpnts*2*pi)*V_Xpnts][sawtooth(p/V_Ypnts*2*pi)*V_Ypnts]
	W_tmp5=Wtmp2D_5[sawtooth(p/V_Xpnts*2*pi)*V_Xpnts][sawtooth(p/V_Ypnts*2*pi)*V_Ypnts]
	AVASEGenerator_OverWriteConfig(2, "W_tmp1")
	AVASEGenerator_OverWriteConfig(3, "W_tmp2")
	AVASEGenerator_OverWriteConfig(4, "W_tmp3")
	AVASEGenerator_OverWriteConfig(5, "W_tmp4")
	AVASEGenerator_OverWriteConfig(6, "W_tmp5")
	AVASE_DataFormat_WaveListGen("PM_AVASE_2DWaveSelect")
	AVASE_makewave()
	return 0
End

Function C_SwapXY(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			AVASEGenerator_OverWriteConfig(17, num2str(checked))
			break
	endswitch
	return 0
End


X Data　　Y Data　　Z Data　　U Data　　V Data
θ Data　　r Data　　Z Data　　Vθ Data　　Vr Data
　「データロード」
　　　ファイルからデータを読み込み、格子点間を補完して分布図を描きます。もしく
　　　は、ベクトル線図、等高線を描くことも出来ます。また、これらすべてを同時に
　　　表示することも可能です。いずれを表示するかは、メニューの「設定」で変更で
　　　きます。

　　　データファイルのフォーマットは、以下のようになります。ここで、XとYは座標
　　　を、Zはスカラー量を、UとVはベクトル（XとY方向の成分）を表しています。ベ
　　　クトル線を描かない場合は、U、Vの値は必要ありません（sample1を参照）。ベ
　　　クトルのみ表示する場合は、スカラー量は必要ありません。

　　　X Data　　Y Data　　Z Data　　U Data　　V Data
　　　X Data　　Y Data　　Z Data　　U Data　　V Data
　　　　：
　　　　：
　　　X Data　　Y Data　　Z Data　　U Data　　V Data

　　　円筒座標データを読み込む場合は、以下のようになります。ここで、θとrは座標
　　　を、Zはスカラー量を、VθとVrはベクトル（θとr方向の成分）を表しています。
　　　ベクトル線を描かない場合は、U、Vの値は必要ありません。ベクトルのみ表示す
　　　る場合は、スカラー量は必要ありません。

　　　θ Data　　r Data　　Z Data　　Vθ Data　　Vr Data
　　　θ Data　　r Data　　Z Data　　Vθ Data　　Vr Data
　　　　：
　　　　：
　　　θ Data　　r Data　　Z Data　　Vθ Data　　Vr Data

　　　θの範囲は、最大値と最小値が幾つであっても、０～２πとして扱われます。
　　　このため、半円などの系は、工夫してデータを与える必要があります。

　　　ｒの範囲は、最小値が幾つであっても、その値を中心のｒとして扱います。
　　　「r Data」の最小値を０にしておかないと、ステータスバーの示す「ｒ」の値が
　　　意味の無い値になってしまいます。（sample2）

　　　このメニューの動作は、「sample1.txt」「sample2.txt」「sample3.txt」を使
　　　って確認することが出来ます。


　「データロード（パネル状）」
　　　表示設定でパネル状を選んだ場合の動作です。
　　　長方形領域に等間隔に配置されたデータを、パネル状の分布図で描くことが出来
　　　ます。ベクトル線、等高線は表示されません。

　　　データファイルのフォーマットは、以下のようになります。

　　　Z Data　　Z Data　　・・・　　Z Data　　Z Data
　　　Z Data　　Z Data　　・・・　　Z Data　　Z Data
　　　　：
　　　　：
　　　Z Data　　Z Data　　・・・　　Z Data　　Z Data

　　　円筒座標データを読み込む場合は、横に並んだデータがθ方向になります。

　　　θの範囲は、最大値と最小値が幾つであっても、０～２πとして扱われます。
　　　このため、半円などの系は、工夫してデータを与える必要があります。

　　　ｒの範囲は、最小値が幾つであっても、その値を中心のｒとして扱います。
　　　「r Data」の最小値を０にしておかないと、ステータスバーの示す「ｒ」の値が
　　　意味の無い値になってしまいます。（sample2）

　　　このメニューの動作は、「sample1.txt」を使って確認すること
　　　が出来ます。