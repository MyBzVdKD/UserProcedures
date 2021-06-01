Function InitNF_WF(num)
	variable num
	switch(num)
		case 1946:
			execute "InitNF_WF1946()"
		break
		case 1943:
			execute "InitNF_WF1943()"
		break
		default:
			abort "Failing: Init WF"+num2str(num)
	endswitch
End

macro InitNF_WF1946()
		DevSelect(0)
		//FOR Wavefactory 1946 2CH
		// set to factory setting
		GPIBWrite "PST\n"
		//Output OFF
		//Fix the Output Range 1V
		//Load impeadance 50 Ohm
		GPIBWrite "CHA 1; SIG 0; ORG 2; OLS 1; OLD 50\n"
		GPIBWrite "CHA 2; SIG 0; ORG 2; OLS 1; OLD 50\n"
		//Frequency , amplitude, and offset
		GPIBWrite "CHA 1; FRQ 1.0E+2; AMV 1.0E+0; OFS 0.0E+0\n"
		GPIBWrite "CHA 2; FRQ 1.0E+0; AMV 1.0E+0; OFS 0.0E+0\n"
		//Waveshape Seesow 
		GPIBWrite "CHA 1; FNC 4\n"
		GPIBWrite "CHA 2; FNC 4\n"
		//Burst setting  Trigger, External, Up trigger, CH2 trig, space 1, stop off, Common CH
		GPIBWrite "CHA 1; BTY 1; TRS 1; BES 0; TRD 0.3E-02; MRK 99; SPC 1; BSS 0; BRO 1\n"
		GPIBWrite "CHA 2; BTY 1; TRS 1; BES 0; BEC 1; TRD 0.3E-02; MRK 1; SPC 1; BSS 0; BRO 1\n"
		// Mode DC
		GPIBWrite "CHA 1; OMO 5\n"
		GPIBWrite "CHA 2; OMO 5\n"
		//Output ON
		GPIBWrite "CHA 1; SIG 1\n"
		GPIBWrite "CHA 2; SIG 1\n"
		if (F_PiezoMode)//OutputRange=Å}10, OpenLoad
			GPIBWrite "CHA 1; SIG 0; ORG 1; OLS 0\n"
			GPIBWrite "CHA 2; SIG 0; ORG 1; OLS 0\n"
		endif
end

Function StopWF1946()
	Execute "GPIBWrite \"CHA 1; SIG 0\\n\""
	Execute "GPIBWrite \"CHA 1; SIG 1\\n\""
End

Function StopWF1946XY()
	wave CLMS_XYwave=$"CLMS_XYwave"
	wave CLMS_tmp=$"CLMS_tmp"
	NVAR X_Pixels=X_Pixels
	NVAR Y_Pixels=Y_Pixels
	Variable i,j
	
	Execute "GPIBWrite \"CHA 1; SIG 0\\n\""
	Execute "GPIBWrite \"CHA 1; SIG 1\\n\""
	
	i=0
	do
		j=0
		do
			CLMS_XYwave[i][j]=CLMS_tmp[i*X_Pixels+j]
			j+=1
		while(j<X_Pixels)
		i+=1
	while(i<Y_Pixels)	
End
