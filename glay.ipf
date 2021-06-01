#pragma rtGlobals=1		// Use modern global access method.


function circle1(x1, y1, r, int)
	Variable x1, y1, r, int
	Variable i, j, mg0, mg1
	wave mglay
	make /N=(1024,768)/O mglay
	mg0=DEGtoRGB(0)
	mg1=DEGtoRGB(int*2)
	for(i=0; i<1024; i+=1)
		for(j=0; j<=768; j+=1)
			if( r*r > (i-x1)*(i-x1)+(j-y1)*(j-y1))
				mglay[i][j]=mg1
			else
				mglay[i][j]=mg0
			endif
		endfor
	endfor
end

function circle1_2(x1, y1, r, int)
	Variable x1, y1, r, int
	Variable i, j, mg0, mg1
	wave mglay
	make /N=(1024,768)/O mglay
	mg0=0
	mg1=int
	for(i=0; i<1024; i+=1)
		for(j=0; j<=768; j+=1)
			if( r*r > (i-x1)*(i-x1)+(j-y1)*(j-y1))
				mglay[i][j]=mg1
			else
				mglay[i][j]=mg0
			endif
		endfor
	endfor
end


function circle2(x1,y1,r1,x2,y2,r2,int1,int2)
	Variable x1, y1, r1, x2, y2, r2, int1, int2
	Variable i, j, mg0, mg1, mg2
	wave coef_P3
	make /N=(1024,768)/O mglay
	mg0=DEGtoRGB(0)
	mg1=DEGtoRGB(int1*2)
	mg2=DEGtoRGB(int2*2)
	print mg0, mg1,mg2
	for(i=0; i<1024; i+=1)
		for(j=0; j<=768; j+=1)
			if( r1*r1 > (i-x1)*(i-x1)+(j-y1)*(j-y1))
				mglay[i][j]=mg1
			elseif( r2*r2 > (i-x2)*(i-x2)+(j-y2)*(j-y2))
				mglay[i][j]=mg2
			else
				mglay[i][j]=mg0
			endif
		endfor
	endfor
end


function radial1(x1, y1, x2, y2, r)
	Variable x1, y1, x2, y2, r
	Variable i, j, mg0, xf, yf
	make /N=(1024,768)/O mglay
	mg0=DEGtoRGB(0)
	for(i=0; i<1024; i+=1)
		for(j=0; j<=768; j+=1)
			if( r*r > (i-x1)*(i-x1)+(j-y1)*(j-y1))//Circle1
			
				if((i-x1>=0) & (j-y1>=0)) //the ‚P‚“‚” quadrant
					mglay[i][j]=DEGtoRGB(180/pi*atan((j-y1)/(i-x1)))
				elseif((i-x1<=0)&(j-y1>=0)) //the 2nd quadrant
					mglay[i][j]=DEGtoRGB(180/pi*(-atan((i-x1)/(j-y1))+pi/2))
				elseif((i-x1<0)&(j-y1<=0)) //the 3rd quadrant
					mglay[i][j]=DEGtoRGB(180/pi*(atan((j-y1)/(i-x1))+pi))
				elseif((i-x1==0)&(j-y1==0))//Center
					mglay[i][j]=0
				elseif((i-x1>=0)&(j-y1<=0)) //the 4th quadrant
					mglay[i][j]=DEGtoRGB(180/pi*(-atan((i-x1)/(j-y1))+3*pi/2))
				endif

			elseif( r*r > (i-x2)*(i-x2)+(j-y2)*(j-y2))//Circle2
				mglay[i][j]=-atan((j-y2)/(i-x2))+pi/4
				if(mglay[i][j]<0) 
					mglay[i][j]+=pi
				endif

				if (mglay[i][j])
					mglay[i][j]=DEGtoRGB(360/pi*mglay[i][j])
				elseif(mglay[i][j]==inf)//n*90 deg
					mglay[i][j]=DEGtoRGB(360/pi*mglay[i][j])
				else //center
					mglay[i][j]=mg0
				endif
			else
				mglay[i][j]=mg0
			endif
			
		endfor
	endfor
end

function radial2(x1, y1, x2, y2, r)
	Variable x1, y1, x2, y2, r
	Variable i, j, mg0
	make /N=(1024,768)/O mglay
	mg0=DEGtoRGB(0)
	for(i=0; i<1024; i+=1)
		for(j=0; j<=768; j+=1)
			if( r*r > (i-x1)*(i-x1)+(j-y1)*(j-y1))//Circle1
			//print "X1"+num2str(i-x1)+"_Y1"+num2str(j-y1)
				if((i-x1>=0)&(j-y1>=0)) //the ‚P‚“‚” quadrant
					mglay[i][j]=DEGtoRGB(180/pi*atan((j-y1)/(i-x1)))
				elseif((i-x1<=0)&(j-y1>=0)) //the 2nd quadrant
					mglay[i][j]=DEGtoRGB(180/pi*(-atan((i-x1)/(j-y1))+pi/2))
				elseif((i-x1<0)&(j-y1<=0)) //the 3rd quadrant
					mglay[i][j]=DEGtoRGB(180/pi*(atan((j-y1)/(i-x1))+pi))
				elseif((i-x1==0)&(j-y1==0))//Center
					mglay[i][j]=0
				elseif((i-x1>=0)&(j-y1<=0)) //the 4th quadrant
					mglay[i][j]=DEGtoRGB(180/pi*(-atan((i-x1)/(j-y1))+3*pi/2))
				endif
				
			elseif( r*r > (i-x2)*(i-x2)+(j-y2)*(j-y2))//Circle2
				//print "X2"+num2str(i-x2)+"_Y2"+num2str(j-y2)
				mglay[i][j]=atan((j-y2)/(i-x2))-pi/4
				if(mglay[i][j]<0) 
					mglay[i][j]+=pi
				endif
				
				if (mglay[i][j])
					mglay[i][j]=DEGtoRGB(360/pi*mglay[i][j])
				elseif(mglay[i][j]==inf)//n*90 deg
					mglay[i][j]=DEGtoRGB(360/pi*mglay[i][j])
				else //center
					mglay[i][j]=mg0
				endif
				
			else
				mglay[i][j]=mg0
			endif
		endfor
	endfor
end

function Bisection(left, right, dirc, e, a, a3, a2, f, phi, y0)
variable left, right, dirc, e, a, a3, a2, f, phi, y0
variable rev, c, i, func
	if((sin3(a, a3, a2, f, phi, y0, left)-dirc) > 1e-9)
		if((sin3(a, a3, a2, f, phi, y0, right)-dirc) > 1e-9)
			dirc=dirc+180
		endif
	endif
	if((sin3(a, a3, a2, f, phi, y0, left)-dirc) < 1e-9)
		if((sin3(a, a3, a2, f, phi, y0, right)-dirc) < 1e-9)
			dirc=dirc-180
		endif
	endif
	rev =0
	if((sin3(a, a3, a2, f, phi, y0, left)-dirc) > 1e-9) 
		rev = 1
	endif

	for(i = 0; ; i+=1)
		c = (left + right) / 2
		func  = sin3(a, a3, a2, f, phi, y0, c)-dirc
//		print c,"	",func,"	",left,"	",right
		if(rev)
			func = -func
		endif
		if(func < 0)
			left = c
		else
			right = c
		endif
		if(right - left < e)
			c = (left + right) / 2
//			print c
			return c
		endif
	endfor
end

function sin3(a, a3, a2, f, phi, y0, RGB)
	variable a, a3, a2, f, phi, y0, RGB
	return (a*sin(a3*RGB^3+a2*RGB^2+f*RGB+phi)+y0)
end


function DEGtoRGB(deg)
	variable deg
	variable RGB, i, j
	wave PolDir_SS
	for(j = 0; j<720; j+=360)
		deg-=j
		for(i = 1; i<=255; i+=1)//255?
			if(PolDir_SS[i-1]*PolDir_SS[i] <= 0)
				if((PolDir_SS[i-1]-deg)*(PolDir_SS[i]-deg)<=0)
					if(abs(PolDir_SS[i-1]-deg)>=abs(PolDir_SS[i]-deg))
						RGB=i
					else
						RGB=i-1
					endif
					return RGB
				 endif
			else
				if((PolDir_SS[i-1]-deg)*(PolDir_SS[i]-deg)<=0)
					if(abs(PolDir_SS[i-1]-deg)<=abs(PolDir_SS[i]-deg))
						RGB=i-1
					else
						RGB=i
					endif
					return RGB
				endif
			endif
		endfor
	endfor
	//abort num2str(deg)+"/ deg missiing RGB value"
	return nan
end


function DEGtoRGB_old (deg)
	variable deg
	variable RGB, i, cnt=0
	wave PolDir_SS
	if(deg==360)
	deg=0
	endif
	for(i = 1; i<=255; i+=1)//255?
		
		//if((PolDir_SS[i-1]<=0) & (deg!=0))
		
		if(PolDir_SS[i-1]*PolDir_SS[i] <= 0)
			if((PolDir_SS[i-1]-deg)*(PolDir_SS[i]-deg)<=0)
				if(abs(PolDir_SS[i-1]-deg)>=abs(PolDir_SS[i]-deg))
					RGB=i
				else
					RGB=i-1
				endif
				return RGB
			 endif

		elseif(PolDir_SS[i-1]<=0)
			if((360.0+PolDir_SS[i-1]-deg)*(360.0+PolDir_SS[i]-deg)<=0)
				if(abs(360.0+PolDir_SS[i-1]-deg)<=abs(360.0+PolDir_SS[i]-deg))
					RGB=i-1
				else
					RGB=i
				endif
				return RGB
			endif
		else
			if((PolDir_SS[i-1]-deg)*(PolDir_SS[i]-deg)<=0)
				if(abs(PolDir_SS[i-1]-deg)<=abs(PolDir_SS[i]-deg))
					RGB=i-1
				else
					RGB=i
				endif
				return RGB
			endif
		endif
		
	endfor
	abort num2str(deg)+"/ deg missiing RGB value"
	return nan

end

function F_reverse(axs, xc, yc, r)
string axs
variable  xc, yc, r
variable i, j, intmed
wave mglay=$"mglay"
for(i=0; i<1024; i+=1)
	for(j=0; j<=768; j+=1)
		if( r*r > (i-xc)*(i-xc)+(j-yc)*(j-yc) )
			if(cmpstr(axs, "x" )==0)
			if(j<yc)
				intmed=mglay[i][j]
				mglay[i][j]=mglay[i][2*yc-j]
				mglay[i][2*yc-j]=intmed
			endif
			endif
		elseif(r*r > (i-xc)*(i-xc)+(j-yc)*(j-yc))
			if(cmpstr(axs, "y" )==0)
			if(i<xc)
				intmed=mglay[i][j]
				mglay[i][j]=mglay[2*xc-i][j]
				mglay[2*xc-i][j]=intmed
			endif
			endif
		endif
	endfor
endfor
end

macro RP1(x1, y1, x2, y2, r)
variable x1, y1, x2, y2, r
mglay=RP1Ptn
end

macro RP2(x1, y1, x2, y2, r)
variable x1, y1, x2, y2, r
mglay=RP2Ptn
end

macro RP3(x1, y1, x2, y2, r)
variable x1, y1, x2, y2, r
mglay=RP3Ptn
end


macro RP4(x1, y1, x2, y2, r)
variable x1, y1, x2, y2, r
mglay=RP4Ptn
end




Window Graph0() : Graph
	PauseUpdate; Silent 1		// building window...
	Display /W=(759,-5.5,1821,559.25)
	AppendImage mglay
	ModifyImage mglay ctab= {*,255,Grays,0}
	ModifyGraph width={Aspect,1.33333},height={perUnit,1,left}
	ModifyGraph tick=3
	ModifyGraph mirror=0
	ModifyGraph noLabel=2
	ModifyGraph axOffset(left)=-10,axOffset(bottom)=-3.11111
	ModifyGraph axThick(left)=0
EndMacro

Proc Graph0Style() : GraphStyle
	PauseUpdate; Silent 1		// modifying window...
	ModifyGraph/Z width={Aspect,1.33333},height={perUnit,1,left}
	ModifyGraph/Z tick=3
	ModifyGraph/Z mirror=0
	ModifyGraph/Z noLabel=2
	ModifyGraph/Z axOffset(left)=-10,axOffset(bottom)=-3.11111
	ModifyGraph/Z axThick(left)=0
EndMacro

function phase2RGB(phase)
variable phase
variable i=128
wave PolDir
do
	if(phase>PolDir[i]&phase>PolDir[i+1])
		i+=1
	elseif(phase<PolDir[i]&phase<PolDir[i-1])
		i-=1
	elseif((phase-PolDir[i])*(PolDir[i+1]-phase)>0)
		if((phase-PolDir[i])<(PolDir[i+1]-phase))
			return PolDir[i]
		else
			return PolDir[i+1]
		endif
	elseif((PolDir[i]-phase)*(phase-PolDir[i-1])>0)
		if((PolDir[i]-phase)<(phase-PolDir[i-1]))
			return PolDir[i]
		else
			return PolDir[i-1]
		endif
	endif
	if(i<0)
	phase+=360
	endif
	if(i>255)
	phase-=360
	endif
while (1)
end

Function PatternGen(ctrlName) : ButtonControl
	String ctrlName
	NVAR V_x1=V_x1
	NVAR V_y1=V_y1
	NVAR V_x2=V_x2
	NVAR V_y2=V_y2
	NVAR V_r1=V_r1
	NVAR V_r2=V_r2
	variable mg
	radial1(V_x1, V_y1, V_x2, V_y2, V_r1)
	duplicate /O mglay RP1Ptn
	print "RP1"
	
	F_reverse("x",V_x1,V_y1 ,V_r1)
	duplicate /O mglay RP3Ptn
	print "RP3"
	
	radial2(V_x1, V_y1, V_x2, V_y2, V_r1)
	duplicate /O mglay RP2Ptn
	print "RP2"
	
	F_reverse("x",V_x1,V_y1, V_r1)
	duplicate /O mglay RP4Ptn
	print "RP4"
	
	circle1(V_x2, V_y2, V_r2, 0)
	duplicate /O mglay LP045
	print "LP45"
	
	circle1(V_x2, V_y2, V_r2, 90)
	duplicate /O mglay LP_045
	print "LP-45"
	
	circle1(V_x2, V_y2, V_r2, 135)
	duplicate /O mglay LP090
	print "LP90"
	
	circle1(V_x2, V_y2, V_r2, 45)
	duplicate /O mglay LP000
	print "LP00"
	


End







Function LP_45(ctrlName) : ButtonControl
	String ctrlName
	wave mglay, LP_045
	mglay=LP_045
End

Function LP45(ctrlName) : ButtonControl
	String ctrlName
	wave mglay, LP045
	mglay=LP045
End












Function LP00(ctrlName) : ButtonControl
	String ctrlName
	wave mglay, LP000
	mglay=LP000
	Nvar LCD_Ctrl_Status
	//if(LCD_Ctrl_Status)//turn OFF LCD wavegeneration
		LCD_Ctrl_ButtonProc("LP00")
	//endif
	LCD_Control_pol("LP00",2,"Xpol")	//"Radial;Xpol;Ypol"
	LCD_Ctrl_ButtonProc("LP00")
End

Function LP90(ctrlName) : ButtonControl
	String ctrlName
	wave mglay, LP090
	mglay=LP090
	Nvar LCD_Ctrl_Status
	//if(LCD_Ctrl_Status)//turn OFF LCD wavegeneration
		LCD_Ctrl_ButtonProc("LP090")
	//endif
	LCD_Control_pol("LP90",3,"Ypol")	//"Radial;Xpol;Ypol"
	LCD_Ctrl_ButtonProc("LP90")
End
