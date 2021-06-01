Function SR400_GPIBDevSelect(ctrlName)
	string ctrlName
	variable Dnum=SR400_GetConfig(1)//GPIB_DevNo
	GPIBDevSelect(Dnum)
end

Function SR400_GetConfig(V_No)
	variable V_No
	wave W_config=$"W_SR400_StatusValue"
	return W_config[V_No]
end

Function SR400_OverWriteConfig(V_No, V_Val)
	variable V_No, V_Val
	wave W_config=$"W_SR400_StatusValue"
	W_config[V_No]=V_Val
end

function BP_SR400_StartCount(ctrlName): ButtonControl
	string ctrlName
	variable F_GPIB=SR400_GetConfig(41)
	if(F_GPIB)
		SR400_GPIBDevSelect("SR400_DiscriminatorLevel")
		GPIBwriteCommand("SR400_StartCount", "CS", 1)
	else
		//RS232send(("SR400_StartCount", "CS"))
	endif
end

function BP_SR400_GPIBinit(ctrlName): ButtonControl
	string ctrlName
	variable V_DevNo=SR400_GetConfig(1)
	//make /O /n=(100) /T W_SR400_StatusName
	//make /O /n=(100) W_SR400_StatusValue
	wave /T W_GPIBDeVName
	W_GPIBDeVName[V_DevNo-1]="SR400"
	InitGPIB2BoardAndDevice("SR400_GPIBinit", 0, V_DevNo)
end


function SR400_DwellTime(ctrlName, V_DwellTime, F_ask, F_GPIB)
	//2E-3<V_DwellTime<6E1
	string ctrlName
	variable V_DwellTime, F_ask, F_GPIB
	string S_command="DT"
	if(2E-3>V_DwellTime&&V_DwellTime)
		print "DwellTime is too SHORT"
		F_ask=1
	elseif(V_DwellTime>6E1&&V_DwellTime)
		print "DwellTime is too LONG"
		F_ask=1
	endif
	if(F_GPIB)
		SR400_GPIBDevSelect("SR400_DiscriminatorLevel")
		if(F_ask==0)
			string S_param=num2str(V_DwellTime)
			GPIBwriteCommand("SR400_DwelllTime",S_command+S_param ,1)
		endif
		GPIBwriteCommand("SR400_DwelllTime",S_command ,1)
		return GPIBReadVal("SR400_DwelllTime",1 ,"")	
	else //RS232Mode
		//RS232send(("SR400_StopCount", "CH"))
	endif
end


function SR400_CntPreset(ctrlName, F_Counter, V_Preset, F_ask, F_GPIB)
	//V_CounterNo 0: A, 1: B, 2: T
	//1E-7<V_PresetTime(sec)<9E4
	string ctrlName
	variable F_Counter, V_Preset, F_ask, F_GPIB
	//print F_Counter, V_Preset, F_ask, F_GPIB
	if(1>V_Preset)
		print "Preset is too SHORT"
		F_ask=1
	elseif(V_Preset>9E11)
		print "Preset is too LONG"
		F_ask=1
	endif
	string S_command="CP"+num2str(F_Counter)
	if(F_GPIB) //GPIBMode
		SR400_GPIBDevSelect("SR400_CntPreset")
		if(F_ask==0)
			string S_param
			sprintf S_param, "%0.0f", V_Preset
			S_param=","+S_param
			GPIBwriteCommand("SR400_DscrSlope",  S_command+S_param, 1)
		endif
		GPIBwriteCommand("SR400_DscrSlope",S_command ,1)
		return GPIBReadVal("SR400_DscrSlope",1 ,"")
	else //RS232Mode
	endif
end

function SR400_DiscrLevel(ctrlName, V_DiscrLevel, F_Counter, F_ask, F_GPIB)
	string ctrlName
	variable V_DiscrLevel, F_Counter, F_ask, F_GPIB
	//-0.3000<=V_DiscrLevel<=0.3000
	//F_Channel: 0=A, 1=B, 2=T
	Variable F_SR400=SR400_GetConfig(41)
	string S_command=""
	if(-0.30001>V_DiscrLevel)
		print "SR400_DiscriminatorLevel is too SHORT"
		F_ask=1
	elseif(V_DiscrLevel>0.30001)
		print "SR400_DiscriminatorLevel is too LONG"
		F_ask=1
	endif
	if(F_GPIB) //GPIBMode
		SR400_GPIBDevSelect("SR400_DiscriminatorLevel")
		S_command="DL"+num2str(F_Counter)
		if(F_ask==0)
			string S_param=","+num2str(V_DiscrLevel)
			GPIBwriteCommand("SR400_DiscriminatorLevel",S_command+S_param , 1)
		endif
		GPIBwriteCommand("SR400_DiscriminatorLevel",S_command ,1)
		return GPIBReadVal("SR400_DiscriminatorLevel",1 ,"")
	else //RS232Mode
	endif
end

Function SR400_DscrSlope(ctrlName, F_Fall, F_Counter, F_ask, F_GPIB)
	String ctrlName
	variable F_Fall, F_Counter, F_ask, F_GPIB
	string S_command="DS"+num2str(F_Counter)
	if(F_GPIB) //GPIBMode
		SR400_GPIBDevSelect("SR400_DscrSlope")
		if(F_ask==0)
			string S_param=","+num2str(F_Fall)
			GPIBwriteCommand("SR400_DscrSlope",  S_command+S_param, 1)
		endif
		GPIBwriteCommand("SR400_DscrSlope",S_command ,1)
		return GPIBReadVal("SR400_DscrSlope",1 ,"")
	else //RS232Mode
	endif
end

Function SR400_InputSource(ctrlName, F_Counter, S_Input, F_ask, F_GPIB)
	String ctrlName, S_Input
	variable  F_Counter, F_ask, F_GPIB
	string S_command="CI"+num2str(F_Counter)
	if(F_GPIB) //GPIBMode
		SR400_GPIBDevSelect("SR400_InputSource")
		if(F_ask==0)
			string S_param=","
			strswitch(S_Input)
				case "10MHz(internal)":
					S_param+="0"
					break
				case "INPUT1":
					S_param+="1"
					break
				case "INPUT2":
					S_param+="2"
					break
				case "TRIG":
					S_param+="3"
					break
				default:
					print "error : in SR400_InputSource"
					F_ask=1
			endswitch
			GPIBwriteCommand("SR400_InputSource",S_command+S_param ,1)
		endif
		GPIBwriteCommand("SR400_InputSource",S_command ,1)
		return GPIBReadVal("SR400_InputSource",1 ,"")
	else //RS232Mode
	endif
end

Function SR400_CntMode(ctrlName, F_CntMode, F_ask, F_GPIB)
	String ctrlName
	variable F_CntMode, F_ask, F_GPIB
	string S_command="CM"
	if(F_GPIB) //GPIBMode
		SR400_GPIBDevSelect("SR400_CntMode")
		if(F_ask==0)
			string S_param=num2str(F_CntMode)
			GPIBwriteCommand("SR400_CntMode",S_command+S_param ,1)
		endif
		GPIBwriteCommand("SR400_CntMode",S_command ,1)
		return GPIBReadVal("SR400_CntMode",1 ,"")	
	else //RS232Mode
	endif
end


Function SR400_DASource(ctrlName, S_DASource, F_ask, F_GPIB)
	String ctrlName, S_DASource
	variable F_GPIB, F_ask
	variable F_DASource
	string S_command="AS"
	if(F_GPIB) //GPIBMode
		SR400_GPIBDevSelect("SR400_DASource")
		if(F_ask==0)
			strswitch(S_DASource)
				case "A":
					F_DASource=0
					break
				case "B":
					F_DASource=1
					break
				case "A-B":
					F_DASource=2
					break
				case "A+B":
					F_DASource=3
					break
				default:
					print "error: in SR400_DASource"
					F_ask=1
			endswitch

			string S_param=num2str(F_DASource)
			GPIBwriteCommand("SR400_DASource",S_command+S_param ,1)
		endif
		GPIBwriteCommand("SR400_DASource",S_command ,1)
		return GPIBReadVal("SR400_DASource",1 ,"")
	else //RS232Mode
	endif
end

function SR400_NPeriods(ctrlName, V_NPeriods, F_ask, F_GPIB)
	String ctrlName
	variable V_NPeriods, F_GPIB, F_ask
	string S_command="NP"
	if(V_NPeriods>2000||V_NPeriods<1)
		print "error: 0<=NPeriods<=2000"
		F_ask=1
	endif
	if(F_GPIB) //GPIBMode
		SR400_GPIBDevSelect("SR400_NPeriods")
		if(F_ask==0)
			string S_param=num2str(V_NPeriods)
			GPIBwriteCommand("SR400_NPeriods",S_command+S_param ,1)
		endif
		GPIBwriteCommand("SR400_NPeriods",S_command ,1)
		return GPIBReadVal("SR400_NPeriods",1 ,"")	
	else //RS232Mode
	endif
end

Function SR400_CycleMode(ctrlName, F_CycleMode, F_ask, F_GPIB)
	String ctrlName
	variable F_CycleMode, F_ask, F_GPIB
	string S_command="NE"
	if(F_GPIB) //GPIBMode
		SR400_GPIBDevSelect("SR400_CycleMode")
		if(F_ask==0)
			string S_param=num2str(F_CycleMode)
			GPIBwriteCommand("SR400_CycleMode",S_command+S_param ,1)
		endif
		GPIBwriteCommand("SR400_CycleMode",S_command ,1)
		return GPIBReadVal("SR400_CycleMode",1 ,"")	
	else //RS232Mode
	endif
end

Function SR400_DisplayMode(ctrlName, F_Continuous, F_ask, F_GPIB)
	String ctrlName
	variable F_Continuous, F_ask, F_GPIB
	string S_command="SD"
	if(F_GPIB) //GPIBMode
		SR400_GPIBDevSelect("SR400_DisplayMode")
		if(F_ask==0)
			string S_param=num2str(F_Continuous)
			GPIBwriteCommand("SR400_DisplayMode",S_command+S_param ,1)
		endif
		GPIBwriteCommand("SR400_DisplayMode",S_command ,1)
		return GPIBReadVal("SR400_DisplayMode",1 ,"")	
	else //RS232Mode
	endif
end

Function SR400_CountingRange(ctrlName, F_CountRange, F_ask, F_GPIB)
	String ctrlName
	variable F_CountRange, F_ask, F_GPIB
		string S_command="AM"
	if(F_GPIB) //GPIBMode
		SR400_GPIBDevSelect("SR400_CountingRange")
		if(F_ask==0)
			string S_param=num2str(F_CountRange)
			GPIBwriteCommand("SR400_CountingRange",S_command+S_param ,1)
		endif
		GPIBwriteCommand("SR400_CountingRange",S_command ,1)
		return GPIBReadVal("SR400_CountingRange",1 ,"")	
	else //RS232Mode
	endif

	//GPIBwriteCommand("SR400_PM_CountingRange", "AM"+num2str(popNum), 1)
end

Function SR400_ScanMode(ctrlName, F_Counter, F_scan, F_ask, F_GPIB)
	String ctrlName
	variable  F_Counter, F_scan, F_ask, F_GPIB
	string S_command="DM"+num2str(F_Counter)
	if(F_GPIB) //GPIBMode
		SR400_GPIBDevSelect("SR400_ScanMode")
		if(F_ask==0)
			string S_param=","+num2str(F_scan)
			GPIBwriteCommand("SR400_ScanMode",S_command+S_param ,1)
		endif
		GPIBwriteCommand("SR400_ScanMode",S_command ,1)
		return GPIBReadVal("SR400_ScanMode",1 ,"")
	else //RS232Mode
	endif
end

Function SR400_ScanStep(ctrlName, F_Counter, V_ScanStep, F_ask, F_GPIB)
	String ctrlName
	variable  F_Counter, V_ScanStep, F_ask, F_GPIB
	string S_command="DY"+num2str(F_Counter)
	if(V_ScanStep<-0.02&&V_ScanStep>0.02)
		print "Error: in SR400_ScanStep (V_ScanStep is out of range)"
		F_ask=1
	endif
	
	if(F_GPIB) //GPIBMode
		SR400_GPIBDevSelect("SR400_ScanStep")
		if(F_ask==0)
			string S_param=","+num2str(V_ScanStep)
			GPIBwriteCommand("SR400_ScanStep",S_command+S_param ,1)
		endif
		GPIBwriteCommand("SR400_ScanStep",S_command ,1)
		return GPIBReadVal("SR400_ScanStep",1 ,"")
	else //RS232Mode
	endif
end

Function SR400_CurrentScanStep(ctrlName, F_GPIB)
	String ctrlName
	variable F_GPIB
	string S_command="NN"
	GPIBwriteCommand("SR400_CurrentScanStep",S_command ,1)
	return GPIBReadVal("SR400_CurrentScanStep",1 ,"")
end

Function SR400_ScanStart(ctrlName, S_wavename, F_CounterA, F_GPIB)
	String ctrlName, S_wavename
	variable F_CounterA, F_GPIB
	string S_command="F"
	if(F_CounterA)
		S_command+="A"
	else
		S_command+="B"
	endif
	if(F_GPIB) //GPIBMode
		GPIBwriteCommand("SR400_ScanStart",S_command ,1)
		
		//SR400_CurrentScanStep("SR400_ScanStart", F_GPIB)
		//variable V_StatsByte
		//Nvar V_countperiod
		//do
		//	waiting(50000, 1000000*SR400_GetConfig(8)*V_countperiod)
		//	V_StatsByte=SR400_StatusByte("SR400_ScanStart",2 , F_GPIB)
		//	if(V_StatsByte)
		//		break
		//	endif
		//while(1)
	else //RS232Mode
	endif
	variable V_npoints=SR400_GetConfig(6)
	make /O /n=(V_npoints) $S_wavename
	SetScale/P x SR400_GetConfig(23),SR400_GetConfig(20),"V", test,test2,test3
	GPIBReadWav("SR400_ScanStart", S_wavename, 0, V_npoints-1, 0)
	
end

Function SR400_StatusByte(ctrlName, F_bit, F_GPIB)
	String ctrlName
	variable F_bit, F_GPIB
	string S_command="SS"+num2str(F_bit)
	if(F_GPIB) //GPIBMode
		GPIBwriteCommand("SR400_StatusByte",S_command ,1)
		return GPIBReadVal("SR400_StatusByte",1 ,"")
	else //RS232Mode
	endif
end


Function SR400_GateMode(ctrlName, F_Counter, F_GateMode, F_ask, F_GPIB)
	String ctrlName
	variable  F_Counter, F_GateMode, F_ask, F_GPIB
	string S_command="GM"+num2str(F_Counter)
	if(F_GPIB) //GPIBMode
		SR400_GPIBDevSelect("SR400_GateMode")
		if(F_ask==0)
			string S_param=","+num2str(F_GateMode)
			GPIBwriteCommand("SR400_GateMode",S_command+S_param ,1)
		endif
		GPIBwriteCommand("SR400_GateMode",S_command ,1)
		return GPIBReadVal("SR400_GateMode",1 ,"")
	else //RS232Mode
	endif
end

SetBackground

Function SR400_GateScanStep(ctrlName, F_Counter, V_ScanStep, F_ask, F_GPIB)
	String ctrlName
	variable  F_Counter, V_ScanStep, F_ask, F_GPIB
	string S_command="GY"+num2str(F_Counter)
	if(V_ScanStep<0&&V_ScanStep>99.92e-3)
		print "Error: in SR400_GateScanStep (V_ScanStep is out of range)"
		F_ask=1
	endif
	
	if(F_GPIB) //GPIBMode
		SR400_GPIBDevSelect("SR400_GateScanStep")
		if(F_ask==0)
			string S_param=","+num2str(V_ScanStep)
			GPIBwriteCommand("SR400_GateScanStep",S_command+S_param ,1)
		endif
		GPIBwriteCommand("SR400_GateScanStep",S_command ,1)
		return GPIBReadVal("SR400_GateScanStep",1 ,"")
	else //RS232Mode
	endif
end


Function SR400_GatePosition(ctrlName, F_Counter, V_GatePosition, F_ask, F_GPIB)
	String ctrlName
	variable  F_Counter, V_GatePosition, F_ask, F_GPIB
	string S_command="GD"+num2str(F_Counter)
	if(V_GatePosition<0&&V_GatePosition>999.2e-3)
		print "Error: in SR400_GatePosition (V_GatePosition is out of range)"
		F_ask=1
	endif
	
	if(F_GPIB) //GPIBMode
		SR400_GPIBDevSelect("SR400_GateScanStep")
		if(F_ask==0)
			string S_param=","+num2str(V_GatePosition)
			GPIBwriteCommand("SR400_GateScanStep",S_command+S_param ,1)
		endif
		GPIBwriteCommand("SR400_GateScanStep",S_command ,1)
		return GPIBReadVal("SR400_GateScanStep",1 ,"")
	else //RS232Mode
	endif
end

Function SR400_GateWidth(ctrlName, F_Counter, V_GateWidth, F_ask, F_GPIB)
	String ctrlName
	variable  F_Counter, V_GateWidth, F_ask, F_GPIB
	string S_command="GW"+num2str(F_Counter)
	if(V_GateWidth<0.005e-6&&V_GateWidth>999.2e-3)
		print "Error: in SR400_GateWidth (V_GateWidth is out of range)"
		F_ask=1
	endif
	
	if(F_GPIB) //GPIBMode
		SR400_GPIBDevSelect("SR400_GateWidth")
		if(F_ask==0)
			string S_param=","+num2str(V_GateWidth)
			GPIBwriteCommand("SR400_GateWidth",S_command+S_param ,1)
		endif
		GPIBwriteCommand("SR400_GateWidth",S_command ,1)
		return GPIBReadVal("SR400_GateWidth",1 ,"")
	else //RS232Mode
	endif
end


function BP_SR400_StopCount(ctrlName): ButtonControl
	string ctrlName
	variable F_GPIB=SR400_GetConfig(41)
	if(F_GPIB)
		SR400_GPIBDevSelect("SR400_DiscriminatorLevel")
		GPIBwriteCommand("SR400_StopCount", "CR", 1)
	else
		//RS232send(("SR400_StopCount", "CR"))
	endif
end
