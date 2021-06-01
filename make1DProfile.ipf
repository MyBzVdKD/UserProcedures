#pragma rtGlobals=1		// Use modern global access method.
string /G S_wname
variable /G F_HorV
variable /G V_Xpos
variable /G V_Ypos


macro Profiler1D(wname)
	String wname
	Variable sliderValue
	if(F_HorV==1)
		Profile1D[]=$wname[p][V_Xpos]
			print 3
	endif
	if(F_HorV==2)
		Profile1D[]=$wname[p][V_Ypos]
			print 2
	endif

	return 0
End


Function PM_SelectWave (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	Nvar V_Xpos
	Nvar V_Ypos
	nvar F_HorV
	Svar S_wname

	Slider S_vertical limits={0,dimsize ($popStr, 0),1} 
	Slider S_Horizontal limits={0,dimsize ($popStr, 1),1} 
	SetVariable SV_Horizontal limits={0,dimsize ($popStr, 1),1}
	SetVariable SV_Vertical limits={0,dimsize ($popStr, 1),1}
	V_Xpos=dimsize ($popStr, 0)/2
	V_Ypos=dimsize ($popStr, 1)/2
	make /O /N=(dimsize ($popStr, F_HorV-1)) Profile1D
	S_wname=popStr
	 Execute "Profiler1D(\""+S_wname+"\")"
End


Function PM_HorV(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	nvar F_HorV
	svar S_wname
	F_HorV=popNum
	if(popNum==1)//H scan
		Slider S_vertical disable=1
		Slider S_Horizontal disable=0
	elseif (popNum==2)//V scan
		Slider S_vertical disable=0
		Slider S_Horizontal disable=1
	endif
	 Execute "Profiler1D(\""+S_wname+"\")"
//Slider S_vertical disable=1
End



Function SP_Yposition(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	Svar S_wname
	 Execute "Profiler1D(\""+S_wname+"\")"

	return 0
End

Function SlP_Xposition(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	Svar S_wname
	 Execute "Profiler1D(\""+S_wname+"\")"

	return 0
End

Function SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	Svar S_wname
	Execute "Profiler1D(\""+S_wname+"\")"
End

Function SV_Xposition(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	Svar S_wname
	Execute "Profiler1D(\""+S_wname+"\")"
End

Function SV_Yposition(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	Svar S_wname
	Execute "Profiler1D(\""+S_wname+"\")"

End

Function SP_Xposition(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	Svar S_wname
	 Execute "Profiler1D(\""+S_wname+"\")"

	return 0
End



Window CP_Slice_2Dimage() : Panel
	string /G S_wname
	variable /G F_HorV=0
	variable /G V_Xpos
	variable /G V_Ypos
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(80,741,458,1142) as "Slice_2Dimage"
	ShowTools
	SetDrawLayer UserBack
	Slider S_Horizontal,pos={68,337},size={169,48},proc=SP_Xposition
	Slider S_Horizontal,limits={0,100,1},variable= V_Xpos,vert= 0,thumbColor= (65280,32768,32768)
	PopupMenu SelectWave,pos={7,30},size={203,23},proc=PM_SelectWave,title="Wave"
	PopupMenu SelectWave,font="Arial"
	PopupMenu SelectWave,mode=2,bodyWidth= 168,popvalue="CLMS_XYwave_RP1_horiz",value= #"WaveList(\"*\",\";\",\"DIMS:2\")+\";_none_\""
	Slider S_vertical,pos={257,142},size={56,185},disable=1,proc=SP_Yposition
	Slider S_vertical,limits={0,100,1},variable= V_Ypos,thumbColor= (65280,32768,32768)
	PopupMenu SlicedDirection,pos={16,4},size={193,23},proc=PM_HorV,title="H  or V  slice"
	PopupMenu SlicedDirection,font="Arial"
	PopupMenu SlicedDirection,mode=1,popvalue="Horizontial Scan",value= #"\"Horizontial Scan; Vertical Scan\""
	SetVariable SV_Horizontal,pos={237,63},size={101,18},proc=SV_Yposition,title="Y position"
	SetVariable SV_Horizontal,font="Arial",limits={0,100,1},value= V_Ypos
	SetVariable SV_Vertical,pos={108,380},size={98,15},proc=SV_Xposition,title="X position"
	SetVariable SV_Vertical,limits={0,100,1},value= V_Xpos
	Display/W=(12,66,225,314)/HOST=#  Profile1D
	ModifyGraph lSize=0.5
	ModifyGraph rgb=(19712,0,39168)
	RenameWindow #,G0
	SetActiveSubwindow ##
EndMacro
