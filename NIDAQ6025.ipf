#pragma rtGlobals=1		// Use modern global access method.

Function NIDAQ_6025_Init() : ButtonControl
	String/G NIDAQ6025_Dev="Dev1"
	if(fDAQmx_ResetDevice(NIDAQ6025_Dev)!=0)
		print "NIDAQ_6025_initialize failure"
	endif
End


Function  NIDAQ_6025E_Obs(AvrTimes, Ch, Range): ButtonControl
	Variable AvrTimes, Ch, Range
	Svar deviceName=$"NIDAQ6025_Dev"
	Variable ret=0, i

	for(i=0; i<AvrTimes; i+=1)
	ret+=fDAQmx_ReadChan(deviceName, Ch, -1*Range, Range, 1)
	endfor
	return ret/AvrTimes
End

Function  NIDAQ_6025E_Wri( Ch, vol): ButtonControl
	Variable Ch, vol
	Svar deviceName=$"NIDAQ6025_Dev"
	return fDAQmx_WriteChan( deviceName, Ch, vol, -10, 10)
End

Function NIDAQ_6025E_WaveScan(L_WavesAndChs, S_TrgCh, V_Range, V_nAvr, F_BKG) : ButtonControl
	string L_WavesAndChs, S_TrgCh
	variable V_Range,  V_nAvr, F_BKG
	Svar deviceName=$"NIDAQ6025_Dev"
	DAQmx_Scan /DEV=deviceName /Ave=(V_nAvr) /BKG=(F_BKG) waves=L_WavesAndChs
end


//function test()
//	variable j=0
//	variable Freq=1000
//	Variable ch, k
//	String wname
	
//	LCD_Control_Init_Val("R")
//	NIDAQ_6025_Init()
//	make /O/N=50 wave1
//	do
//		make/O/N=(200)  wave2
//		SetScale/P x 0,5e-6,"s" wave2
//		wave2= sin(2*Pi*j/50)

//		DAQmx_WaveformGen/DEV="Dev1" "wave2,8;"
//		wave1[j]=NIDAQ_6025E_Obs(10,0,1)
//		fDAQmx_WaveformStop("Dev1")
//		j+=1
//	While(j<51)
//	Print "end"
//end
