#pragma rtGlobals=1 // Use modern global access method.
//////////////////////////////////////////////////////
// Programme for running TDS1012 using RS232C
//
// Made by R. KANAMARU
// Date 29/Sep/2005
// Copyright(C) 2005 Marunaka Factory ?????
// All Rights reserved.
//
// Modified by M. Hashimoto
// Date 23/June/2006
// becase it dose not worked
//
// Modified by Y. Akisawa and K. Ashida
// Date 1/August/2006
//
//////////////////////////////////////////////////////
Variable/G Power_CH1
Variable/G Power_CH2
Variable/G Scale_V1 //Scale's number
Variable/G Scale_V2
Variable/G ScaleNum1

Window Tektronix_Tds1012() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(611,139,1273,437)
	ShowTools
	SetDrawLayer UserBack
	DrawRect 620,11,328,94
	DrawRect 327,187,619,104
	DrawRect 620,194,329,242
	PopupMenu Change_Scale_CH1,pos={409,59},size={201,20},disable=2,proc=Change_Scale_CH1,title="Scale CH1 [VOLTS/DIV]"
	PopupMenu Change_Scale_CH1,mode=1,popvalue="5.00 V",value= #"DS_string_v_axis"
	PopupMenu Time_Ctrl,pos={338,210},size={194,20},proc=Change_Time_Scale,title="Time Ctrl[TIMES/DIV]"
	PopupMenu Time_Ctrl,mode=17,popvalue=" 250 us",value= #"DS_string_time_axis"
	PopupMenu Change_Scale_CH2,pos={409,154},size={208,20},disable=2,proc=Change_Scale_CH2,title="Scale CH2 [VOLTS/DIV]"
	PopupMenu Change_Scale_CH2,mode=5,popvalue="200 mV",value= #"DS_string_v_axis"
	CheckBox Display_CH1,pos={342,29},size={82,14},proc=Display_CH1,title="Display CH1"
	CheckBox Display_CH1,value= 0
	CheckBox Display_CH2,pos={343,121},size={82,14},proc=Display_CH2,title="Display CH2"
	CheckBox Display_CH2,value= 0
	Button Reload_CH1,pos={495,28},size={80,20},disable=2,proc=Reload_CH1,title="Reload_CH1"
	Button Reload_CH2,pos={496,117},size={80,20},disable=2,proc=Reload_CH2,title="Reload_CH2"
	Button Reload_Time,pos={535,210},size={80,20},proc=Reload_Time,title="Reload Time"
	Slider Offset,pos={345,49},size={50,41},disable=2,proc=CH1_Offset_Slider
	Slider Offset,limits={-4,4,0},value= 0
	Slider Offset2,pos={344,140},size={50,43},disable=2,proc=CH2_Offset_Slider
	Slider Offset2,limits={-4,4,0},value= 0
	Button button0,pos={336,258},size={50,20}
	Display/W=(9,11,321,278)/HOST=# 
	ModifyGraph frameStyle=2
	RenameWindow #,G1
	SetActiveSubwindow ##
EndMacro

// When you make this checkbox on, Display CH1's graph of window and CH1's monitor of TDS1012
Function Display_CH1(ctrlName,checked) : CheckBoxControl
String ctrlName
Variable checked
Variable axis_val, axis_val_inv
Make/O/N=4 sety
sety[3]=checked
if(sety[3]==1)
DS_observe1(real_w)
Slider Offset value=0.04*sety[1]
AppendToGraph/L/W=#G1 real_w
ModifyGraph/W=#G1 grid =1,gridHair=3,tick=3, nticks=10,noLabel(bottom)=2,manTick(bottom)={0,250,0,0},manMinor(bottom)={0,50}
axis_val_inv = sety[0] *(-100)
axis_val = sety[0] * 100
SetAxis/W=#G1 left axis_val_inv, axis_val
PopupMenu Change_Scale_CH1 disable=0
Button Reload_CH1 disable=0
Slider Offset disable=0
else
RemoveFromGraph/W=#G1 real_w
PopupMenu Change_Scale_CH1 disable=2
Button Reload_CH1 disable=2
Slider Offset value=0,disable=2
VDTWrite2/Q/O=3 "SELECT:CH1 OFF\n"
Endif
End

// When this button push, Reload CH1 data and renew a graph
Function Reload_CH1(ctrlName) : ButtonControl
String ctrlName
Variable ans_ymult,axis_val_inv,axis_val
Wave sety
Make/O/N=1500 real_w
Make/O/N=1500 nama
if(sety[3]==1)
RemoveFromGraph/W=#G1 real_w
ans_ymult=DS_observe1(real_w)
nama=real_w
Slider Offset value=0.04*sety[1]
AppendToGraph/L/W=#G1 real_w
ModifyGraph/W=#G1 grid =1,gridHair=3,tick=3, nticks=10,noLabel(bottom)=2,manTick(bottom)={0,250,0,0},manMinor(bottom)={0,50}
axis_val_inv = ans_ymult *(-100)
axis_val = ans_ymult * 100
SetAxis/W=#G1 left axis_val_inv, axis_val
endif
End

Function Change_Scale_CH1(ctrlName,popNum,popStr) : PopupMenuControl
String ctrlName
String popStr
Variable popNum
String ans
Wave v_axis=$"DS_wave_v_axis"
SetAxis/W=#G1 left (-4*v_axis[popNum-1]), (4*v_axis[popNum-1])
DS_set_v_axis(1, v_axis[popNum-1], 0)
End

Function Display_CH2(ctrlName,checked) : CheckBoxControl
// When you make this checkbox on,
// Display CH2's graph of window and CH2's monitor of TDS1012
String ctrlName
Variable checked
Variable ans_ymult
Variable axis_val, axis_val_inv,sliderValue
Make/O/N=4 sety2
sety2[3]=checked
if(sety2[3]==1)
ans_ymult=DS_observe2(real_w2)
Slider Offset2 value=0.04*sety2[1]
AppendToGraph/R/W=#G1 real_w2
ModifyGraph/W=#G1 grid =1,gridHair=3,tick=3, nticks=10,noLabel(bottom)=2,manTick(bottom)={0,250,0,0},manMinor(bottom)={0,50}
axis_val_inv = ans_ymult *(-100)
axis_val = ans_ymult * 100
SetAxis/W=#G1 right axis_val_inv, axis_val
PopupMenu Change_Scale_CH2 disable=0
Button Reload_CH2 disable=0
Slider Offset2 disable=0
else
RemoveFromGraph/W=#G1 real_w2
PopupMenu Change_Scale_CH2 disable=2
Button Reload_CH2 disable=2
Slider Offset2 value=0,disable=2
VDTWrite2/Q/O=3 "SELECT:CH2 OFF\n"
endif
End

// When this button push, Reload CH2 data and renew a graph
Function Reload_CH2(ctrlName) : ButtonControl
String ctrlName
Variable ans_ymult, axis_val, axis_val_inv
Nvar power=$"Power_CH2"
Nvar volt=$"Scale_V2"
Wave sety2
Make/O/N=1500 real_w2
Make/O/N=1500 nama2
if(sety2[3]==1)
RemoveFromGraph/W=#G1 real_w2
ans_ymult=DS_observe2(real_w2)
nama2=real_w2
Slider Offset2 value=0.04*sety2[1]
AppendToGraph/R/W=#G1 real_w2
ModifyGraph/W=#G1 grid =1,gridHair=3,tick=3, nticks=10,noLabel(bottom)=2,manTick(bottom)={0,250,0,0},manMinor(bottom)={0,50}
axis_val_inv = ans_ymult *(-100)
axis_val = ans_ymult * 100
SetAxis/W=#G1 right axis_val_inv, axis_val
endif
End

// When this button push, Reload CH2 data and renew a graph
Function Change_Scale_CH2(ctrlName,popNum,popStr) : PopupMenuControl
String ctrlName
String popStr
Variable popNum
String ans
Nvar scale2=$"Scale_V2"
Wave v_axis=$"DS_wave_v_axis"
SetAxis/W=#G1 right (-4*v_axis[popNum-1]), (4*v_axis[popNum-1])
DS_set_v_axis(2, v_axis[popNum-1], 0)
End

//If you want to chang time scale , you change this popup
Function Change_Time_Scale(ctrlName,popNum,popStr) : PopupMenuControl
String ctrlName
Variable popNum
String popStr
Wave time_axis=$"DS_wave_time_axis"
SetAxis/W=#G1 bottom(-5*time_axis[popNum-1]), (5*time_axis[popNum-1])
DS_set_time_axis( time_axis[popNum-1])
doupdate
End

//Push this button when you change time scale, renew graphs of CH1 and CH2
Function Reload_Time(name) : ButtonControl
String name
Reload_CH1("")
Reload_CH2("")
End

Function Trigger_Source(ctrlName,popNum,popStr) : PopupMenuControl
String ctrlName
Variable popNum
String popStr
Variable maxval, minval,step,a,b
Nvar val1=$"scale_V1"
Nvar val2=$"scale_V2"
strswitch(popStr)
case "CH1":
VDTWrite2/Q/O=3 "TRIGger:MAIn:PULse:SOUrce CH1 \n"
maxval=val1*8
minval=val1*(-8)
step = val1/250
Slider slider0 limits={minval,maxval,step}
SetVariable setvar0 limits={minval,maxval,step}
break
case "CH2":
VDTWrite2/Q/O=3 "TRIGger:MAIn:PULse:SOUrce CH2 \n"
maxval=val1*8
minval=val1*(-8)
step = val1/250
Slider slider0 limits={minval,maxval,step}
SetVariable setvar0 limits={minval,maxval,step}
break
endswitch
End
Function CH1_Offset_Slider(ctrlName,sliderValue,event) : SliderControl
String ctrlName
Variable sliderValue
Variable event // bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
wave sety
wave real_w
wave nama
Slider Offset limits={-4, 4,0}
if(event %& 0x1) // bit 0, value set
real_w = (sliderValue-0.04*sety[1])*sety[0]*25+nama
endif
End
Function CH2_Offset_Slider(ctrlName,sliderValue,event) : SliderControl
String ctrlName
Variable sliderValue
Variable event // bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
wave sety2,real_w2,nama2
NVar scale2=$"Scale_V2"
Slider Offset limits={-4, 4,0}
if(event %& 0x1) // bit 0, value set
real_w2=(sliderValue-0.04*sety2[1])*scale2+nama2
endif
End













Function DS_init()
make/O/N=(11) DS_wave_v_axis
DS_wave_v_axis={5, 2, 1, 500e-3, 200e-3, 100e-3, 50e-3, 20e-3, 10e-3, 5e-3, 2e-3}
String/G DS_string_v_axis="5.00 V;2.00 V;1.00 V;500 mV;200 mV;100 mV;50.0 mV;20.0 mV;10.0 mV;5.00 mV;2.00 mV"
End
Function DC_time_init()
make/O/N=(31) DS_wave_time_axis
DS_wave_time_axis={50, 25, 10, 5, 2.5, 1, 500e-3, 250e-3, 100e-3,50e-3, 25e-3, 10e-3, 5e-3, 2.5e-3, 1e-3, 500e-6, 250e-6, 100e-6, 50e-6, 25e-6,10e-6, 5e-6, 2.5e-6, 1e-6, 500e-9, 250e-9, 100e-9, 50e-9, 25e-9, 10e-9, 5e-9}
String/G DS_string_time_axis="50 s;25 s;10 s; 5 s; 2.5 s; 1 s; 500 ms; 250 ms; 100 ms;50 ms; 25 ms; 10 ms; 5 ms; 2.5 ms; 1 ms; 500 us; 250 us; 100 us; 50 us; 25 us; 10 us;5 us; 2.5 us; 1 us; 500 ns; 250 ns; 100 ns; 50 ns; 25 ns; 10 ns; 5 ns; 2.5 ns; 1 ns}"
End
Function DS_comm_init() // Initialization of RS-232C
VDT2 /P=COM1 baud=9600, buffer=4096, databits=8, in=1,line=1, out=1, parity=0, port=1, rts=1, stopbits=1, terminalEOL=1
End
// ********************* for RS-232C control ***************
Function DS_Write(command)
String command
VDTWrite2/Q/O=2 command+"\n"
End

Function DS_Read_Val(command)
String command
String ans
VDTWrite2/Q/O=2 command+"\n"
VDTRead2/N=256/Q/O=2/T="\n" ans
return str2num(StringFromList(1,ans," "))
End

Function DS_Read_Wave(command, w)
String command
Wave w
VDTWrite2/Q/O=2 command+"\n"
VDTReadWave2/T=",\n"/O=20 w
End
//********************* command for tektronix ***************
Function DS_set_v_axis(ch, scale, offset)
Variable ch, scale, offset
String cmnd
sprintf cmnd "CH%d:SCALe %1G", ch, scale
DS_Write(cmnd)
End
Function DS_set_time_axis(scale)
Variable scale
String cmnd
sprintf cmnd "HORizontal:MAIn:SCAle %1G", scale
DS_Write(cmnd)
End

Function DS_observe1(w)
Wave w
Wave sety,real_w
DS_Write("SELECT:CH1 ON")
DS_Write("DATA:START 1")
DS_Write("DATA:STOP 1500")
DS_Write("DATA:ENCDG ASCII")
DS_Write("DATA:SOURCE CH1")
DS_Read_Wave("CURVe?", w)
sety[0] =DS_Read_Val(":YMULt?")
sety[1] =DS_Read_Val("WFMPre:YOFf?")
sety[2] =DS_Read_Val("WFMPre:YZEro?")
real_w=w*sety[0]+sety[2]
return sety[0]
End

Function DS_observe2(w2)
	Wave w2
	Wave sety2,real_w2
	DS_Write("SELECT:CH2 ON")
	DS_Write("DATA:START 1")
	DS_Write("DATA:STOP 1500")
	DS_Write("DATA:ENCDG ASCII")
	DS_Write("DATA:SOURCE CH2")
	DS_Read_Wave("CURVe?", w2)
	sety2[0] =DS_Read_Val("WFMPre:YMULt?")
	sety2[1] =DS_Read_Val("WFMPre:YOFf?")
	sety2[2] =DS_Read_Val("WFMPre:YZEro?")
	real_w2=w2*sety2[0]+sety2[2]
	return sety2[0]
End
