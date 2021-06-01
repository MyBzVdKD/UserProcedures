#pragma rtGlobals=1		// Use modern global access method.
#include  <Multi-peak fitting 1.4>
	
variable /G V_amplitude
variable /G F_subMethod
string /G S_Awave
	
Function SPsynthesize(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	NVAR /Z V_amplitude = V_amplitude	
	if (!NVAR_Exists(V_amplitude))	
		Variable/G V_amplitude
	endif
	
	NVAR /Z V_XviewOn = V_XviewOn	
	if (!NVAR_Exists(V_XviewOn))	
		Variable/G V_XviewOn
	endif
	variable V_ONOFF=abs(V_XviewOn-1)
	
	if(event!=4)	
		V_amplitude=sliderValue
	endif
	
	NVAR /Z F_subMethod = F_subMethod	
	if (!NVAR_Exists(F_subMethod))	
		Variable/G F_subMethod
	endif

	nvar V_Xshift, V_Yshift, V_Rshift, V_mag
	variable V_cos=cos(V_Rshift/180*pi)
	variable V_sin=sin(V_Rshift/180*pi)
	
	Svar S_Awave, S_Bwave, S_Swave
	wave W_A=$S_Awave
	wave W_B=$S_Bwave
	wave W_S=$S_Swave
	//RMV_backgroud_2D("", S_Awave, 3, 0)
	//RMV_backgroud_2D("", S_Bwave, 3, 0)
	
	//print V_mag*V_cos,-V_mag*V_sin,V_Xshift,V_mag*V_sin,V_mag*V_cos,V_Yshift,1,0
	ImageInterpolate /APRM={V_mag*V_cos,-V_mag*V_sin,V_Xshift,V_mag*V_sin,V_mag*V_cos,V_Yshift,1,0 } Affine2D  W_B
	wave M_Affine
	

	switch (F_subMethod)
		case 1://X-aY
			multithread W_S=W_A[p][q]-V_amplitude*V_ONOFF*M_Affine[p][q]
			break
		case 2://X+aY
			multithread W_S=W_A[p][q]+V_amplitude*V_ONOFF*M_Affine[p][q]
			break
		case 3://X/aY
			multithread W_S=W_A[p][q]/(V_amplitude*V_ONOFF*M_Affine[p][q])
			break
		case 4://(X-aY)/(X+aY)
			multithread W_S=(W_A[p][q]-V_amplitude*V_ONOFF*M_Affine[p][q])/(W_A[p][q]+V_amplitude*V_ONOFF*M_Affine[p][q])
			break
	endswitch

	return 0
End

Function /S PM_Subtraction_method(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	NVAR /Z F_subMethod = F_subMethod	
	if (!NVAR_Exists(F_subMethod))	
		Variable/G F_subMethod
	endif
	F_subMethod=popNum
	return popStr
End

Function /S PM_Subtraction_waveA(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	string /G S_Awave=popStr
	return popStr
End

Function /S PM_Subtraction_waveB(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	string /G S_Bwave=popStr
	return popStr
End


Function /S PM_Subtraction_Solution(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	string /G S_Swave=popStr
	return popStr
End



Function SV_Amplitude(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	Variable dval = sva.dval
	String sval = sva.sval
	SPsynthesize("SV_Amplitude",dval,0)
	return 0
End

Function SV_Xshift(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	NVAR /Z V_Xshift = V_Xshift	
	if (!NVAR_Exists(V_Xshift))	
		Variable/G V_Xshift
	endif
	V_Xshift=varNum
	SPsynthesize("SV_Xshift",0,4)
End

Function SV_Yshift(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	NVAR /Z V_Yshift = V_Yshift	
	if (!NVAR_Exists(V_Yshift))	
		Variable/G V_Yshift
	endif
	V_Yshift=varNum
	SPsynthesize("SV_Yshift",0,4)
End

Function SV_Rshift(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	NVAR /Z V_Rshift = V_Rshift	
	if (!NVAR_Exists(V_Rshift))	
		Variable/G V_Rshift
	endif
	V_Rshift=varNum
	SPsynthesize("SV_Yshift",0,4)
End

Function SV_Magnitude(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	NVAR /Z V_mag = V_mag	
	if (!NVAR_Exists(V_mag))	
		Variable/G V_mag
	endif
	V_mag=varNum
	SPsynthesize("SV_Yshift",0,4)
End

Window Image_Substruction() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(877,327,1210,653) as "Image_Substruction"
	ShowTools
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18
	DrawText 106,94,"VS"
	SetDrawEnv fsize= 18
	DrawText 72,139,"Y"
	SetDrawEnv fsize= 18
	DrawText 125,173,"="
	SetDrawEnv fsize= 18
	DrawText 72,52,"X"
	Slider slider0,pos={15.00,37.00},size={50.00,146.00},proc=SPsynthesize
	Slider slider0,font="Arial",limits={0,10,0.1},variable= V_amplitude
	PopupMenu A_subtracted,pos={89.00,31.00},size={82.00,23.00},proc=PM_Subtraction_waveA
	PopupMenu A_subtracted,font="Arial"
	PopupMenu A_subtracted,mode=2,popvalue="M_PMC_R",value= #"WaveList(\"*\",\";\",\"DIMS:2\")+\";_none_\""
	PopupMenu B_subtract,pos={90.00,119.00},size={82.00,23.00},proc=PM_Subtraction_waveB
	PopupMenu B_subtract,font="Arial"
	PopupMenu B_subtract,mode=3,popvalue="M_PMC_T",value= #"WaveList(\"*\",\";\",\"DIMS:2\")+\";_none_\""
	PopupMenu C_Solution,pos={90.00,184.00},size={88.00,23.00},proc=PM_Subtraction_Solution
	PopupMenu C_Solution,font="Arial"
	PopupMenu C_Solution,mode=11,popvalue="M_tot_PMC",value= #"WaveList(\"*\",\";\",\"DIMS:2\")+\";_none_\""
	SetVariable Amplitude,pos={12.00,11.00},size={92.00,14.00},proc=SV_Amplitude,title="a: amp"
	SetVariable Amplitude,limits={0,10,0.1},value= V_amplitude
	PopupMenu Methods_Substruction,pos={121.00,8.00},size={88.00,23.00},proc=PM_Subtraction_method,title="Method"
	PopupMenu Methods_Substruction,mode=1,popvalue="X-aY",value= #"\"X-aY;X+aY;X/aY;(X-aY)/(X+aY)\""
	SetVariable X,pos={182.00,100.00},size={50.00,14.00},proc=SV_Xshift,title="X"
	SetVariable X,font="Arial",value= V_Xshift
	SetVariable Y,pos={237.00,100.00},size={50.00,14.00},proc=SV_Yshift,title="Y"
	SetVariable Y,font="Arial",value= V_Yshift
	SetVariable R,pos={182.00,120.00},size={82.00,14.00},proc=SV_Rshift,title="Rot. / deg"
	SetVariable R,font="Arial",limits={-inf,inf,0.1},value= V_Rshift
	SetVariable Mag,pos={183.00,138.00},size={93.00,14.00},proc=SV_Magnitude,title="Mag / times"
	SetVariable Mag,font="Arial",limits={0.0001,inf,0.001},value= V_mag
	Execute/Q/Z "SetWindow kwTopWin sizeLimit={44,20,inf,inf}" // sizeLimit requires Igor 7 or later
EndMacro

Function CP_Xon(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			SPsynthesize("CP_Xon",checked,4) 
			break
		case -1: // control being killed
		print -1
			break
	endswitch

	return 0
End
