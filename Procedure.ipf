#pragma rtGlobals=1		// Use modern global access method.


Macro polarizationAnalysis(wname)
string wname
variable i=0
variable /G maxpol, minpol, P_direction

Make/O /N=8 /D 'chisq'
WaveStats /Q $wname
K0 = (V_max+V_min)/2
K1 = (V_max+V_min)/2
K2 = 2*pi/180
K3 = 0
CurveFit /Q /H="0010" sin $wname /D 
//CurveFit sin  $wname /D
chisq[0]=V_chisq
duplicate /O W_coef, coef_0
duplicate /O W_sigma, sigma_0

Make/D/N=5/O W_coef
W_coef= {coef_0[0], coef_0[3]/pi*180, coef_0[1], 0, 1e-5}
FuncFit /Q Polarization_Harmonic1 W_coef  $wname /D
chisq[1]=V_chisq
over360(W_coef[1], 360)
over360(W_coef[3], 360)
duplicate /O W_coef, coef_1
duplicate /O W_sigma, sigma_1

Make/D/N=7/O W_coef
W_coef[5]=0
W_coef[6]=1e-4
FuncFit /Q Polarization_Harmonic2 W_coef  $wname /D
chisq[2]=V_chisq
W_coef[1]=over360(W_coef[1], 360)
W_coef[3]=over360(W_coef[3], 360)
W_coef[5]=over360(W_coef[5], 360)


duplicate /O W_coef, coef_2
duplicate /O W_sigma, sigma_2

Make/D/N=9/O W_coef
W_coef[7]=0
W_coef[8]=1e-4
FuncFit /Q Polarization_Harmonic3 W_coef  $wname /D
chisq[3]=V_chisq
W_coef[1]=over360(W_coef[1], 360)
W_coef[3]=over360(W_coef[3], 360)
W_coef[5]=over360(W_coef[5], 360)
W_coef[7]=over360(W_coef[7], 360)

duplicate /O W_coef, coef_3
duplicate /O W_sigma, sigma_3

Make/D/N=11/O W_coef
W_coef[9]=0
W_coef[10]=1e-4
FuncFit /Q Polarization_Harmonic4 W_coef  $wname /D
chisq[4]=V_chisq
W_coef[1]=over360(W_coef[1], 360)
W_coef[3]=over360(W_coef[3], 360)
W_coef[5]=over360(W_coef[5], 360)
W_coef[7]=over360(W_coef[7], 360)
W_coef[9]=over360(W_coef[9], 360)

duplicate /O W_coef, coef_4
duplicate /O W_sigma, sigma_4

Make/D/N=13/O W_coef
W_coef[11]=0
W_coef[12]=1e-4
FuncFit /Q Polarization_Harmonic5 W_coef  $wname /D
chisq[5]=V_chisq
W_coef[1]=over360(W_coef[1], 360)
W_coef[3]=over360(W_coef[3], 360)
W_coef[5]=over360(W_coef[5], 360)
W_coef[7]=over360(W_coef[7], 360)
W_coef[9]=over360(W_coef[9], 360)
W_coef[11]=over360(W_coef[11], 360)

duplicate /O W_coef, coef_5
duplicate /O W_sigma, sigma_5

Make/D/N=15/O W_coef
W_coef[13]=0
W_coef[14]=1e-4
FuncFit /Q Polarization_Harmonic6 W_coef  $wname /D
chisq[6]=V_chisq
W_coef[1]=over360(W_coef[1], 360)
W_coef[3]=over360(W_coef[3], 360)
W_coef[5]=over360(W_coef[5], 360)
W_coef[7]=over360(W_coef[7], 360)
W_coef[9]=over360(W_coef[9], 360)
W_coef[11]=over360(W_coef[11], 360)
W_coef[13]=over360(W_coef[13], 360)

duplicate /O W_coef, coef_6
duplicate /O W_sigma, sigma_6

Make/D/N=17/O W_coef
W_coef[15]=0
W_coef[16]=1e-4
FuncFit /Q Polarization_Harmonic7 W_coef  $wname /D
chisq[7]=V_chisq
W_coef[1]=over360(W_coef[1], 360)
W_coef[3]=over360(W_coef[3], 360)
W_coef[5]=over360(W_coef[5], 360)
W_coef[7]=over360(W_coef[7], 360)
W_coef[9]=over360(W_coef[9], 360)
W_coef[11]=over360(W_coef[11], 360)
W_coef[11]=over360(W_coef[13], 360)
W_coef[15]=over360(W_coef[15], 360)

duplicate /O W_coef, coef_7
duplicate /O W_sigma, sigma_7

maxpol=abs(W_coef[0])+abs(W_coef[4])
minpol=abs(W_coef[0])-abs(W_coef[4])
P_direction=W_coef[3]
//if (abs(P_direction)>360)
//P_direction=P_direction-trunc(P_direction/360)*360+90
//endif

end

macro TotalAnalysis(step)
variable i=0, step, j
variable /G maxpol, minpol, P_direction
string wname

Make/O /N=(abs(255/step)+1) /D 'PolDir'
Make/O /N=(abs(255/step)+1) /D 'ExtinctionRatio'
Make/O /N=(abs(255/step)+1) /D 'W_chisq'
SetScale/I x 0,255,"", PolDir,ExtinctionRatio, W_chisq

do
wname="tmp_"+num2str(i)
polarizationAnalysis(wname)
PolDir[i/step]=-P_direction+45
ExtinctionRatio[i/step]=minpol/maxpol
W_chisq[i/step]=chisq[7]
i+=step
while(i<256)

connection(step)
down(step,180)

end

macro down(step,deg)
variable j, step, deg, num
do
	num=0
	if(abs(PolDir[0])>deg)
		num+=1
		j=0
		do
			PolDir[j/step]-=PolDir[0]/abs(PolDir[0])*deg
			j+=step
		while(j<256)
	endif
while(num>0)
end

macro connection(step)
variable j, step, num=0
do
	j=0
	num=0
	do
		j+=step
		if(abs(PolDir[j/step]-PolDir[(j-step)/step])>70)
			PolDir[j/step] -= (PolDir[j/step]-PolDir[(j-step)/step])/abs(PolDir[j/step]-PolDir[(j-step)/step])*90
			num+=1
		endif
	while(j<256)
while(num>0)
end

macro b3(step,deg)
variable j, step, deg
j=0
do
j+=step
if(abs(PolDir[j/step]-PolDir[(j-1)/step])>deg)
print (PolDir[j/step]-PolDir[(j-1)/step])/deg, trunc((PolDir[j/step]-PolDir[(j-1)/step])/deg)
PolDir[j/step]-=trunc((PolDir[j/step]-PolDir[(j-1)/step])/deg)*deg
endif
while(j<256)

end

function over360(deg, threshhold)
variable  deg, threshhold
if (abs(deg)>threshhold)
deg-=trunc(deg/threshhold)*threshhold
endif
return deg
end

macro P_RGB()
	//CurveFitDialog/ w[0] = f
	//CurveFitDialog/ w[1] = phi
	//CurveFitDialog/ w[2] = y0
	//CurveFitDialog/ w[3] = A
	//CurveFitDialog/ w[4] = a2
	//CurveFitDialog/ w[5] = a3
	//CurveFitDialog/ w[6] = a4
Make/O /N=4 /D 'P_chisq'

CurveFit  sin  PolDir /D
P_chisq[0]=V_chisq
duplicate /O W_coef, coef_P1
duplicate /O W_sigma, sigma_P1

Make/D/N=5/O W_coef
W_coef= {coef_P1[2], coef_P1[3], coef_P1[0], coef_P1[1], 0}
FuncFit/H="10000" SLM_2 W_coef  PolDir /D
P_chisq[1]=V_chisq
W_coef[1]=over360(W_coef[1], 2*pi)
duplicate /O W_coef, coef_P2
duplicate /O W_sigma, sigma_P2

Make/D/N=6/O W_coef
W_coef[5]=0
FuncFit/H="100000"  SLM_3 W_coef  PolDir /D
P_chisq[2]=V_chisq
W_coef[1]=over360(W_coef[1], 2*pi)
duplicate /O W_coef, coef_P3
duplicate /O W_sigma, sigma_P3

Make/D/N=7/O W_coef
W_coef[6]=0
FuncFit/H="1000000"  SLM_4 W_coef  PolDir /D
P_chisq[3]=V_chisq
W_coef[3]=over360(W_coef[1], 2*pi)
duplicate /O W_coef, coef_P4
duplicate /O W_sigma, sigma_P4

end


Function polarization(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a*sin(a2*x^2+a1*x+b1)*sin(pi*(x+b)/180)+y0+a3*sin(2*pi*(x+b)/180)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 7
	//CurveFitDialog/ w[0] = a1
	//CurveFitDialog/ w[1] = b1
	//CurveFitDialog/ w[2] = b
	//CurveFitDialog/ w[3] = y0
	//CurveFitDialog/ w[4] = a
	//CurveFitDialog/ w[5] = a2
	//CurveFitDialog/ w[6] = a3

	return w[4]*sin(w[5]*x^2+w[0]*x+w[1])*sin(pi*(x+w[2])/180)+w[3]+w[6]*sin(2*pi*(x+w[2])/180)
End

Function Polarization_GCtrl_Linear(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a*sin(a1*x+b1)*sin(pi*(x+b)/180)+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = a
	//CurveFitDialog/ w[3] = b1
	//CurveFitDialog/ w[4] = a1

	return w[2]*sin(w[4]*x+w[3])*sin(pi*(x+w[1])/180)+w[0]
End

Function Polarization_GCtrl_NL2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x)=a*sin(a2*x^2+a1*x+b1)*sin(pi*(x+b)/180)+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 6
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = a
	//CurveFitDialog/ w[3] = b1
	//CurveFitDialog/ w[4] = a1
	//CurveFitDialog/ w[5] = a2

	return w[2]*sin(w[5]*x^2+w[4]*x+w[3])*sin(pi*(x+w[1])/180)+w[0]
End

Function Polarization_GCtrl_NL3(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a*sin(a3*x^3+a2*x^2+a1*x+b1)*sin(pi*(x+b)/180)+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 7
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = a
	//CurveFitDialog/ w[3] = b1
	//CurveFitDialog/ w[4] = a1
	//CurveFitDialog/ w[5] = a2
	//CurveFitDialog/ w[6] = a3

	return w[2]*sin(w[6]*x^3+w[5]*x^2+w[4]*x+w[3])*sin(pi*(x+w[1])/180)+w[0]
End

Function Polarization_Harmonic1(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a*sin(pi*(x+b)/180)+a1*sin(2*pi*(x+b1)/180)+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = a
	//CurveFitDialog/ w[3] = b1
	//CurveFitDialog/ w[4] = a1

	return w[2]*sin(pi*(x+w[1])/180)+w[4]*sin(2*pi*(x+w[3])/180)+w[0]
End

Function Polarization_Harmonic2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a*sin(pi*(x+b)/180)+a1*sin(2*pi*(x+b1)/180)+a2*sin(3*pi*(x+b2)/180)+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 7
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = a
	//CurveFitDialog/ w[3] = b1
	//CurveFitDialog/ w[4] = a1
	//CurveFitDialog/ w[5] = b2
	//CurveFitDialog/ w[6] = a2

	return w[2]*sin(pi*(x+w[1])/180)+w[4]*sin(2*pi*(x+w[3])/180)+w[6]*sin(3*pi*(x+w[5])/180)+w[0]
End

Function Polarization_harmonic3(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a*sin(pi*(x+b)/180)+a1*sin(2*pi*(x+b1)/180)+a2*sin(3*pi*(x+b2)/180)+a0*sin(0.5*pi*(x+b0)/180)+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 9
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = a
	//CurveFitDialog/ w[3] = b1
	//CurveFitDialog/ w[4] = a1
	//CurveFitDialog/ w[5] = b2
	//CurveFitDialog/ w[6] = a2
	//CurveFitDialog/ w[7] = b0
	//CurveFitDialog/ w[8] = a0

	return w[2]*sin(pi*(x+w[1])/180)+w[4]*sin(2*pi*(x+w[3])/180)+w[6]*sin(3*pi*(x+w[5])/180)+w[8]*sin(0.5*pi*(x+w[7])/180)+w[0]
End

Function Polarization_Harmonic4(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a*sin(pi*(x+b)/180)+a1*sin(2*pi*(x+b1)/180)+a2*sin(3*pi*(x+b2)/180)+a0*sin(0.5*pi*(x+b0)/180)+a3*sin(4*pi*(x+b3)/180)+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 11
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = a
	//CurveFitDialog/ w[3] = b1
	//CurveFitDialog/ w[4] = a1
	//CurveFitDialog/ w[5] = b2
	//CurveFitDialog/ w[6] = a2
	//CurveFitDialog/ w[7] = b0
	//CurveFitDialog/ w[8] = a0
	//CurveFitDialog/ w[9] = b3
	//CurveFitDialog/ w[10] = a3

	return w[2]*sin(pi*(x+w[1])/180)+w[4]*sin(2*pi*(x+w[3])/180)+w[6]*sin(3*pi*(x+w[5])/180)+w[8]*sin(0.5*pi*(x+w[7])/180)+w[10]*sin(4*pi*(x+w[9])/180)+w[0]
End

Function Polarization_Harmonic5(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a*sin(pi*(x+b)/180)+a1*sin(2*pi*(x+b1)/180)+a2*sin(3*pi*(x+b2)/180)+a0*sin(0.5*pi*(x+b0)/180)+a3*sin(4*p@Lâd$PL–LH Lã E3ÌAˆÄG\Ñ•∞dTˆê õê HhHãÀM2XË( ≥  IçWHDã–ÀË9Óˇˇ"M@åãî‚Lã»ÒãËËü± ¬ òcÑ∞à: ›ã˛Eä_[L ãAÉ„tbPEãWI]JA]˘F¯C]]Aã F]Î.]@O]F]ÎEâ©ÅTHÉ√Hˇœuà¥ﬂDã‡ﬂ;ÛvU±Y1 ÄfLãT›0_”Lã Àt-HçL›¯S√‡•fê¿YIP:I9@~Y„Aˇ √Hˇ√NâTÕ  D;ﬁr≥Aã O`∫·s(P s"¡ÈA ã’É·?ê; Òã¡B∆;– sˇ¬ÎÒ;˜ LãﬂvN˜ÖˇíN·ã◊ct(aJ›ÛaÇ¡A9¬av1ç›ˇ«êar;˛rºf!`sh˝E∂G^IãL@d∏◊£p =
◊£AÉ¿d)Òö@Mp-8 =L Ø¡E3“†:I˜ ËIç ?Mç ,H¡˚Hã √H¡Ë?Hÿ ÖˆÑ.–Aã \Mã¸ã«— ËD∂ÿJãT ≈ D9öÒá˘a1ãJH;ÀàèÏ¿ Aãá!XÄ¡Ë∂¿9Bãá”Ä∫bCurveFitDialog/ w[11] = b4
	//CurveFitDialog/ w[12] = a4

	return w[2]*sin(pi*(x+w[1])/180)+w[4]*sin(2*pi*(x+w[3])/180)+w[6]*sin(3*pi*(x+w[5])/180)+w[8]*sin(0.5*pi*(x+w[7])/180)+w[10]*sin(4*pi*(x+w[9])/180)+w[12]*sin(5*pi*(x+w[11])/180)+w[0]
End

Function Polarization_Harmonic6(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a*sin(pi*(x+b)/180)+a1*sin(2*pi*(x+b1)/180)+a2*sin(3*pi*(x+b2)/180)+a0*sin(0.5*pi*(x+b0)/180)+a3*sin(4*pi*(x+b3)/180)+a4*sin(5*pi*(x+b4)/180)+a5*sin(6*pi*(x+b5)/180)+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 15
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = a
	//CurveFitDialog/ w[3] = b1
	//CurveFitDialog/ w[4] = a1
	//CurveFitDialog/ w[5] = b2
	//CurveFitDialog/ w[6] = a2
	//CurveFitDialog/ w[7] = b0
	//CurveFitDialog/ w[8] = a0
	//CurveFitDialog/ w[9] = b3
	//CurveFitDialog/ w[10] = a3
	//CurveFitDialog/ w[11] = b4
	//CurveFitDialog/ w[12] = a4
	//CurveFitDialog/ w[13] = b5
	//CurveFitDialog/ w[14] = a5

	return w[2]*sin(pi*(x+w[1])/180)+w[4]*sin(2*pi*(x+w[3])/180)+w[6]*sin(3*pi*(x+w[5])/180)+w[8]*sin(0.5*pi*(x+w[7])/180)+w[10]*sin(4*pi*(x+w[9])/180)+w[12]*sin(5*pi*(x+w[11])/180)+w[14]*sin(6*pi*(x+w[13])/180)+w[0]
End

Function Polarization_Harmonic7(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a*sin(pi*(x+b)/180)+a1*sin(2*pi*(x+b1)/180)+a2*sin(3*pi*(x+b2)/180)+a0*sin(0.5*pi*(x+b0)/180)+a3*sin(4*pi*(x+b3)/180)+a4*sin(5*pi*(x+b4)/180)+a5*sin(6*pi*(x+b5)/180)+a6*sin(7*pi*(x+b6)/180)+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 17
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = a
	//CurveFitDialog/ w[3] = b1
	//CurveFitDialog/ w[4] = a1
	//CurveFitDialog/ w[5] = b2
	//CurveFitDialog/ w[6] = a2
	//CurveFitDialog/ w[7] = b0
	//CurveFitDialog/ w[8] = a0
	//CurveFitDialog/ w[9] = b3
	//CurveFitDialog/ w[10] = a3
	//CurveFitDialog/ w[11] = b4
	//CurveFitDialog/ w[12] = a4
	//CurveFitDialog/ w[13] = b5
	//CurveFitDialog/ w[14] = a5
	//CurveFitDialog/ w[15] = b6
	//CurveFitDialog/ w[16] = a6

	return w[2]*sin(pi*(x+w[1])/180)+w[4]*sin(2*pi*(x+w[3])/180)+w[6]*sin(3*pi*(x+w[5])/180)+w[8]*sin(0.5*pi*(x+w[7])/180)+w[10]*sin(4*pi*(x+w[9])/180)+w[12]*sin(5*pi*(x+w[11])/180)+w[14]*sin(6*pi*(x+w[13])/180)+w[16]*sin(7*pi*(x+w[15])/180)+w[0]
End



Function SLM_2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = A*sin(a2*x^2+f*x+phi)+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = f
	//CurveFitDialog/ w[1] = phi
	//CurveFitDialog/ w[2] = y0
	//CurveFitDialog/ w[3] = A
	//CurveFitDialog/ w[4] = a2

	return w[3]*sin(w[4]*x^2+w[0]*x+w[1])+w[2]
End

Function SLM_3(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = A*sin(a3*x^3+a2*x^2+f*x+phi)+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 6
	//CurveFitDialog/ w[0] = f
	//CurveFitDialog/ w[1] = phi
	//CurveFitDialog/ w[2] = y0
	//CurveFitDialog/ w[3] = A
	//CurveFitDialog/ w[4] = a2
	//CurveFitDialog/ w[5] = a3

	return w[3]*sin(w[5]*x^3+w[4]*x^2+w[0]*x+w[1])+w[2]

End

Function SLM_4(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = A*sin(a4*x^4+a3*x^3+a2*x^2+f*x+phi)+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 7
	//CurveFitDialog/ w[0] = f
	//CurveFitDialog/ w[1] = phi
	//CurveFitDialog/ w[2] = y0
	//CurveFitDialog/ w[3] = A
	//CurveFitDialog/ w[4] = a2
	//CurveFitDialog/ w[5] = a3
	//CurveFitDialog/ w[6] = a4

	return w[3]*sin(w[6]*x^4+w[5]*x^3+w[4]*x^2+w[0]*x+w[1])+w[2]
End

