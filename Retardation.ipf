#pragma rtGlobals=1		// Use modern global access method.


Function GetRetardation(wname)
	String wname
	variable j
	variable Freq=1000
	Variable ch, k
	Variable V_Start=0
	Variable V_Stop=7.1
	Variable V_Step=0.1
	variable V_time
	V_time=DateTime
	LCD_Control_pol("Initialize",1,"Radial") 
	Sigma_RStage_Init_Val()
	NIDAQ_6025_Init()
	fDAQmx_WaveformStop("Dev4")
	
	j=V_Start
	do
		make/O/N=(200)  wave2
		SetScale/P x 0,5e-6,"s" wave2
		wave2= j*sin(2*Pi*x*Freq)

		ch=8
		do
			fDAQmx_WriteChan("Dev4", ch, 0, -10, 10)
			ch +=1
		While( ch <24)

		DAQmx_WaveformGen/DEV="Dev4" "wave2,8;wave2,9;wave2,10;wave2,11;wave2,12;wave2,13;wave2,14;wave2,15;"
		Sigma_RStage_Init_Button("")
		PolarizationMeasurement(wname+"_"+num2str(j*10),10)
		fDAQmx_WaveformStop("Dev4")
//		ch=8
//		do
//			fDAQmx_WriteChan("dev1", ch, 0, -10, 10)
//			ch +=1
//		While( ch <24)
		print j
		j+=V_Step
	While(j<V_Stop)
	GetParam(wname, V_Start, V_Stop, V_Step,0)
	V_time=DateTime-V_time
	print V_time/60, "min"
	Print "end"
	
end

Function GetParam(S_BaseWN, V_StartVolt, V_EndVolt, V_DetVol, F_display)
	string S_BaseWN
	variable V_StartVolt, V_EndVolt, V_DetVol, F_display
	variable i, j
	make /O /N=((V_EndVolt-V_StartVolt)/V_DetVol+1) $S_BaseWN+"_PolDir", $S_BaseWN+"_ExtRatio", $S_BaseWN+"_Intensity", $S_BaseWN+"_PIntensity", $S_BaseWN+"_chisq"
	wave W_ExtRatio=$S_BaseWN+"_ExtRatio", W_PolDir=$S_BaseWN+"_PolDir", W_Intensity=$S_BaseWN+"_Intensity", W_PIntensity=$S_BaseWN+"_PIntensity", W_chisq=$S_BaseWN+"_chisq"
	W_ExtRatio=0
	for(i=0; i<(V_EndVolt-V_StartVolt)/V_DetVol+1; i+=1)
		//print i
		wave W_current=$S_BaseWN+"_"+num2str((V_StartVolt+V_DetVol*i)*10)
		wave W_ResSinFit
		WaveStats /Q /Z W_current

		Sinfitting(S_BaseWN+"_"+num2str((V_StartVolt+V_DetVol*i)*10), V_avg, V_avg,  2*pi/180, -W_ResSinFit[0]+pi/2, 5)//0: Polarization direction, 1: Extinction ratio, 2: Chi SQR, 3: Total Intensity, 4: Intensity at polarizationdirection
		
		W_ExtRatio[i]=W_ResSinFit[1]
		W_PolDir[i]=W_ResSinFit[0]
		
		if(i<1)
				W_PolDir[i]-=round(W_PolDir[i]/pi)*pi
		else
				W_PolDir[i]-=round((W_PolDir[i]-W_PolDir[i-1])/pi*2)*pi/2
		endif
		W_chisq[i]=W_ResSinFit[2]
		W_Intensity[i]=W_ResSinFit[3]
		W_PIntensity[i]=W_ResSinFit[4]+W_ResSinFit[3]
	endfor
	
	//Save/T/M="\r\n" original,fit_original,D061008_800nm_0,D061008_800nm_1,D061008_800nm_2,D061008_800nm_3,D061008_800nm_4,D061008_800nm_5,D061008_800nm_6,D061008_800nm_7,D061008_800nm_8,D061008_800nm_9,D061008_800nm_10,D061008_800nm_11,D061008_800nm_12,D061008_800nm_13,D061008_800nm_14,D061008_800nm_15 as "original++.itx"
//Save/T/M="\r\n"/A D061008_800nm_16,D061008_800nm_17,D061008_800nm_18,D061008_800nm_19,D061008_800nm_20,D061008_800nm_21,D061008_800nm_22,D061008_800nm_23,D061008_800nm_24,D061008_800nm_25,D061008_800nm_26,D061008_800nm_27,D061008_800nm_28,D061008_800nm_29,D061008_800nm_30,D061008_800nm_31 as "original++.itx"
	
	
	SetScale/I x V_StartVolt,V_EndVolt,"V", W_PolDir, W_ExtRatio, W_Intensity, W_Intensity, W_PIntensity, W_chisq
	SetScale d 0,0,"rad", W_PolDir
	Interpolate2/T=3/N=(100*(V_EndVolt-V_StartVolt)/V_DetVol+1)/F=0 /Y=$S_BaseWN+"_PolDir_SS" W_PolDir
	ShowTrc(S_BaseWN, S_BaseWN+"_PolDir_ExtR", 0, 0, 1)//Display PolDir
	ShowTrc(S_BaseWN, S_BaseWN+"_PolDir_ExtR", 1, 1, 0)//AppendExtRatio
	//SetAxis right 0,0.03
	//Legend
	TextBox/C/N=$S_BaseWN+"_PS" /F=0/A=MC/B=1 "["+S_BaseWN+"]"
	AppendText "\\s("+S_BaseWN+"_PolDir) Phase shift"
	AppendText "\\s("+S_BaseWN+"_ExtRatio) Extinction ratio"
	SetAxis right 0,0.1 
	ShowTrc(S_BaseWN, S_BaseWN+"_Intensities", 2, 0, 1)
	ShowTrc(S_BaseWN, S_BaseWN+"_PIntensities", 3, 0, 1)
	ShowTrc(S_BaseWN, S_BaseWN+"_PIntensities", 4, 1, 0)
end

function ShowTrc(S_BaseWN, S_Winame, F_Data, F_Append, F_L_axis)
//Display the variation of paramaters as a graph
//S_BaseWN	:The Basename of target wave
//S_Winame	:The target Window's name
//F_Data		:Specify the wave to display or append to graph as shonw below
//0: PhaseDelay, 1: ExtinctionRatio, 2: Intensity, 3: Intensity at polarization direction, 4: ChiSquare of fitting
//F_Append	:if you wanna append the waves to exsisting graph, please input non-zero
//F_L_axis	:if you wanna reference the left axis as the vertical axis, please input non-zero
	string S_BaseWN, S_Winame
	variable F_Data, F_Append, F_L_axis
	switch(F_Data)
		case 0://PhaseDelay
			if (F_Append)
				Appendtograph /W=$S_Winame $S_BaseWN+"_PolDir", $S_BaseWN+"_PolDir_SS"
			else
				Display /N=$S_Winame $S_BaseWN+"_PolDir", $S_BaseWN+"_PolDir_SS"
			endif
			ModifyGraph mode($S_BaseWN+"_PolDir")=3,marker($S_BaseWN+"_PolDir")=8,standoff(left)=0
			ModifyGraph rgb($S_BaseWN+"_PolDir_SS")=(0,0,0)
			PiLabelgenerator("W_PiLabel", "W_PiLaPos", -4*pi, 4*pi, pi/2, 2)
			if(F_L_axis)
				Label left "Phase delay / \\U"
			else 
				Label right "Phase delay / \\U"
			endif
			break
		case 1://ExtinctionRatio
			if(F_Append)
				if(F_L_axis)
					Appendtograph/W=$S_Winame /L $S_BaseWN+"_ExtRatio"
					ModifyGraph lowTrip(left)=0.001
				else
					Appendtograph/W=$S_Winame /R $S_BaseWN+"_ExtRatio"
					ModifyGraph lowTrip(right)=0.001
				endif
			else
				if(F_L_axis)
					display /N=$S_Winame /L $S_BaseWN+"_ExtRatio"
				else
					display /N=$S_Winame /R $S_BaseWN+"_ExtRatio"
				endif
				
			endif
			ModifyGraph lstyle($S_BaseWN+"_ExtRatio")=1,rgb($S_BaseWN+"_ExtRatio")=(0,0,0),standoff(right)=0
			if(F_L_axis)
				Label Left "Extinction Ratio"
			else 
				Label right "Extinction Ratio"
			endif
			break
		case 2://Intensity
			if(F_Append)
				if(F_L_axis)
					Appendtograph/W=$S_Winame /L $S_BaseWN+"_Intensity"
				else
					Appendtograph/W=$S_Winame /R $S_BaseWN+"_Intensity"
				endif
			else
				if(F_L_axis)
					Display /N=$S_Winame /L $S_BaseWN+"_Intensity"
				else
					Display /N=$S_Winame /R $S_BaseWN+"_Intensity"
				endif
			endif
			wavestats /Q $S_BaseWN+"_Intensity"
			if(F_L_axis)
				Label left "Intensity A.U."
			else 
				Label right  "Intensity A.U."
			endif
			break
		case 3://Intensity in polarized angle
			if(F_Append)
				if(F_L_axis)
					Appendtograph/W=$S_Winame /L $S_BaseWN+"_PIntensity"
				else
					Appendtograph/W=$S_Winame /R $S_BaseWN+"_PIntensity"
				endif
			else
				if(F_L_axis)
					Display /N=$S_Winame /L $S_BaseWN+"_PIntensity"
				else
					Display /N=$S_Winame /R $S_BaseWN+"_PIntensity"
				endif
				
			endif
			wavestats /Q $S_BaseWN+"_PIntensity"
			if(F_L_axis)
				Label left "Intensity in polarized direction A.U."
			else 
				Label right  "Intensity in polarized direction A.U."
			endif
			break
		case 4://Chi SQ
			if(F_Append)
				if(F_L_axis)
					Appendtograph/W=$S_Winame /L $S_BaseWN+"_chisq"
				else
					Appendtograph/W=$S_Winame /R $S_BaseWN+"_chisq"
				endif
				
			else
				if(F_L_axis)
					Display /N=$S_Winame /L $S_BaseWN+"_chisq"
				else
					Display /N=$S_Winame /R $S_BaseWN+"_chisq"
				endif
			endif
			if(F_L_axis)
				Label left "\F'Symbol'c\M\S2"
			else 
				Label right  "\F'Symbol'c\M\S2"
			endif
			ModifyGraph lstyle($S_BaseWN+"_chisq")=1,rgb($S_BaseWN+"_chisq")=(0,0,0)
			break		
		default:
			break
	endswitch
end



function PiLabelgenerator(S_WLab, S_WPos, V_start, V_stop, V_dMajor, V_divSubminor)
//S_WLab: Wavename of LabelWave
//S_WPos: Wavename of PositionWave
//V_start: StartValue of Position Wave
//V_stop: EndValue of Position Wave
//V_dMajor: the Step of Major Ticks
//V_divSubminor: the Division by subminor ticks
//It requiers the function "Reduction(V_devided, V_devide, F_output)" 
	string S_WLab, S_WPos
	variable V_start, V_stop, V_dMajor, V_divSubminor
	make /O /T /n=((V_stop-V_start)/V_dMajor*V_divSubminor+1 , 2) $S_WLab
	make /O /n=((V_stop-V_start)/V_dMajor*V_divSubminor+1) $S_WPos
	wave /T W_PiLabel=$S_WLab
	wave W_PiPoswave= $S_WPos
	variable i
	for(i=0;i<(V_stop-V_start)/V_dMajor*V_divSubminor+1;i+=1)
		W_PiPoswave[i]=V_start+V_dMajor/V_divSubminor*i
		if(abs(W_PiPoswave[i]-round(W_PiPoswave[i]/pi)*pi)<V_dMajor/V_divSubminor/10)
			if(round((V_start+V_dMajor/V_divSubminor*i)/pi)==0)
				W_PiLabel[i][0]="0"
			elseif(round((V_start+V_dMajor/V_divSubminor*i)/pi)==1)
				W_PiLabel[i][0]="\F'Symbol'p"
			else
				W_PiLabel[i][0]=num2str(round((V_start+V_dMajor/V_divSubminor*i)/pi))+"\F'Symbol'p"
			endif
			W_PiLabel[i][1]="Major"
		elseif(abs(W_PiPoswave[i]-round(W_PiPoswave[i]/V_dMajor)*V_dMajor)<V_dMajor/V_divSubminor/10)
			W_PiLabel[i][0]=num2str(Reduction((round(W_PiPoswave[i]/V_dMajor)), (round(pi/V_dMajor)), 0))+"/"+num2str(Reduction((round(W_PiPoswave[i]/V_dMajor)), (round(pi/V_dMajor)), 1))+" \F'Symbol'p"
			W_PiLabel[i][1]="Major"
		else
			W_PiLabel[i][0]=num2str(Reduction((round(W_PiPoswave[i]/V_dMajor*V_divSubminor)), (round(pi/V_dMajor*V_divSubminor)), 0))+"/"+num2str(Reduction((round(W_PiPoswave[i]/V_dMajor*V_divSubminor)), (round(pi/V_dMajor*V_divSubminor)), 1))+" \F'Symbol'p"
			W_PiLabel[i][1]="Subminor"
		endif
	endfor
	ModifyGraph userticks(left)={W_PiPoswave,W_PiLabel}
end

Reduction(round(W_PiPoswave[i]/V_dMajor*V_divSubminor), round(pi/V_dMajor*V_divSubminor), )

function Reduction(V_devided, V_devide, F_output)
	variable V_devided, V_devide, F_output
	variable COPY_V_devided = abs(V_devided), COPY_V_devide = abs(V_devide)
	variable V_CommonDivisor, V_residue, V_residue2, V_AnsDevided, V_AnsDevide


	if(COPY_V_devide >= COPY_V_devided)
		V_CommonDivisor = COPY_V_devided+1
		V_residue = mod(COPY_V_devide, V_CommonDivisor)
		V_residue2 = mod(COPY_V_devided, V_CommonDivisor)
		do
			V_CommonDivisor -= 1
			V_residue = mod(COPY_V_devide, V_CommonDivisor)
			V_residue2 = mod(COPY_V_devided, V_CommonDivisor)
		while((V_residue != 0) || (V_residue2 != 0))
	else
		V_CommonDivisor = COPY_V_devide
		V_residue = mod(COPY_V_devide, V_CommonDivisor)
		V_residue2 = mod(COPY_V_devided, V_CommonDivisor)
		do
			V_CommonDivisor -= 1
			V_residue = mod(COPY_V_devide, V_CommonDivisor)
			V_residue2 = mod(COPY_V_devided, V_CommonDivisor)
		while((V_residue != 0) || (V_residue2 != 0))
	endif
	if(((V_devided > 0) && (V_devide > 0)) || ((V_devided < 0) && (V_devide < 0)))
		V_AnsDevided = COPY_V_devided / V_CommonDivisor
		V_AnsDevide = COPY_V_devide / V_CommonDivisor
	else
		V_AnsDevided = -1*COPY_V_devided / V_CommonDivisor
		V_AnsDevide = COPY_V_devide / V_CommonDivisor
	endif

	if(F_output)
		return V_AnsDevide
	else
		return V_AnsDevided
	endif
end

Function Sinfitting(S_wname, V_y0, V_A, V_frq, V_phy, F_output)
//S_wname:	Target Wavename in string
//V_y0:		The 1st guess of Offset of sin curve
//V_A:		The 1st guess of Amplitude of sin curve
//V_frq:		The value of Frequency of sin curve (FIXED) 
//V_phy:		The 1st guess of phase delay of sin curve
//F_output:	Specify the return value as shown below
//0: Polarization direction, 1: Extinction ratio, 2: Chi SQR, 3: Total Intensity, 4: Intensity at polarizationdirection
	string S_wname
	variable V_y0, V_A, V_frq, V_phy, F_output
	variable V_ExtRatio=0, V_PolDir, V_chisq, V_intensity,j
	wave W_current=$S_wname
	wave W_coef=W_coef
	K0 = V_y0; K1 = V_A; K2 = V_frq ;K3 = V_phy
	Make/O/T/N=4 T_Constraints
	Make/O/N=7 W_ResSinFit
	T_Constraints = {"K0 > 0","K1 > 0","K3 < 2*pi"}
	//T_Constraints = {"K0 > 0","K1 > 0","K3 > 0","K3 < 2*pi"}
	//T_Constraints = {"K0 > 0","K1 > 0","K3 > -100","K3 < 100"}
	CurveFit/G /Q /H="0010" sin  W_current /D //C=T_Constraints
	//F={0.999999, 4}  
	V_ExtRatio=(W_coef[0]-W_coef[1])/(W_coef[0]+W_coef[1])
	if(V_ExtRatio>1)
		V_ExtRatio=V_ExtRatio^-1
	endif
	V_PolDir=-W_coef[3]+pi/2

	j=0
	do
		if(W_coef[j]<0)
			W_coef[j]*=-1
		endif
		j+=1
	while(j<2)

	W_ResSinFit={V_PolDir, V_ExtRatio, V_chisq, W_coef[0], W_coef[1], W_coef[2], W_coef[3]}//C0+C1*sin(C2*x+C3)
	
	
	switch(F_output)
		case 0:	//Polarization direction
			return V_PolDir
		case 1:	//Extinction ratio
			return V_ExtRatio
		case 2:	//Chi SQR
			return V_chisq
		case 3:	//Total Intensity
			return W_coef[0]*2*pi
		case 4:	//Intensity at polarizationdirection
			return W_coef[1]
		default:
			break
	endswitch
	
end


Function PolarizationMeasurement(wname, div)
	string wname
	variable div
	variable i=0,k
	variable ch=1
	variable ATime=10
	variable Range=1
	variable W_Offset=-0.0004193-0.000265782
	Make/O/N=(360/div+1) $wname
	wave w1=$wname
	setscale /I x, 0, 360, "deg", w1
	
	do
		w1[i]=NIDAQ_6025E_Obs(ATime,ch,Range)-W_Offset
		//print i*div, "deg"
		i+=1
		Sigma_Rotation_Stage_Goto(i*div,1)
		//Waiting(50000, 1000000)
		//Waiting(50000, 2*50000)

	while(i<=360/div)
end


Function PolarizerInitZero(S_wname, V_DegStep)//now constructing
	String S_wname
	Variable V_DegStep
	Nvar V_RStage_ZeroPoint
	V_RStage_ZeroPoint=0
	do
		Sigma_RStage_Init_Button("PolarizerInitZero")
		PolarizationMeasurement(S_wname, V_DegStep)
		wave  W_wname=$S_wname, W_ResSinFit=W_ResSinFit
		wavestats /Q/Z W_wname
		PolDirfitting(S_wname)
		V_RStage_ZeroPoint+=W_ResSinFit[0]/pi*90
		if(V_RStage_ZeroPoint<0)
			V_RStage_ZeroPoint+=180
		endif
		print "V_RStage_ZeroPoint=",V_RStage_ZeroPoint
	while(abs(W_ResSinFit[0]/pi*90)>5e-2)
end

Function PolDirfitting(S_wname)
	string S_wname
	wave  W_wname=$S_wname, W_ResSinFit=W_ResSinFit
	wavestats /Q/Z W_wname
	Sinfitting(S_wname, V_avg, V_avg,  2*pi/180, pi/2, 0)
	//W_ResSinFit={V_PolDir, V_ExtRatio, V_chisq, W_coef[0], W_coef[1], W_coef[2], W_coef[3]}
	//Sinfitting(S_wname, V_avg, V_avg,  2*pi/180, pi/2, 0)
	W_ResSinFit[0]-=trunc(W_ResSinFit[0]/2/pi)*2*pi
	print "Polatization direction=",W_ResSinFit[0]/pi*90
	print "Extinction ratio=",W_ResSinFit[1]
end 



Function Retardation2Voltage(S_Wname, V_Ret_rad)
	string S_Wname
	variable V_Ret_rad
	variable i
	wave W_Vol2Ret=$S_Wname
	//print V_Ret_rad/pi,"*pi"
	for(i=0; i<numpnts(W_Vol2Ret)-1; i+=1)
		if((W_Vol2Ret[i]-V_Ret_rad)*(W_Vol2Ret[i+1]-V_Ret_rad)<0)
			return pnt2x(W_Vol2Ret, i)+(pnt2x(W_Vol2Ret, i+1)-pnt2x(W_Vol2Ret, i))*(V_Ret_rad-W_Vol2Ret[i])/(W_Vol2Ret[i+1]-W_Vol2Ret[i])
		elseif((W_Vol2Ret[i]-V_Ret_rad-2*pi)*(W_Vol2Ret[i+1]-V_Ret_rad-2*pi)<0)
			return pnt2x(W_Vol2Ret, i)+(pnt2x(W_Vol2Ret, i+1)-pnt2x(W_Vol2Ret, i))*(V_Ret_rad+2*pi-W_Vol2Ret[i])/(W_Vol2Ret[i+1]-W_Vol2Ret[i])
		elseif((W_Vol2Ret[i]-V_Ret_rad+2*pi)*(W_Vol2Ret[i+1]-V_Ret_rad+2*pi)<0)
			return pnt2x(W_Vol2Ret, i)+(pnt2x(W_Vol2Ret, i+1)-pnt2x(W_Vol2Ret, i))*(V_Ret_rad-2*pi-W_Vol2Ret[i])/(W_Vol2Ret[i+1]-W_Vol2Ret[i])
		endif
	endfor
	print "Error"
end

Function Retardation2Voltage_oldver(S_Wname, V_Ret_rad)
	string S_Wname
	variable V_Ret_rad
	variable i
	wave W_Vol2Ret=$S_Wname
	for(i=0; i<numpnts(W_Vol2Ret)-1; i+=1)
		if(abs(W_Vol2Ret[i]) < abs(V_Ret_rad) && abs(W_Vol2Ret[i+1]) > abs(V_Ret_rad))
			return pnt2x(W_Vol2Ret, i)+(pnt2x(W_Vol2Ret, i+1)-pnt2x(W_Vol2Ret, i))*(V_Ret_rad-W_Vol2Ret[i])/(W_Vol2Ret[i+1]-W_Vol2Ret[i])
		elseif(abs(W_Vol2Ret[i]) < abs(V_Ret_rad+2*pi) && abs(W_Vol2Ret[i+1]) > abs(V_Ret_rad+2*pi))
			return pnt2x(W_Vol2Ret, i)+(pnt2x(W_Vol2Ret, i+1)-pnt2x(W_Vol2Ret, i))*(V_Ret_rad+2*pi-W_Vol2Ret[i])/(W_Vol2Ret[i+1]-W_Vol2Ret[i])
		endif
	endfor
	print "Error"
end

Function Waiting(n, V_time_microsec)
	//recommended
	//n=50000(>1sec)

	variable n, V_time_microsec
	variable i=-1, V_CurrTime, F_TimerNo, F_TimerNo2
	do
		i+=1
	while(stopMSTimer(i))
	F_TimerNo2=startMSTimer
	do
	F_TimerNo=startMSTimer
			for(i=0; i<n; i+=1)
			endfor
		V_CurrTime+=stopMSTimer(F_TimerNo)
	while(V_CurrTime<V_time_microsec)
	//print V_CurrTime
	return stopMSTimer(F_TimerNo2)
end