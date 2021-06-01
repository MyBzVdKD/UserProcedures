#pragma rtGlobals=1		// Use modern global access method.

variable /G V_CountPeriod, V_DwellTime
variable /G V_DiscrLV,V_Offset,V_DwellTime,V_CountPeriod

variable /G V_T_SR400_SelectCounter

function SR400_RestrictInputSources(ctrlName)
	String ctrlName
	variable F_CountMode=SR400_GetConfig(2)//CountMode
	Nvar F_Counter=$"V_T_SR400_SelectCounter"
	if(F_Counter==0)//Tab=CounterA
		SetVariable ContPeriod disable=1, win=SR400_PhotonCounter
		return 0//Tab=CounterA
	endif
	switch(F_CountMode)//CountMode
	case 0://preset T
	case 1://preset T
	case 2://preset T
		TabControl TB_SelectCounter value=F_Counter,tabLabel(2)="CounterT", win=SR400_PhotonCounter
		if(F_Counter==1)//Tab=CounterB
			SetVariable ContPeriod disable=1, win=SR400_PhotonCounter
		else 
			SetVariable ContPeriod disable=0, win=SR400_PhotonCounter
		endif

		return 1//preset T
	case 3://preset B
		if(F_Counter==2)//Tab=CounterT
			PopupMenu InputSource disable=1, win=SR400_PhotonCounter
			SetVariable ContPeriod disable=1, win=SR400_PhotonCounter
			F_Counter=0
		else
			SetVariable ContPeriod disable=0, win=SR400_PhotonCounter
			PopupMenu InputSource disable=0, win=SR400_PhotonCounter
		endif
		TabControl TB_SelectCounter value=F_Counter,tabLabel(2)="", win=SR400_PhotonCounter
		return 2//preset B
	default:
		print "Error_SR400 in [SR400_RestrictInputSources]"
		return nan
	endswitch
end

Window SR400_PhotonCounter() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1351,126,1940,542)
	ShowTools
	SetDrawLayer UserBack
	DrawRect 26,71,258,363
	DrawRect 383,279,528,391
	DrawRect 34,210,249,355
	SetVariable SR400_DiscrLevel,pos={34,80},size={151,18},proc=SV_SR400_DiscrLevel,title="DiscrLevel"
	SetVariable SR400_DiscrLevel,labelBack=(65535,65535,65535),font="Arial"
	SetVariable SR400_DiscrLevel,format="%.1W0PV"
	SetVariable SR400_DiscrLevel,limits={-0.3,0.3,0.0002},value= W_SR400_StatusValue[25]
	ValDisplay VD_IntensityOffset,pos={201,20},size={124,17},title="Offset"
	ValDisplay VD_IntensityOffset,font="Arial",format="%.1W0PV"
	ValDisplay VD_IntensityOffset,limits={0,0,0},barmisc={0,1000},value= #"V_Offset"
	ValDisplay VD_SR400_GPIBNo,pos={279,147},size={126,17},title="CounterGPIB"
	ValDisplay VD_SR400_GPIBNo,font="Arial",format="%g"
	ValDisplay VD_SR400_GPIBNo,limits={0,0,0},barmisc={0,1000}
	ValDisplay VD_SR400_GPIBNo,value= #"W_SR400_StatusValue[1]"
	SetVariable DwellTime,pos={279,171},size={131,18},proc=SV_SR400_DwellTime,title="DwellTime"
	SetVariable DwellTime,font="Arial",format="%.1W0Ps"
	SetVariable DwellTime,limits={0.002,60,0.001},value= W_SR400_StatusValue[8]
	SetVariable ContPeriod,pos={32,147},size={219,18},proc=SV_SR400_CountingPeriod,title="CountPeriod (preset)"
	SetVariable ContPeriod,labelBack=(65535,65535,65535),font="Arial"
	SetVariable ContPeriod,format="%g counts"
	SetVariable ContPeriod,limits={1e-07,90000,0.001},value= V_CountPeriod
	PopupMenu CountingDigit,pos={273,119},size={153,23},proc=PM_SR400_CountingRange,title="CountingDigit(<1E)"
	PopupMenu CountingDigit,font="Arial"
	PopupMenu CountingDigit,mode=7,popvalue="4",value= #"\"10;9;8;7;6;5;4;LOG\""
	PopupMenu CountMode,pos={18,17},size={148,23},proc=PM_SR400_CountMode,title="CountMode"
	PopupMenu CountMode,font="Arial"
	PopupMenu CountMode,mode=1,popvalue="A, BforT",value= #"\"A, BforT;A-BforT;A+BforT;AforB\""
	TabControl TB_SelectCounter,pos={26,51},size={234,21},proc=T_SR400_SelectCounter
	TabControl TB_SelectCounter,font="Arial",tabLabel(0)="CounterA"
	TabControl TB_SelectCounter,tabLabel(1)="CounterB",tabLabel(2)="CounterT"
	TabControl TB_SelectCounter,value= 2
	PopupMenu InputSource,pos={35,123},size={147,23},proc=PM_SR400_InputSource,title="InputSource"
	PopupMenu InputSource,font="Arial"
	PopupMenu InputSource,mode=2,popvalue="INPUT2",value= #"\"10MHz(internal);INPUT2;TRIG\""
	TabControl TB_BackPortSelect,pos={383,257},size={145,24},proc=T_SR400_SelectBackPort
	TabControl TB_BackPortSelect,font="Arial",tabLabel(0)="Port1"
	TabControl TB_BackPortSelect,tabLabel(1)="Port2",value= 1
	SetVariable NPeriods,pos={271,101},size={164,18},proc=SV_SR400_NPeriods,title="Number of Periods"
	SetVariable NPeriods,font="Arial"
	SetVariable NPeriods,limits={0,2000,1},value= W_SR400_StatusValue[6]
	CheckBox ContMode,pos={278,79},size={78,15},proc=CP_SR400_CycleMode,title="CycleMode"
	CheckBox ContMode,font="Arial",value= 0
	PopupMenu DA_out,pos={279,55},size={108,23},proc=PM_SR400_DASource,title="D/A Output"
	PopupMenu DA_out,font="Arial",mode=1,popvalue="A",value= #"\"A;B\""
	CheckBox DisplayMode,pos={358,78},size={85,15},proc=CP_SR400_DisplayMode,title="HoldDisplay"
	CheckBox DisplayMode,font="Arial",value= 0
	PopupMenu DscrSlope,pos={34,101},size={125,23},proc=PM_SR400_DscrSlope,title="DscrSlope"
	PopupMenu DscrSlope,font="Arial",mode=1,popvalue="RISE",value= #"\"RISE;FALL\""
	CheckBox SR400_GPIB,pos={348,21},size={46,15},proc=C_SR400_GPIB,title="GPIB"
	CheckBox SR400_GPIB,font="Arial",value= 1
	Button GetCurrentConfig,pos={404,21},size={128,19},proc=BP_SR400_GetCurrentConfig,title="Get Current Config"
	Button GetCurrentConfig,font="Arial"
	CheckBox Scan,pos={44,174},size={46,15},proc=C_SR400_ScanMode,title="Scan"
	CheckBox Scan,font="Arial",value= 0
	CheckBox ExternalDwell,pos={413,172},size={62,15},title="External",font="Arial"
	CheckBox ExternalDwell,value= 0
	Button SR400_Initialize,pos={487,52},size={50,20},proc=BP_SR400_GPIBinit,title="Initialize"
	Button SR400_Initialize,font="Arial"
	Button SR400_Start,pos={489,81},size={50,20},proc=BP_SR400_StartCount,title="Start"
	Button SR400_Start,font="Arial"
	Button SR400_Stop,pos={489,110},size={50,20},proc=BP_SR400_StopCount,title="Stop"
	Button SR400_Stop,font="Arial"
	SetVariable SR400_ScanStep,pos={109,173},size={141,18},proc=SV_SR400_ScanStep,title="ScanStep"
	SetVariable SR400_ScanStep,labelBack=(65535,65535,65535),font="Arial"
	SetVariable SR400_ScanStep,format="%.1W0PV"
	SetVariable SR400_ScanStep,limits={-0.02,0.02,0.0002},value= W_SR400_StatusValue[22]
	Button StartScan,pos={471,137},size={72,21},proc=BP_SR400_ScanStart,title="StartScan"
	Button StartScan,font="Arial"
	PopupMenu SR400_GateMode,pos={43,216},size={115,23},disable=1,proc=PM_SR400_GateMode,title="GateMode"
	PopupMenu SR400_GateMode,font="Arial"
	PopupMenu SR400_GateMode,mode=1,popvalue="CW",value= #"\"CW;FIXED;SCAN\""
	SetVariable SR400_GeteScanStep,pos={43,246},size={135,18},disable=1,proc=SV_SR400_GateScanStep,title="ScanStep"
	SetVariable SR400_GeteScanStep,labelBack=(65535,65535,65535),font="Arial"
	SetVariable SR400_GeteScanStep,format="%.1W0Ps"
	SetVariable SR400_GeteScanStep,limits={0,0.09992,0.001},value= W_SR400_StatusValue[36]
	SetVariable SR400_GeteScanSt01,pos={44,294},size={147,18},disable=1,proc=SV_SR400_GatePosition,title="ScanPosition"
	SetVariable SR400_GeteScanSt01,labelBack=(65535,65535,65535),font="Arial"
	SetVariable SR400_GeteScanSt01,format="%.1W0Ps"
	SetVariable SR400_GeteScanSt01,limits={0,0.09992,0.001},value= W_SR400_StatusValue[38]
	SetVariable SR400_GeteWidth,pos={42,270},size={135,18},disable=1,proc=SV_SR400_GateWidth,title="GateWidth"
	SetVariable SR400_GeteWidth,labelBack=(65535,65535,65535),font="Arial"
	SetVariable SR400_GeteWidth,format="%.1W0Ps"
	SetVariable SR400_GeteWidth,limits={0,0.09992,0.0001},value= W_SR400_StatusValue[40]
EndMacro





Function T_SR400_SelectBackPort(ctrlName,tabNum) : TabControl
	String ctrlName
	Variable tabNum
	switch(tabNum)
	case 0:
		
		break
	case 1:
		
		break
	default:
		print "Error_SR400 in [T_SR400_SelectBackPort]"
		return nan
	endswitch
	return tabNum
End



Function T_SR400_SelectCounter(ctrlName,tabNum) : TabControl
	String ctrlName
	Variable tabNum
	Variable /G V_T_SR400_SelectCounter=tabNum
	
	switch(tabNum)
	case 0://
		PopupMenu InputSource value="10MHz(internal);INPUT1", win=SR400_PhotonCounter
		PopupMenu SR400_GateMode disable=0, win=SR400_PhotonCounter
		SetVariable SR400_GeteScanStep disable=0, win=SR400_PhotonCounter
		SetVariable SR400_GeteScanSt01 title="ScanPosition",disable=0, win=SR400_PhotonCounter
		SetVariable SR400_GeteWidth disable=0
		break
	case 1://
		PopupMenu InputSource value="INPUT1;INPUT2", win=SR400_PhotonCounter
		PopupMenu SR400_GateMode disable=0, win=SR400_PhotonCounter
		SetVariable SR400_GeteScanStep disable=0, win=SR400_PhotonCounter
		SetVariable SR400_GeteScanSt01 title="ScanPosition",disable=0, win=SR400_PhotonCounter
		SetVariable SR400_GeteWidth disable=0
		break
	case 2://
		PopupMenu InputSource value="10MHz(internal);INPUT2;TRIG", win=SR400_PhotonCounter
		PopupMenu SR400_GateMode disable=1, win=SR400_PhotonCounter
		SetVariable SR400_GeteScanStep disable=1, win=SR400_PhotonCounter
		SetVariable SR400_GeteScanSt01 title="ScanPosition",disable=1, win=SR400_PhotonCounter
		SetVariable SR400_GeteWidth disable=1
		break
	default:
		print "Error_SR400 in [T_SR400_SelectCounter]"
		return nan
	endswitch
	execute "SetVariable SR400_DiscrLevel value=W_SR400_StatusValue["+num2str(23+tabNum)+"]"
	
	wave W_SR400_StatusValue
	SetVariable SR400_DiscrLevel value=W_SR400_StatusValue[23+tabNum], win=SR400_PhotonCounter
	PopupMenu DscrSlope mode=W_SR400_StatusValue[14+tabNum]+1, win=SR400_PhotonCounter
	PopupMenu InputSource mode=W_SR400_StatusValue[3+tabNum]+1, win=SR400_PhotonCounter//W_SR400_StatusValue[3+tabNum]‚Æ‚Ì®‡«
	SR400_RestrictInputSources("T_SR400_SelectCounter")
	C_SR400_ScanMode("T_SR400_SelectCounter",SR400_GetConfig(17+tabNum))
	SetVariable SR400_ScanStep value=W_SR400_StatusValue[20+tabNum], win=SR400_PhotonCounter
	PopupMenu SR400_GateMode mode=W_SR400_StatusValue[32+tabNum]+1, win=SR400_PhotonCounter
	SetVariable SR400_GeteScanStep value=W_SR400_StatusValue[34+tabNum], win=SR400_PhotonCounter
	SetVariable SR400_GeteScanSt01 title="ScanPosition",value=W_SR400_StatusValue[36+tabNum], win=SR400_PhotonCounter
	SetVariable SR400_GeteWidth value=W_SR400_StatusValue[38+tabNum], win=SR400_PhotonCounter
	PopupMenu InputSource mode=SR400_ConvInputSourceNo(ctrlName, W_SR400_StatusValue[3+tabNum]), win=SR400_PhotonCounter
	return tabNum
End


Function PM_SR400_DscrSlope(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable I_config=14
	Nvar F_Counter=$"V_T_SR400_SelectCounter"
	SR400_OverWriteConfig(I_config+F_Counter, popNum-1)
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	variable F_stats	
	F_stats=SR400_DscrSlope("PM_SR400_DscrSlope", popNum-1, F_Counter, 0, F_GPIB)
	SR400_OverWriteConfig(I_config+F_Counter, F_stats)
End

Function BP_SR400_GetCurrentConfig(ctrlName) : ButtonControl
	String ctrlName

End



Function SR400_ConvInputSourceNo(ctrlName, F_InputSource)
	String ctrlName
	variable F_InputSource
	variable F_PMnumber
	Nvar F_Counter=$"V_T_SR400_SelectCounter"
	switch(F_InputSource)
		case 0://10MHz(internal)
			if(F_Counter==0)//counterA
				F_PMnumber=1
			elseif(F_Counter==2)//counterT
				F_PMnumber=1
			endif
			break
		case 1://"INPUT1"
			if(F_Counter==0)//counterA
				F_PMnumber=2
			elseif(F_Counter==1)//counterB
				F_PMnumber=1
			endif
			break
		case 2://"INPUT2"
			if(F_Counter==1)//counterB
				F_PMnumber=2
			elseif(F_Counter==2)//counterT
				F_PMnumber=2
			endif
			break
		case 3://"TRIG"
			if(F_Counter==2)//counterT
				F_PMnumber=3
			endif
			break
		default:
	endswitch
	return F_PMnumber
end


Function PM_SR400_CountMode(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable I_config=2//CountMode
	variable F_stats
	SR400_OverWriteConfig(I_config, popNum-1)
	SR400_RestrictInputSources("PM_SR400CountMode")
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	F_stats=SR400_CntMode("PM_CntMode", popNum-1, 0, F_GPIB)
	SR400_OverWriteConfig(I_config, F_stats)
	PopupMenu CountMode mode=F_stats+1, win=SR400_PhotonCounter
	variable F_PMdisable, F_PMmode
	F_PMmode=SR400_DASource("PM_SR400_CountMode", "", F_GPIB, 1)+1
	switch(F_stats)
		case 0:
			F_PMdisable=0
			PopupMenu DA_out disable=F_PMdisable, mode=F_PMmode ,value="A;B", win=SR400_PhotonCounter
			break
		case 1:
		case 2:
		case 3:
			F_PMdisable=2
			PopupMenu DA_out disable=F_PMdisable, mode=F_PMmode ,value="A;B;A-B;A+B", win=SR400_PhotonCounter
			break
		default:
			print "error: in PM_SR400_CountMode"
	endswitch
End

Function PM_SR400_DASource(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable I_config=9//DASource
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	variable F_stats
	SR400_OverWriteConfig(I_config, popNum-1)
	F_stats=SR400_DASource("PM_CntMoT A L ~ 3 . H T M       ïˆ    p Z     ’„    kà€ƒÉQ ¸)JÉkà€ƒÉê\Å¨‰êÊ        &1             I N S T A L ~ 4 . H T M       ðˆ    ˜ „     ’„    kà€ƒÉQ ¸)JÉkà€ƒÉD¿Ç¨‰êÊ       (             !I n t e r l e a v e d - a n d - s p l i t - a r r a y s . h t m l     ðˆ    p Z     ’„    kà€ƒÉQ ¸)JÉkà€ƒÉD¿Ç¨‰êÊ       (             I N T E R L ~ 1 . H T M       ñˆ    x d     ’„    kà€ƒÉQ ¸)JÉkà€ƒÉž!Ê¨‰êÊ        s*             I n t r o d u c t i o n . h 
 on CP_SR400_DisplayMode(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	variable I_config=11//DisplayMode
	variable F_stats
	F_stats=SR400_DisplayMode("CP_SR400_DisplayMode", checked, 0, F_GPIB)
	CheckBox DisplayMode value=F_stats
	SR400_OverWriteConfig(I_config, F_stats)
End

Function PM_SR400_CountingRange(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	variable I_config=10
	variable F_stats
	if(F_GPIB)
		variable V_DevNo=SR400_GetConfig(1)//GPIB_DevNo
	endif
	if (popNum>0&&popNum<8)
		if(F_GPIB)
			SR400_GPIBDevSelect("PM_SR400_CountingRange")
			F_stats=SR400_CountingRange("PM_SR400_CountingRange", popNum, 0, F_GPIB)
		else
		endif
	elseif(popNum==8)
		if(F_GPIB)
			SR400_GPIBDevSelect("PM_SR400_CountingRange")
			F_stats=SR400_CountingRange("PM_SR400_CountingRange", 0, 0, F_GPIB)
		else
		endif
	else
		F_stats=SR400_CountingRange("PM_SR400_CountingRange", 0, 1, F_GPIB)
		print "[SR400_PM_CountingRange] parameter is invalid"
	endif
	SR400_OverWriteConfig(I_config, F_stats)
End


Function C_SR400_GPIB(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	variable I_config=41
	SR400_OverWriteConfig(I_config, checked)
	if(checked)
		BP_SR400_GPIBinit("C_SR400_GPIB")
	endif
End
 

Function C_SR400_ScanMode(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	Nvar F_Counter=$"V_T_SR400_SelectCounter"
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	variable I_config=17//DscrScan
	variable F_stats
	F_stats=SR400_ScanMode("C_SR400_ScanMode", F_Counter, checked, 0, F_GPIB)
	SR400_OverWriteConfig(I_config+F_Counter, F_stats)
	CheckBox Scan value=F_stats, win=SR400_PhotonCounter
End

Function SV_SR400_ScanStep(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	Nvar F_Counter=$"V_T_SR400_SelectCounter"
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	variable I_config=20//DscrScan
	variable V_stats
	V_stats=SR400_ScanStep("SV_SR400_ScanStep", F_Counter, varNum, 0, F_GPIB)
	SR400_OverWriteConfig(I_config+F_Counter, V_stats)
End


Function SV_SR400_CountingPeriod(ctrlName,varNum,varStr,varName) : SetVariableControl
	//V_CountPeriod is necessary
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	variable I_config=3//InputSource
	Nvar F_Counter=$"V_T_SR400_SelectCounter"
	Nvar V_indicator=$"V_CountPeriod"
	variable V_stats
	variable F_PeriodSource=SR400_GetConfig(I_config+F_Counter)
	//print varNum*(1e7)^(F_PeriodSource==0), varNum,(F_PeriodSource==0)
	V_stats=SR400_CntPreset("SV_CountingPeriod", F_Counter, varNum*(1e7)^(F_PeriodSource==0), 0, F_GPIB)
	//print "SV_CountingPeriod", F_Counter, varNum*(1e7)^(F_PeriodSource==0), 0, F_GPIB,V_stats
	BP_SR400_StartCount("SV_DwellTime") 
	SR400_OverWriteConfig(42, V_stats)
	V_indicator=V_stats/(1e7)^(F_PeriodSource==0)
	return V_stats
End

Function SR400_UnitChange_CountPeriods(ctrlName)
	String ctrlName
	variable I_config=3//InputSource
	Nvar F_Counter=$"V_T_SR400_SelectCounter"
	variable F_PeriodSource=SR400_GetConfig(I_config+F_Counter)
	if(F_PeriodSource)
		SetVariable ContPeriod format="%g counts", win=SR400_PhotonCounter
	else
		SetVariable ContPeriod format="%.1W0Ps", win=SR400_PhotonCounter
	endif
end

Function CP_SR400_CycleMode(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	variable I_config=7//EndOfScanMode
	variable F_stats
	F_stats=SR400_CycleMode("CP_SR400_CycleMode", checked, 0, F_GPIB)
	CheckBox ContMode value=F_stats
	SR400_OverWriteConfig(I_config, F_stats)
End

Function BP_SR400_ScanStart(ctrlName) : ButtonControl
	String ctrlName
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	SR400_ScanStart("BP_SR400_ScanStart", "test", 1, F_GPIB)	
End

Function SV_SR400_DwellTime(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	variable I_config=8//DwellTime
	variable V_stats
	V_stats=SR400_DwellTime("SV_DwellTime", varNum, 0, F_GPIB)
	SR400_OverWriteConfig(I_config, V_stats)
	BP_SR400_StartCount("SV_DwellTime")
End


Function PM_SR400_GateMode(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable I_config=32//GateMode
	variable F_stats
	Nvar F_Counter=$"V_T_SR400_SelectCounter"
	SR400_OverWriteConfig(I_config+F_Counter, popNum-1)
	SR400_RestrictInputSources("PM_SR400_GateMode")
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	F_stats=SR400_GateMode("PM_SR400_GateMode", F_Counter, popNum-1, 0, F_GPIB)
	SR400_OverWriteConfig(I_config+F_Counter, F_stats)
	PopupMenu SR400_GateMode mode=F_stats+1, win=SR400_PhotonCounter
End



Function SV_SR400_GateScanStep(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	variable I_config=34//GateDelayScanStep
	Nvar F_Counter=$"V_T_SR400_SelectCounter"
	variable V_stats
	V_stats=SR400_GateScanStep("SV_SR400_GateScanStep", F_Counter, varNum, 0, F_GPIB)
	SR400_OverWriteConfig(I_config+F_Counter, V_stats)
End



Function SV_SR400_GatePosition(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	variable I_config=36//GateDelayScanStep
	Nvar F_Counter=$"V_T_SR400_SelectCounter"
	variable V_stats
	V_stats=SR400_GatePosition("SV_SR400_GatePosition", F_Counter, varNum, 0, F_GPIB)
	SR400_OverWriteConfig(I_config+F_Counter, V_stats)
	
End

Function SV_SR400_GateWidth(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	variable I_config=38//GateDelayScanStep
	Nvar F_Counter=$"V_T_SR400_SelectCounter"
	variable V_stats
	V_stats=SR400_GateWidth("SV_SR400_GateWidth", F_Counter, varNum, 0, F_GPIB)
	print I_config+F_Counter, V_stats
	SR400_OverWriteConfig(I_config+F_Counter, V_stats)
End


Function SV_SR400_DiscrLevel(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable I_config=23//DscrLevel
	Nvar F_Counter=$"V_T_SR400_SelectCounter"
	variable V_stats
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	V_stats=SR400_DiscrLevel("SR400_DiscrLevel", varNum, F_Counter, 0, F_GPIB)
	SR400_OverWriteConfig(I_config+F_Counter, V_stats)
End

Function PM_SR400_InputSource(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	variable F_GPIB=SR400_GetConfig(41)//GPIBFlag
	variable I_config=3//InputSource
	variable F_stats
	Nvar F_Counter=$"V_T_SR400_SelectCounter"
	SR400_OverWriteConfig(I_config+F_Counter, popNum-1)
	F_stats=SR400_InputSource("PM_SR400_InputSource", F_Counter, popStr, 0, F_GPIB)
	PopupMenu InputSource mode=SR400_ConvInputSourceNo(ctrlName, F_stats), win=SR400_PhotonCounter
	SR400_UnitChange_CountPeriods("PM_SR400_InputSource")
	SR400_OverWriteConfig(I_config+F_Counter, F_stats)
	//Change the Unit of Preset
	if(F_Counter==2)
		Nvar V_indicator=$"V_CountPeriod"
		V_indicator=SR400_CntPreset("PM_SR400_InputSource", F_Counter, 1, 1, F_GPIB)/(1e7)^(F_stats==0)
	endif
End
