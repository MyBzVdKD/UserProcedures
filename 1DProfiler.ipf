#pragma rtGlobals=1		// Use modern global access method.
#include "GeneralTools"
EndMacro
Window Profiler_Cfg() : Table
	PauseUpdate; Silent 1		// building window...
	Edit/W=(276.75,88.25,594.75,298.25) Cfg_Profiler,Cfg_Profiler_Name as "T_Profiler_Cfg"
	ModifyTable format(Point)=1,width(Cfg_Profiler_Name)=140
EndMacro

Window CP_Slice_2Dimage() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(714,128,1350,676) as "Slice_2Dimage"
	ShowTools
	Slider SLD_Slice_pos,pos={352,371},size={230,44},proc=S_SliceExtPos
	Slider SLD_Slice_pos,font="Verdana"
	Slider SLD_Slice_pos,limits={-2,2,0.105263},value= 0.842105263157895,vert= 0,ticks= 20,thumbColor= (0,39168,0)
	Slider S_Axis1,pos={107,246},size={227,43},proc=SP_Axis1,font="Arial"
	Slider S_Axis1,limits={0,358,0},value= 181.594202898551,vert= 0,thumbColor= (65280,32768,32768)
	PopupMenu SelectWave,pos={27,12},size={194,17},bodyWidth=168,disable=2,proc=PM_SelectWave,title="Wave"
	PopupMenu SelectWave,font="Arial"
	PopupMenu SelectWave,mode=11,popvalue="M_ImagePlane",value= #"WaveList(\"*\",\";\",\"DIMS:2\")+\";_none_\""
	Slider S_Axis2,pos={323,58},size={55,158},proc=SP_Axis2,font="Arial"
	Slider S_Axis2,limits={-2,2,-0.1},value= 0,thumbColor= (0,15872,65280)
	SetVariable SV_Axis2,pos={320,18},size={126,13},proc=SV_Axis2,title="Axis 2"
	SetVariable SV_Axis2,font="Arial",format="%g pnt"
	SetVariable SV_Axis2,limits={0,39,1},value= Cfg_Profiler[1]
	SetVariable SV_Axis1,pos={96,294},size={104,13},proc=SV_Axis1,title="Axis 1"
	SetVariable SV_Axis1,font="Arial",format="%g pnt"
	SetVariable SV_Axis1,limits={0,180,1},value= Cfg_Profiler[0]
	Button SaveY,pos={493,256},size={50,20},proc=BP_SaveA2,title="SaveY"
	Button SaveY,font="Arial"
	Button SaveX,pos={81,480},size={50,20},proc=BP_SaveA1,title="SaveX",font="Arial"
	SetVariable SV_Scale_Axis2,pos={450,18},size={126,13},proc=SV_Schale_Axis2,title="Axis 2"
	SetVariable SV_Scale_Axis2,font="Arial",format="%g"
	SetVariable SV_Scale_Axis2,limits={-2,2,-0.1},value= Cfg_Profiler[3]
	SetVariable SV_Scale_Axis1,pos={220,294},size={104,13},proc=SV_Schale_Axis1,title="Axis 1"
	SetVariable SV_Scale_Axis1,font="Arial",format="%g"
	SetVariable SV_Scale_Axis1,limits={0,358,0},value= Cfg_Profiler[2]
	SetVariable SV_LineWidth,pos={339,274},size={136,14},title="LineWidth"
	SetVariable SV_LineWidth,font="Verdana",limits={1,inf,2},value= Cfg_Profiler[12]
	PopupMenu P_Wave3D,pos={346,303},size={142,17},proc=PM_3DWaveSelect,title="Wave3D"
	PopupMenu P_Wave3D,font="Verdana",fStyle=1
	PopupMenu P_Wave3D,mode=1,popvalue="W_ExtRatio",value= #"WaveList(\"*\",\";\",\"DIMS:3\")+\";_none_\""
	PopupMenu PM_Wave4D,pos={345,426},size={115,17},proc=PM_4DWaveSelect,title="Wave4D"
	PopupMenu PM_Wave4D,font="Verdana",fStyle=1
	PopupMenu PM_Wave4D,mode=1,popvalue="_none_",value= #"WaveList(\"*\",\";\",\"DIMS:4\")+\";_none_\""
	PopupMenu PM_SelectPlene,pos={346,327},size={106,17},proc=PM_ExtractPlane,title="Sliced Plane"
	PopupMenu PM_SelectPlene,font="Verdana"
	PopupMenu PM_SelectPlene,mode=1,popvalue="X-Y",value= #"\"X-Y;X-T;Y-T\""
	PopupMenu PM_SelectVol,pos={346,450},size={138,17},proc=PM_ExtractVolume,title="Selected Volume"
	PopupMenu PM_SelectVol,font="Verdana"
	PopupMenu PM_SelectVol,mode=2,popvalue="X-Y-T",value= #"\"X-Y-Z;X-Y-T;X-Z-T;Y-Z-T\""
	SetVariable SV_Slice_pnt,pos={346,353},size={134,14},proc=SV_SlicePoint,title="Position"
	SetVariable SV_Slice_pnt,font="Verdana",format="%g pnt"
	SetVariable SV_Slice_pnt,limits={0,2500,1},value= Cfg_Profiler[18]
	SetVariable SV_Slice_pos,pos={481,352},size={111,14},proc=SV_SlicePosition,title="="
	SetVariable SV_Slice_pos,font="Verdana",format="%g deg"
	SetVariable SV_Slice_pos,limits={-2,2,0.105263},value= Cfg_Profiler[20]
	Slider SLD_Volume_pos,pos={346,490},size={230,53},proc=S_VolumeExtPos
	Slider SLD_Volume_pos,font="Verdana"
	Slider SLD_Volume_pos,limits={-0.0125,0.01249,1e-05},value= -0.00721,vert= 0,ticks= 20,thumbColor= (65280,43520,0)
	SetVariable SV_Volume_pnt,pos={346,473},size={148,14},title="Position"
	SetVariable SV_Volume_pnt,font="Verdana",format="%g pnt"
	SetVariable SV_Volume_pnt,limits={0,2499,1},value= Cfg_Profiler[19]
	SetVariable SV_Volume_pos,pos={497,474},size={68,14},title="=",font="Verdana"
	SetVariable SV_Volume_pos,format="%g sec"
	SetVariable SV_Volume_pos,limits={-0.0125,0.01249,1e-05},value= Cfg_Profiler[21]
	Display/W=(406,46,564,254)/HOST=#  W_Profile_A2
	ModifyGraph font="Arial"
	ModifyGraph swapXY=1
	RenameWindow #,G0
	SetActiveSubwindow ##
	Display/W=(77,330,332,471)/HOST=#  W_Profile_A1
	ModifyGraph font="Arial"
	ModifyGraph axOffset(bottom)=0.166667
	RenameWindow #,G2
	SetActiveSubwindow ##
	Display/W=(50,52,324,243)/HOST=# 
	AppendImage M_SlicerOrg
	ModifyImage M_SlicerOrg ctab= {*,69,Spectrum,0}
	ModifyGraph mirror=2
	ModifyGraph lblMargin(left)=55
	ModifyGraph axOffset(left)=9.8
	ModifyGraph lblLatPos(left)=10
	Label left "\\F'Arial' \\U"
	Label bottom "\\F'Arial' \\U"
	ColorScale/C/N=text0/F=0/B=1/A=MC/X=-96.77/Y=-5.41 image=M_SlicerOrg, font="Arial"
	RenameWindow #,G3
	SetActiveSubwindow ##
EndMacro

Function PM_SelectWave (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	string /G S_Slicer_2DWname
	wave wv2=$popStr
	duplicate /O wv2, M_SlicerOrg
	wave wv=M_SlicerOrg
	wave M_Conf=Cfg_Profiler
	wave /T Cfg_Profiler_Str
	Cfg_Profiler_Str[2]=popStr
	variable i
	//Slider S_Axis1 limits={0,dimsize (wv, 0),1} 
	//Slider S_Axis2 limits={0,dimsize (wv, 1),1} 
	PopupMenu SelectWave win=CP_Slice_2Dimage, mode=WhichListItem(popStr, WaveList("*",";","DIMS:2")+";_none_")+1
	SetVariable SV_Axis1 win=CP_Slice_2Dimage, limits={0,dimsize (wv, 0),1}
	SetVariable SV_Axis2 win=CP_Slice_2Dimage, limits={0,dimsize (wv, 1),1}
	for(i=0;i<=1;i+=1)
		M_Conf[4+i]=dimsize (wv, i)//NumberPoint
		M_Conf[6+i]=DimOffset(wv, i)//ScaleMin
		M_Conf[8+i]=DimOffset(wv, i) + (M_Conf[4+i]-1) *DimDelta(wv,i)//ScaleMax
		make /O /N=(dimsize (wv, i)) $"W_Profile_A"+num2str(i+1)
		setscale /I x, M_Conf[6+i], M_Conf[8+i], $"W_Profile_A"+num2str(i+1)
		Slider $"S_Axis"+num2str(i+1) win=CP_Slice_2Dimage, limits={M_Conf[6+i],M_Conf[8+i],M_Conf[6+i]/20}
		SetVariable $"SV_Scale_Axis"+num2str(i+1) win=CP_Slice_2Dimage, limits={M_Conf[6+i],M_Conf[8+i],M_Conf[6+i]/20}
		SetVariable $"SV_Axis"+num2str(i+1) win=CP_Slice_2Dimage, limits={0,dimsize (wv, i),1}
		//print M_Conf[4+i], M_Conf[6+i],"W_Profile_A"+num2str(i+1)
	endfor
	//make /O /N=(dimsize (wv, 0)) Profile_A1
	//make /O /N=(dimsize (wv, 0)) Profile_A2
	 //Execute "Profiler1D(\""+S_wname+"\")"
	 wavestats /M=1 /Q wv
	 //SetAxis /W=Slice_2Dimage# left 0,V_max
End



function Profiler1D(ctrlName, V_pnt, F_Vert)
	String ctrlName
	Variable V_pnt, F_Vert
	wave wv=M_SlicerOrg
	Wave W_prifile=$"W_Profile_A"+num2str(F_Vert+1)
	wave Cfg_Profiler
	variable V_LineWidth=Cfg_Profiler[12]
	variable V_offset=trunc(V_LineWidth/2)
	variable i=0
	DelayUpdate
	W_prifile=0
	if(F_Vert)
		i=-V_offset
		do
			W_prifile[]+=wv[V_pnt+i][p]
			i+=1
		while(i<V_offset+1)
	else
		i=-V_offset
		do
			W_prifile[]+=wv[p][V_pnt+i]
			i+=1
		while(i<V_offset+1)
	endif
	W_prifile/=2*V_offset+1
	DoUpdate
	//ImageLineProfile xWave=W_x, yWave=W_y, srcwave=Pin_S_H_A_01, width=5;Duplicate/O W_ImageLineProfile W_01; nrm("W_01")
	return F_Vert
End

function Profiler1D2(ctrlName, V_pnt, F_Vert)
	String ctrlName
	Variable V_pnt, F_Vert
	wave wv=M_SlicerOrg
	Wave W_prifile=$"W_Profile_A"+num2str(F_Vert+1)
	wave Cfg_Profiler
	variable V_LineWidth=Cfg_Profiler[12]
	variable V_offset=trunc(V_LineWidth/2)
	variable i=0
	DelayUpdate
	W_prifile=0
	ImageLineProfile 
	if(F_Vert)
		i=-V_offset
		do
			W_prifile[]+=wv[V_pnt+i][p]
			i+=1
		while(i<V_offset+1)
	else
		i=-V_offset
		do
			W_prifile[]+=wv[p][V_pnt+i]
			i+=1
		while(i<V_offset+1)
	endif
	W_prifile/=2*V_offset+1
	DoUpdate
	return F_Vert
End

Function SV_Axis1(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	//Svar S_wname
	wave Cfg_Profiler
	string wname="M_SlicerOrg"
	Cfg_Profiler[0]=varNum//trunc(varNum)
	if(cmpstr(ctrlName, "SP_Axis1"))
		SP_Axis1("SV_Axis1",pnt2x_MD(wname, 0, varNum), 0)
	endif
End

Function SV_Axis2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	//Svar S_wname
	wave Cfg_Profiler
	string wname="M_SlicerOrg"
	Cfg_Profiler[1]=varNum//trunc(varNum)
	if(cmpstr(ctrlName, "SP_Axis2"))
		SP_Axis2("SV_Axis2",pnt2x_MD(wname, 1, varNum), 0)
	endif

End

Function SV_Schale_Axis1(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	SP_Axis1("SV_Schale_Axis1",varNum, 0)
End

Function SV_Schale_Axis2(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	SP_Axis2("SV_Schale_Axis2",varNum, 0)
End

Function BP_SaveA1(ctrlName) : ButtonControl
	String ctrlName
	SaveBinfile("W_Profile_A1")
End

Function BP_SaveA2(ctrlName) : ButtonControl
	String ctrlName
	SaveBinfile("W_Profile_A2")
End

function SaveBinfile(wname)
	string wname
	wave wv=$wname
	Save/C wv as wname+"_"+TodaysFileneme()+".ibw"
End

function / S TodaysFileneme()
	return date()+"_"+ReplaceString(":", time(), "")
end

Function SP_Axis2(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	string wname="M_SlicerOrg"
	wave Cfg_Profiler
	Cfg_Profiler[3]=sliderValue
	Cfg_Profiler[1]=x2pnt_MD(wname, 1, sliderValue)
	Profiler1D("SP_Axis2",  x2pnt_MD(wname, 1, sliderValue), 0)
	Slider S_Axis2 win=CP_Slice_2Dimage, value=sliderValue
	return 0
End

Function SP_Axis1(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	string wname="M_SlicerOrg"
	wave Cfg_Profiler
	Cfg_Profiler[2]=sliderValue
	Cfg_Profiler[0]=x2pnt_MD(wname, 0, sliderValue)
	Profiler1D("SP_Axis1",  x2pnt_MD(wname, 0, sliderValue), 1)
	Slider S_Axis1 win=CP_Slice_2Dimage, value=sliderValue
//	if(cmpstr(ctrlName, "SV_Axis1"))
//		SV_Axis1("SP_Axis1",x2pnt_MD(wname, 0, sliderValue),"","")
//	endif
	return 0
End

function /S GetcenterCenterProfiles(S_MatrixWave, S_Profilewave)
	string S_MatrixWave, S_Profilewave
	wave M_Matrix=$S_MatrixWave
	PM_SelectWave ("",0, S_MatrixWave)
	SV_Schale_Axis2("",0,"","") 
	wave W_Profile_A1
	SV_Schale_Axis1("",0,"","") 
	wave W_Profile_A2
	duplicate /O W_Profile_A1, $S_Profilewave+"_x"
	duplicate /O W_Profile_A2, $S_Profilewave+"_y"
	//execute "normalize("+S_Profilewave+",1)"
	return S_Profilewave
end


function /S Conv_3DSlice(S_src3Dwave, S_dest2Dwave, V_i_plane ,F_plane)
	string S_src3Dwave, S_dest2Dwave
	variable V_i_plane, F_plane
//	F_plane: Specifies the plane to use with the getPlane keyword.
//	F_plane=0: XY plane.
//	F_plane=1: XZ plane.
//	F_plane=2: YZ plane.
//	/Q Quiet flag. When used
	ImageTransform /P=(V_i_plane) /PTYP=(F_plane) getPlane $S_src3Dwave
	wave M_ImagePlane
	duplicate /O M_ImagePlane, $S_dest2Dwave
	killwaves M_ImagePlane
	return S_dest2Dwave
end


function /S GetCenterPlane(S_3DWname_src, S_2DWname_dist, F_plane)
	string S_3DWname_src, S_2DWname_dist
	variable F_plane
	wave M_3D_src=$S_3DWname_src
	variable V_pWidth=dimsize(M_3D_src, 2-F_plane)
	
	if(mod(V_pWidth, 2))
		wave M_2D_dist=$Conv_3DSlice(nameofwave(M_3D_src), S_2DWname_dist, round(V_pWidth/2) ,F_plane)
		wave M_2D_dist_tmp=$Conv_3DSlice(nameofwave(M_3D_src), S_2DWname_dist+"_tmp", round(V_pWidth/2)+1 ,F_plane)
		M_2D_dist+=M_2D_dist_tmp
		M_2D_dist/=2
		killwaves M_2D_dist_tmp
	else
		wave M_2D_dist=$Conv_3DSlice(nameofwave(M_3D_src), S_2DWname_dist, round(V_pWidth/2) ,F_plane)
	endif
	return NameOfwave(M_2D_dist)
end

Function PM_Select3DWave(ctrlName,popNum,popStr)  : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	String S_SliceWaveName="M_Slice"
	wave Cfg_Profiler
	variable F_plane=Cfg_Profiler[12]
	GetCenterPlane(popStr, S_SliceWaveName, F_plane)
	PM_SelectWave ("PM_Select3DWave",0,S_SliceWaveName)
End






Function PM_Plane(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			break
	endswitch
	wave Cfg_Profiler
	Cfg_Profiler[13]=popNum-1
	return 0
End

