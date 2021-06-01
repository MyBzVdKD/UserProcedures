//
variable /G V_CountPeriod, V_DwellTime
variable /G F_SR400_GPIB

function SR400_GPIBinit(ctrlName)
	string ctrlName
	variable /G V__GPIBDevNo_SR400=4
	Execute "InitGPIBBoardAndDevice(2)"
end
	

function SR400_StartCount(ctrlName)
	string ctrlName
	Nvar F_SR400_GPIB
	if(F_SR400_GPIB)
		GPIBwriteCommand("SR400_StartCount", "CS", 1)
	else
		//RS232send(("SR400_StartCount", "CS"))
	endif
end

function SR400_StopCount(ctrlName)
	string ctrlName
	variable F_SR400_GPIB
	if(F_SR400_GPIB)
		GPIBwriteCommand("SR400_StopCount", "CH", 1)
	else
		//RS232send(("SR400_StopCount", "CH"))
	endif
end

function SR400_DwellTime(ctrlName, V_DwellTime)
	//2E-3<V_DwellTime<6E1
	string ctrlName
	variable V_DwellTime
	Nvar F_SR400_GPIB
	if(2E-3>V_DwellTime)
		print "DwellTime is too SHORT"
	elseif(V_DwellTime>6E1)
		print "DwellTime is too LONG"
	endif
	
	if(F_SR400_GPIB)
		//print V_DwellTime
		GPIBwriteCommand("SR400_DwelllTime", "DT"+num2str(V_DwellTime), 1)
	else
		//RS232send(("SR400_StopCount", "CH"))
	endif
end

function SR400_CounrePreset(ctrlName, V_CounterNo, V_PresetTime)
	//V_CounterNo 0: A, 1: B, 2: T,
	//1E-7<V_PresetTime(sec)<9E4
	string ctrlName
	variable V_CounterNo, V_PresetTime
	Nvar F_SR400_GPIB
	string S_parameter
	if(1e-7>V_PresetTime)
		print "PresetTime is too SHORT"
	elseif(V_PresetTime>9E4)
		print "PresetTime is too LONG"
	endif
	sprintf S_parameter, "%0.0f", V_PresetTime*1e7
	if(F_SR400_GPIB)
		//print V_DwellTime
		GPIBwriteCommand("SR400_CounrePreset", "CP"+num2str(V_CounterNo)+", "+S_parameter, 1)
	else
	endif
end


Function SR400_PM_CountingRange(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	Nvar F_LogOutput
	Nvar F_SR400_GPIB
	if (popNum>0&&popNum<8)
		if(F_SR400_GPIB)
			GPIBwriteCommand("SR400_PM_CountingRange", "AM"+num2str(popNum), 1)
		else
			
		endif
		F_LogOutput=0
	elseif(popNum==8)
		if(F_SR400_GPIB)
			GPIBwriteCommand("SR400_PM_CountingRange", "AM0", 1)
		else
			
		endif
		F_LogOutput=1
	else
		print "[SR400_PM_CountingRange] parameter is invalid"
	endif

End


Function SV_DwellTime(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	SR400_DwellTime("SV_DwellTime", varNum)
	SR400_StartCount("SV_DwellTime")
End

Function SV_CountingPeriod(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	SR400_CounrePreset("SV_CountingPeriod", 2, varNum)
	SR400_StartCount("SV_DwellTime")
End
