#pragma rtGlobals=1		// Use modern global access method.
	
// _/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
// _/
// _/	HeNe Laser
// _/		x	LCD_Control_makeLine(0,2.1)
// _/		y	LCD_Control_makeLine(0,2.7)
// _/		Radi	LCD_amp_ch={1.99, 2.16, 2.30, 2.45, 2.59, 2.74, 2.90, 3.08, 2.15, 2.45, 2.74, 3.08, 2.15, 2.45, 2.74, 3.08}
// _/
// _/	maitai ( 2006 / 08 / 02 )
// _/		x	LCD_Control_makeLine(0,2.86)
// _/		y	LCD_Control_makeLine(0,2.03)
// _/	Radi	LCD_amp_ch={4.27, 3.76, 3.39, 3.10, 2.86, 2.65, 2.46, 2.25, 3.10, 3.75, 2.25, 2.65, 3.10, 3.75, 2.25, 2.65}
// _/	
// _/      Chameleon_800 ( 2006 / 09 / 07 )
// _/		x	LCD_Control_makeLine(0,2.927)
// _/		y	LCD_Control_makeLine(0,2.097)
// _/		Radi	LCD_amp_ch={3.645,4.094,2.202,2.408,3.314,3.047,2.816,2.609,2.712,2.308,1.828,3.172,2.712,2.308,1.828,3.172}
// _/					      
// _/	Chameleon_780 ( 2006 / 09 / 07 )
// _/		x	LCD_Control_makeLine(0,2.985)
// _/		y	LCD_Control_makeLine(0,2.178)
// _/		Radi	LCD_amp_ch={3.713,4.182,2.28,2.475,3.375,3.104,2.873,2.668,2.768,2.378,1.946,3.232,2.768,2.378,1.946,3.232}
// _/
// _/	Chameleon_900 ( 2006 / 09 / 07 )
// _/		x	LCD_Control_makeLine(0,2.67)
// _/		y	LCD_Control_makeLine(0,4.098)
// _/		Radi	LCD_amp_ch={3.382,3.815,1.822,2.108,3.063,2.795,2.551,2.328,2.437,1.982,3.58,2.925,2.437,1.982,3.58,2.925}
// _/
// _/
// _/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
//W_LCDVoltages={V_WaveLength, V_x, V_y, V_Cell1, V_Cell2, V_Cell3, V_Cell4, V_Cell5, V_Cell6, V_Cell7, V_Cell8, V_Cell9, V_Cell10, V_Cell11, V_Cell12, V_Cell13, V_Cell14, V_Cell15, V_Cell16}
//V_No, 
//WS_NameLCDSetting=S_Name+V_WaveLength

Function AddLCDSettings(V_WaveLength)
	Variable V_WaveLength
	Variable i
	wave W_LCD=W_LCDSettings
	
	for(i=0; i<dimsize(W_LCDSettings, 0); i+=1)
		if(W_LCD[i][0]==V_WaveLength)
			return i
		elseif(W_LCD[i+1][0]>V_WaveLength)
		print W_LCD[i+1][0],V_WaveLength
			InsertPoints i, 1, W_LCD
			W_LCD[i][0]=V_WaveLength
			return i
		endif
	endfor
	InsertPoints dimsize(W_LCD, 0), 1, W_LCD
	W_LCD[dimsize(W_LCD, 0)][0]=V_WaveLength
	return dimsize(W_LCD, 0)
end


//Function LCD_Control_Init_Val(ctrlName)
//	String ctrlName
//	if(cmpstr(ctrlName,"0")==0)
//		Make/O/N=16 LCD_amp_ch={3.645,4.094,2.202,2.408,3.314,3.047,2.816,2.609,2.712,2.308,1.828,3.172,2.712,2.308,1.828,3.172}
//	elseif(cmpstr(ctrlName,"1")==0)
//		LCD_Control_makeLine(0,2.927)
//	elseif(cmpstr(ctrlName,"2")==0)
//		LCD_Control_makeLine(0,2.097)
//	else
//		print "Miss Input"
//	endif
//	Variable/G  LCD_Frequency=1000
//	Variable/G  LCD_Ctrl_Status=0    // 0: stop,   1: working
//	String/G    Device="Dev4"
//end





Function LCD_Control_makeLine(Amp1,Amp2)
	Variable Amp1		//change delay
	Variable Amp2		//change polarizetion
	Make/O/N=16 LCD_amp_ch={Amp2, Amp2, Amp2, Amp2, Amp2, Amp2, Amp2, Amp2, Amp1, Amp1, Amp1, Amp1, Amp1, Amp1, Amp1, Amp1}
end

Window LCD_Control() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(556,70,1009,377) as "LCD_Control"
	ShowTools
	SetDrawLayer UserBack
	DrawOval 50,50,60,60
	DrawOval 44,189,100,255
	DrawLine 71,189,71,254
	DrawLine 44,228,100,216
	DrawLine 54,245,90,198
	DrawLine 92,241,49,201
	DrawOval 113,217,169,283
	DrawLine 140,217,140,282
	SetDrawEnv arrow= 1
	DrawLine 101,258,181,241
	DrawLine 123,273,159,226
	DrawLine 161,269,118,229
	SetDrawEnv linethick= 5,linepat= 2,linefgc= (65280,16384,16384),dash= 1,arrow= 1,arrowfat= 1
	DrawLine 249,293,181,266
	DrawText 113,210,"PhaseControl"
	SetDrawEnv gstart
	DrawText 53,274,"Polarization"
	DrawText 56,288,"Control"
	SetDrawEnv gstop
	SetDrawEnv fname= "Arial"
	DrawText 132,276,"8"
	SetDrawEnv fname= "Arial"
	DrawText 121,269,"9"
	SetDrawEnv fname= "Arial"
	DrawText 152,247,"14"
	SetDrawEnv fname= "Arial"
	DrawText 154,262,"13"
	SetDrawEnv fname= "Arial"
	DrawText 143,277,"12"
	SetDrawEnv fname= "Arial"
	DrawText 125,236,"11"
	SetDrawEnv fname= "Arial"
	DrawText 116,252,"10"
	SetDrawEnv fname= "Arial"
	DrawText 140,236,"15"
	SetDrawEnv fname= "Arial"
	DrawText 49,240,"16"
	SetDrawEnv fname= "Arial"
	DrawText 59,251,"17"
	SetDrawEnv fname= "Arial"
	DrawText 73,249,"18"
	SetDrawEnv fname= "Arial"
	DrawText 82,234,"19"
	SetDrawEnv fname= "Arial"
	DrawText 83,218,"20"
	SetDrawEnv fname= "Arial"
	DrawText 73,209,"21"
	SetDrawEnv fname= "Arial"
	DrawText 58,208,"22"
	SetDrawEnv fname= "Arial"
	DrawText 48,224,"23"
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 151,292,"7"
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 125,292,"6"
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 111,276,"5"
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 107,253,"4"
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 123,224,"3"
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 151,223,"2"
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 166,239,"1"
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 169,262,"8"
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 98,213,"9"
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 79,194,"10"
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 49,195,"11"
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 31,222,"12"
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 36,248,"13"
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 50,264,"14"
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 80,265,"15"
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 99,239,"16"
	SetDrawEnv gstart
	SetDrawEnv fname= "Arial",textrgb= (65280,0,0)
	DrawText 196,234,"CellNo."
	SetDrawEnv fname= "Arial"
	DrawText 196,248,"Ch.No."
	SetDrawEnv gstop
	SetVariable CH8,pos={25,10},size={80,15},title="CH8 ",format="%gV"
	SetVariable CH8,limits={0,10,0.01},value= LCD_amp_ch[0]
	SetVariable CH9,pos={25,30},size={80,15},title="CH9 ",format="%gV"
	SetVariable CH9,limits={0,10,0.01},value= LCD_amp_ch[1]
	SetVariable CH10,pos={25,50},size={80,15},title="CH10",format="%gV"
	SetVariable CH10,limits={0,10,0.01},value= LCD_amp_ch[2]
	SetVariable CH11,pos={25,70},size={80,15},title="CH11",format="%gV"
	SetVariable CH11,limits={0,10,0.01},value= LCD_amp_ch[3]
	SetVariable CH12,pos={25,90},size={80,15},title="CH12",format="%gV"
	SetVariable CH12,limits={0,10,0.01},value= LCD_amp_ch[4]
	SetVariable CH13,pos={25,110},size={80,15},title="CH13",format="%gV"
	SetVariable CH13,limits={0,10,0.01},value= LCD_amp_ch[5]
	SetVariable CH14,pos={25,130},size={80,15},title="CH14",format="%gV"
	SetVariable CH14,limits={0,10,0.01},value= LCD_amp_ch[6]
	SetVariable CH15,pos={25,150},size={80,15},title="CH15",format="%gV"
	SetVariable CH15,limits={0,10,0.01},value= LCD_amp_ch[7]
	SetVariable CH16,pos={130,10},size={80,15},title="CH16",format="%gV"
	SetVariable CH16,limits={0,10,0.01},value= LCD_amp_ch[8]
	SetVariable CH17,pos={130,30},size={80,15},title="CH17",format="%gV"
	SetVariable CH17,limits={0,10,0.01},value= LCD_amp_ch[9]
	SetVariable CH18,pos={130,50},size={80,15},title="CH18",format="%gV"
	SetVariable CH18,limits={0,10,0.01},value= LCD_amp_ch[10]
	SetVariable CH19,pos={130,70},size={80,15},title="CH19",format="%gV"
	SetVariable CH19,limits={0,10,0.01},value= LCD_amp_ch[11]
	SetVariable CH20,pos={130,90},size={80,15},title="CH20",format="%gV"
	SetVariable CH20,limits={0,10,0.01},value= LCD_amp_ch[12]
	SetVariable CH21,pos={130,110},size={80,15},title="CH21",format="%gV"
	SetVariable CH21,limits={0,10,0.01},value= LCD_amp_ch[13]
	SetVariable CH22,pos={130,130},size={80,15},title="CH22",format="%gV"
	SetVariable CH22,limits={0,10,0.01},value= LCD_amp_ch[14]
	SetVariable CH23,pos={130,150},size={80,15},title="CH23",format="%gV"
	SetVariable CH23,limits={0,10,0.01},value= LCD_amp_ch[15]
	SetVariable LCD_Frequency,pos={247,40},size={100,15},title="freq."
	SetVariable LCD_Frequency,format="%.2W0P Hz"
	SetVariable LCD_Frequency,limits={1000,100000,1},value= LCD_Frequency
	Button LCD_Ctrl,pos={266,70},size={80,30},proc=LCD_Ctrl_ButtonProc,title="Ctrl"
	Button LCD_Ctrl,font="Arial"
	PopupMenu popup0,pos={276,111},size={69,20},proc=LCD_Control_pol
	PopupMenu popup0,help={"Select Polarization Mode"},font="Arial"
	PopupMenu popup0,mode=1,popvalue="Radial",value= #"\"Radial;Xpol;Ypol\""
	PopupMenu Popup_WL,pos={220,8},size={124,23},proc=Pop_ChangeWL,title="Wavelength"
	PopupMenu Popup_WL,font="Arial"
	PopupMenu Popup_WL,mode=1,popvalue="800",value= #"Gen_WavelengthList(\"W_LCDSettings\", \"S_ListWL\")"
EndMacro

Function /S Gen_WavelengthList(S_RefWave, S_ListWL)//popup menue generator
	//In this proceasure, 
	//S_RefWave="W_LCDSettings"
	//S_ListWL="S_ListWL"
	String S_RefWave, S_ListWL
	Svar L_ListWL=$S_ListWL
	wave W_RefWave=$S_RefWave
	//print dimsize(W_RefWave, 0)
	Variable i
	for(i=0, L_ListWL=""; i<dimsize(W_RefWave, 0); i+=1)
		L_ListWL+=";"+num2str(W_RefWave[i][0])
	endfor
	return L_ListWL
end


Function GenVolSet(S_ListCell2Ch, V_Wavelength, F_PolMode)
	String S_ListCell2Ch
	Variable V_Wavelength, F_PolMode
	Variable i
	wave W_LCDSettings
	FindValue /V=(V_Wavelength) /Z W_LCDSettings
	Make/O/N=16 LCD_amp_ch=0
	switch(F_PolMode)	//
		case 1://RadiallyPolarizationMode
			//LCD_amp_ch[str2num(StringFromList(p, S_ListCell2Ch))]=W_LCDSettings[V_value][p+3]
			i=0
			do 
				LCD_amp_ch[str2num(StringFromList(i, S_ListCell2Ch))-8]=W_LCDSettings[V_value][i+3]
				//print str2num(StringFromList(i, S_ListCell2Ch))-8,W_LCDSettings[V_value][i+3]
				i+=1
			while(i<16)
			return 1
			break
		case 2:// X-PolarizationMode(onMicroscope)
			LCD_Control_makeLine(W_LCDSettings[V_value][1], W_LCDSettings[V_value][2])
			return 2
			break
		case 3:// Y-PolarizationMode(onMicroscope)
			LCD_Control_makeLine(W_LCDSettings[V_value][1], W_LCDSettings[V_value][1])
			return 3
			break
		default:							// optional default expression executed
			print "invalied flag"
			abort 
	endswitch
	
	Variable/G  LCD_Frequency=1000
	Variable/G  LCD_Ctrl_Status=0    // 0: stop,   1: working
	String/G    Device="Dev4"
end

Function GenChVset(S_Basename, V_Wavelength)
	String S_Basename
	Variable V_Wavelength
	Variable i
	variable /G F_PhaseInversion
	wave W_LCDSettings//W_LCDVoltages={V_WaveLength, V_x, V_y, V_Cell1, V_Cell2, V_Cell3, V_Cell4, V_Cell5, V_Cell6, V_Cell7, V_Cell8, V_Cell9, V_Cell10, V_Cell11, V_Cell12, V_Cell13, V_Cell14, V_Cell15, V_Cell16}
	AddLCDSettings(V_Wavelength)
	FindValue /V=(V_Wavelength) /Z W_LCDSettings
	
	for(i=0; i<8; i+=1)//Phase control
	//print "Phase ",i
		if(F_PhaseInversion)
			W_LCDSettings[V_value][10-i]=Retardation2Voltage(S_Basename+"_"+num2str(V_Wavelength)+"nm_PolDir_SS", (22.5+45*i)*pi/180)
		else
			W_LCDSettings[V_value][i+3]=Retardation2Voltage(S_Basename+"_"+num2str(V_Wavelength)+"nm_PolDir_SS", (22.5+45*i)*pi/180)
		endif
	endfor
	for(i=0; i<4; i+=1)//polarization control
		//print "polarization ", i, i+4
		W_LCDSettings[V_value][i+11]=Retardation2Voltage(S_Basename+"_"+num2str(V_Wavelength)+"nm_PolDir_SS", 2*(22.5+45*i)*pi/180)
		W_LCDSettings[V_value][i+15]=Retardation2Voltage(S_Basename+"_"+num2str(V_Wavelength)+"nm_PolDir_SS", 2*(22.5+45*i)*pi/180)
	endfor
		W_LCDSettings[V_value][1]=Retardation2Voltage(S_Basename+"_"+num2str(V_Wavelength)+"nm_PolDir_SS", 0)
		W_LCDSettings[V_value][2]=Retardation2Voltage(S_Basename+"_"+num2str(V_Wavelength)+"nm_PolDir_SS", pi)
end


//Function /S GenCorrTable(S_ListCh)
	//S_ListCh:	Channel Number connected by i th Cell
	//A String S_ListCh is required
//	String S_ListCh
//	String S_Output
//	Variable i
//	if(ItemsInList(S_ListCh)!=16)
//		print "Input Lists is invalid..."
//		return ""
//	endif
//	for(i=0; i<ItemsInList(S_ListCh); i+=1, S_Output+=";")
//		S_Output+=StringFromList(i, S_ListCh)
//	endfor
//	return S_Output
//end


Function Pop_ChangeWL(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	Variable /G V_Wavelength=str2num(popStr)
End



Function LCD_Control_pol(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable /G F_PolMod
	string /G S_PolMod
	Svar S_ListCell2Ch
	Nvar V_Wavelength
	F_PolMod=popNum
	S_PolMod=popStr
	GenVolSet(S_ListCell2Ch, V_Wavelength, popNum)
end








Function LCD_Ctrl_ButtonProc(ctrlName) : ButtonControl
	String ctrlName
	Variable ch
	String Mess = ""
	Nvar status=$"LCD_Ctrl_Status"
	Nvar Freq=$"LCD_Frequency"
	Svar device_name=$"Device"
	wave  LCD_amp_ch=$"LCD_amp_ch"
	
	if(status == 0)
		for(ch=8; ch <24; ch +=1)
			make/O/N=(200)  $"LCD_Ctrl_Wave"+num2str(ch)
			SetScale/P x 0,5e-6,"s" $"LCD_Ctrl_Wave"+num2str(ch)
			wave w=$"LCD_Ctrl_Wave"+num2str(ch)
			w= LCD_amp_ch[ch-8]*sin(2*Pi*x*Freq)
			Mess = Mess + "LCD_Ctrl_Wave"+num2str(ch)+","+num2str(ch) +";"
		endfor
		DAQmx_WaveformGen/DEV=device_name Mess
		Button LCD_Ctrl,pos={266,70},size={80,30},proc=LCD_Ctrl_ButtonProc,title="Stop", fColor=(65280,48896,48896),win=LCD_Control
		//print "Running"
		status=1
	else
		fDAQmx_WaveformStop(device_name)
		Button LCD_Ctrl,pos={266,70},size={80,30},proc=LCD_Ctrl_ButtonProc,title="Ctrl",fColor=(0,0,0), win=LCD_Control
		for(ch=8; ch <24; ch+=1)
			fDAQmx_WriteChan(device_name, ch, 0, -10, 10)
		endfor
		//print "Stop"
		status=0
	endif
End




Function C_PhaseInv(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	variable /G F_PhaseInversion
	Nvar V_Wavelength, F_PolMod
	Svar S_PolMod
	F_PhaseInversion=checked
	GenChVset("D061125", V_Wavelength)
	LCD_Control_pol("C_PhaseInv", F_PolMod, S_PolMod)
	// Basename is unchangable in GenChVset("D061111", V_Wavelength)
End
