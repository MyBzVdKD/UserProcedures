


function /D ClampDimPoint_MD(W_src, F_Dim, V_Point)
	wave W_src
	variable F_Dim, V_Point

	variable V_LastPoint=DimSize(W_src, F_Dim)-1
	if(V_LastPoint<=0)
		return 0
	endif
	if(numtype(V_Point)!=0)
		return 0
	endif
	V_Point=round(V_Point)
	if(V_Point<0)
		return 0
	endif
	if(V_Point>V_LastPoint)
		return V_LastPoint
	endif
	return V_Point
end

function /D ClampDimPosition_MD(W_src, F_Dim, V_Position)
	wave W_src
	variable F_Dim, V_Position

	variable V_FirstPos=DimOffset(W_src, F_Dim)
	variable V_LastPos=V_FirstPos+DimDelta(W_src, F_Dim)*(DimSize(W_src, F_Dim)-1)
	variable V_MinPos=min(V_FirstPos, V_LastPos)
	variable V_MaxPos=max(V_FirstPos, V_LastPos)
	if(numtype(V_Position)!=0)
		return V_FirstPos
	endif
	if(V_Position<V_MinPos)
		return V_MinPos
	endif
	if(V_Position>V_MaxPos)
		return V_MaxPos
	endif
	return V_Position
end

Function Get4DVolumeFixedDim(F_ExtractedVolume)
	variable F_ExtractedVolume

	switch(F_ExtractedVolume)
		case 1:		// X-Y-Z
			return 3
		case 2:		// X-Y-T
			return 2
		case 3:		// X-Z-T
			return 1
		case 4:		// Y-Z-T
			return 0
		default:
			return 2
	endswitch
End

Function SyncSliceUI(S_win, W_src, F_FixedDim)
	string S_win
	wave W_src
	variable F_FixedDim

	if(strlen(S_win)==0)
		S_win="CP_Slice_2Dimage"
	endif
	variable V_FirstPos=DimOffset(W_src, F_FixedDim)
	variable V_LastPos=V_FirstPos+DimDelta(W_src, F_FixedDim)*(DimSize(W_src, F_FixedDim)-1)
	variable V_PosMin=min(V_FirstPos, V_LastPos)
	variable V_PosMax=max(V_FirstPos, V_LastPos)
	variable V_PosStep=abs(DimDelta(W_src, F_FixedDim))
	string S_Unit=WaveUnits(W_src, F_FixedDim)
	if(V_PosStep==0)
		V_PosStep=1
	endif
	Slider SLD_Slice_pos win=$S_win, limits={V_PosMin,V_PosMax,V_PosStep}
	SetVariable SV_Slice_pos win=$S_win, limits={V_PosMin,V_PosMax,V_PosStep}
	if(strlen(S_Unit))
		SetVariable SV_Slice_pos win=$S_win, format="%g "+S_Unit
	else
		SetVariable SV_Slice_pos win=$S_win, format="%g"
	endif
	SetVariable SV_Slice_pnt win=$S_win, limits={0,DimSize(W_src, F_FixedDim)-1,1}
End

Function SyncVolumeUI(S_win, W_src, F_FixedDim)
	string S_win
	wave W_src
	variable F_FixedDim

	if(strlen(S_win)==0)
		S_win="CP_Slice_2Dimage"
	endif
	variable V_FirstPos=DimOffset(W_src, F_FixedDim)
	variable V_LastPos=V_FirstPos+DimDelta(W_src, F_FixedDim)*(DimSize(W_src, F_FixedDim)-1)
	variable V_PosMin=min(V_FirstPos, V_LastPos)
	variable V_PosMax=max(V_FirstPos, V_LastPos)
	variable V_PosStep=abs(DimDelta(W_src, F_FixedDim))
	string S_Unit=WaveUnits(W_src, F_FixedDim)
	if(V_PosStep==0)
		V_PosStep=1
	endif
	Slider SLD_Volume_pos win=$S_win, limits={V_PosMin,V_PosMax,V_PosStep}
	SetVariable SV_Volume_pos win=$S_win, limits={V_PosMin,V_PosMax,V_PosStep}
	if(strlen(S_Unit))
		SetVariable SV_Volume_pos win=$S_win, format="%g "+S_Unit
	else
		SetVariable SV_Volume_pos win=$S_win, format="%g"
	endif
	SetVariable SV_Volume_pnt win=$S_win, limits={0,DimSize(W_src, F_FixedDim)-1,1}
End

function /S Extract3Dfrom4D(ctrlName, W_src, F_FixedDim, V_FixedPoint)
	string ctrlName
	wave W_src
	variable F_FixedDim, V_FixedPoint
	//F_FixedDim=
	//	0:	Rows.
	//	1:	Columns.
	//	2:	Layers.
	//	3:	Chunks.
	variable i
	string L_Dim_npnts=""
	F_FixedDim=round(F_FixedDim)
	if((F_FixedDim<0) || (F_FixedDim>3))
		print "Error: Trns4Dto3D"
		return ""
	endif
	V_FixedPoint=ClampDimPoint_MD(W_src, F_FixedDim, V_FixedPoint)
	for(i=0; i<4; i+=1)
		if(i!=F_FixedDim)
			L_Dim_npnts+=num2str(dimsize(W_src, i))+";"
		endif
	endfor
	string S_wname=nameofwave(W_src)+"_3D"
	make /O /D /n=(str2num(StringFromList(0, L_Dim_npnts)), str2num(StringFromList(1, L_Dim_npnts)), str2num(StringFromList(2, L_Dim_npnts))) $S_wname
	wave W_dest=$S_wname
	switch(F_FixedDim)
		case 0:
			W_dest=W_src[V_FixedPoint][p][q][r]
			break
		case 1:
			W_dest=W_src[p][V_FixedPoint][q][r]
			break
		case 2:
			W_dest=W_src[p][q][V_FixedPoint][r]
			break
		case 3:
			W_dest=W_src[p][q][r][V_FixedPoint]
			break
		default:
			print "Error: Trns4Dto3D"
			return ""
	endswitch
	variable i_dim=0
	for(i=0; i<4; i+=1)
		if(i!=F_FixedDim)
			switch(i_dim)
				case 0:
					SetScale /P x, DimOffset(W_src, i), DimDelta(W_src, i), WaveUnits(W_src, i), W_dest
					break
				case 1:
					SetScale /P y, DimOffset(W_src, i), DimDelta(W_src, i), WaveUnits(W_src, i), W_dest
					break
				case 2:
					SetScale /P z, DimOffset(W_src, i), DimDelta(W_src, i), WaveUnits(W_src, i), W_dest
					break
			endswitch
			i_dim+=1
		endif
	endfor
	return S_wname
end

function /S Extract2Dfrom3D(ctrlName, W_src, F_FixedDim, V_FixedPoint)
	string ctrlName
	wave W_src
	variable F_FixedDim, V_FixedPoint
	//F_FixedDim
		//F_FixedDim =0 :	YZ plane (X axis is fixed).
		//F_FixedDim =1:	XZ plane (Y axis is fixed).
		//F_FixedDim =2:	XY plane (Z axis is fixed).
	F_FixedDim=round(F_FixedDim)
	if((F_FixedDim<0) || (F_FixedDim>2))
		return ""
	endif
	V_FixedPoint=ClampDimPoint_MD(W_src, F_FixedDim, V_FixedPoint)
	variable F_PTYP=str2num(StringFromList(F_FixedDim, "2;1;0"))
	ImageTransform /P=(V_FixedPoint) /PTYP=(F_PTYP) getPlane W_src
	wave M_ImagePlane
	return nameofwave(M_ImagePlane)
end

Function /S RefreshCurrent2DSlice(S_win)
	string S_win

	if(strlen(S_win)==0)
		S_win="CP_Slice_2Dimage"
	endif
	wave Cfg_Profiler
	wave /T Cfg_Profiler_Str
	wave /Z W_src=$Cfg_Profiler_Str[1]
	if(!WaveExists(W_src))
		return ""
	endif
	variable F_FixedDim=round(Cfg_Profiler[16])
	if((F_FixedDim<0) || (F_FixedDim>2))
		F_FixedDim=2
	endif
	Cfg_Profiler[16]=F_FixedDim
	Cfg_Profiler[18]=ClampDimPoint_MD(W_src, F_FixedDim, Cfg_Profiler[18])
	Cfg_Profiler[20]=pnt2x_MD(Cfg_Profiler_Str[1], F_FixedDim, Cfg_Profiler[18])
	Cfg_Profiler_Str[3]="2;1;0"
	SyncSliceUI(S_win, W_src, F_FixedDim)
	PopupMenu PM_SelectPlene win=$S_win, mode=(3-F_FixedDim)
	Slider SLD_Slice_pos win=$S_win, value=Cfg_Profiler[20]
	Extract2Dfrom3D("RefreshCurrent2DSlice", W_src, F_FixedDim, Cfg_Profiler[18])
	PopupMenu SelectWave win=$S_win, disable=2, mode=(WhichListItem("M_ImagePlane", WaveList("*",";","DIMS:2"))+1)
	PM_SelectWave("RefreshCurrent2DSlice", 0, "M_ImagePlane")
	return "M_ImagePlane"
End

Function /S RefreshCurrent3DVolume(S_win)
	string S_win

	if(strlen(S_win)==0)
		S_win="CP_Slice_2Dimage"
	endif
	wave Cfg_Profiler
	wave /T Cfg_Profiler_Str
	wave /Z W_src=$Cfg_Profiler_Str[0]
	if(!WaveExists(W_src))
		return ""
	endif
	if((Cfg_Profiler[17]<1) || (Cfg_Profiler[17]>4))
		Cfg_Profiler[17]=2
	endif
	variable F_FixedDim=Get4DVolumeFixedDim(Cfg_Profiler[17])
	Cfg_Profiler[19]=ClampDimPoint_MD(W_src, F_FixedDim, Cfg_Profiler[19])
	Cfg_Profiler[21]=pnt2x_MD(Cfg_Profiler_Str[0], F_FixedDim, Cfg_Profiler[19])
	PopupMenu PM_SelectVol win=$S_win, mode=Cfg_Profiler[17]
	Gen_PopMenue("RefreshCurrent3DVolume", S_win)
	SyncVolumeUI(S_win, W_src, F_FixedDim)
	Slider SLD_Volume_pos win=$S_win, value=Cfg_Profiler[21]
	string S_wname=Extract3Dfrom4D("RefreshCurrent3DVolume", W_src, F_FixedDim, Cfg_Profiler[19])
	if(strlen(S_wname)==0)
		return ""
	endif
	PopupMenu P_Wave3D win=$S_win, disable=2, mode=(WhichListItem(S_wname, WaveList("*",";","DIMS:3"))+1)
	Cfg_Profiler[14]=1
	Cfg_Profiler[15]=1
	Cfg_Profiler_Str[1]=S_wname
	Cfg_Profiler[13]=1
	RefreshCurrent2DSlice(S_win)
	return S_wname
End

Function PM_3DWaveSelect(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	string S_win=pa.win
	wave Cfg_Profiler
	wave /T Cfg_Profiler_Str
	Variable popNum
	String popStr
	if(strlen(S_win)==0)
		S_win="CP_Slice_2Dimage"
	endif
	switch( pa.eventCode )
		case 2: // mouse up
			popNum = pa.popNum
			popStr = pa.popStr
			break
		default:
			return 0
	endswitch
	if(stringmatch(popStr, "_none_"))//2Dmode
		PopupMenu SelectWave win=$S_win, disable=0
		Cfg_Profiler[13]=0
		Cfg_Profiler_Str[1]=popStr
	else//3Dmode
		Cfg_Profiler[13]=1
		Cfg_Profiler_Str[1]=popStr
		RefreshCurrent2DSlice(S_win)
	endif
	return 0
End

Function PM_4DWaveSelect(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	string S_win=pa.win
	wave Cfg_Profiler
	wave /T Cfg_Profiler_Str
	Variable popNum
	String popStr
	if(strlen(S_win)==0)
		S_win="CP_Slice_2Dimage"
	endif
	switch( pa.eventCode )
		case 2: // mouse up
			popNum = pa.popNum
			popStr = pa.popStr
			break
		default:
			return 0
	endswitch
	if(stringmatch(popStr, "_none_"))//3Dmode
		PopupMenu P_Wave3D win=$S_win, disable=0
		Cfg_Profiler[14]=0
		Cfg_Profiler[15]=0
		Cfg_Profiler_Str[0]=popStr
	else//4Dmode
		Cfg_Profiler_Str[0]=popStr
		RefreshCurrent3DVolume(S_win)
	endif
	return 0
End

Function PM_ExtractPlane(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	string S_win=pa.win
	wave Cfg_Profiler
	Variable popNum
	String popStr
	if(strlen(S_win)==0)
		S_win="CP_Slice_2Dimage"
	endif
	switch( pa.eventCode )
		case 2: // mouse up
			popNum = pa.popNum
			popStr = pa.popStr
			Cfg_Profiler[16]=3-popNum
			break
		default:
			return 0
	endswitch
	RefreshCurrent2DSlice(S_win)
	return 0
End


Function PM_ExtractVolume(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	string S_win=pa.win
	wave Cfg_Profiler
	wave /T Cfg_Profiler_Str
	Variable popNum
	String popStr
	if(strlen(S_win)==0)
		S_win="CP_Slice_2Dimage"
	endif
	switch( pa.eventCode )
		case 2: // mouse up
			popNum = pa.popNum
			popStr = pa.popStr
			Cfg_Profiler[17]=popNum//F_ExtractedVolume_for4D
			Gen_PopMenue("PM_ExtractVolume", S_win)
			if((strlen(Cfg_Profiler_Str[0])!=0) && !stringmatch(Cfg_Profiler_Str[0], "_none_"))
				RefreshCurrent3DVolume(S_win)
			endif
			break
		default:
			return 0
	endswitch
	return 0
End

Function Gen_PopMenue(ctrlName, S_WinName)
	string ctrlName, S_WinName
	wave Cfg_Profiler
	string L_PMList
	switch(Cfg_Profiler[17])	//F_ExtractedVolume_for4D
		//F_FixedDim =0 :	YZ plane (X axis is fixed).
		//F_FixedDim =1:	XZ plane (Y axis is fixed).
		//F_FixedDim =2:	XY plane (Z axis is fixed).
		case 1://X-Y-Z
			L_PMList="\"X-Y;X-Z;Y-Z\""
			break
		case 2://X-Y-T
			L_PMList="\"X-Y;X-T;Y-T\""
			break
		case 3://X-Z-T
			L_PMList="\"X-Z;X-T;Z-T\""
			break
		case 4://Y-Z-T
			L_PMList="\"Y-Z;Y-T;Z-T\""
			break
		default:
			L_PMList="\"X-Y;X-T;Y-T\""
	endswitch
	PopupMenu PM_SelectPlene win=$S_WinName, value=#L_PMList
end


Function S_SliceExtPos(sa) : SliderControl
	STRUCT WMSliderAction &sa
	string S_win=sa.win
	wave Cfg_Profiler
	wave /T Cfg_Profiler_Str
	wave /Z W_src=$Cfg_Profiler_Str[1]
	if(strlen(S_win)==0)
		S_win="CP_Slice_2Dimage"
	endif
	if(!WaveExists(W_src))
		return 0
	endif
	switch( sa.eventCode )
		case -1: // kill
			break
		case 2:
			break
		case 4:
			break
		default:
			Variable F_FixedDim=round(Cfg_Profiler[16])
			if((F_FixedDim<0) || (F_FixedDim>2))
				F_FixedDim=2
			endif
			if( sa.eventCode == 9) // value set
				Cfg_Profiler[20]=ClampDimPosition_MD(W_src, F_FixedDim, sa.curval)
				Cfg_Profiler[18]=ClampDimPoint_MD(W_src, F_FixedDim, x2pnt_MD(Cfg_Profiler_Str[1], F_FixedDim, Cfg_Profiler[20]))
			else
				Cfg_Profiler[18]=ClampDimPoint_MD(W_src, F_FixedDim, Cfg_Profiler[18])
			endif
			Cfg_Profiler[20]=pnt2x_MD(Cfg_Profiler_Str[1], F_FixedDim, Cfg_Profiler[18])
			RefreshCurrent2DSlice(S_win)
			break
	endswitch

	return 0
	//All procedure to update slice should use the function.
	//This function updates slice position & point with slider operation
	//If it is used by other function, the slider will be moved to the value in Cfgwave
End

Function S_VolumeExtPos(sa) : SliderControl
	STRUCT WMSliderAction &sa
	string S_win=sa.win
	wave Cfg_Profiler
	wave /T Cfg_Profiler_Str
	wave /Z W_src=$Cfg_Profiler_Str[0]
	if(strlen(S_win)==0)
		S_win="CP_Slice_2Dimage"
	endif
	if(!WaveExists(W_src))
		return 0
	endif
	switch( sa.eventCode )
		case -1: // kill
			break
		default:
			Variable F_FixedDim=Get4DVolumeFixedDim(Cfg_Profiler[17])
			if( sa.eventCode == 9 ) // value set
				Cfg_Profiler[21]=ClampDimPosition_MD(W_src, F_FixedDim, sa.curval)
				Cfg_Profiler[19]=ClampDimPoint_MD(W_src, F_FixedDim, x2pnt_MD(Cfg_Profiler_Str[0], F_FixedDim, Cfg_Profiler[21]))
			else
				Cfg_Profiler[19]=ClampDimPoint_MD(W_src, F_FixedDim, Cfg_Profiler[19])
			endif
			Cfg_Profiler[21]=pnt2x_MD(Cfg_Profiler_Str[0], F_FixedDim, Cfg_Profiler[19])
			RefreshCurrent3DVolume(S_win)
			break
	endswitch

	return 0
End


Function SV_SlicePosition(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			wave Cfg_Profiler
			Cfg_Profiler[20]=dval
			break
	endswitch
	STRUCT WMSliderAction sa
	S_SliceExtPos(sa)
	return 0
End

Function SV_SlicePoint(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			wave Cfg_Profiler
			Cfg_Profiler[18]=dval
			break
	endswitch
	STRUCT WMSliderAction sa
	S_SliceExtPos(sa)
	return 0
End

Function SV_VolumePosition(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			wave Cfg_Profiler
			Cfg_Profiler[21]=dval
			break
	endswitch
	STRUCT WMSliderAction sa
	S_VolumeExtPos(sa)
	return 0
End

Function SV_VolumePoint(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			wave Cfg_Profiler
			Cfg_Profiler[19]=dval
			break
	endswitch
	STRUCT WMSliderAction sa
	S_VolumeExtPos(sa)
	return 0
End
