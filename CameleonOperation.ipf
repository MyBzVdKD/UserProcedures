#pragma rtGlobals=1

//////////////////////////////////////////////////////
// Programme for running chameleon
// 
// Made by    R. KANAMARU
// Date       21/Sep/2006
// Copyright(C) 2006 Marunaka Factory
// All Rights reserved.
//
/////////////////////////////////////////////////////
Function CameleonGetParams(ctrlName) : ButtonControl
	String ctrlName
	variable/G F_Chameleon_Shutter=DS_Read("?S")//0: closed 1: open
	variable/G F_Chameleon_RUNNING=DS_Read("?L")//0: Standby 1: ON 2: OFF due to a fault
	//variable/G F_Chameleon_FRONTPANEL=DS_Read("?LFP")
	variable/G V_Chameleon_WAVELENGTH=DS_Read("?VW")
	variable/G V_Chameleon_LBOTemperture=DS_Read("?LBOT")
	variable/G V_Chameleon_Diode1Curr=DS_Read("?d1c")
	variable/G V_Chameleon_Diode2Curr=DS_Read("?d2c")
	variable/G V_Chameleon_Power=DS_Read("?UF")
	variable/G V_Chameleon_Diode1RunT=DS_Read("?d1h")
	variable/G V_Chameleon_Diode2RunT=DS_Read("?d2h")
	variable/G V_Chameleon_Diode1Tmp=DS_Read("?d1t")
	variable/G V_Chameleon_Diode2Tmp=DS_Read("?d2t")
	variable/G V_Chameleon_Diode1SetTmp=DS_Read("?d1st")
	variable/G V_Chameleon_Diode2SetTmp=DS_Read("?d2st")
	variable/G V_Chameleon_HeadRunT=DS_Read("?hh")
	variable/G F_Chameleon_Modelock=DS_Read("?MDLK")//0:off, 1: OK, 2: CW
	GetTimes("CameleonGetParams")
	//ConstructDatabase("CameleonGetParams")
end

Function ConstructDatabese(ctrlName) : ButtonControl//now constructing
	String ctrlName
	Nvar V_Chameleon_LBOTemperture, V_Chameleon_Diode1Curr, V_Chameleon_Diode2Curr, V_Chameleon_WAVELENGTH
	Nvar V_Chameleon_Power, V_Chameleon_Diode1RunT, V_Chameleon_Diode2RunT, V_Chameleon_Diode1Tmp
	Nvar V_Chameleon_Diode2Tmp, V_Chameleon_Diode1SetTmp, V_Chameleon_Diode2SetTmp, V_Chameleon_HeadRunT
	//make 
end

Function/S GetTimes(ctrlName) : ButtonControl
	String ctrlName
	string/G S_Date=Secs2Date(DateTime,-1)
	string/G S_Time=time()
	variable/G V_hours=str2num(stringfromlist(0, S_Time, ":"))
	variable/G V_minutes=str2num(stringfromlist(1, S_Time, ":"))
	variable/G V_seconts=str2num(stringfromlist(2, S_Time, ":"))
	variable/G V_date=str2num(stringfromlist(0, S_Date, "/"))
	variable/G V_month=str2num(stringfromlist(1, S_Date, "/"))
	variable/G V_year=str2num(stringfromlist(0, stringfromlist(2, S_Date, "/"), " "))
	//print S_Date, S_Time
	//print V_year, V_month, V_date, V_hours, V_minutes, V_seconts
	return S_Date+S_Time
end


Function DS_comm_init(ctrlName) : ButtonControl    // Initialization of RS-232C
	string ctrlName
	VDT2 /P=COM1 baud=19200, buffer=4096, databits=8, echo=0, in=0, killio, out=0, parity=0, rts=0, stopbits=1, terminalEOL=2, line=1
//	DS_Write("SERIAL BAUDRATE=19200")
End


Window Chameleon_MainWindow() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(98,172,532,390)
	ShowTools
	SetDrawLayer UserBack
	DrawRect 149,2,392,181
	DrawRect 5,48,136,119
	CheckBox Chameleon_RUNNING,pos={11,59},size={59,14},proc=Chameleon_RUNNINGControl,title="Running"
	CheckBox Chameleon_RUNNING,variable= F_Chameleon_RUNNING
	CheckBox Chameleon_Shutter,pos={11,79},size={55,14},proc=Chameleon_ShutterControl,title="Shutter"
	CheckBox Chameleon_Shutter,value= 1
	CheckBox Chameleon_FRONTPANEL,pos={11,100},size={105,14},proc=Chameleon_FRONTPANELControl,title="Lock Front Panel"
	CheckBox Chameleon_FRONTPANEL,value= 1
	SetVariable Chameleon_WAVELENGTH,pos={14,136},size={120,18},proc=Chameleon_WAVELENGTHControl,title="Wavelength"
	SetVariable Chameleon_WAVELENGTH,font="Arial"
	SetVariable Chameleon_WAVELENGTH,limits={715,955,1},value= V_Chameleon_WAVELENGTH
	ValDisplay Diode1_Current,pos={154,47},size={142,17},title="Diode1 Current"
	ValDisplay Diode1_Current,font="Arial",format="%g / A"
	ValDisplay Diode1_Current,limits={0,0,0},barmisc={0,1000}
	ValDisplay Diode1_Current,value= #"V_Chameleon_Diode1Curr"
	ValDisplay Diode2_Current,pos={154,64},size={140,17},title="Diode2 Current"
	ValDisplay Diode2_Current,font="Arial",format="%g / A"
	ValDisplay Diode2_Current,limits={0,0,0},barmisc={0,1000}
	ValDisplay Diode2_Current,value= #"V_Chameleon_Diode2Curr"
	Button Setting,pos={153,3},size={70,20},proc=CameleonVariables,title="Infomation"
	ValDisplay Chameleon_Power,pos={154,27},size={198,17},title="Chameleon_Power"
	ValDisplay Chameleon_Power,font="Arial",format="%g / mW"
	ValDisplay Chameleon_Power,limits={0,0,0},barmisc={0,1000}
	ValDisplay Chameleon_Power,value= #"V_Chameleon_Power"
	Button Chameleon_Synchronization,pos={27,37},size={85,20},proc=Chameleon_synchronization,title="Syncronization"
	Button Chameleon_TurnOff1,pos={18,159},size={99,20},proc=Chameleon_TurnOff_1,title="Shut down"
	ValDisplay RunningTime_Head,pos={154,81},size={213,17},title="RunningTime (Head)"
	ValDisplay RunningTime_Head,font="Arial",format="%g / hours"
	ValDisplay RunningTime_Head,limits={0,0,0},barmisc={0,1000}
	ValDisplay RunningTime_Head,value= #"V_Chameleon_HeadRunT"
	ValDisplay RunningTime_Diode1,pos={154,97},size={234,17},title="RunningTime (Diode1)"
	ValDisplay RunningTime_Diode1,font="Arial",format="%g / hours"
	ValDisplay RunningTime_Diode1,limits={0,0,0},barmisc={0,1000}
	ValDisplay RunningTime_Diode1,value= #"V_Chameleon_Diode1RunT"
	ValDisplay RunningTime_Diode2,pos={154,113},size={234,17},title="RunningTime (Diode2)"
	ValDisplay RunningTime_Diode2,font="Arial",format="%g / hours"
	ValDisplay RunningTime_Diode2,limits={0,0,0},barmisc={0,1000}
	ValDisplay RunningTime_Diode2,value= #"V_Chameleon_Diode2RunT"
	Button Init_COMport,pos={17,8},size={98,20},proc=DS_comm_init,title="Init COM port"
	Button Init_COMport,font="Arial"
	Button LaserON,pos={28,188},size={65,19},title="LaserON",font="Arial"
	ValDisplay Diode1_Temp,pos={153,133},size={142,17},title="Diode1 Temp"
	ValDisplay Diode1_Temp,font="Arial",format="%g",limits={0,0,0},barmisc={0,1000}
	ValDisplay Diode1_Temp,value= #"V_Chameleon_Diode1Tmp"
	ValDisplay Diode2_Tem,pos={152,151},size={142,17},title="Diode2 Temp"
	ValDisplay Diode2_Tem,font="Arial",format="%g",limits={0,0,0},barmisc={0,1000}
	ValDisplay Diode2_Tem,value= #"V_Chameleon_Diode2Tmp"
	ValDisplay Diode1_SetTemp,pos={306,132},size={77,17},title="Set",font="Arial"
	ValDisplay Diode1_SetTemp,format="%g",limits={0,0,0},barmisc={0,1000}
	ValDisplay Diode1_SetTemp,value= #"V_Chameleon_Diode1SetTmp"
	ValDisplay Diode2_SetTem1,pos={307,150},size={74,17},title="Set",font="Arial"
	ValDisplay Diode2_SetTem1,format="%g",limits={0,0,0},barmisc={0,1000}
	ValDisplay Diode2_SetTem1,value= #"V_Chameleon_Diode2SetTmp"
	ValDisplay ModeLocked,pos={231,6},size={89,14},title="ModeLocked"
	ValDisplay ModeLocked,labelBack=(65535,65535,65535),font="Arial",format="%g"
	ValDisplay ModeLocked,frame=0
	ValDisplay ModeLocked,limits={1,1.5,-1},barmisc={0,0},bodyWidth= 15,mode= 1,lowColor= (30464,30464,30464)
	ValDisplay ModeLocked,value= #"F_Chameleon_Modelock"
EndMacro


Window Chameleon_ShutDownWindow() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(527,66,855,262)
	ShowTools
	SetDrawLayer UserBack
	DrawText 40,40,"Cool-down cycle is in operation now"
	DrawText 60,50,"14:17:14"
	Button Chameleon_TurnOff2,pos={79,6},size={128,20},proc=Chameleon_TurnOff_2,title="Shut Down Start"
	ValDisplay Chameleon_LBOT,pos={52,66},size={198,18},title="LBO temperture"
	ValDisplay Chameleon_LBOT,fSize=16,format="%g / deg"
	ValDisplay Chameleon_LBOT,limits={0,0,0},barmisc={0,1000}
	ValDisplay Chameleon_LBOT,value= #"V_Chameleon_LBOTemperture"
EndMacro


Function Chameleon_ShutterControl(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	String mess
	variable /G V_Chameleon_Shutter
	V_Chameleon_Shutter=checked
	mess = "S="+num2str(V_Chameleon_Shutter)
	DS_Write(mess)
End




Function Chameleon_FRONTPANELControl(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	String mess
	Nvar value=$"Chameleon_FRONTPANEL"
	value=checked
	mess = "LFP="+num2str(value)
	DS_Write(mess)
End


Function Chameleon_WAVELENGTHControl(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	String mess
	Nvar value=$"Chameleon_WAVELENGTH"
	value=varNum
	mess="VW="+num2str(value)
	DS_Write(mess)
End


Function Chameleon_synchronization(ctrlName) : ButtonControl
	String ctrlName
	Nvar val=$"Chameleon_RUNNING"
	val   =DS_Read("?L")
	if(val==2)
		CheckBox Chameleon_Shutter,disable= val
	else
		CheckBox Chameleon_Shutter,value= val
	endif
	Nvar val=$"Chameleon_Shutter"
	val   =DS_Read("?S")
	CheckBox Chameleon_Shutter,value= val
	Nvar val=$"Chameleon_WAVELENGTH"
	Val   =DS_Read("?VW")
	CheckBox Chameleon_WAVELENGTH,value= val
End


Function Chameleon_Information(ctrlName) : ButtonControl
	String ctrlName
	ValDisplay Chameleon_Power value=DS_Read("?UF")
	ValDisplay Diode1_Current value=DS_Read("?d1c")
	ValDisplay Diode2_Current value=DS_Read("?d2c")
End


Function Chameleon_TurnOff_1(ctrlName) : ButtonControl
	String ctrlName
	
	Execute "Chameleon_ShutDownWindow()"

End


Function Chameleon_TurnOff_2(ctrlName) : ButtonControl
	String ctrlName
	String ans
	variable i, Time1, Time2
	variable RunTime =1*60*60
	Nvar temp=$"Chameleon_LBOTemperture"

	DS_comm_init("")
	
	// Start Time //
	ans = time()
	print ans
	Time1 = str2num(StringFromList(0,ans,":"))*60*60 + str2num(StringFromList(1,ans,":"))*60 + str2num(StringFromList(2,ans,":"))

	DrawText 40,40,"Cool-down cycle is in operation now"
	DrawText 60,50,ans
	ValDisplay Chameleon_LBOT,pos={52,66},size={198,21},title="LBO temperture"
	ValDisplay Chameleon_LBOT,fSize=16,limits={0,0,0},barmisc={0,1000},value= DS_Read("?LBOT")

	//LBO CoolDown : 0=cooldown, 1=heating//
	DS_Write("LBOH=0")
	
	do
		i=0
		do
			i=i+1
		while(i<10e7)
		temp=DS_Read("?LBOT")
		ValDisplay Chameleon_LBOT, value= DS_Read("?LBOT")
		if(temp>0)
		else
			temp=100
		endif
		
		//  operating time //
		ans = time()
		Time2 = str2num(StringFromList(0,ans,":"))*60*60 + str2num(StringFromList(1,ans,":"))*60 + str2num(StringFromList(2,ans,":"))
		If(Time2-Time1>RunTime)
			if(temp<40)
				break
			endif
		endif
	while(1)
	DrawText 40,150,"Cool-down cycle is ended"
	DrawText 60,160, ans
	DrawText 60,170, "LBO Temperture"+num2str(temp)
	DrawText 60,180, "Run Time"+num2str(Time2-Time1)
End

//_/_/_/_/_/_/_/_/RS-232C control_/_/_/_/_/_/_/_/_/_/_/_/_/
Function DS_Write(command)
	String command
	VDTWrite2/O=10 command+"\r\n"
End

Function DS_Read(command)
	String command
	String ans, ans2
	variable i
	VDTWrite2/Q/O=10 command+"\r\n" 
	VDTRead2/N=256/O=20/T="\n" ans
	VDTRead2/N=256/O=20/T="\n" ans2
	for(i=0;i<1e5;i+=1)
	endfor
//	print ans
//	print ans2
	//return str2num(StringFromList(0,ans2,"\r\n"))
	return str2num(ans2)
End

Function Chameleon_RUNNINGControl(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	String mess
	Nvar value=$"F_Chameleon_RUNNING"
	value=checked
	mess = "L="+num2str(value)
	DS_Write(mess)
End
