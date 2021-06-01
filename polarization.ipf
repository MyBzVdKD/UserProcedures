#pragma rtGlobals=1		// Use modern global access method.


Function NI_DAQ_6025E_Init()
	fNIDAQ_Mode(2)
	fNIDAQ_BoardReset(1)
	fNIDAQ_SetInputChans(1, 16, 12, 1, 1)
	fNIDAQ_SetOutputChans(1, 2, 12, 0, 0, 0)
	fNIDAQ_OutputConfig(1, 0, 0, 10.000000)
	fNIDAQ_Mode(0)
End


Function  NI_DAQ_6025E_Obs(AvrTimes, Dev, Ch, Gain)
	Variable AvrTimes, Dev, Ch, Gain
	Variable ret=0, i
	for(i=0; i<AvrTimes; i+=1)
		ret+=fNIDAQ_ReadChan(Dev, Ch, Gain)
	endfor
	return ret/AvrTimes
End

macro Polarizer_Init(S, F, R)
	variable S, F, R //S: start, F: finish, R: acceleration
	String ans1 
	//SKIDS-60YAW: max movement 30deg/s, 0.005deg/pulse
	VDTWrite2/O=1/Q "D:2S"+num2str(S)+"F"+num2str(F)+"R"+num2str(R)+"\r\n"
	VDTRead2/t=",\n"/O=1/Q ans1
	do
		VDTWrite2/O=1/Q "H:2\r\n"
		VDTRead2/t=",\n"/O=1/Q ans1
	while(cmpstr(ans1, "NG\r")==0)
	do
		VDTWrite2/O=1/Q "!:\r\n"
		VDTRead2/t=",\n"/O=1/Q ans1
	while(cmpstr(ans1, "B\r")==0)
	Polarizer_Goto(29.61+180)
	do
		VDTWrite2/O=1/Q "R:2\r\n"
		VDTRead2/t=",\n"/O=1/Q ans1
	while(cmpstr(ans1, "NG\r")==0)
End

Function Polarizer_Ans()
	String ans1,ans2, ans3, ans4, ans5, ans6
	VDTWrite2/O=1/Q "Q:\r\n"
	VDTRead2/t=",\n"/O=1/Q ans1, ans2, ans3, ans4, ans5
	print ans1
	print ans2
	print ans3, ans4, ans5
	print str2num(ans2)
End

Function Polarizer_Goto(degree)
	Variable degree
	String ans1,ans2, ans3, ans4, ans5, ans6
	Variable num
	num=round((degree)*100)
	//print num
	do
		VDTWrite2/O=1/Q "!:\r\n"
		VDTRead2/t=",\n"/O=1/Q ans1
	while(cmpstr(ans1, "B\r")==0)
	do
		VDTWrite2/O=1/Q "A:2+P"+num2str(num)+"\r\n"
		VDTRead2/t=",\n"/O=1/Q ans1
	while(cmpstr(ans1, "NG\r")==0)
	do
		VDTWrite2/O=1/Q "G:\r\n"
		VDTRead2/t=",\n"/O=1/Q ans1
	while(cmpstr(ans1, "NG\r")==0)
	do
		VDTWrite2/O=1/Q "!:\r\n"
		VDTRead2/t=",\n"/O=1/Q ans1
	while(cmpstr(ans1, "B\r")==0)
End

Macro Obs_Polarization_dependence()
	string wname,ans1
	Variable i,j=0,k
//	Variable 	x1=V_x2, y1=V_y2, r=V_r2
	Variable i1, j1, mg0, mg1
	make /N=(1024,768)/O mglay
	
	do
		mglay=j
		//Execute "Circle1_2("+num2str(V_x2)+","+num2str(V_y2)+","+num2str(V_r2)+","+num2str(j)+")"

		do//delaying action
			 k+=1
		while(k<=4000)

		print j
		k=0
		do
			 k+=1
		while(k<=250)
		wname="tmp_"+num2str(j)
		PolarizationMeasurement(wname, 1)

		Polarizer_Goto(360)
		do
			VDTWrite2/O=1/Q "R:2\r\n"
			VDTRead2/t=",\n"/O=1/Q ans1
		while(cmpstr(ans1, "NG\r")==0)
		j+=5
	while (j<256)
End

Function Obs_Phase_Corr()
	Make/O/N=32 tmp2
	SetScale/P x 0,8,"intensity", tmp2
	String Alert
	Variable i
	for(i=0; i<32; i+=1)
		Alert="Set To "+num2str(i*8)
		DoAlert 0, Alert
		tmp2[i]=NI_DAQ_6025E_Obs(100,1,1,1)
	endfor
End

Macro Obs_Polarization_PeakToPeak()
	string ans1, wname
	Variable i,k
//		mglay=0
		Execute "Polarizer_Init("+num2str(V_SSpeed)+", "+num2str(V_FSpeed)+", "+num2str(V_ASpeed)+")"	
		wname="tmp"
		//Make/O/N=360 $wname
		//SetScale/P x 0,1,"degree", $wname
		i=-1
		do
			i+=1
			Polarizer_Goto(i)
			$wname[i]=NI_DAQ_6025E_Obs(100,1,1,1)
		while(i<360)
		Polarizer_Goto(360)
		do
			VDTWrite2/O=1/Q "R:2\r\n"
			VDTRead2/t=",\n"/O=1/Q ans1
		while(cmpstr(ans1, "NG\r")==0)
		
	WaveStats /Q $wname
	print "[Non-analized]"
	print "Extinction Ratio=",V_min/V_max
	if(V_maxloc>180)
		V_maxloc-=180
	endif
	if(V_minloc>180)
		V_minloc-=180
	endif
	print "Max Location=", V_maxloc
	print "Min Location=", V_minloc

	polarizationAnalysis(wname)


	print "[Analized]"
	print "chi=",chisq[7]
	print "Extinction Ratio=",(W_coef[0]-abs(W_coef[4]))/(W_coef[0]+abs(W_coef[4]))
	W_coef[3]+=45
	do
		W_coef[3]-=90
	while(W_coef[3]>90)
	do
		W_coef[3]+=90
	while(W_coef[3]<-90)

	if(W_coef[3]<0)
		print "Max Location=", (-W_coef[3])
		print "Min Location=", (-W_coef[3])+90
	else
		do
			W_coef[3]-=180
		while (W_coef[3]>0)
		if(-W_coef[3]>180)
			print "Max Location=", (-W_coef[3])+90
		else
			print "Max Location=", (-W_coef[3])-90
		endif
		print "Min Location=", -W_coef[3]
	endif

end


Macro polarizationAnalysis(wname)
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
string wname
variable i=0
variable /G maxpol, minpol, P_direction

Make/O /N=8 /D 'chisq'
WaveStats /Q $wname
K0 = (V_max+V_min)/2
K1 = (V_max+V_min)/2
K2 = 2*pi/180
K3 = 0
CurveFit /Q /N /H="0010" sin $wname /D 
CurveFit sin  $wname /D
chisq[0]=V_chisq
duplicate /O W_coef, coef_0
duplicate /O W_sigma, sigma_0
//‚Ç‚¤‚µ‚Ä‚à‚¾‚ß‚È‚ç¨‚’²”g‚ÌƒQƒCƒ“(0.1)‚ð’²®‚µ‚Ä‚Ý‚é
Make/D/N=5/O W_coef
//W_coef= {coef_0[0], coef_0[3]/pi*180, coef_0[1], 0, 1e-5}
W_coef= {coef_0[0], coef_0[3]/pi*180, 1, 0, coef_0[1]}
FuncFit /Q /N Polarization_Harmonic1 W_coef  $wname /D
chisq[1]=V_chisq
W_coef[1]=over360(W_coef[1], 360)
W_coef[3]=over360(W_coef[3], 360)
duplicate /O W_coef, coef_1
duplicate /O W_sigma, sigma_1

Make/D/N=7/O W_coef
W_coef[5]=0
W_coef[6]=0.1
FuncFit /Q /N Polarization_Harmonic2 W_coef  $wname /D
W_coef[1]=over360(W_coef[1], 360)
W_coef[3]=over360(W_coef[3], 180)
W_coef[5]=over360(W_coef[5], 120)


duplicate /O W_coef, coef_2
duplicate /O W_sigma, sigma_2

Make/D/N=9/O W_coef
W_coef[7]=0
W_coef[8]=0.1
FuncFit /Q /N Polarization_Harmonic3 W_coef  $wname /D
chisq[3]=V_chisq
W_coef[1]=over360(W_coef[1], 360)
W_coef[3]=over360(W_coef[3], 180)
W_coef[5]=over360(W_coef[5], 120)
W_coef[7]=over360(W_coef[7], 720)

duplicate /O W_coef, coef_3
duplicate /O W_sigma, sigma_3

Make/D/N=11/O W_coef
W_coef[9]=0
W_coef[10]=0.1
FuncFit /Q /N Polarization_Harmonic4 W_coef  $wname /D
chisq[4]=V_chisq
W_coef[1]=over360(W_coef[1], 360)
W_coef[3]=over360(W_coef[3], 180)
W_coef[5]=over360(W_coef[5], 120)
W_coef[7]=over360(W_coef[7], 720)
W_coef[9]=over360(W_coef[9], 90)

duplicate /O W_coef, coef_4
duplicate /O W_sigma, sigma_4

Make/D/N=13/O W_coef
W_coef[11]=0
W_coef[12]=0.1
FuncFit /Q /N Polarization_Harmonic5 W_coef  $wname /D
chisq[5]=V_chisq
W_coef[1]=over360(W_coef[1], 360)
W_coef[3]=over360(W_coef[3], 180)
W_coef[5]=over360(W_coef[5], 120)
W_coef[7]=over360(W_coef[7], 720)
W_coef[9]=over360(W_coef[9], 90)
W_coef[11]=over360(W_coef[11],72)

duplicate /O W_coef, coef_5
duplicate /O W_sigma, sigma_5

Make/D/N=15/O W_coef
W_coef[13]=0
W_coef[14]=0.1
FuncFit /Q /N Polarization_Harmonic6 W_coef  $wname /D
chisq[6]=V_chisq
W_coef[1]=over360(W_coef[1], 360)
W_coef[3]=over360(W_coef[3], 180)
W_coef[5]=over360(W_coef[5], 120)
W_coef[7]=over360(W_coef[7], 720)
W_coef[9]=over360(W_coef[9], 90)
W_coef[11]=over360(W_coef[11], 72)
W_coef[13]=over360(W_coef[13], 60)

duplicate /O W_coef, coef_6
duplicate /O W_sigma, sigma_6

Make/D/N=17/O W_coef
W_coef[15]=0
W_coef[16]=0.2
FuncFit /Q /N Polarization_Harmonic7 W_coef  $wname /D
chisq[7]=V_chisq
W_coef[1]=over360(W_coef[1], 360)
W_coef[3]=over360(W_coef[3], 180)
W_coef[5]=over360(W_coef[5], 120)
W_coef[7]=over360(W_coef[7], 720)
W_coef[9]=over360(W_coef[9], 90)
W_coef[11]=over360(W_coef[11], 72)
W_coef[11]=over360(W_coef[13], 60)
W_coef[15]=over360(W_coef[15], 51.4286)

duplicate /O W_coef, coef_7
duplicate /O W_sigma, sigma_7

maxpol=abs(W_coef[0])+abs(W_coef[4])
minpol=abs(W_coef[0])-abs(W_coef[4])
P_direction=W_coef[3]
//if (abs(P_direction)>360)
//P_direction=P_direction-trunc(P_direction/360)*360+90
//endif

end

macro TotalAnalysis(step)//fitting
variable i=0, step, j
variable /G maxpol, minpol, P_direction
string wname

Make/O /N=(abs(255/step)+1) /D 'PolDir'
Make/O /N=(abs(255/step)+1) /D 'ExtinctionRatio'
Make/O /N=(abs(255/step)+1) /D 'W_chisq'
SetScale/I x 0,255,"", PolDir,ExtinctionRatio, W_chisq

do
	print i
	wname="tmp_"+num2str(i)
	polarizationAnalysis(wname)
	PolDir[i/step]=-P_direction+45
	ExtinctionRatio[i/step]=minpol/maxpol
	W_chisq[i/step]=chisq[7]
	i+=step
while(i<256)

connection(step)
down(step,180)
PolDir=2*PolDir+90

WaveStats /Q PolDir
do
do
if(V_avg<0)
	PolDir=PolDir+180
	WaveStats /Q PolDir
endif
if(V_avg>180)
	PolDir=PolDir-180
	WaveStats /Q PolDir
endif
while(V_avg<0)
while(V_avg>180)
Interpolate2/T=3/N=256/F=0/Y=PolDir_SS PolDir
end



function TotalAnalysis2(step)//interpolation
variable step
variable  i=0,j
variable /G maxpol, minpol, P_direction
string wname

Make/O /N=(abs(255/step)+1) /D 'PolDir'
Make/O /N=(abs(255/step)+1) /D 'ExtinctionRatio'
Make/O /N=(abs(255/step)+1) /D 'W_chisq'
SetScale/I x 0,255,"", PolDir,ExtinctionRatio
WaveStats/Q/R=[0,128] $"tmp_0"

do
wname="tmp_"+num2str(i)
WaveStats/Q/R=(V_minloc-100,V_minloc+100) $wname
PolDir[i/step]=V_minloc
ExtinctionRatio[i/step]=V_min/V_max
i+=step
while(i<256)

execute "connection("+num2str(step)+")"
execute "down("+num2str(step)+",180)"
PolDir=2*PolDir-90

WaveStats /Q PolDir
do
if(V_avg<0)
	PolDir=PolDir+180
	WaveStats /Q PolDir
endif
if(V_avg>180)
	PolDir=PolDir-180
	WaveStats /Q PolDir
endif
while(V_avg<0&V_avg>180)

//execute "P_RGB()"
Interpolate2/T=3/N=256/F=0/Y=PolDir_SS PolDir
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
		if(abs(PolDir[j/step]-PolDir[(j-step)/step])>45)
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
	if(abs(deg)<1e-1)
		deg=1e-1
	endif
	return deg
end


macro P_RGB_old()
	//CurveFitDialog/ w[0] = f
	//CurveFitDialog/ w[1] = phi
	//CurveFitDialog/ w[2] = y0
	//CurveFitDialog/ w[3] = A
	//CurveFitDialog/ w[4] = a2
	//CurveFitDialog/ w[5] = a3
	//CurveFitDialog/ w[6] = a4
Make/O /N=6 /D 'P_chisq'

CurveFit /Q sin  PolDir /D
P_chisq[0]=V_chisq
duplicate /O W_coef, coef_P1
duplicate /O W_sigma, sigma_P1

Make/D/N=5/O W_coef
W_coef= {coef_P1[2], coef_P1[3], coef_P1[0], coef_P1[1], 0}
FuncFit /Q/H="10000" SLM_2 W_coef  PolDir /D
P_chisq[1]=V_chisq
W_coef[1]=over360(W_coef[1], 2*pi)
duplicate /O W_coef, coef_P2
duplicate /O W_sigma, sigma_P2

Make/D/N=6/O W_coef
W_coef[5]=0
FuncFit /Q/H="100000"  SLM_3 W_coef  PolDir /D
P_chisq[2]=V_chisq
W_coef[1]=over360(W_coef[1], 2*pi)
duplicate /O W_coef, coef_P3
duplicate /O W_sigma, sigma_P3

Make/D/N=7/O W_coef
W_coef[6]=0
FuncFit /Q/H="1000000"  SLM_4 W_coef  PolDir /D
P_chisq[3]=V_chisq
W_coef[1]=over360(W_coef[1], 2*pi)
duplicate /O W_coef, coef_P4
duplicate /O W_sigma, sigma_P4

Make/D/N=8/O W_coef
W_coef[7]=0
FuncFit /Q/H="10000000"  SLM_5 W_coef  PolDir /D
P_chisq[4]=V_chisq
W_coef[1]=over360(W_coef[1], 2*pi)
duplicate /O W_coef, coef_P5
duplicate /O W_sigma, sigma_P5

Make/D/N=9/O W_coef
W_coef[8]=0
FuncFit /H="100000000"  SLM_6 W_coef  PolDir /D
P_chisq[5]=V_chisq
W_coef[1]=over360(W_coef[1], 2*pi)
duplicate /O W_coef, coef_P6
duplicate /O W_sigma, sigma_P6

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
	//CurveFitDialog/ f(x) = a*sin(pi*(x+b)/180)+a1*sin(2*pi*(x+b1)/180)+a2*sin(3*pi*(x+b2)/180)+a0*sin(0.5*pi*(x+b0)/180)+a3*sin(4*pi*(x+b3)/180)+a4*sin(5*pi*(x+b4)/180)+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 13
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

Function SLM_5(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = A*sin(a5*x^5+a4*x^4+a3*x^3+a2*x^2+f*x+phi)+y0
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
	//CurveFitDialog/ w[7] = a5

	return w[3]*sin(w[7]*x^5+w[6]*x^4+w[5]*x^3+w[4]*x^2+w[0]*x+w[1])+w[2]
End

Function SLM_6(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = A*sin(a6*x^6+a5*x^5+a4*x^4+a3*x^3+a2*x^2+f*x+phi)+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 8
	//CurveFitDialog/ w[0] = f
	//CurveFitDialog/ w[1] = phi
	//CurveFitDialog/ w[2] = y0
	//CurveFitDialog/ w[3] = A
	//CurveFitDialog/ w[4] = a2
	//CurveFitDialog/ w[5] = a3
	//CurveFitDialog/ w[6] = a4
	//CurveFitDialog/ w[7] = a5
	//CurveFitDialog/ w[8] = a6

	return w[3]*sin(w[8]*x^6+w[7]*x^5+w[6]*x^4+w[5]*x^3+w[4]*x^2+w[0]*x+w[1])+w[2]
End


Macro Obs_Polarization_dependence_old(V_DevPol,V_DevSLM)
	variable V_DevPol, V_DevSLM
	string wname,ans1
	Variable i,j=0,k
	do
		mglay=j
		print j
		k=0
		do
			 k+=1
		while(k<=4000)
		wname="tmp_"+num2str(j)
		Make/O/N=(360/V_DevPol) $wname
		SetScale/P x 0,V_DevPol,"deg", $wname
		$wname=0
		i=0
		do
			Polarizer_Goto(i)
			k=0
			do
				 k+=1
			while(k<=400)
			$wname[i/V_DevPol]=NI_DAQ_6025E_Obs(100,1,1,1)
			i+=V_DevPol
		while(i<360)
		Polarizer_Goto(360)
		do
			VDTWrite2/O=1/Q "R:2\r\n"
			VDTRead2/t=",\n"/O=1/Q ans1
		while(cmpstr(ans1, "NG\r")==0)
		j+=V_DevSLM
	while (j<256)
End

macro PolarizationMeasurement(wname, dev)
	string wname
	variable dev
	variable i=0
	silent 1
	Make/O/N=(360/dev) $wname
	setscale /I x, 0, 360, "deg", $wname
	do
		i+=1
	while(i<999)
	i=0
	do
		//NI_DAQ_6025E_Obs(AvrTimes, Dev, Ch, Gain)
		$wname[i]=NI_DAQ_6025E_Obs(128,1,1,1)
		i+=1
		Polarizer_Goto(i*dev)
	while(i<360/dev)
		
end

macro Fitting(wname)//fitting
variable i=0, step, j
variable /G maxpol, minpol, P_direction
string wname
silent 1
	polarizationAnalysis(wname)
	print "["+wname+"]"
	print "Polarization	"+num2str(-P_direction+45)+"deg"
	print "Extinction Ratio	"+num2str(minpol/maxpol)
	print "Chi_sqr	"+num2str(chisq[7])

//PolDir=2*PolDir+90
end

macro Profiler(prestring, wavelength, rotation, PowerRange, dev, AppendFlag)
//dev: 
//AppendFlag:(=0 NewGraph, !=0 AppendTracesToPreexsistingGraph)
string prestring
variable wavelength, rotation, PowerRange, dev, AppendFlag
string wname=prestring+"_"+num2str(wavelength)+"nm_"+num2str(rotation)+"deg"
Execute "Polarizer_Init("+num2str(V_SSpeed)+", "+num2str(V_FSpeed)+", "+num2str(V_ASpeed)+")"
PolarizationMeasurement(wname, dev)
$wname=$wname*PowerRange

if (AppendFlag)
	AppendToGraph $wname
else
	Display $wname
	ModifyGraph margin(left)=40,margin(bottom)=34,margin(top)=0,margin(right)=142
	Label left "Power / mW"
	Label bottom "Polarizer / \U"
endif
Fitting(wname)
	TextBox /B=1/F=0/A=MC  "\Z06\s("+wname+")["+wname+"]\rPolarization	"+num2str(-P_direction+45)+"deg\rExtinction Ratio	"+num2str(minpol/maxpol)+"\rChi_sqr	"+num2str(chisq[7])
end
//C/N=$wname