#pragma rtGlobals=1		// Use modern global access method.
Function NIDAQ_6723_Init() : ButtonControl
	String/G NIDAQ6723_Dev="Dev4"
	if(fDAQmx_ResetDevice(NIDAQ6723_Dev)!=0)
		print "NIDAQ_6025_initialize failure"
	endif
End

Function  NIDAQ_6723_Wri( Ch, vol): ButtonControl
	Variable Ch, vol
	Svar deviceName=$"NIDAQ6723_Dev"
	return fDAQmx_WriteChan( deviceName, Ch, vol, -10, 10)
End