


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
	string L_dim_asgn=""
	for(i=0; i<4; i+=1)
		if(i!=F_FixedDim)
			L_Dim_npnts+=num2str(dimsize(W_src, i))+";"
			//L_Dim_asgn+=StringFromList(i, "x;y;z;t")+";"
			//print StringFromList(i, L_Dim_npnts)
		endif
	endfor
	string S_wname=nameofwave(W_src)+"_3D"
	make /O /D /n=(str2num(StringFromList(0, L_Dim_npnts)), str2num(StringFromList(1, L_Dim_npnts)), str2num(StringFromList(2, L_Dim_npnts))) $S_wname
	wave W_dest=$S_wname
	switch(F_FixedDim)
		case 0:
			W_dest=W_src[V_FixedPoint][p][q][r]
			//copyscales
			//redimension
			
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
			break
	endswitch
	variable i_dim=0
	string S_command
	for(i=0; i<4; i+=1)
		if(i!=F_FixedDim)
			S_command="setscale /P "+StringFromList(i_dim, "x;y;z;t")+", "
			S_command+=num2str(DimOffset(W_src, i))+", "
			S_command+=num2str(DimDelta(W_src, i))+", "
			S_command+="\""+WaveUnits(W_src, i)+"\", "
			S_command+=nameofwave(W_dest)
			Execute S_command
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
	variable F_PTYP=str2num(StringFromList(F_FixedDim, "2;1;0"))
	ImageTransform /P=(V_FixedPoint) /PTYP=(F_PTYP) getPlane W_src
	wave M_ImagePlane
	return nameofwave(M_ImagePlane)
end

Function PM_3DWaveSelect(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	string S_win=pa.win
	wave Cfg_Profiler
	wave /T Cfg_Profiler_Str
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			break
	endswitch
		if(stringmatch(popStr, "_none_"))//2Dmode
			PopupMenu SelectWave win=$S_win, disable=0
			Cfg_Profiler[13]=0
			Cfg_Profiler_Str[1]=popStr
		else//3Dmode
			variable F_SlicedWave=WhichListItem("M_ImagePlane", WaveList("*",";","DIMS:2"))+1
			PopupMenu SelectWave win=$S_win, disable=2, mode=(F_SlicedWave)
			Cfg_Profiler[13]=1
			PM_SelectWave ("PM_3DWaveSelect",F_SlicedWave ,"M_ImagePlane")
			Cfg_Profiler_Str[1]=popStr
			STRUCT WMSliderAction sa
			S_SliceExtPos(sa)
		endif
	return 0
End

Function PM_4DWaveSelect(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	string S_win=pa.win
	wave Cfg_Profiler
	wave /T Cfg_Profiler_Str
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			break
	endswitch
		if(stringmatch(popStr, "_none_"))//3Dmode
			PopupMenu P_Wave3D win=$S_win, disable=0, mode=1
			pa.popStr=""
			Cfg_Profiler[14]=0
			Cfg_Profiler[15]=0
		else//4Dmode
			popStr+="_3D"
			variable F_SlicedWave=WhichListItem(popStr, WaveList("*",";","DIMS:3"))+1
			PopupMenu P_Wave3D win=$S_win, disable=2, mode=(F_SlicedWave)
			Cfg_Profiler[14]=1
			Cfg_Profiler[15]=1
			//PM_SelectWave ("PM_3DWaveSelect",F_SlicedWave ,"M_ImagePlane")
		endif
		Cfg_Profiler_Str[0]=popStr
		PM_3DWaveSelect(pa)
	return 0
End

Function PM_ExtractPlane(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	string S_win=pa.win
	wave Cfg_Profiler
	wave /T Cfg_Profiler_Str
	switch( pa.eventCode )

		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			Cfg_Profiler[16]=str2num(StringFromList(popNum-1, Cfg_Profiler_Str[3]))//F_F_SliceFixedDim_for3D
			variable V_FixedDim=Cfg_Profiler[16]
			string S_SrcWname=Cfg_Profiler_Str[1]
			variable V_PosSliderMin=DimOffset($S_SrcWname, V_FixedDim)
			variable V_PosSliderInc=DimDelta($S_SrcWname, V_FixedDim)
			variable V_PosSliderMax=V_PosSliderMin+V_PosSliderInc*(DimSize($S_SrcWname, V_FixedDim)-1)
			Slider SLD_Slice_pos win=$S_win, limits={V_PosSliderMin,V_PosSliderMax,V_PosSliderInc}
			SetVariable SV_Slice_pos win=$S_win, limits={V_PosSliderMin,V_PosSliderMax,V_PosSliderInc}
			SetVariable SV_Slice_pos win=$S_win, format="%g "+WaveUnits($S_SrcWname, V_FixedDim )
			break
	endswitch
//	refresh	
	STRUCT WMSliderAction sa
	S_SliceExtPos(sa)
//	refresh
	return 0
End


Function PM_ExtractVolume(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	string S_win=pa.win
	wave Cfg_Profiler
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			Cfg_Profiler[17]=popNum//F_ExtractedVolume_for4D
			Gen_PopMenue("PM_ExtractVolume", S_win)
			break
	endswitch
	return 0
End

Function Gen_PopMenue(ctrlName, S_WinName)
	string ctrlName, S_WinName
	wave Cfg_Profiler
	string L_PMList, L_FixedDim
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
	endswitch
	PopupMenu PM_SelectPlene win=$S_WinName, value=#L_PMList
end


Function S_SliceExtPos(sa) : SliderControl
	STRUCT WMSliderAction &sa
	string S_win=sa.win
	wave Cfg_Profiler
	wave /T Cfg_Profiler_Str
	//print sa.eventCode
	switch( sa.eventCode )
		case -1: // kill
			break
		case 2:
			break
		case 4:
			break
		//case 0: 
		//	break
		default:
			Variable V_SliceFixedPnt, F_FixedDim
			F_FixedDim=Cfg_Profiler[16]//SlicedPlane_for3D
			if( sa.eventCode == 9) // value set
				Variable curval = sa.curval
				V_SliceFixedPnt = x2pnt_MD(Cfg_Profiler_Str[1], F_FixedDim, curval)
				Cfg_Profiler[18]=V_SliceFixedPnt//V_SlicedPnt_for3D
				Cfg_Profiler[20]=curval//
			elseif(sa.eventCode == 0)
				variable V_SliceFixedPos = Cfg_Profiler[20]//SlicedPnt_for3D
				Slider SLD_Slice_pos win=$S_win, value=V_SliceFixedPos
				V_SliceFixedPnt =Cfg_Profiler[18]
				
			endif
			wave W_src=$Cfg_Profiler_Str[1]//3DWave
			F_FixedDim=str2num(StringFromList(Cfg_Profiler[16], Cfg_Profiler_Str[3]))
			Extract2Dfrom3D("S_SliceExtPos", W_src, F_FixedDim, V_SliceFixedPnt)
			//print F_FixedDim, V_SliceFixedPnt
			PM_SelectWave ("S_SliceExtPos",0,"M_ImagePlane")
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
	switch( sa.eventCode )
		case -1: // kill
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
			else
				//Cfg_Profiler[19]
			endif
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
			String sval = sva.sval
			wave Cfg_Profiler
			wave /T Cfg_Profiler_Str
			variable F_FixedDim=Cfg_Profiler[16]
			Cfg_Profiler[20]=dval//V_SlicedPositionPnt
			Cfg_Profiler[18]=x2pnt_MD(Cfg_Profiler_Str[1], F_FixedDim, dval)//V_SlicedPositionPos
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
			String sval = sva.sval
			wave Cfg_Profiler
			wave /T Cfg_Profiler_Str
			variable F_FixedDim=Cfg_Profiler[16]
			Cfg_Profiler[18]=dval//V_SlicedPositionPnt
			Cfg_Profiler[20]=pnt2x_MD(Cfg_Profiler_Str[1], F_FixedDim, dval)//V_SlicedPositionPos
			break
	endswitch
 	STRUCT WMSliderAction sa
 	sa.curval=Cfg_Profiler[20]
	S_SliceExtPos(sa)
	return 0
End
