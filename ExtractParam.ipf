#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


Function GetParam(S_BaseWN, V_StartVolt, V_EndVolt, V_DetVol, F_display)
	string S_BaseWN
	variable V_StartVolt, V_EndVolt, V_DetVol, F_display
	variable i, j
	wave M_profiles=$S_BaseWN
	variable N_x=dimsize(M_profiles, 0), N_y=dimsize(M_profiles, 1)
	string S_curProfName="W_profile"
	//print	(V_EndVolt-V_StartVolt)/V_DetVol+1
	make /O /D/N=((V_EndVolt-V_StartVolt)/V_DetVol+1) $S_BaseWN+"PolDir", $S_BaseWN+"ExtRatio", $S_BaseWN+"Intensity", $S_BaseWN+"PIntensity", $S_BaseWN+"chisq", $S_BaseWN+"max", $S_BaseWN+"min"
	SetScale/I x V_StartVolt,V_EndVolt,"V", $S_BaseWN+"PolDir", $S_BaseWN+"ExtRatio", $S_BaseWN+"Intensity", $S_BaseWN+"PIntensity", $S_BaseWN+"chisq", $S_BaseWN+"max", $S_BaseWN+"min"
	wave W_ExtRatio=$S_BaseWN+"ExtRatio"
	wave W_PolDir=$S_BaseWN+"PolDir"
 	wave W_Intensity=$S_BaseWN+"Intensity"
 	wave W_PIntensity=$S_BaseWN+"PIntensity"
 	wave W_chisq=$S_BaseWN+"chisq"
 	wave W_max=$S_BaseWN+"max"
 	wave W_min=$S_BaseWN+"min"
	W_ExtRatio=0
	//wave wv=$S_BaseWN+num2str((V_StartVolt+V_DetVol*i)*10)
	make /O /n=(dimsize(M_profiles, 0)) W_profile 
	wave W_curProf=$S_curProfName
	wave W_ResSinFit

	for(j=0; j<(V_EndVolt-V_StartVolt)/V_DetVol+1; j+=1)
		print j
		multithread W_curProf[]=M_profiles[p][j]
		WaveStats /Q /Z W_curProf
		Sinfitting(S_curProfName, V_avg, (V_max-V_min)/2,  pi/180, 0)
//		if(Sinfitting(S_curProfName, V_avg, V_avg,  2*pi/180, -W_ResSinFit[0]+pi/2, 2)>0.1)
//			Sinfitting(S_curProfName, V_avg, V_avg,  pi/180, 0, 5)
//		endif
			//0: Polarization direction, 1: Extinction ratio, 2: Chi SQR, 3: Total Intensity, 4: Intensity at polarizationdirection
			//W_PolDir[j]=nan
			//W_chisq[j]=nan
			//W_Intensity[j]=nan
			//W_PIntensity[j]=nan
			//W_max[j]=nan
			//W_min[j]=nan
			//W_ExtRatio[j]=nan
			//print S_BaseWN+num2str((V_StartVolt+V_DetVol*j)*10)
		//else
			W_ExtRatio[j]=1/W_ResSinFit[1]//Extinction ratio by sin fitting
			W_PolDir[j]=W_ResSinFit[0]
			if(j<1)
					W_PolDir[j]-=round(W_PolDir[j]/pi)*pi
			else
					W_PolDir[j]-=round((W_PolDir[j]-W_PolDir[j-1])/pi*2)*pi/2
			endif

			W_chisq[j]=W_ResSinFit[2]
			W_Intensity[j]=W_ResSinFit[3]
			W_PIntensity[j]=W_ResSinFit[4]+W_ResSinFit[3]
			wavestats /Q W_curProf//W_current
			//W_PolDir[j]=V_minloc*pi/180
			//if(j<1)
			//		W_PolDir[j]-=round(W_PolDir[j]/pi)*pi
			//else
			//		W_PolDir[j]-=round((W_PolDir[j]-W_PolDir[j-1])/pi*2)*pi/2
			//endif
			W_max[j]=V_max
			W_min[j]=V_min
			W_ExtRatio[j]=V_max/V_min
		//endif
	endfor
	
//	Save/T/M="\r\n" original,fit_original,D061008_800nm_0,D061008_800nm_1,D061008_800nm_2,D061008_800nm_3,D061008_800nm_4,D061008_800nm_5,D061008_800nm_6,D061008_800nm_7,D061008_800nm_8,D061008_800nm_9,D061008_800nm_10,D061008_800nm_11,D061008_800nm_12,D061008_800nm_13,D061008_800nm_14,D061008_800nm_15 as "original++.itx"
//	Save/T/M="\r\n"/A D061008_800nm_16,D061008_800nm_17,D061008_800nm_18,D061008_800nm_19,D061008_800nm_20,D061008_800nm_21,D061008_800nm_22,D061008_800nm_23,D061008_800nm_24,D061008_800nm_25,D061008_800nm_26,D061008_800nm_27,D061008_800nm_28,D061008_800nm_29,D061008_800nm_30,D061008_800nm_31 as "original++.itx"
	

		SetScale/I x V_StartVolt,V_EndVolt,"V", W_PolDir, W_ExtRatio, W_Intensity, W_Intensity, W_PIntensity, W_chisq
		SetScale d 0,0,"rad", W_PolDir
		Interpolate2/T=3/N=(100*(V_EndVolt-V_StartVolt)/V_DetVol+1)/F=0 /Y=$S_BaseWN+"PolDir_SS" W_PolDir

	
end

Sinfitting(S_curProfName, V_avg, (V_max-V_min)/2,  pi/180, 0)
Function /wave Sinfitting(S_wname, V_y0, V_A, V_frq, V_phy)
//S_wname:	Target Wavename in string
//V_y0:		The 1st guess of Offset of sin curve
//V_A:		The 1st guess of Amplitude of sin curve
//V_frq:		The value of Frequency of sin curve (FIXED) 
//V_phy:		The 1st guess of phase delay of sin curve
//F_output:	Specify the return value as shown below
//0: Polarization direction, 1: Extinction ratio, 2: Chi SQR, 3: Total Intensity, 4: Intensity at polarizationdirection
	string S_wname
	variable V_y0, V_A, V_frq, V_phy
	variable V_ExtRatio=0, V_PolDir, V_chisq, V_intensity,j
	wave W_current=$S_wname
	wave W_coef=W_coef
	K0 = V_y0; K1 = V_A; K2 = V_frq ;K3 = V_phy
	Make/O/T/N=4 T_Constraints
	Make/O/N=7 W_ResSinFit
	T_Constraints = {"K0 > 0","K1 > 0","K3 < 2*pi"}
//	T_Constraints = {"K0 > 0","K1 > 0","K3 > 0","K3 < 2*pi"}
//	T_Constraints = {"K0 > 0","K1 > 0","K3 > -100","K3 < 100"}
	CurveFit /Q /N sin W_current  /D //F={0.997300, 7} 
	//CurveFit/G /Q  /H="0000" sin  W_current /D /F={0.997300, 7} 
	//C=T_Constraints
//	CurveFit/G /Q  /H="0000" sin  W_current /D //C=T_Constraints
//	F={0.999999, 4}  
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
	
	print V_PolDir, V_ExtRatio, V_chisq, W_coef[0], W_coef[1], W_coef[2], W_coef[3]
	
//	switch(F_output)
//		case 0:	//Polarization direction
//		return V_PolDir
//		case 1:	//Extinction ratio
//			return V_ExtRatio
//		case 2:	//Chi SQR
//			return V_chisq
//		case 3:	//Total Intensity
//			return W_coef[0]*2*pi
//		case 4:	//Intensity at polarizationdirection
//			return W_coef[1]
//		default:
//			break
//	endswitch
	return W_ResSinFit
end