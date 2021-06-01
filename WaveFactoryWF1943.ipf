macro InitNF_WF1943()
		DevSelect(1)
		//FOR Wavefactory 1943 1CH
		// set to factory setting
		GPIBWrite "PST\n"
		//Output OFF
		//Fix the Output Range 10V
		//Load impeadance Open
		GPIBWrite "SIG 0; ORG0 ; OLS 0\n"
		//Frequency , amplitude, and offset
		GPIBWrite "FRQ 1.0E+3; AMV "+num2str(V_CmpVol)+"E+0; OFS 0.0E+0\n"
		//Waveshape
		GPIBWrite "FNC 3\n"
		// Mode Normal
		GPIBWrite "OMO 0\n"
		//Output ON
		GPIBWrite "SIG 1\n"
		
		//DevSelect(0)//Current Device is always Dev0
end