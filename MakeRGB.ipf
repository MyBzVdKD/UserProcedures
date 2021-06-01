#pragma rtGlobals=1		// Use modern global access method.
//#include  <All IP Procedures>
#include  <Image Saver>
#include <WindowBrowser>
//global variables for RGB superposition
string /G WN_R
string /G WN_G
string /G WN_B
variable /G R_X
variable /G R_Y
variable /G G_X
variable /G G_Y
variable /G B_X
variable /G B_Y
variable /G R_mag
variable /G R_shift
variable /G G_mag
variable /G G_shift
variable /G B_mag
variable /G B_shift
variable /G F_8bit=1
variable /G F_RGB=1
variable /G F_scale=0
string /G S_wname




function ULfix(S_wname, V_upper, V_lower)
	string S_wname
	variable V_upper, V_lower
	wave wv=$S_wname
	wavestats /Q wv
	wv-=V_min-V_lower
	V_max-=V_min-V_lower
	wv=wv/abs(V_max)*abs(V_upper)
end


Function PM_Scaling(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	nvar F_scale
	F_scale=popNum
	RGB_RefreshChannels("PM_Scaling")
End

Function PM_Rwave(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	svar WN_R
	wave W_R=$WN_R
	WN_R=popStr
	RGB_RefreshChannels("PM_Rwave")

End

Function PM_Gwave(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	svar WN_G
	wave W_G=$WN_G
	WN_G=popStr
	RGB_RefreshChannels("PM_Gwave")

End

Function PM_Bwave(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	svar WN_B
	wave W_B=$WN_B
	WN_B=popStr
	RGB_RefreshChannels("PM_Bwave")

End

Function C_8bit(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	nvar F_8bit
	F_8bit=checked
	RGB_RefreshChannels("C_8bit")
End

Function SV_RX(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	nvar R_X
	R_X=varNum
	RGBsperpose("SV_RX")
End

Function SV_RY(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	nvar R_Y
	R_Y=varNum
	RGBsperpose("SV_RY")
End

Function SV_GX(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	nvar G_X
	G_X=varNum
	RGBsperpose("SV_GX")
End

Function SV_GY(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	nvar G_Y
	G_Y=varNum
	RGBsperpose("SV_GY")
End

Function SV_BX(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	nvar B_X
	B_X=varNum
	RGBsperpose("SV_BX")
End

Function SV_BY(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	nvar B_Y
	B_Y=varNum
	RGBsperpose("SV_BY")
End

Function SV_R_mag(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	nvar R_mag
	R_mag=varNum
	RGBsperpose("SV_R_mag")
End

Function SV_G_mag(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	nvar G_mag
	G_mag=varNum
	RGBsperpose("SV_G_mag")
End

Function SV_B_mag(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	nvar B_mag
	B_mag=varNum
	RGBsperpose("SV_B_mag")
End

Function SV_R_shift(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	nvar R_shift
	R_shift=varNum
	RGBsperpose("SV_R_shift")
End

Function SV_G_shift(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	nvar G_shift
	G_shift=varNum
	RGBsperpose("SV_G_shift")
End

Function SV_B_shift(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	nvar B_mag
	B_mag=varNum
	RGBsperpose("SV_B_mag")
End

Window PC_RGB_Indicator() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(119,61,434,448) as "RGB_Indicator"
	ShowTools
	PopupMenu Rwave,pos={13,7},size={164,23},proc=PM_Rwave,title="Red",font="Arial"
	PopupMenu Rwave,mode=7,popvalue="CLMS_XYwave_RP1",value= #"WaveList(\"*\",\";\",\"DIMS:2\")+\";_none_\""
	PopupMenu Gwave,pos={2,27},size={179,23},proc=PM_Gwave,title="Green"
	PopupMenu Gwave,font="Arial"
	PopupMenu Gwave,mode=8,popvalue="CLMS_XYwave_LP00",value= #"WaveList(\"*\",\";\",\"DIMS:2\")+\";_none_\""
	PopupMenu Bwave,pos={11,47},size={170,23},proc=PM_Bwave,title="Blue"
	PopupMenu Bwave,font="Arial"
	PopupMenu Bwave,mode=9,popvalue="CLMS_XYwave_LP90",value= #"WaveList(\"*\",\";\",\"DIMS:2\")+\";_none_\""
	Button B_Refresh,pos={180,94},size={79,30},proc=RGB_RefreshChannels,title="Refresh"
	Button B_Refresh,labelBack=(52224,52224,52224),font="Arial"
	Button B_Refresh,fColor=(65280,65280,48896)
	SetVariable RX,pos={175,9},size={50,18},proc=SV_RX,title="X",font="Arial"
	SetVariable RX,value= R_X
	SetVariable RY,pos={230,9},size={50,18},proc=SV_RY,title="Y",font="Arial"
	SetVariable RY,value= R_Y
	SetVariable GX,pos={175,30},size={50,18},proc=SV_GX,title="X",font="Arial"
	SetVariable GX,value= G_X
	SetVariable GY,pos={229,30},size={50,18},proc=SV_GY,title="Y",font="Arial"
	SetVariable GY,value= G_Y
	SetVariable BX,pos={175,51},size={50,18},proc=SV_BX,title="X",font="Arial"
	SetVariable BX,value= B_X
	SetVariable BY,pos={229,51},size={50,18},proc=SV_BY,title="Y",font="Arial"
	SetVariable BY,value= B_Y
	CheckBox C_norm,pos={5,73},size={131,15},proc=C_8bit,title="Normarization to 8bit"
	CheckBox C_norm,font="Arial",variable= F_8bit
	PopupMenu Scaling,pos={5,95},size={159,20},proc=PM_Scaling,title="ScalingMethod"
	PopupMenu Scaling,mode=1,bodyWidth= 80,popvalue="x",value= #"\"x;log10;log2;ln\""
	Button SaveRGB,pos={186,72},size={63,20},proc=BP_SaveImage,title="SaveRGB"
	Button SaveRGB,font="Arial"
	Display/W=(6,126,271,375)/HOST=# 
	AppendImage/T Im_RGBsuperpose
	ModifyImage Im_RGBsuperpose ctab= {*,*,Grays,0}
	ModifyGraph margin(left)=14,margin(bottom)=14,margin(top)=14,margin(right)=14
	ModifyGraph mirror=2
	ModifyGraph nticks=3
	ModifyGraph minor=1
	ModifyGraph fSize=8
	ModifyGraph standoff=0
	ModifyGraph tkLblRot(left)=90
	ModifyGraph btLen=3
	ModifyGraph tlOffset=-2
	Label left "\\F'Arial'\\U"
	Label top "\\F'Arial'\\U"
	SetAxis/A/R left
	RenameWindow #,SuperposedRGB
	SetActiveSubwindow ##
EndMacro


Function RGBsperpose(ctrlname)
	String ctrlName
	variable i
	wave W_Rch
	wave W_Gch
	wave W_Bch
	nvar R_X
	nvar R_Y
	nvar G_X
	nvar G_Y
	nvar B_X
	nvar B_Y
	variable V_Xnpnt, V_Ynpnt
	i=0

	
	V_Xnpnt=max(dimsize(W_Rch, 0), dimsize(W_Gch, 0))
	V_Xnpnt=max(V_Xnpnt, dimsize(W_Bch, 0))
	V_Ynpnt=max(dimsize(W_Rch, 1), dimsize(W_Gch, 1))
	V_Ynpnt=max(V_Ynpnt, dimsize(W_Bch, 1))

	Make /O /N=((V_Xnpnt),(V_Ynpnt),3)/B/U Im_RGBsuperpose
	
	Im_RGBsuperpose[][][0]=W_Rch[p-R_X][q-R_Y]
	Im_RGBsuperpose[][][1]=W_Gch[p-G_X][q-G_Y]
	Im_RGBsuperpose[][][2]=W_Bch[p-B_X][q-B_Y]
	
	makenote("RGBsperpose", "Im_RGBsuperpose")
	note /NOCR Im_RGBsuperpose,"(X_R, Y_R) = ("+num2str(R_X)+", "+num2str(R_Y)+")"
	note /NOCR Im_RGBsuperpose,"(X_G, Y_G) = ("+num2str(G_X)+", "+num2str(G_Y)+")"
	note /NOCR Im_RGBsuperpose,"(X_B, Y_B) = ("+num2str(B_X)+", "+num2str(B_Y)+")"
	//wavescaling("RGBsperpose", "Im_RGBsuperpose", 0, 0)
	//wavescaling("RGBsperpose", "Im_RGBsuperpose", 1, 1)
end

Function BP_SaveImage(ctrlName) : ButtonControl
	String ctrlName
	wave Im_RGBsuperpose
	Save/T/M="\r\n" Im_RGBsuperpose as "Im_RGBsuperpose.itx"
End

Function RGB_RefreshChannels(ctrlName) : ButtonControl
	String ctrlName
	variable Vmax_Rch, Vmax_Gch, Vmax_Bch, Vmin_Rch, Vmin_Gch, Vmin_Bch
	variable V_max, V_RGBmax
	svar WN_R
	svar WN_G
	svar WN_B
	nvar F_scale
	nvar F_8bit
	wave W_R=$WN_R
	wave W_G=$WN_G
	wave W_B=$WN_B
	duplicate /O W_R W_Rch
	duplicate /O W_G W_Gch
	duplicate /O W_B W_Bch
	
	switch(F_scale)//scaling
		case 1://x
			break
		case 2://log10
			W_Rch=log(W_Rch)
			W_Gch=log(W_Gch)
			W_Bch=log(W_Bch)
			break
		case 3://log2
			W_Rch=log(W_Rch)/log(2)
			W_Gch=log(W_Gch)/log(2)
			W_Bch=log(W_Bch)/log(2)
			break
		case 4://ln
			W_Rch=ln(W_Rch)
			W_Gch=ln(W_Gch)
			W_Bch=ln(W_Bch)
			break
		default:	
			print "Invailed scaling flag"
	endswitch
	
	//store maximum value
	wavestats /Z /Q  W_Rch
	Vmax_Rch=V_max
	Vmin_Rch=V_min

	wavestats /Z /Q  W_Gch
	Vmax_Gch=V_max
	Vmin_Gch=V_min

	wavestats /Z /Q  W_Bch
	Vmax_Bch=V_max
	Vmin_Bch=V_min

	V_RGBmax=max(Vmax_Rch, Vmax_Gch)
	V_RGBmax=max(V_RGBmax, Vmax_Bch)
	
	print WN_R,": Rmax=", Vmax_Rch
	print WN_G,": Gmax=", Vmax_Gch
	print WN_B,": Bmax=", Vmax_Bch	
	
	if (F_8bit)//adjust to 8bit?
		ULfix("W_Rch", 255, 0)
		ULfix("W_Gch", 255, 0)
		ULfix("W_Bch", 255, 0)
	else
		ULfix("W_Rch", 255*Vmax_Rch/V_RGBmax, 0)
		ULfix("W_Gch", 255*Vmax_Gch/V_RGBmax, 0)
		ULfix("W_Bch", 255*Vmax_Bch/V_RGBmax, 0)
	endif
	
	RGBsperpose("RGB_RefreshChannels")
	
end

	nvar F_8bit
	nvar F_scale
	nvar R_mag
	nvar R_shift
	nvar G_mag
	nvar G_shift
	nvar B_mag
	nvar B_shift
	
	nvar F_RGB=1