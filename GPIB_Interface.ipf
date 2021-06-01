#pragma rtGlobals=1		// Use modern global access method.
//WF1946
//Execute "InitGPIBBoardAndDevice(0)"
//WF1943
//Execute "InitGPIBBoardAndDevice(1)"
//Sigma_Mark-202
//Execute "InitGPIBBoardAndDevice(2)"
//SR400
//Execute "InitGPIBBoardAndDevice(3)"
//ButtonProc_Initialize("Start")



Window GPIBPrefs() : Table
	PauseUpdate; Silent 1		// building window...
	Edit/W=(217.5,74,722.25,283.25) W_GPIBDeVName,W_GPIBDevices as "GPIBPrefs"
EndMacro


//↓昔のメインプログラム
function InitGPIBBoardAndDevice(Dnum, GPIBBrdnum, GPIBnum)//You need to Input gBoardAddress and gDeviceAddress in the wave W_GPIBDevices
// Initialization for NI-GPIB board
// Device number of the system is Dnum
// W_GPIBDevices[devNo][paramter]=gBoardAddress(Userinput), gDeviceAddress(Userinput), gBoardUnitDescriptor, gDeviceUnitDescriptor
	variable  Dnum, GPIBBrdnum, GPIBnum
	variable /G V_GPIBDescriptor
	wave W_GPIBDevices
	Dnum=x2pnt(W_GPIBDevices, Dnum)
	W_GPIBDevices[Dnum][0]=GPIBBrdnum
	W_GPIBDevices[Dnum][1]=GPIBnum
	Execute "NI488 ibfind \"gpib"+num2str(W_GPIBDevices(Dnum)[0])+"\",V_GPIBDescriptor"; W_GPIBDevices[Dnum][2]=V_GPIBDescriptor
	Execute "NI488 ibfind \"dev"+num2str(W_GPIBDevices(Dnum)[1])+"\", V_GPIBDescriptor"; W_GPIBDevices[Dnum][3]=V_GPIBDescriptor
	GPIBDevSelect(GPIBnum)
		// Make sure we are in a clean state.
	Execute "GPIB KillIO"
	Execute "GPIB InterfaceClear"
End

function InitGPIB2BoardAndDevice(ctrlName, GPIBBrdnum, GPIBDevnum)//You need to Input gBoardAddress and gDeviceAddress in the wave W_GPIBDevices
// Initialization for NI-GPIB board
// Device number of the system is Dnum
// W_GPIBDevices[devNo][paramter]=gBoardAddress(Userinput), gDeviceAddress(Userinput), gBoardUnitDescriptor, gDeviceUnitDescriptor
	string ctrlName
	variable GPIBBrdnum, GPIBDevnum
	variable Dnum
	wave W_GPIBCfig=$"W_GPIBDevices"
	Dnum=x2pnt(W_GPIBCfig, GPIBDevnum)
	W_GPIBCfig[Dnum][0]=GPIBBrdnum
	W_GPIBCfig[Dnum][1]=GPIBDevnum
	NI4882 ibfind={"gpib"+num2str(W_GPIBCfig[Dnum][0])}
	W_GPIBCfig[Dnum][2]=V_flag
	NI4882 ibfind={"dev"+num2str(W_GPIBCfig[Dnum][1])}
	W_GPIBCfig[Dnum][3]=V_flag
	GPIBDevSelect(GPIBDevnum)
		// Make sure we are in a clean state.
	GPIB2 KillIO
	GPIB2 InterfaceClear
End

function GPIB2makeClean(ctrlName, V_GPIBBrdDcrpt, V_GPIBDevDcrpt)
	string ctrlName
	variable V_GPIBBrdDcrpt, V_GPIBDevDcrpt
	wave W_GPIBDevices
	//Dnum=x2pnt(W_GPIBDevices, Dnum)
	GPIBDevSelect2("GPIBmakeClean", V_GPIBBrdDcrpt, V_GPIBDevDcrpt)
	GPIB2 KillIO
	GPIB2 InterfaceClear
end



function GPIBDeviceDescriptor(ctrlName, V_GPIBBrdDcrpt, V_GPIBDevNo)
	string ctrlName
	variable V_GPIBBrdDcrpt, V_GPIBDevNo
	variable / G V_GPIBDescriptor
	Execute "GPIB board "+num2str(V_GPIBBrdDcrpt)
	Execute "NI488 ibfind \"dev"+num2str(V_GPIBDevNo)+"\", V_GPIBDescriptor"
	return V_GPIBDescriptor
End

function	GPIBDevSelect(Dnum)
		variable Dnum
		wave W_GPIBDevices
		Dnum=x2pnt(W_GPIBDevices, Dnum)
		GPIB2 board=W_GPIBDevices[Dnum][2]		// Board to use for GPIB InterfaceClear command.
		GPIB2 device=W_GPIBDevices[Dnum][3]		// Device to use for GPIBXXX operations.
End

function	GPIB2DevSelect(Dnum)//Old
		variable Dnum
		wave W_GPIBDevices
		Dnum=x2pnt(W_GPIBDevices, Dnum)
		Execute "GPIB board "+num2str(W_GPIBDevices[Dnum][2])		// Board to use for GPIB InterfaceClear command.
		Execute "GPIB device "+num2str(W_GPIBDevices[Dnum][3])		// Device to use for GPIBXXX operations.
End

function	GPIBDevSelect2(ctrlName, V_GPIBBrdDcrpt, V_GPIBDevDcrpt)//旧バージョン：ディクリプタを直接入力するタイプ
		string ctrlName
		variable V_GPIBBrdDcrpt, V_GPIBDevDcrpt
		Execute "GPIB board "+num2str(V_GPIBBrdDcrpt)		// Board to use for GPIB InterfaceClear command.
		Execute "GPIB device "+num2str(V_GPIBDevDcrpt)		// Device to use for GPIBXXX operations.
End

Function GPIBwriteCommand_old(ctrlname, S_command, F_CR)
	string ctrlname, S_command
	variable F_CR
	String ans1
	Silent 1
	if (F_CR)
		Execute "GPIBWrite \""+ S_command+"\""
	else
		Execute "GPIBWrite/F=\"%s\" \""+ S_command+"\""
	endif
//	do
//		GPIBWrite/F="%s" "!:";
//		GPIBRead/Q ans1
//	while(cmpstr(ans1, "B")==0)
	return 0
end

Function GPIBwriteCommand(ctrlname, S_command, F_CR)
	string ctrlname, S_command
	variable F_CR
	String ans1
	Silent 1
	if (F_CR)
		GPIBWrite2 S_command
	else
		GPIBWrite2  S_command +"\r"
	endif
//	do
//		GPIBWrite/F="%s" "!:";
//		GPIBRead/Q ans1
//	while(cmpstr(ans1, "B")==0)
	return 0
end


Function GPIBReadVal(ctrlname, F_Terminater, S_Terminater)
	string ctrlname
	variable F_Terminater
	string S_Terminater
	variable V_GPIBVal
	switch(F_Terminater)
		case 0:// CR terminator
			GPIBRead2 /Q V_GPIBVal
			break
		case 1:// CRLF terminator
			String lf
			GPIBRead2 /Q /T="\r\n" V_GPIBVal, lf
			break
		case 2://read every character into a string until END is asserted
			GPIBRead2 /Q /T="" V_GPIBVal
			break
		case 3://user defined terminator S_Terminater
			GPIBRead2 /Q /T=S_Terminater V_GPIBVal
		break
		default:
			print "error F_Terminater in GPIBReadVal"
			return nan
	endswitch
	return V_GPIBVal
end

Function /S GPIBReadStr(ctrlname, F_Terminater, S_Terminater)
	string ctrlname
	variable F_Terminater
	string S_Terminater
	string S_GPIBStr
		switch(F_Terminater)
		case 0:// CR terminator
			GPIBRead2 /Q S_GPIBStr
			break
		case 1:// CRLF terminator
			String lf
			GPIBRead2 /Q /T="\r\n" S_GPIBStr, lf
			break
		case 2://read every character into a string until END is asserted
			GPIBRead2 /Q /T="" S_GPIBStr
			break
		case 3://user defined terminator S_Terminater
			GPIBRead2 /Q /T=S_Terminater S_GPIBStr
			break
		default:
			print "error F_Terminater in GPIBReadVal"
			return ""
	endswitch
	return S_GPIBStr
end

Function GPIBReadWav(ctrlname, S_wavename, P_start, P_end, F_Terminater)
	string ctrlname, S_wavename
	variable  P_start, P_end, F_Terminater
	wave W_GPIBans=$S_wavename
	if(F_Terminater)
		GPIBReadWave2 /Q /R=[P_start, P_end ] W_GPIBans
	else
		GPIBReadWave2 /Q /T="%s"/R=[P_start, P_end ] W_GPIBans
	endif
end



