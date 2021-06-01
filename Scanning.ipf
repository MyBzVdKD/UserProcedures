#pragma rtGlobals=1		// Use modern global access method.
//20060729 ÉXÉLÉÉÉìÉvÉçÉOÉâÉÄÇsÇóÇèÇvÇÅÇôÅ@ÇoÇìÇÉÇÅÇéÇ…ÇƒäÆóπ
//nÅ~nÉCÉÅÅ[ÉWÇn+1Å~n+1çsóÒÇ…ïœä∑

//#include ":NIDAQ Procedures:NIDAQ Wave Scan Procs"
//#include ":NIDAQ Procedures:NIDAQ WaveForm Gen Procs"
//#include "MakeRGB"
//#include "make1DProfile"


|************************************************
|   ConfocalÅ@fluorescence microscopy system using GPIB
|   Produced by M. Hashimoto  June 27 2003
|   Ver. 0.1
|************************************************

Variable/G X_position=0
Variable/G Y_position=0
Variable/G X_amplitude=.5
Variable/G Y_amplitude=.5
Variable/G X_Offset=0
Variable/G Y_Offset=0
Variable/G X_Pixels=100
Variable/G Y_Pixels=100
Variable/G X_Frequency=100
Variable/G Z_Current=0
Variable/G Z_Temp=0
Variable/G Z_Upper=0
Variable/G Z_Lower=-1
Variable/G Z_Step=1.0
Variable/G Deg_Step1=0.072
Variable/G Deg_Step2=0.036
Variable/G micron_rev=100
Variable/G fine=0
Variable/G V_NPscan=1
Variable/G SliceAndScan=0
Variable/G V_resolution=micron_rev/360.0*Deg_Step1
Variable/G V_Separate=1
Variable/G navr=1
Variable/G V_x1
Variable/G V_y1
Variable/G V_x2
Variable/G V_y2
Variable/G V_r=125
Variable/G V_r1=125
Variable/G V_r2=125
Variable/G V_SLM=0
Variable/G V_deg1=100
Variable/G V_deg2=100
Variable/G V_sampleingRate=X_Pixels*X_Frequency
Variable/G V_CmpVol=3.04
Variable/G V_ConpPlaneRef=0
variable/G V_Svol=1., V_Evol=6., V_Dvol=0.01
variable/G V_DevPol=10,V_SLM_set=128
variable/G F_PiezoMode=0
variable/G F_VscanMode=0
variable/G F_TwoWay=0
variable/G F_Histogram=1
variable/G F_PintScan=0
variable/G F_lines
variable/G V_Xscale
variable/G V_Yscale
variable/G V_CmpIntensity_RP=1
variable/G V_CmpIntensity_00
variable/G V_CmpIntensity_90
variable/G V_SSpeed=1000
variable/G V_FSpeed=12000
variable/G V_ASpeed=50
variable/G V_ImageThreshold=0.5
variable/G V_PmarginX=2
variable/G V_PmarginY=2
variable/G V_PMeterRange
variable/G F_piezoZscan
variable /G F_Objectivelocked
variable /G F_PiezoZscan
String/G S_Format="GenTxT"
String/G S_fileName="smpl"
String/G S_RatioMode="none"
variable /G F_LogOutput
variable /G V_DisZpoint
variable /G V_compmin
variable /G F_repeat
variable /G F_make3Dwave
variable /G V_time




Function SetVarProc_OutputX(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	Execute "GPIBWrite \"CHA 1; OFS "+Num2Str(varNum)+"\\n\""
End

Function SetVarProc_OutputY(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	Execute "GPIBWrite \"CHA 2; OFS "+Num2Str(varNum)+"\\n\""
End

Window CFM_Control() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(7,38,897,669) as "CFM_Control"
	ModifyPanel cbRGB=(57856,56320,53504)
	ShowTools
	SetDrawLayer UserBack
	DrawRect 489,630,818,502
	SetDrawEnv fillfgc= (53760,52224,48896)
	DrawRect 845,20,461,162
	SetDrawEnv fillfgc= (53760,52224,48896)
	DrawRect 4,22,455,193
	SetDrawEnv fsize= 14,fstyle= 1
	DrawText 5,89,"X"
	SetDrawEnv fsize= 14,fstyle= 1
	DrawText 5,111,"Y"
	SetDrawEnv linebgc= (53760,52224,48896),fillfgc= (53760,52224,48896)
	DrawRect 5,213,412,454
	DrawRRect 12,3,82,23
	SetDrawEnv fstyle= 1
	DrawText 19,20,"Scanning"
	DrawRRect 9,197,58,216
	SetDrawEnv fstyle= 1
	DrawText 16,215,"Slicer"
	SetDrawEnv gstart
	SetDrawEnv textrot= 90
	DrawText 174,319,"Position"
	SetDrawEnv textrgb= (52224,0,0),textrot= 90
	DrawText 173,355.999999999999,"Lower"
	SetDrawEnv fname= "Symbol",textrot= 90
	DrawText 171.999999999998,272,"m"
	SetDrawEnv textrot= 90
	DrawText 174,263,"m"
	SetDrawEnv gstop
	SetDrawEnv gstart
	SetDrawEnv textrot= 90
	DrawText 19,322,"Position"
	SetDrawEnv textrgb= (52224,0,0),textrot= 90
	DrawText 19,367,"Current"
	SetDrawEnv fname= "Symbol",textrot= 90
	DrawText 17,271,"m"
	SetDrawEnv textrot= 90
	DrawText 19,262,"m"
	SetDrawEnv gstop
	SetDrawEnv gstart
	SetDrawEnv textrot= 90
	DrawText 96,318.999999999999,"Position"
	SetDrawEnv textrgb= (52224,0,0),textrot= 90
	DrawText 96,357,"Upper"
	SetDrawEnv fname= "Symbol",textrot= 90
	DrawText 94,271,"m"
	SetDrawEnv textrot= 90
	DrawText 96,262,"m"
	SetDrawEnv gstop
	SetDrawEnv gstart
	SetDrawEnv textrgb= (65280,0,0)
	DrawText 261,230,"Step"
	DrawText 288,231,"of Moving"
	SetDrawEnv gstop
	SetDrawEnv gstart
	SetDrawEnv fname= "Symbol"
	DrawText 327,246,"m"
	DrawText 336,247,"m"
	SetDrawEnv gstop
	SetDrawEnv gstart
	DrawText 159,402,"m/rev"
	SetDrawEnv fname= "Symbol"
	DrawText 150,401,"m"
	SetDrawEnv gstop
	DrawText 339,402,"deg/step"
	DrawText 339,418,"deg/step"
	SetDrawEnv gstart
	DrawText 161,419,"m/step"
	SetDrawEnv fname= "Symbol"
	DrawText 152,418,"m"
	SetDrawEnv gstop
	DrawRRect 467,3,600,23
	SetDrawEnv fstyle= 1
	DrawText 472,20,"Polarization Control"
	DrawRRect 497,512,598,492
	SetDrawEnv fstyle= 1
	DrawText 503,510,"Current Images"
	DrawText 514,623,"1 scanning"
	DrawText 614,624,"N scanning"
	SetDrawEnv gstart
	DrawLine 571,341,571,261
	DrawLine 616,305,526,305
	DrawLine 595,331,542,274
	DrawLine 544,350,599,259
	DrawText 619,313,"LP00"
	DrawText 556,263,"LP90"
	DrawText 602,287,"LP 45"
	DrawText 596,340,"LP-45"
	DrawLine 600,282,547,325
	DrawLine 586,267,599,259
	DrawLine 599,273,599,260
	SetDrawEnv gstop
	SetDrawEnv gstart
	DrawOval 546,191,573,217
	DrawOval 590,193,615,217
	SetDrawEnv fillpat= 0
	DrawRect 535,167,640,242
	DrawText 586,190,"(X1,Y1)"
	DrawText 539,189,"(X2,Y2)"
	DrawText 595,235,"1st"
	DrawText 549,234,"2nd"
	SetDrawEnv gstop
	SetDrawEnv arrow= 1
	DrawLine 494,519,494,602
	SetDrawEnv arrow= 1
	DrawLine 583,515,499,515
	Button Initialize,pos={9,115},size={49,72},proc=ButtonProc_Initialize,title="Initialize"
	Button Initialize,font="Arial"
	SetVariable X_axis_position,pos={8,29},size={150,18},proc=SVP_OutputX,title="X position"
	SetVariable X_axis_position,font="Arial",format="%+.0W0PV"
	SetVariable X_axis_position,limits={-5,5,-0.01},value= X_position
	SetVariable Y_axis_position,pos={8,49},size={150,18},proc=SVP_OutputY,title="Y position"
	SetVariable Y_axis_position,font="Arial",format="%+.0W0PV"
	SetVariable Y_axis_position,limits={-5,5,-0.01},value= Y_position
	SetVariable X_axis_Amplitude,pos={17,72},size={130,18},proc=ChangeVariable,title="Amplitude"
	SetVariable X_axis_Amplitude,font="Arial",format="%5.3f"
	SetVariable X_axis_Amplitude,limits={0,5,0.01},value= X_amplitude
	SetVariable X_axis_Offset,pos={150,72},size={110,18},proc=ChangeVariable,title="Offset"
	SetVariable X_axis_Offset,font="Arial",format="%5.3f"
	SetVariable X_axis_Offset,limits={-5,5,0.01},value= X_offset
	SetVariable X_axis_step,pos={262,73},size={83,15},title="Pixels",format="%5d"
	SetVariable X_axis_step,limits={0,1000,1},value= X_Pixels
	SetVariable Y_axis_Amplitude,pos={17,94},size={130,18},proc=ChangeVariable,title="Amplitude"
	SetVariable Y_axis_Amplitude,font="Arial",format="%5.3f"
	SetVariable Y_axis_Amplitude,limits={0,5,0.01},value= Y_amplitude
	SetVariable Y_axis_Offset,pos={150,93},size={110,18},proc=ChangeVariable,title="Offset"
	SetVariable Y_axis_Offset,font="Arial",format="%5.3f"
	SetVariable Y_axis_Offset,limits={-5,5,0.01},value= Y_offset
	SetVariable Y_axis_step,pos={262,95},size={83,15},title="Pixels",format="%5d"
	SetVariable Y_axis_step,limits={0,1000,1},value= Y_Pixels
	SetVariable X_Y_Fresuency,pos={164,50},size={122,15},proc=Chngefrequency,title="XFrequency"
	SetVariable X_Y_Fresuency,format="%.0W0PHz"
	SetVariable X_Y_Fresuency,limits={0.01,100,1},value= X_Frequency
	Button One_D_scan,pos={209,153},size={60,35},proc=ButtonProc_XScan,title="1D scan"
	Button One_D_scan,font="Arial"
	Button CSB,pos={62,116},size={127,33},proc=ButtonProcContScan,title="Continuous 2Dscan"
	Button CSB,font="Arial"
	Button One_D_scan1,pos={359,217},size={38,34},proc=SetZero,title="Zero"
	Button One_D_scan1,font="Arial"
	Slider CurrentHight,pos={33,236},size={59,150},proc=SC_ZCurrentPosition
	Slider CurrentHight,font="Arial"
	Slider CurrentHight,limits={-30,30,1},variable= Z_Temp,live= 0,side= 2,thumbColor= (65280,21760,0)
	Slider Lower_Z_Position,pos={191,235},size={59,150},font="Arial"
	Slider Lower_Z_Position,limits={-30,30,1},variable= Z_Lower,live= 0,side= 2
	SetVariable Current_Z,pos={35,219},size={60,15},proc=Zposition,title=" "
	SetVariable Current_Z,value= Z_Temp,bodyWidth= 60
	SetVariable Upper_Z,pos={108,219},size={60,15},title=" "
	SetVariable Upper_Z,value= Z_Upper,bodyWidth= 60
	SetVariable Lower_Z,pos={190,219},size={60,15},title=" "
	SetVariable Lower_Z,value= Z_Lower,bodyWidth= 60
	Button GOTO,pos={330,274},size={68,51},proc=Slice1,title="Slice",font="Arial"
	Button GOTO,fStyle=1
	SetVariable Z_step,pos={262,232},size={61,18},title=" ",font="Arial"
	SetVariable Z_step,limits={0.0001,4000,1},value= Z_Step
	SetVariable degParStep,pos={213,388},size={119,15},title="CoarseMode:"
	SetVariable degParStep,help={"Enter the property of the Stepping Motor (Data1)"}
	SetVariable degParStep,value= Deg_Step1,bodyWidth= 50
	SetVariable setvar0,pos={20,388},size={124,15},title="Microscope:"
	SetVariable setvar0,help={"Enter the property of the Microscope"}
	SetVariable setvar0,value= micron_rev,bodyWidth= 60
	Slider Upper_Z_Position,pos={110,235},size={59,150},font="Arial"
	Slider Upper_Z_Position,limits={-30,30,1},variable= Z_Upper,live= 0,side= 2
	CheckBox Fine,pos={339,347},size={42,15},proc=C_Fine,title="Fine",font="Arial"
	CheckBox Fine,variable= fine
	SetVariable degParStep1,pos={227,405},size={105,15},title="FineMode:"
	SetVariable degParStep1,help={"Enter the property of the Stepping Motor (Data2)"}
	SetVariable degParStep1,value= Deg_Step2,bodyWidth= 50
	Button button0,pos={256,275},size={68,19},proc=UP1stp,title="UP",font="Arial"
	Button button1,pos={256,296},size={68,19},proc=DOWN1stp,title="DOWN"
	Button button1,font="Arial"
	SetVariable Z_Resolution,pos={20,404},size={131,18},disable=2,title="Resolution (Max):"
	SetVariable Z_Resolution,font="Arial"
	SetVariable Z_Resolution,limits={-inf,inf,0},value= V_resolution,bodyWidth= 32
	Button ReturnTOZero,pos={257,252},size={140,21},proc=ReturnToZero,title="Rrturn to Zero"
	Button ReturnTOZero,font="Arial"
	PopupMenu popup0,pos={259,325},size={149,23},proc=DataFormat,title="Data Format"
	PopupMenu popup0,font="Arial"
	PopupMenu popup0,mode=2,popvalue="IgorTxT",value= #"\"GenTxT;IgorTxT;Bin\""
	CheckBox check0,pos={261,346},size={68,15},proc=CheckSeparate,title="Separate"
	CheckBox check0,font="Arial",value= 1
	Button CSB2,pos={63,152},size={137,35},proc=Navrage,title="2Dscan (Avr. n scan)"
	Button CSB2,font="Arial"
	SetVariable n,pos={293,117},size={86,18},title="n=",font="Arial"
	SetVariable n,limits={1,1000,1},value= navr
	Button button2,pos={257,364},size={150,22},proc=Slice6D,title="Start 6D Scanning"
	Button button2,font="Arial"
	Button button4,pos={474,27},size={50,20},proc=ButtonProc_RP1,title="RP1"
	Button button4,font="Arial"
	Button button6,pos={470,51},size={70,19},proc=LP00,title="LP_0 deg",font="Arial"
	Button button7,pos={545,51},size={70,19},proc=LP90,title="LP_90deg",font="Arial"
	Button button8,pos={621,51},size={70,19},proc=LP_45,title="LP -45deg"
	Button button8,font="Arial"
	Button button9,pos={526,27},size={50,20},proc=ButtonProc_RP2,title="RP2"
	Button button9,font="Arial"
	Button button10,pos={577,27},size={50,20},proc=ButtonProc_RP3,title="RP3"
	Button button10,font="Arial"
	Button button11,pos={628,27},size={50,20},proc=ButtonProc_RP4,title="RP4"
	Button button11,font="Arial"
	SetVariable setvar1,pos={474,81},size={68,15},title="deg1"
	SetVariable setvar1,limits={0,400,1},value= V_deg1
	Button button5,pos={468,135},size={50,18},proc=ButtonProc_plane,title="plane"
	Button button5,font="Arial"
	SetVariable setvar2,pos={477,114},size={66,15},title="X2"
	SetVariable setvar2,limits={0,inf,1},value= V_x2
	SetVariable setvar3,pos={477,98},size={66,15},title="X1"
	SetVariable setvar3,limits={0,inf,1},value= V_x1
	SetVariable setvar4,pos={547,98},size={66,15},title="Y1"
	SetVariable setvar4,limits={0,inf,1},value= V_y1
	SetVariable setvar5,pos={547,114},size={66,15},title="Y2"
	SetVariable setvar5,limits={0,inf,1},value= V_y2
	SetVariable setvar6,pos={619,97},size={67,15},title="r1"
	SetVariable setvar6,limits={0,inf,1},value= V_r1
	Button button12,pos={524,134},size={50,20},proc=ButtonProc_Circle,title="Circle"
	Button button12,font="Arial"
	SetVariable setvar7,pos={619,114},size={67,15},title="r2"
	SetVariable setvar7,limits={0,inf,1},value= V_r2
	SetVariable setvar8,pos={547,81},size={68,15},title="deg2"
	SetVariable setvar8,limits={0,400,1},value= V_deg2
	Button button13,pos={580,134},size={50,20},proc=ButtonProc_Circle2,title="Circle2"
	Button button13,font="Arial"
	Button button14,pos={192,119},size={89,29},proc=scan3DP,title="3Dpolarization"
	Button button14,font="Arial"
	SetVariable Navr,pos={164,28},size={116,18},proc=Chngefrequency,title="S/point"
	SetVariable Navr,font="Arial",value= V_NPscan
	SetVariable setvar9,pos={88,6},size={155,15},title="Sampling Rate"
	SetVariable setvar9,format="%.0W0PS/sec",value= V_sampleingRate
	Button button15,pos={638,134},size={78,20},proc=PatternGen,title="\\F'Arial'PatternGen"
	Button button15,font="Arial"
	Button button09,pos={621,75},size={70,19},proc=LP45,title="LP  45deg"
	Button button09,font="Arial"
	CheckBox Piezo,pos={255,6},size={45,14},proc=C_Piezo,title="Piezo"
	CheckBox Piezo,variable= F_PiezoMode
	CheckBox VerticalScan,pos={305,5},size={86,15},proc=C_VerticalScanningMode,title="VerticalScan"
	CheckBox VerticalScan,font="Arial",variable= F_VscanMode
	CheckBox piezoZscan,pos={67,197},size={81,15},proc=C_PiezoZscan,title="piezoZscan"
	CheckBox piezoZscan,font="Arial",variable= F_piezoZscan
	CheckBox TwoWayScanning,pos={284,139},size={64,15},proc=C_TwoWay,title="TwoWay"
	CheckBox TwoWayScanning,font="Arial",variable= F_TwoWay
	CheckBox MakeHistgram,pos={654,317},size={69,15},title="Histgram",font="Arial"
	CheckBox MakeHistgram,variable= F_Histogram
	PopupMenu RatioMode,pos={690,606},size={126,23},proc=PM_RatioImg,title="Ratio"
	PopupMenu RatioMode,font="Arial"
	PopupMenu RatioMode,mode=4,popvalue="RP_LPratio",value= #"\"00/90;RP/00;RP/90;RP_LPratio\""
	SetVariable ConpensationRatioRP,pos={22,457},size={78,18},disable=2,title="RP"
	SetVariable ConpensationRatioRP,font="Arial",value= V_CmpIntensity_RP
	SetVariable ConpensationRatioLP00,pos={146,459},size={87,18},proc=SVP_IntensityCompensation,title="LP00"
	SetVariable ConpensationRatioLP00,font="Arial",value= V_CmpIntensity_00
	SetVariable ConpensationRatioLP90,pos={279,459},size={87,18},proc=SVP_IntensityCompensation,title="LP90"
	SetVariable ConpensationRatioLP90,font="Arial",value= V_CmpIntensity_90
	Button SweepGray,pos={683,28},size={24,20},proc=BP_Sweep_Gray,title="SG"
	Button SweepGray,font="Arial"
	CheckBox PointScan,pos={284,155},size={74,15},proc=CP_PointScan,title="PointScan"
	CheckBox PointScan,font="Arial",variable= F_PintScan
	SetVariable ImageThreshold,pos={693,504},size={120,18},proc=SVP_RatioImageThreshold,title="Threshold"
	SetVariable ImageThreshold,font="Arial"
	SetVariable ImageThreshold,limits={-inf,inf,0.1},value= V_ImageThreshold
	CheckBox Lines,pos={284,172},size={108,15},title="UpdatePerLines",font="Arial"
	CheckBox Lines,variable= F_lines
	SetVariable X_MRG,pos={289,28},size={104,18},proc=ChangeVariable,title="X_Margin"
	SetVariable X_MRG,font="Arial",format="%5d",limits={0,100,1},value= V_PmarginX
	SetVariable Y_MRG1,pos={290,49},size={103,18},proc=ChangeVariable,title="Y_Margin"
	SetVariable Y_MRG1,font="Arial",format="%5d",limits={0,100,1},value= V_PmarginY
	ValDisplay Xrange,pos={345,73},size={33,14},format="%gum"
	ValDisplay Xrange,limits={0,0,0},barmisc={0,1000}
	ValDisplay Xrange,value= #"X_amplitude*2*(1+9*F_piezomode)"
	ValDisplay Yrange,pos={345,95},size={33,14},format="%gum"
	ValDisplay Yrange,limits={0,0,0},barmisc={0,1000}
	ValDisplay Yrange,value= #"Y_amplitude*2*(1+9*F_piezomode)"
	ValDisplay XPixelSize,pos={379,73},size={75,14},format="%5.2fum/pixel"
	ValDisplay XPixelSize,limits={0,0,0},barmisc={0,1000}
	ValDisplay XPixelSize,value= #"X_amplitude*2*(1+9*F_piezomode)/X_pixels"
	ValDisplay YPixelSize,pos={378,95},size={74,14},format="%5.2fum/pixel"
	ValDisplay YPixelSize,limits={0,0,0},barmisc={0,1000}
	ValDisplay YPixelSize,value= #"Y_amplitude*2*(1+9*F_piezomode)/Y_pixels"
	CheckBox ObjectiveLock,pos={157,197},size={94,15},proc=C_ObjectiveLock,title="ObjectiveLock"
	CheckBox ObjectiveLock,font="Arial",variable= F_Objectivelocked
	ValDisplay Pezo_um2VolRatio,pos={21,425},size={138,17},title="Pezo(Z-ch)"
	ValDisplay Pezo_um2VolRatio,font="Arial",format="%g um / Vol"
	ValDisplay Pezo_um2VolRatio,limits={0,0,0},barmisc={0,1000},value= #"V_Mag_um2V"
	ValDisplay PiezoChDev,pos={163,427},size={76,14},format="Ch %g in Dev4"
	ValDisplay PiezoChDev,limits={0,0,0},barmisc={0,1000},value= #"V_PiezoCh"
	CheckBox Make3Dwave,pos={259,316},size={58,14},title="3Dwave",value= 0
	Slider Z_position,pos={0,612},size={390,13},proc=SP_moveZSispPoint,font="Arial"
	Slider Z_position,fSize=10,limits={0,2,1},variable= V_DisZpoint,side= 0,vert= 0
	CheckBox LogOutput,pos={400,612},size={70,14},title="LogOutput"
	CheckBox LogOutput,variable= F_LogOutput
	ValDisplay DisplayedZpos,pos={396,594},size={90,14},title="Zposition"
	ValDisplay DisplayedZpos,format="%g um",limits={0,0,0},barmisc={0,1000}
	ValDisplay DisplayedZpos,value= #"V_DisZval*1e6"
	Button ViewMode,pos={397,566},size={86,23},proc=BP_ViewMode,title="ViewMode"
	Button ViewMode,font="Arial"
	Button Save4D,pos={400,541},size={50,20},proc=BP_Save4D,title="Save 4D"
	Button Save4D,font="Arial"
	PopupMenu comp,pos={667,463},size={115,20},proc=PM_CompMode,font="Arial"
	PopupMenu comp,mode=2,popvalue="Radial/Lin_max",value= #"\"Radial/Lin_min;Radial/Lin_max\""
	CheckBox Repeat,pos={388,116},size={58,15},title="Repeat",font="Arial"
	CheckBox Repeat,variable= F_repeat
	Button Save2D,pos={401,514},size={50,20},proc=BP_Save2D,title="Save2D"
	Button Save2D,font="Arial"
	Display/W=(713,24,835,116)/HOST=# 
	AppendImage mglay
	ModifyImage mglay ctab= {0,255,Grays256,0}
	ModifyGraph margin(left)=-1,margin(bottom)=-1,margin(top)=-1,margin(right)=-1,width={Aspect,1.33333}
	ModifyGraph tick=3
	ModifyGraph mirror=0
	ModifyGraph noLabel=2
	ModifyGraph lblMargin(left)=18
	ModifyGraph axOffset(bottom)=-3.11111
	ModifyGraph axThick(left)=0
	RenameWindow #,G1
	SetActiveSubwindow ##
	Display/W=(500,519,585,604)/HOST=# 
	AppendImage CLMS_XYwave1
	ModifyImage CLMS_XYwave1 ctab= {0,3,Rainbow,1}
	ModifyGraph margin(left)=-1,margin(bottom)=-1,margin(top)=-1,margin(right)=-1,width={Aspect,1}
	ModifyGraph height=85.0394
	ModifyGraph tick=3
	ModifyGraph mirror=0
	ModifyGraph noLabel=2
	ModifyGraph axOffset(left)=-10,axOffset(bottom)=-3.11111
	ModifyGraph axThick(left)=0
	SetAxis/A/R left
	SetAxis/A/R bottom
	SetDrawLayer UserFront
	SetDrawEnv xcoord= abs,ycoord= abs
	DrawText 773,314,"Right"
	ModifyGraph swapXY=1
	RenameWindow #,G2
	SetActiveSubwindow ##
	Display/W=(606,519,691,604)/HOST=# 
	AppendImage CLMS_XYwave_avr
	ModifyImage CLMS_XYwave_avr ctab= {0,*,Rainbow,1}
	ModifyGraph margin(left)=-1,margin(bottom)=-1,margin(top)=-1,margin(right)=-1,width={Aspect,1}
	ModifyGraph height=85.0394
	ModifyGraph tick=3
	ModifyGraph mirror=0
	ModifyGraph noLabel=2
	ModifyGraph axOffset(left)=-10,axOffset(bottom)=-3.11111
	ModifyGraph axThick(left)=0
	ModifyGraph swapXY=1
	RenameWindow #,G3
	SetActiveSubwindow ##
	Display/W=(3,478,129,604)/HOST=# 
	AppendImage CLMS_XYwave_RP1
	ModifyImage CLMS_XYwave_RP1 ctab= {0,7,Rainbow,1}
	ModifyGraph margin(left)=-1,margin(bottom)=-1,margin(top)=-1,margin(right)=-1,width={Aspect,1}
	ModifyGraph tick=3
	ModifyGraph mirror=0
	ModifyGraph noLabel=2
	ModifyGraph axOffset(left)=-10,axOffset(bottom)=-3.11111
	ModifyGraph axThick(left)=0
	ModifyGraph swapXY=1
	RenameWindow #,G4
	SetActiveSubwindow ##
	Display/W=(135,479,260,604)/HOST=# 
	AppendImage CLMS_XYwave_LP00
	ModifyImage CLMS_XYwave_LP00 ctab= {0,7,Rainbow,1}
	ModifyGraph margin(left)=-1,margin(bottom)=-1,margin(top)=-1,margin(right)=-1,width={Aspect,1}
	ModifyGraph tick=3
	ModifyGraph mirror=0
	ModifyGraph noLabel=2
	ModifyGraph axOffset(left)=-10,axOffset(bottom)=-3.11111
	ModifyGraph axThick(left)=0
	ModifyGraph swapXY=1
	RenameWindow #,G5
	SetActiveSubwindow ##
	Display/W=(267,479,392,604)/HOST=# 
	AppendImage CLMS_XYwave_LP90
	ModifyImage CLMS_XYwave_LP90 ctab= {0,7,Rainbow,1}
	ModifyGraph margin(left)=-1,margin(bottom)=-1,margin(top)=-1,margin(right)=-1,width={Aspect,1}
	ModifyGraph tick=3
	ModifyGraph mirror=0
	ModifyGraph noLabel=2
	ModifyGraph axOffset(left)=-10,axOffset(bottom)=-3.11111
	ModifyGraph axThick(left)=0
	ModifyGraph swapXY=1
	RenameWindow #,G6
	SetActiveSubwindow ##
	Display/W=(653,166,853,315)/HOST=#  W_ImageHist
	ModifyGraph mode=3
	ModifyGraph marker=19
	ModifyGraph msize=0.01
	ModifyGraph mrkThick=0.01
	ModifyGraph log(left)=1
	ModifyGraph lblMargin(bottom)=8
	ModifyGraph lblLatPos(bottom)=-2
	SetAxis/A/N=1/E=1 left
	SetAxis bottom 0,10
	RenameWindow #,G0
	SetActiveSubwindow ##
	Display/W=(713,521,798,606)/HOST=# 
	AppendImage W_Ratio2D
	ModifyImage W_Ratio2D ctab= {-1,1,RedWhiteBlue,1}
	ModifyImage W_Ratio2D minRGB=(4352,4352,4352),maxRGB=(4352,4352,4352)
	ModifyGraph margin(left)=-1,margin(bottom)=-1,margin(top)=-1,margin(right)=-1,width={Aspect,1}
	ModifyGraph height=85.0394
	ModifyGraph tick=3
	ModifyGraph mirror=0
	ModifyGraph noLabel=2
	ModifyGraph axOffset(left)=-10,axOffset(bottom)=-3.11111
	ModifyGraph axThick(left)=0
	ModifyGraph swapXY=1
	RenameWindow #,G7
	SetActiveSubwindow ##
	Display/W=(608,342,839,461)/HOST=#  W_RPZprof,W_LP00Zprof,W_LP90Zprof
	AppendToGraph/R W_RLratio
	ModifyGraph margin(left)=40,margin(bottom)=34,margin(right)=28
	ModifyGraph rgb(W_LP00Zprof)=(0,0,65280),rgb(W_LP90Zprof)=(0,26112,0),rgb(W_RLratio)=(4352,4352,4352)
	Label bottom "\\F'Arial'\\U"
	RenameWindow #,G8
	SetActiveSubwindow ##
EndMacro


Function ButtonProc_XYScan(ctrlName) : ButtonControl
	String ctrlName
	ScanConfig(ctrlName)
	Scaning_One(ctrlName)
end

Function ScanConfig(ctrlName)
	String ctrlName
	Nvar X_amplitude=X_amplitude
	Nvar X_Offset=X_Offset
	Nvar X_Pixels=X_Pixels
	Nvar Y_amplitude=Y_amplitude
	Nvar Y_Offset=Y_Offset
	Nvar Y_Pixels=Y_Pixels
	Nvar X_Frequency=X_Frequency
	Nvar V_NPscan=V_NPscan
	Nvar F_PiezoMode=F_PiezoMode
	Nvar F_TwoWay=F_TwoWay
	Nvar F_PintScan=F_PintScan
	Nvar F_VscanMode=F_VscanMode
	Nvar F_lines=F_lines
	Nvar V_Xscale=V_Xscale
	Nvar V_Yscale=V_Yscale
	Nvar V_PmarginX=V_PmarginX
	Nvar V_PmarginY=V_PmarginY
	Variable Y_Frequency
	
	Y_Frequency=X_Frequency/Y_Pixels

	Make/O/N=(Y_Pixels+1, X_Pixels+1) CLMS_XYwave1
	SetScale/P x 0,(2*X_amplitude*V_Xscale/X_pixels*1e-6), "m", CLMS_XYwave1
	SetScale/P y 0,(2*Y_amplitude*V_Yscale/Y_pixels*1e-6), "m", CLMS_XYwave1
	if (F_VscanMode | F_lines)
		Make/O/N=(V_NPscan*(X_Pixels+1+2*V_PmarginX)) CLMS_tmp
	else
		Make/O/N=((X_Pixels+1+2*V_PmarginX)*(Y_Pixels+1+2*V_PmarginY)*V_NPscan) CLMS_tmp
	endif
	
	//SetScale/P x 0,(1/X_Frequency*X_pixels/V_NPscan), "points", CLMS_tmp
	ScanMatrixGeneration()
	//Execute "PrintScanSetting()"
	//DAQmx_Waveformgen /DEV="Dev1"/STRT=0/NPRD=1 /CLK={ "/Dev1/pfi2", 1} /TRIG={ "/Dev1/pfi2", 1, 0} "CLMS_tmpX, 0;CLMS_tmpY, 1;"
	//DAQmx_Scan /DEV="Dev1" /STRT=0 /BKG=1/AVE=1/CLK={ "/Dev1/pfi2",1} /TRIG={ "/Dev1/pfi2", 1, 0} waves="CLMS_tmp, 0/RSE"

end

macro PrintScanSetting()
	Print "[ScanConfig]"
	if(F_PiezoMode)
		print "Piezo-Scan"
	else
		print "Galvano-Scan"
	endif
	if(F_VscanMode)
		print "Vertical-Scanning"
	else
		print "Horizontal-Scanning"
	endif
	if(F_TwoWay)
		print "Two-Way"
	else
		print "One-Way"
	endif
	
	if(F_PintScan)
		print "Point-Scan"
	else
		print "Line-Scan"
	endif

	if(F_lines)
		print "Update per Lines"
	else
		print "Updata per Plane"
	endif
end


Function Scaning_One(ctrlName)
	String ctrlName
	Nvar X_Frequency=X_Frequency
	Nvar X_Pixels=X_Pixels
	Nvar V_NPscan=V_NPscan
	Nvar Y_Pixels=Y_Pixels
	Nvar F_TwoWay=F_TwoWay
	Nvar F_PintScan=F_PintScan
	Nvar X_amplitude=X_amplitude
	Nvar Y_amplitude=Y_amplitude
	Nvar X_Offset=X_Offset
	Nvar Y_Offset=Y_Offset
	Nvar V_PmarginX=V_PmarginX
	Nvar V_PmarginY=V_PmarginY
	Nvar V_time
	wave M_ScanPositionMatrixX
	wave M_ScanPositionMatrixY
	wave CLMS_tmp, CLMS_tmpX, CLMS_tmpY, CLMS_XYwave1
	variable V_sizeX=X_Pixels*V_NPscan+2*V_PmarginX+1
	variable V_sizeY=Y_Pixels+2*V_PmarginY+1
	variable V_pscantime, V_pscantime1, V_pscantime2
	CLMS_tmp=0
	Variable i, j, k, val, counter1, counter2
	Nvar F_ScanningStats
	V_time=DateTime
	//fDAQmx_ScanStop("Dev1")
	//fDAQmx_ResetDevice("Dev1")
	//fNIDAQ_ResetScan(1)9 : ∆  ª  ∑    0 ¬  ¡ » Õ  Œ œ Ã ”  ‘ “ ⁄  € Ÿ 1∆ ‹Ø ¿À  ⁄∏   Ê «É 	
    !"#$% &'()*+,- ./012345 6789:;<= >?@ABCDE FGHIJKLM NOPQRSTU VWXYZ[\] ^_`abcde fghijklm nopqrstu vwxyz{|}~?  ¡¢£ €??§¨Ÿª« ¬?®¯°±?? ´µ¶·¸?ºﬂÄ¿ÀÁÂÃÄÅ ﬁÇÈÉ˝˙ÌÍ ÎÏ?ÑÒÓÔÕ Ö?ØÙÚÛÜ? ?ßàáâãäå ˛çèéêëìí îï?ñòóôõÄö÷øùúûü∆∆ÊÅ»Ë??–ı‹?ŒœII©πÿÆæƒˇø??????â'ˆˇØ˚?˜è??????"˘ˇˇ???????ˇ????????ˇˇˇˇ[V_sizeX*i+j]=stopMSTimer(V_pscantime)
//					endfor
//
//				else //Order
//					for(j=0; j<V_sizeX; j+=1)//x-roop
//						//V_pscantime=startMSTimer
//						//SVP_OutputX("", M_ScanPositionMatrixX[j],"","")
//						//CLMS_tmp[V_sizeX*i+j]=NIDAQ_6025E_Obs(V_NPscan, 0, 10)
//						//CLMS_tmp[V_sizeX*i+j]=stopMSTimer(V_pscantime)
//					endfor
//				endif
//			endfor

	ScanwithClock("CLMS_tmp", "CLMS_tmpX", "CLMS_tmpY")
	//CLMS_tmp=CLMS_tmp-CLMS_tmpX
	//wavestats /Q CLMS_tmp ;print V_sdev 
	Reorder1Dto2D("Scaning_One")
	endif
	endif
end

function Reorder1Dto2D(ctrlName)
	string ctrlName
	Nvar F_LogOutput
	wave CLMS_tmp, CLMS_XYwave1
	Nvar F_Histogram, V_time
	variable i,j
	Nvar F_TwoWay, Y_Pixels, X_Pixels, V_NPscan, V_PmarginY, V_PmarginX, F_Histogram
	variable V_sizeX=X_Pixels*V_NPscan+2*V_PmarginX+1
	variable V_sizeY=Y_Pixels+2*V_PmarginY+1
	if(F_LogOutput)
		CLMS_tmp=10^(CLMS_tmp)//-10^1.94089
	endif
	//CLMS_tmp=CLMS_tmpX
		
		//else //OneWayMode
			i=0; j=0
			//NI_DAQ_6025E_Obs(AvrTimes, Dev, Ch, Gain)
			//for(i=0; i<=V_sizeY; i+=1)//y-roop
				// SVP_OutputY("", M_ScanPositionMatrixY[i],"","")
				//for(j=0; j<=V_sizeX; j+=1)//x-roop
				//	V_pscantime=startMSTimer
					//SVP_OutputX("", M_ScanPositionMatrixX[j],"","")
					//CLMS_tmp[V_sizeX*i+j]=fDAQmx_ReadChan("Dev1", 0, -10, 10, 1)
					//CLMS_tmp[V_sizeX*i+j]= NIDAQ_6025E_Obs(V_NPscan, 0, 10)
				//	CLMS_tmp[V_sizeX*i+j]=stopMSTimer(V_pscantime)
				//endfor
			//endfor
		//endif
		//ResumeUpdate
		//reset position
		 //SVP_OutputX("", 0,"","")
		 //SVP_OutputY("", 0,"","")
		 
	//else //LineScan
		//fNIDAQ_WriteChan(1,0,2)
		//PauseUpdate
		//Execute "GPIBWrite \"GET\\n\""
		//fNIDAQ_ScanWaves(1, 1, "CLMS_tmp, 0", 1)
		//ResumeUpdate

	//endif
	

	//"TwoWay" or "OneWay"------------------
	CLMS_XYwave1=0
	if(F_TwoWay)
		for(i=0;i<=Y_Pixels/2;i+=1)
			for(j=0;j<=X_Pixels;j+=1)
				if(2*i<=Y_Pixels)
					CLMS_XYwave1[2*i][j]+=CLMS_tmp[(2*i)*V_sizeX+V_sizeX*V_PmarginY+(V_PmarginX+j)]
				endif
				if(2*i+1<=Y_Pixels)
					CLMS_XYwave1[2*i+1][j]+=CLMS_tmp[(2*i+1)*V_sizeX+V_sizeX*V_PmarginY+(V_sizeX-V_PmarginX-j)-1]
				endif
			endfor
		endfor
		ResumeUpdate
	else
		for(i=0;i<=Y_Pixels;i+=1)
			for(j=0;j<=X_Pixels;j+=1)
				CLMS_XYwave1[i][j]+=CLMS_tmp[i*V_sizeX+V_sizeX*V_PmarginY+(V_PmarginX+j)]
			endfor
		endfor
	endif

	if (F_Histogram==1)
		V_time-=DateTime
		if(-V_time/60<1)
			print -V_time, "sec"
		else
			print -V_time/60, "min"
		endif
		wavescaling("Scaning_One", "CLMS_XYwave1", 0, 0)
		wavescaling("Scaning_One", "CLMS_XYwave1", 1, 1)
		return MakeHistogram("CLMS_XYwave1", 10)
	endif
	wavescaling("Scaning_One", "CLMS_XYwave1", 0, 0)
	wavescaling("Scaning_One", "CLMS_XYwave1", 1, 1)
End



Function ScanMatrixGeneration()
	variable i, j
	Nvar V_PmarginX=V_PmarginX
	Nvar V_PmarginY=V_PmarginY
	Nvar X_Pixels=X_Pixels
	Nvar Y_Pixels=Y_Pixels
	Nvar V_NPscan=V_NPscan
	Nvar X_amplitude=X_amplitude
	Nvar Y_amplitude=Y_amplitude
	Nvar X_Offset=X_Offset
	Nvar Y_Offset=Y_Offset
	Nvar F_PintScan
	Nvar F_TwoWay
	variable V_sizeX=X_Pixels*V_NPscan+2*V_PmarginX+1
	variable V_sizeY=Y_Pixels+2*V_PmarginY+1
	Make/O/N=(V_sizeX) M_ScanPositionMatrixX
	Make/O/N=(V_sizeY) M_ScanPositionMatrixY
	for(i=0;i<V_sizeX;i+=1)	// Xroop
		//M_ScanPositionMatrixX[i]=2*X_amplitude*(i-V_PmarginX)/X_Pixels-X_amplitude+X_Offset
		M_ScanPositionMatrixX[i]=2*X_amplitude*(i-V_PmarginX)/(X_Pixels)-X_amplitude+X_Offset
	endfor
	for(j=0;j<V_sizeY;j+=1)	// Yroop
		M_ScanPositionMatrixY[j]=2*Y_amplitude*(j-V_PmarginY)/(Y_Pixels)-Y_amplitude+Y_Offset
	endfor
	//duplicate /O CLMS_tmp, CLMS_tmpX
	//duplicate /O CLMS_tmp, CLMS_tmpY
	make /O /N=(dimsize(CLMS_tmp, 0)+V_sizeX) CLMS_tmpX//, CLMS_tmpX2
	make /O /N=(dimsize(CLMS_tmp, 0)+V_sizeX) CLMS_tmpY
	redimension /N=(dimsize(CLMS_tmpX, 0)) CLMS_tmp
	CLMS_tmpX=0; CLMS_tmpY=0

	if(F_PintScan)//PointScan
		PauseUpdate
		if(F_TwoWay)//Two-Way Mode
			i=0; j=0
			for(i=0; i<V_sizeY; i+=1)//y-roop
				if(mod(i, 2))//Odd
					for(j=0; j<=V_sizeX+1; j+=1)//x-roop
						CLMS_tmpX[V_sizeX*i+j]=M_ScanPositionMatrixX[V_sizeX-j-1-2]//-0.05*M_ScanPositionMatrixX[V_sizeX-1]
						
						//CLMS_tmpX[V_sizeX*i+j]=M_ScanPositionMatrixX[V_sizeX-j-1-1]-0.0015*M_ScanPositionMatrixX[V_sizeX-1]
						//CLMS_tmpX2[V_sizeX*i+j]=M_ScanPositionMatrixX[V_sizeX-j-1]
						CLMS_tmpY[V_sizeX*i+j]=M_ScanPositionMatrixY[i]
					endfor
				else //Order
					for(j=0; j<V_sizeX+1; j+=1)//x-roop
						CLMS_tmpX[V_sizeX*i+j]=M_ScanPositionMatrixX[j+3]//-0.05*M_ScanPositionMatrixX[0]
						//CLMS_tmpX[V_sizeX*i+j]=M_ScanPositionMatrixX[j+1]-0.0015*M_ScanPositionMatrixX[0]
						//CLMS_tmpX2[V_sizeX*i+j]=M_ScanPositionMatrixX[j]
						CLMS_tmpY[V_sizeX*i+j]=M_ScanPositionMatrixY[i]
					endfor
				endif
			endfor
		endif
	endif

	for(i=V_sizeX*V_sizeY+1; i<=dimsize(CLMS_tmpX, 0); i+=1)
		CLMS_tmpX[i]=CLMS_tmpX[V_sizeX*V_sizeY]-(CLMS_tmpX[V_sizeX*V_sizeY]-CLMS_tmpX[0])*(i-(V_sizeX*V_sizeY+1))/(V_sizeX-1)
		//CLMS_tmpX2[i]=CLMS_tmpX[V_sizeX*V_sizeY]-(CLMS_tmpX[V_sizeX*V_sizeY]-CLMS_tmpX[0])*(i-(V_sizeX*V_sizeY+1))/(V_sizeX-1)
		CLMS_tmpY[i]=CLMS_tmpY[V_sizeX*V_sizeY]-(CLMS_tmpY[V_sizeX*V_sizeY]-CLMS_tmpY[0])*(i-(V_sizeX*V_sizeY+1))/(V_sizeX-1)
	endfor

end




function GotoOutOfRange(ctrlname)
	string ctrlName 
	wave M_ScanPositionMatrixX, M_ScanPositionMatrixY
	variable i
	for (i=dimsize(M_ScanPositionMatrixX, 0)-1; i>=0; i-=1)
		NIDAQ_6025E_Wri( 0, M_ScanPositionMatrixX[i])
		NIDAQ_6025E_Wri( 1, M_ScanPositionMatrixY[i])
		waiting(5000, 20e3)
	endfor
end

function GenerateScanningTrig(ctrlName)
	String ctrlName
	Make/B/U/O/N=10 W_ScanningTrig
	SetScale/P x 0,1,"s", W_ScanningTrig
	W_ScanningTrig=round(p/2)*2-p
	DAQmx_DIO_Config /DEV="Dev1" /DIR=1 /Wave={W_ScanningTrig} /LGRP=1 "/dev1/port0/line3"
	//DAQmx_DIO_Config /DEV="Dev1" /DIR=1 /Wave={W_ScanningTrig} /LGRP=1/RPTC=1 "/dev1/port0/line3"
	//DAQmx_DIO_Config /DEV="Dev1" /DIR=1 /HAND /Wave={W_ScanningTrig} /LGRP=1/RPTC=1 /CLK={"/Dev1/ao/sampleclock", 0}  "/dev1/port0/line3"
	
	//M_MotorTaskIndex[2]=V_DAQmx_DIO_TaskNumber

	//DAQmxErrorReport("C_Fine", fDAQmx_DIO_Write( "Dev1", M_MotorTaskIndex[2], 0))
	
end


function ScanwithClockOldVer(S_InWname, S_OutWnameX, S_OutWnameY)

	string S_InWname, S_OutWnameX, S_OutWnameY
	
	//DevSelect(2)
	//SR400_StartCount("ScanwithClock", 1)
	fDAQmx_ScanStop("Dev1")
	fDAQmx_waveformstop("Dev1")
	DAQmx_Waveformgen /DEV="Dev1"/Strt=0/NPRD=1 /CLK={ "/Dev1/pfi2", 1} /TRIG={ "/Dev1/pfi2", 1, 0} S_OutWnameX+", 0;"+S_OutWnameY+", 1;"
	DAQmx_Scan /DEV="Dev1"/Strt=0/AVE=1/CLK={ "/Dev1/pfi2",0} /TRIG={ "/Dev1/pfi2", 1, 1} waves=S_InWname+", 0/RSE"
	fDAQmx_WaveformStart("Dev1", 1);fDAQmx_ScanStart("Dev1", 2)
	
//BKG=1
end

function ScanwithClock(S_InWname, S_OutWnameX, S_OutWnameY)
	string S_InWname, S_OutWnameX, S_OutWnameY
	Nvar F_ScanningStats, X_Pixels, Y_Pixels
	wave CLMS_tmp//, CLMS_tmpX//, CLMS_tmpX2
	F_ScanningStats=1
	DevSelect(2)
	SR400_StopCount("ScanwithClock")
	CLMS_tmp=0
	//print S_InWname, S_OutWnameX, S_OutWnameY
	fDAQmx_ScanStop("Dev1")
	fDAQmx_waveformstop("Dev1")
	DAQmx_Waveformgen /DEV="Dev1"/STRT=0/NPRD=1 /CLK={ "/Dev1/pfi2", 1} /TRIG={ "/Dev1/pfi2", 1, 0} S_OutWnameY+", 0;"+S_OutWnameX+", 1;"
	DAQmx_Scan /DEV="Dev1" /STRT=0 /BKG=1/AVE=1/CLK={ "/Dev1/pfi2",1} /TRIG={ "/Dev1/pfi2", 1, 0} waves=S_InWname+", 0/RSE"
	//DAQmx_Waveformgen /DEV="Dev1"/STRT=0/NPRD=1 /CLK={ "/Dev1/pfi2", 1} /TRIG={ "/Dev1/pfi2", 1, 0} S_OutWnameX+", 0;"+S_OutWnameY+", 1;"
	//DAQmx_Scan /DEV="Dev1" /STRT=0 /BKG=1/AVE=1/CLK={ "/Dev1/pfi2",0} /TRIG={ "/Dev1/pfi2", 1, 0} waves=S_InWname+", 0/RSE"
	fDAQmx_ScanStart("Dev1", 0);fDAQmx_WaveformStart("Dev1", 1)

	//waiting(50000, 1e5)
	//waiting(5000, 10e6)
	SR400_StartCount("ScanwithClock")
	waiting(50000,7200*X_Pixels*Y_Pixels)//7000is should be adjusted with couting period
	fDAQmx_ScanGetAvailable("Dev1")
	F_ScanningStats=0
	//CLMS_tmp=CLMS_tmp-CLMS_tmpX2
end

function Reverce(ctrlName)
	string ctrlName
	


end


Function RedimensionScanMatrix()
//redimension
end


Function ButtonProcContScan(ctrlName) : ButtonControl
	String ctrlName
	wave CLMS_XYwave1
	ScanConfig(ctrlName)
	duplicate /O CLMS_XYwave1, CLMS_XYwave2,CLMS_XYwave3,CLMS_XYwave4,CLMS_XYwave5,CLMS_XYwave6,CLMS_XYwave7,CLMS_XYwave8,CLMS_XYwave9,CLMS_XYwave10,CLMS_XYwave_avr

	do
	CLMS_XYwave2=CLMS_XYwave1
	CLMS_XYwave3=CLMS_XYwave2
	CLMS_XYwave4=CLMS_XYwave3
	CLMS_XYwave5=CLMS_XYwave4
	CLMS_XYwave6=CLMS_XYwave5
	CLMS_XYwave7=CLMS_XYwave6
	CLMS_XYwave8=CLMS_XYwave7
	CLMS_XYwave9=CLMS_XYwave8
	CLMS_XYwave10=CLMS_XYwave9
	Scaning_One(ctrlName)
	CLMS_XYwave_avr = (CLMS_XYwave1+ CLMS_XYwave2+CLMS_XYwave3+CLMS_XYwave4+CLMS_XYwave5+CLMS_XYwave6+CLMS_XYwave7+CLMS_XYwave8+CLMS_XYwave9+CLMS_XYwave10)/10
	doupdate
	while(1)

End



Function DataFormat(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	SVAR S_Format=S_Format
	S_Format=popStr
End


Function CheckSeparate(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	NVAR V_Separate
	if (checked>0)
		V_Separate=1
	else
		V_Separate=0
	endif
End


Function ButtonProc_RP2(ctrlName) : ButtonControl
	String ctrlName
	NVAR V_x1=V_x1
	NVAR V_y1=V_y1
	NVAR V_x2=V_x2
	NVAR V_y2=V_y2
	NVAR V_r1=V_r1
	Execute "RP2("+num2str(V_x1)+","+num2str(V_y1)+","+num2str(V_x2)+","+num2str(V_y2)+","+num2str(V_r1)+")"
end

Function ButtonProc_RP3(ctrlName) : ButtonControl
	String ctrlName
	NVAR V_x1=V_x1
	NVAR V_y1=V_y1
	NVAR V_x2=V_x2
	NVAR V_y2=V_y2
	NVAR V_r1=V_r1
	Execute "RP3("+num2str(V_x1)+","+num2str(V_y1)+","+num2str(V_x2)+","+num2str(V_y2)+","+num2str(V_r1)+")"
end

Function ButtonProc_RP4(ctrlName) : ButtonControl
	String ctrlName
	NVAR V_x1=V_x1
	NVAR V_y1=V_y1
	NVAR V_x2=V_x2
	NVAR V_y2=V_y2
	NVAR V_r1=V_r1
	Execute "RP4("+num2str(V_x1)+","+num2str(V_y1)+","+num2str(V_x2)+","+num2str(V_y2)+","+num2str(V_r1)+")"
end

Function ButtonProc_Circle(ctrlName) : ButtonControl
	String ctrlName
	NVAR V_x1=V_x1
	NVAR V_y1=V_y1
	NVAR V_r1=V_r1
	NVAR V_deg1=V_deg1
	Execute "Circle1("+num2str(V_x1)+","+num2str(V_y1)+","+num2str(V_r1)+","+num2str(V_deg1)+")"
end

Function ButtonProc_Circle2(ctrlName) : ButtonControl
	String ctrlName
	NVAR V_x1=V_x1
	NVAR V_y1=V_y1
	NVAR V_r1=V_r1
	NVAR V_x2=V_x2
	NVAR V_y2=V_y2
	NVAR V_r2=V_r2
	NVAR V_deg1=V_deg1
	NVAR V_deg2=V_deg2
	Execute "circle2("+num2str(V_x1)+","+num2str(V_y1)+","+num2str(V_r1)+","+num2str(V_x2)+","+num2str(V_y2)+","+num2str(V_r2)+","+num2str(V_deg1)+","+num2str(V_deg2)+")"
end



Function ButtonProc_0(ctrlName) : ButtonControl
	String ctrlName
	
end

Function ButtonProc_45(ctrlName) : ButtonControl
	String ctrlName
	
end

Function ButtonProc_90(ctrlName) : ButtonControl
	String ctrlName
	
end


Window Table2() : Table
	PauseUpdate; Silent 1		// building window...
	Edit/W=(5.25,41.75,510,251) CLMS_XYwave_avr
EndMacro

//Function Pscan(V_NScan)
//	variable V_Nscan
//	String ctrlName
//	NVAR X_amplitude=X_amplitude
//	NVAR X_Offset=X_Offset
//	NVAR X_Pixels=X_Pixels
//	NVAR Y_amplitude=Y_amplitude
//	NVAR Y_Offset=Y_Offset
//	NVAR Y_Pixels=Y_Pixels
//	Variable i=0, j=0, k=0
//	Make/O/N=(V_NScan) CLMS_tmp
//	ButtonProc_Initialize(ctrlName)
//	Make/O/N=(Y_Pixels, X_Pixels) CLMS_XYwave1
//
//	Execute "GPIBWrite \"CHA 1; OFS "+Num2Str(X_Offset-X_amplitude/2)+"\\n\""
//	Execute "GPIBWrite \"CHA 2; OFS "+Num2Str(Y_Offset-Y_amplitude/2)+"\\n\""

			
		
//	for(j=0 ; j<Y_Pixels ; j+=1)
//		for(i=0 ; i<X_Pixels ; i+=1)
//			Execute "GPIBWrite \"CHA 1; OFS "+Num2Str(X_Offset-X_amplitude/2+X_amplitude*i/X_Pixels)+"\\n\""
//			//CLMS_XYwave1[i][j]=NI_DAQ_6025E_Obs(V_Nscan,1,0,1)

//			fNIDAQ_ScanWaves(1, 1, "CLMS_tmp, 0", 128)
//			k=0
//			do 
//				CLMS_XYwave1[i][j]+=CLMS_tmp[k]
//				k+=1
//			while(k<V_Nscan)
//			CLMS_XYwave1[i][j]=CLMS_XYwave1[i][j]/V_Nscan
//		endfor
//		Execute "GPIBWrite \"CHA 2; OFS "+Num2Str(Y_Offset-Y_amplitude/2+Y_amplitude*j/Y_Pixels)+"\\n\""
//	endfor

//	ResumeUpdate
//end

Function Chngefrequency(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	NVAR V_sampleingRate
	NVAR X_Pixels
	NVAR X_Frequency
	NVAR V_NPscan
	
	V_sampleingRate=X_Pixels*X_Frequency*V_NPscan

End




function BP_SearchCompVolt2(ctrlName) : ButtonControl
	String ctrlName
	Nvar V_Svol, V_Evol, V_Dvol
	Nvar V_DevPol
	Nvar V_CmpVol
	Nvar V_SSpeed, V_FSpeed, V_ASpeed
	wave tmp, mglay
	variable i
	String ans
	Execute "InitGPIBBoardAndDevice(1)"
	mglay=256/2
	make /O /N=(72, (V_Evol-V_Svol)/V_Dvol) W_PolComp_2D
	setscale /I x, 1, 360, "deg" W_PolComp_2D
	setscale /I y, V_Svol, V_Evol, "V" W_PolComp_2D
	Execute "Polarizer_Init("+num2str(V_SSpeed)+", "+num2str(V_FSpeed)+", "+num2str(V_ASpeed)+")"
	i=0
	for(V_CmpVol=V_Svol; V_CmpVol<=V_Evol; V_CmpVol+=V_Dvol)
		SVP_Cmp_V("", V_CmpVol, "", "")
		Execute "PolarizationMeasurement(\"tmp\", 5)"
		Execute "Polarizer_Goto(360)"
		Execute "BP_SearchCompVolt_sub()"
		//do
		//	Execute "VDTWrite2/O=1/Q \"R:2\\r\\n\""
		//	
		//	Execute "VDTRead2/t=\",\\n\"/O=1/Q ans"
		//while(cmpstr(ans, "NG\r")==0)
		W_PolComp_2D[][i]=tmp[p]
		i+=1
	endfor
	V_CmpVol=3
	SVP_Cmp_V("", V_CmpVol, "", "")
End

macro BP_SearchCompVolt_sub()
	string ans
	do
		VDTWrite2/O=1/Q "R:2\r\n"
		VDTRead2/t=",\n"/O=1/Q ans
	while(cmpstr(ans, "NG\r")==0)
end

Function BP_SearchCompVolt(ctrlName) : ButtonControl
	String ctrlName
	Nvar V_Svol, V_Evol, V_Dvol
	Nvar V_DevPol, V_DevSLM
	Nvar V_SSpeed, V_FSpeed, V_ASpeed
	variable i=0, j=0, k=0
	Nvar V_CmpVol
	wave  PolDir, W_chisq
	V_CmpVol=V_Svol
	wavestats /Q /Z PolDir
	print "Nsteps of CompV: (V_Evol-V_Svol)/V_Dvol+1", (V_Evol-V_Svol)/V_Dvol+1
	print "Nsteps of SLM: 255/V_DevSLM", 255/V_DevSLM
	print "Nsetps of Polarization: 360/V_DevPol", 360/V_DevPol
	make /D/N=((V_Evol-V_Svol)/V_Dvol+1) /O W_ERavg, W_ERsdev, W_ERmin, W_ERmax
	make /D/N=(((V_Evol-V_Svol)/V_Dvol+1), (255/V_DevSLM)) /O PolDir2D, W_chisq2D
	make /D/N=(((V_Evol-V_Svol)/V_Dvol+1), (255/V_DevSLM), (360/V_DevPol)) /O W_CompData3D
	W_ERavg=0; W_ERsdev=0; W_ERmin=0; W_ERmax=0
	PolDir2D=0; W_chisq2D=0
	W_CompData3D=0
	SetScale/P x  V_Svol, V_Dvol,"V", W_ERavg, W_ERsdev, W_ERmin, W_ERmax, PolDir2D, W_chisq2D, W_CompData3D
	SetScale/P y  0, (V_DevSLM),"G signal", PolDir2D, W_chisq2D, W_CompData3D
	SetScale/P z  0, (V_DevPol),"deg", W_CompData3D

//SetScale/P x 0,1,"degree", $wname
//Make/O /N=(abs(255/step)+1) /D 'PolDir'
//Make/O /N=(abs(255/step)+1) /D 'ExtinctionRatio'
//Make/O /N=(abs(255/step)+1) /D 'W_chisq'
//maxpol=abs(W_coef[0])+abs(W_coef[4])
//minpol=abs(W_coef[0])-abs(W_coef[4])
//P_direction=W_coef[3]
//30ìxíuÇ´Ç…åvÇÈ

	// Acquisition roop
	k=0
	do		//compensation Voltages variation
		print "k=", k
		print "V_CmpVol=",V_CmpVol
		SVP_Cmp_V("",V_CmpVol,"","")
		Execute "Polarizer_Init("+num2str(V_SSpeed)+", "+num2str(V_FSpeed)+", "+num2str(V_ASpeed)+")"
		Execute "Obs_Polarization_dependence_old("+num2str(V_DevPol)+","+num2str(V_DevSLM)+")"//(Dev polarizer, Dev SLMsignal)
		j=0
		do 			// Green signal variation
			duplicate /O $"tmp_"+num2str(j) W_data
			print "tmp_"+num2str(j)
			i=0
			
			do			//Polarization orientation variation
				W_CompData3D[i/V_DevPol][j/V_DevSLM][k]=W_data[i/V_DevPol][j/V_DevSLM]
				i+=V_DevPol
			while(i<360)
			print "Last i =", i-V_DevPol
			j+=V_DevSLM
		while (j<255)
		print "Last j=", j-V_DevSLM
		V_CmpVol+=V_Dvol
		k+=1
	while (V_CmpVol < V_Evol+V_Dvol)

	//return 0
	// Analysis roop
	k=0
	do		//compensation Voltages variation
		j=0
		do 			// Green signal variation
			i=0
			do			//Plarization orientation variation
				W_data[i][j]=W_CompData3D[i][j][k]
				i+=1
			while(i<360)
			j+=1
		while (j<V_npnts)
		Execute "TotalAnalysis(5)"
		PolDir2D[i][j]=PolDir[j]
		W_chisq2D[i][j]=W_chisq[j]
		wavestats /Q /Z W_chisq
		W_ERavg[k]=V_avg
		W_ERsdev[k]=V_sdev
		W_ERmin[k]=V_min
		W_ERmax[k]=V_max
		
		V_CmpVol+=V_Dvol
		k+=1
	while (V_CmpVol < V_Evol+V_Dvol)
	
	
End


Function TPoptimizeData(ctrlName,tabNum) : TabControl
	String ctrlName
	Variable tabNum
	switch(tabNum)
		case 0:
			duplicate /O W_ERavg W_ERmont
			break
		case 1:
			duplicate /O W_ERmax W_ERmont
			break
		case 2:
			duplicate /O W_ERmin W_ERmont
			break
		case 3:
			duplicate /O W_ERsdev W_ERmont
			break
		default:
			
	endswitch
//W_ERmax
//W_ERmin
//W_ERsdev
//W_ERavg
//PolDir2D[i][j]
//W_chisq2D[i][j]=W_chisq[j]
	return 0
End

Function SVP_Cmp_V(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	Execute "DevSelect(1)"
	Execute "GPIBWrite \"AMV "+num2str(varNum)+"E+0\n\""
	//Execute "DevSelect(0)"
End

Window Calibration() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(150,77,450,277) as "Calibration"
	
EndMacro


Function SV_ShowSection_CompData(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	SetVariable SVC_RefCompVal limits={0,DimSize(W_CompData3D,0),1}
	SP_ShowSection_CompData(ctrlName,varNum,0)
End

Function SP_ShowSection_CompData(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	Imagetransform  /P=(sliderValue) /PTYP=0 getPlane W_CompData3D
	duplicate /O M_ImagePlane RefCompData2D
	setscale /I x, 0, 360,"deg" , RefCompData2D
	Slider SC_RefCompVal limits={0,DimSize(W_CompData3D,0),1}
	return 0
End



Function CHK_Amp_Ofst()	//Checking and correcting of scanning range
	variable U_Limitation, L_Limitation
	Nvar X_amplitude, Y_amplitude, X_Offset, Y_Offset
	Nvar F_PiezoMode
	if (F_PiezoMode==0)
		U_Limitation=1; L_Limitation=-1
	else
		U_Limitation=10; L_Limitation=0
	endif

	if (2*X_amplitude > U_Limitation-L_Limitation)
		X_amplitude = (U_Limitation-L_Limitation)/2
	elseif (Y_amplitude > U_Limitation-L_Limitation)
		Y_amplitude = (U_Limitation-L_Limitation)/2
	endif

	if (F_PiezoMode==0)
		if(X_Offset+X_amplitude>U_Limitation)
			X_Offset=U_Limitation-X_amplitude
		endif
		if(X_Offset-X_amplitude<L_Limitation)
			X_Offset=L_Limitation+X_amplitude
		endif
		if(Y_Offset+Y_amplitude>U_Limitation)
			Y_Offset=U_Limitation-Y_amplitude
		endif
		if(Y_Offset-Y_amplitude<L_Limitation)
			Y_Offset=L_Limitation+Y_amplitude
		endif
	else
		if(X_Offset<L_Limitation)
			X_Offset=L_Limitation
		endif
		if(X_Offset+X_amplitude>U_Limitation)
			X_Offset=U_Limitation-X_amplitude
		endif
		if(Y_Offset<L_Limitation)
			Y_Offset=L_Limitation
		endif
		if(Y_Offset+Y_amplitude>U_Limitation)
			Y_Offset=U_Limitation-Y_amplitude
		endif

	endif
End


Function C_TwoWay(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	Nvar F_TwoWay
	if (checked==1)
		F_TwoWay=1
	else
		F_TwoWay=0
	endif
End



Function MakeHistogram(S_wavename, V_range)
	string S_wavename
	variable V_range
	variable i
	wave WV=$S_wavename
	duplicate /O WV W_256
	W_256=W_256/V_range
	//W_256/=V_range
	W_256=W_256*255
	imagehistogram W_256
	//SetScale/I x 0,V_range,"V", W_ImageHist
	wavestats /Q WV
	return V_avg
end




Function SVP_IntensityCompensation(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	Nvar V_CmpIntensity_RP, V_CmpIntensity_00, V_CmpIntensity_90
	Wave CLMS_XYwave_RP1, CLMS_XYwave_LP00, CLMS_XYwave_LP90
	CLMS_XYwave_LP00*=V_CmpIntensity_00/V_CmpIntensity_RP
	CLMS_XYwave_LP90*=V_CmpIntensity_90/V_CmpIntensity_RP
End

Function scan3DP_Vert(ctrlName) : ButtonControl
	String ctrlName
	variable i,j
	NVAR Z_Current=Z_Current
	NVAR Z_Temp=Z_Temp
	NVAR V_resolution=V_resolution
	NVAR Z_Upper=Z_Upper
	NVAR Z_Lower=Z_Lower
	NVAR Z_step
	wave CLMS_XYwave_avr, CLMS_Xwave_avg
	NVAR X_Pixels
	SVAR S_Format
	SVAR S_fileName
	make /D/O/N=(X_Pixels, (Z_Upper-Z_Lower)/Z_step+1) CLMS_XYwave_RP1, CLMS_XYwave_LP00, CLMS_XYwave_LP90
	ScanConfig(ctrlName)
	ButtonProc_XScan_config(ctrlName)
	//Goto LowerPoint
	if (Z_Current>Z_Lower)
		MoveStp(-1,(Z_Current-Z_Lower)/V_resolution+100)
		MoveStp(1,100)
	elseif(Z_Current<Z_Lower)
		MoveStp(1,(Z_Lower-Z_Current)/V_resolution)	
	endif
	
	i=0
	do
		 i+=1
	while(i<=10000)
	j=0
	for(;Z_Current<=Z_Upper;)
	
		//RP_Scanning
		ButtonProc_RP1(ctrlName)
		doupdate
		i=0
		do
			 i+=1
		while(i<=999999)
		ButtonProc_XScan(ctrlName)
		//duplicate/O CLMS_Xwave_avg CLMS_Xwave_RP1
		CLMS_XYwave_RP1[][j]= CLMS_Xwave_avg[p]
	

		//00deg_Scanning
		LP00(ctrlName)
		doupdate
		i=0
		do
			 i+=1
		while(i<=999999)
		ButtonProc_XScan(ctrlName)
		//duplicate/O CLMS_Xwave_avg CLMS_Xwave_LP00
		CLMS_XYwave_LP00[][j]= CLMS_Xwave_avg[p]

		//90deg_Scanning
		LP90(ctrlName)
		doupdate
		i=0
		do
			 i+=1
		while(i<=1999999)
		ButtonProc_XScan(ctrlName)
		//duplicate/O CLMS_Xwave_avg CLMS_Xwave_LP90
		CLMS_XYwave_LP90[][j]= CLMS_Xwave_avg[p]
	print j
		j+=1
		UP1stp("")
		//GoUpOneStep
	endfor
	SVP_IntensityCompensation("",0,"","")
	ReturnToZero(ctrlName)
	ReturnToZero(ctrlName)
End


Function ButtonProc_XScan_config(ctrlName) : ButtonControl
	String ctrlName
	NVAR navr
	wave CLMS_Xwave
	Nvar X_amplitude=X_amplitude
	Nvar X_Offset=X_Offset
	Nvar X_Pixels=X_Pixels
	Nvar Y_amplitude=Y_amplitude
	Nvar Y_Offset=Y_Offset
	Nvar Y_Pixels=Y_Pixels
	Nvar X_Frequency=X_Frequency
	Nvar V_NPscan=V_NPscan
	Nvar F_PiezoMode=F_PiezoMode
	Nvar F_TwoWay=F_TwoWay
	Nvar F_PintScan=F_PintScan
	variable i, j, k


	//Execute "GPIBWrite \"CHA 1; SIG 0\\n\""
	//Execute "GPIBWrite \"CHA 2; SIG 0\\n\""


	Execute "GPIBWrite \"CHA 1; FRQ "+num2str(X_Frequency)+"; AMV "+num2str(X_amplitude*2)+"; OFS "+num2str(X_Offset)+"\\n\""
	
	Execute "GPIBWrite \"CHA 1; BTY 1; TRS 1; BES 0; TRD 0.3E-02; MRK 1; BSS 0; BRO 1\\n\""
	Execute "GPIBWrite \"CHA 2; OMO 5\\n\""

	Make/O/N=(X_Pixels*V_NPscan) CLMS_tmp
	Make/O/N=(X_Pixels) CLMS_Xwave , CLMS_Xwave_avg
	SetScale/P x 0,(1/X_Frequency/X_pixels/V_NPscan),"s", CLMS_tmp

	if(F_PintScan)
		Execute "GPIBWrite \"CHA 1; OMO 5\\n\""
	else
		Execute "GPIBWrite \"CHA 1; OMO 1\\n\""
	endif
	Execute "GPIBWrite \"CHA 1; SIG 1\\n\""
	
	end
	
	

Function C_VerticalScanningMode(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	Nvar F_VscanMode, Z_step
	F_VscanMode=checked
	if (F_VscanMode==1)
		SetVariable Y_axis_Amplitude disable=1
		//SetVariable Y_axis_Offset disable=1
		SetVariable Y_axis_step disable=1
		Z_step=0.1
		Button button14 proc=scan3DP_Vert
	else
		SetVariable Y_axis_Amplitude disable=0
		//SetVariable Y_axis_Offset disable=0
		SetVariable Y_axis_step disable=0
		Z_step=1
		Button button14 proc=scan3DP
	endif
End

Function ChangeVariable(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
//	CHK_Amp_Ofst()
End


Function ButtonProc_plane(ctrlName) : ButtonControl
	String ctrlName
	NVAR V_deg1=V_deg1
	wave mglay
	variable i
	i=DEGtoRGB(V_deg1*2)
	//print i
	mglay=i
end




Function SVP_OutputX(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	//nvar X_position
	//X_position=varNum 
	//Execute "GPIBWrite \"CHA 1; OFS "+Num2Str(varNum)+"\\n\""
	//fNIDAQ_writeChan(1,0,varNum)
	//print ctrlName,varNum,varStr,varName
	NIDAQ_6025E_Wri( 0, varNum)
End


Function SVP_OutputY(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	//nvar Y_position
	//Y_position=varNum
	//Execute "GPIBWrite \"CHA 2; OFS "+Num2Str(varNum)+"\\n\""
	//fNIDAQ_writeChan(1,1,varNum)
	NIDAQ_6025E_Wri( 1, varNum)
End

Function CP_PointScan(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
End







Function SliderProc_1(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	if(event %& 0x1)	// bit 0, value set

	endif

	return 0
End

Function SVP_RatioImageThreshold(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

End




Function ButtonProc_XScan(ctrlName) : ButtonControl
	String ctrlName
	NVAR navr
	wave CLMS_Xwave
	Nvar X_amplitude=X_amplitude
	Nvar X_Offset=X_Offset
	Nvar X_Pixels=X_Pixels
	Nvar Y_amplitude=Y_amplitude
	Nvar Y_Offset=Y_Offset
	Nvar Y_Pixels=Y_Pixels
	Nvar X_Frequency=X_Frequency
	Nvar V_NPscan=V_NPscan
	Nvar F_PiezoMode=F_PiezoMode
	Nvar F_TwoWay=F_TwoWay
	Nvar F_PintScan=F_PintScan
	variable i, j, k, val
	wave CLMS_Xwave_avg, CLMS_tmp
	//-----------------------------

	CLMS_Xwave_avg=0
	//fNIDAQ_WriteChan(1,0,0)
	NIDAQ_6025E_Wri( 0, 0)
	k=0
	do
		PauseUpdate
		if (F_PintScan)
			for(j=0; j<X_Pixels; j+=1)//x-roop
			//print "(",X_Offset,"-",X_amplitude,")+",j,"/(",X_Pixels,"-1)*2*",X_amplitude,"=", (X_Offset-X_amplitude)+j/(X_Pixels-1)*2*X_amplitude
				//SVP_OutputX("", (X_Offset-X_amplitude)+j/(X_Pixels-1)*2*X_amplitude,"","")
				SVP_OutputX("", (X_Offset-X_amplitude)+j/(X_Pixels-1)*2*X_amplitude,"","")
				CLMS_Xwave[j]= NIDAQ_6025E_Obs(V_NPscan, 0, 10)
			endfor
		else
			//fNIDAQ_WriteChan(1,0,5)
			//fNIDAQ_ScanWaves(1, 1, "CLMS_tmp, 0", 1)
			//fNIDAQ_WriteChan(1,0,0)
		endif
		CLMS_Xwave_avg+=CLMS_Xwave/navr
		k+=1
	while(k<navr)
	
End

macro savepoldata(wname)
	string wname
	Save/T/M="\r\n" tmp_0,tmp_5,tmp_10,tmp_15,tmp_20,tmp_25,tmp_30,tmp_35,tmp_40,tmp_45,tmp_50,tmp_55,tmp_60,tmp_65,tmp_70,tmp_75,tmp_80,tmp_85,tmp_90,tmp_95,tmp_100,tmp_105,tmp_110,tmp_115,tmp_120,tmp_125,tmp_130,tmp_135,tmp_140,tmp_145,tmp_150,tmp_155,tmp_160,tmp_165,tmp_170,tmp_175,tmp_180,tmp_185 as wname+".itx"
	Save/T/M="\r\n"/A tmp_190,tmp_195,tmp_200,tmp_205,tmp_210,tmp_215,tmp_220,tmp_225,tmp_230,tmp_235,tmp_240,tmp_245,tmp_250,tmp_255,chisq,PolDir,PolDir_SS,ExtinctionRatio as wname+".itx"
end






Function SaveCmp_ProfileData(wname, S_savemode)
	//[S_savemode]
	//IB:Igor Binary
	//IT:Igor TxT
	//GT:General TxT
	//DT:Delimited TxT
	string wname, S_savemode
	strswitch(S_savemode)						// string switch
		case "IB":
			Save/C RefCompData2D as wname+"RefCompData2D.ibw"
			Save/C W_Polarization_Disp as wname+"W_Polarization_Disp.ibw"
			Save/C W_ExtRatio_Disp as wname+"W_ExtRatio_Disp.ibw"
			break
		case "IT":
			Save/T/M="\r\n" RefCompData2D,W_ExtRatio_Disp, W_Polarization_Disp as wname+".itx"
			break
		case "GT":
			Save/G/M="\r\n"/W/U={1,1,1,1} RefCompData2D,W_ExtRatio_Disp, W_Polarization_Disp as wname+".txt"
			break
		case "DT":
			Save/J/M="\r\n"/W/U={1,1,1,1} RefCompData2D,W_ExtRatio_Disp, W_Polarization_Disp as wname+".txt"
			break
		default:
			print "S_ savemode incorrect"
	endswitch
	 
end




//Normalize function//
function normalize(wname)
string wname
wave wv=$wname
WaveStats /Q wv
wv/=V_max
end






Function BP_SLM_Modsulation(ctrlName) : ButtonControl
	String ctrlName
	nvar V_PMeterRange=V_PMeterRange
	variable i
	wave mglay
	make /O /N=51 tmp
	//make /O /N=255 tmp
	SetScale/I x 0,255,"SLM", tmp
	SetScale d 0,0,"W", tmp
	//do
	for(i=0; i<51 ;i+=1)
	//for(i=0; i<255 ;i+=1)
			mglay=i*5
			//mglay=i
			doupdate
			tmp[i]=NIDAQ_6025E_Obs(100,1,10)*V_PMeterRange
	endfor
	//while (1)
	mglay=0
	normalize("tmp")
Save/C tmp as "Adjustment_lambda2_.ibw"
End


Function ButtonProcCaribration (ctrlName) : ButtonControl
	String ctrlName
	Nvar V_SSpeed, V_FSpeed, V_ASpeed
	V_SSpeed=1000
	V_FSpeed=12000
	V_ASpeed=50
	Execute "Polarizer_Init_GPIB("+num2str(V_SSpeed)+", "+num2str(V_FSpeed)+", "+num2str(V_ASpeed)+")"
	Execute "Obs_Polarization_depend_GPIB(12)"
	Execute "TotalAnalysis(5)"
	Execute "TotalAnalysis2(5)"
	V_SSpeed=1000
	V_FSpeed=12000
	V_ASpeed=50
End

Function C_Piezo(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	Nvar F_PiezoMode=F_PiezoMode
	Nvar X_amplitude, Y_amplitude, X_Offset, Y_Offset, X_Frequency, navr
	F_PiezoMode=checked

	if (F_PiezoMode==0)//Galvano Mode
		SetVariable X_axis_position limits={-1,1,0.01}
		SetVariable Y_axis_position limits={-1,1,0.01}
		SetVariable X_axis_Offset limits={-1,1,0.01}
		SetVariable Y_axis_Offset limits={-1,1,0.01}
		SetVariable X_axis_Amplitude limits={-1,1,0.01}
		SetVariable Y_axis_Amplitude limits={-1,1,0.01}
		SetVariable X_Y_Fresuency limits={0.01,1000,1}
		X_amplitude=.5; Y_amplitude=.5; X_Offset=0; Y_Offset=0
		X_Frequency=100; navr=10
		//Load impeadance 50 Ohm
	else //Piezo Mode
		SetVariable X_axis_position limits={0,5,-5.01}
		SetVariable Y_axis_position limits={0,5,-5.01}
		SetVariable X_axis_Offset limits={0,5,-5.01}
		SetVariable Y_axis_Offset limits={0,5,-5.01}
		SetVariable X_axis_Amplitude limits={0,5,0.01}
		SetVariable Y_axis_Amplitude limits={0,5,0.01}
		SetVariable X_Y_Fresuency limits={0.01,100,1}
		X_amplitude=3; Y_amplitude=3; X_Offset=0; Y_Offset=0
		X_Frequency=10; navr=1
		//Load impeadance Open
	endif

	
End





function Save2Dimages (ctrlName, S_basename, Num)
	string ctrlName, S_basename
	variable Num
	NVAR Z_Current=Z_Current
	NVAR Z_Temp=Z_Temp
	wave CLMS_XYwave_LP00, CLMS_XYwave_LP90, CLMS_XYwave_RP1
	SVAR S_Format
	SVAR S_fileName
		//RP_Scanning
		strswitch(S_Format)	// string switch
			case "GenTxT":		// execute if case matches expression
				save /O/G /W /M="\r\n" /P=Home CLMS_XYwave_avr as S_fileName+"_RP_"+num2str(Num)+".dat"
				break						// exit from switch
			case "IgorTxT":		// execute if case matches expression
				save /O/T/M="\r\n" /P=Home CLMS_XYwave_avr as S_fileName+"_RP_"+num2str(Num)+".itx"
				break
			case "Bin":		// execute if case matches expression
				save/O/C /P=Home CLMS_XYwave_avr as S_fileName+"_RP_"+num2str(Num)+".ibw"
				break
			default:							// optional default expression executed
				print "Data Format Error"					// when no case matches
		endswitch
	
	
		//00deg_Scanning
		strswitch(S_Format)	// string switch
			case "GenTxT":		// execute if case matches expression
				save /O/G /W /M="\r\n" /P=Home CLMS_XYwave_avr as S_fileName+"_00deg_"+num2str(Num)+".dat"
				break						// exit from switch
			case "IgorTxT":		// execute if case matches expression
				save /O/T/M="\r\n" /P=Home CLMS_XYwave_avr as S_fileName+"_00deg_"+num2str(Num)+".itx"
				break
			case "Bin":		// execute if case matches expression
				save/O/C /P=Home CLMS_XYwave_avr as S_fileName+"_00deg_"+num2str(Num)+".ibw"
				break
			default:							// optional default expression executed
				print "Data Format Error"					// when no case matches
		endswitch

		//90deg_Scanning
		strswitch(S_Format)	// string switch
			case "GenTxT":		// execute if case matches expression
				save /O/G /W /M="\r\n" /P=Home CLMS_XYwave_avr as S_fileName+"_90deg_"+num2str(Num)+".dat"
				break						// exit from switch
			case "IgorTxT":		// execute if case matches expression
				save /O/T/M="\r\n" /P=Home CLMS_XYwave_avr as S_fileName+"_90deg_"+num2str(Num)+".itx"
				break
			case "Bin":		// execute if case matches expression
				save/O/C /P=Home CLMS_XYwave_avr as S_fileName+"_90deg_"+num2str(Num)+".ibw"
				break
			default:							// optional default expression executed
				print "Data Format Error"					// when no case matches
		endswitch
		
end


function Make4DMatrix(ctrlName)
	string ctrlName
	NVAR Z_Upper=Z_Upper
	NVAR Z_Lower=Z_Lower
	NVAR Z_step=Z_step
	NVAR F_PiezoMode=F_PiezoMode
	NVAR F_piezoZscan
	NVAR X_Pixels
	NVAR Y_Pixels
	
	make /O /n=(X_pixels, Y_pixels, round((Z_Upper-Z_Lower)/Z_step+1) , 7) M_4D
	wavescaling("Make4DMatrix", "M_4D", 0, 0)
	wavescaling("Make4DMatrix", "M_4D", 1, 1)
	wavescaling("Make4DMatrix", "M_4D", 2 ,2)
	makenote("Make4DMatrix", "M_4D")
end

function Make3DMatrix(ctrlName)
	string ctrlName
	NVAR Z_Upper=Z_Upper
	NVAR Z_Lower=Z_Lower
	NVAR Z_step=Z_step
	NVAR F_PiezoMode=F_PiezoMode
	NVAR F_piezoZscan
	NVAR X_Pixels
	NVAR Y_Pixels
	
	make /O /n=(X_pixels, Y_pixels, round((Z_Upper-Z_Lower)/Z_step+1)) M_3D
	wavescaling("Make4DMatrix", "M_3D", 0, 0)
	wavescaling("Make4DMatrix", "M_3D", 1, 1)
	wavescaling("Make4DMatrix", "M_3D", 2 ,2)
	makenote("Make4DMatrix", "M_3D")
end

function makenote(ctrlName, S_wavename)
	string ctrlName, S_wavename
	wave WV=$S_wavename
	Nvar X_amplitude, Y_amplitude, X_pixels, Y_pixels
	Nvar F_PiezoMode, F_VscanMode, F_TwoWay, F_PintScan, F_lines, Z_step, Z_upper, Z_Lower, V_resolution
	note /K WV, date()+"\r"
	note /NOCR WV, "[imagesize]\r"
	note /NOCR WV, "X	:"+num2str(X_amplitude*2*(1+9*F_piezomode))+" um\r"
	note /NOCR WV, "Y	:"+num2str(Y_amplitude*2*(1+9*F_piezomode))+" um\r"
	if(dimsize(WV, 2))
		note /NOCR WV, "Z	:"+num2str(Z_Upper-Z_Lower)+" um\r"
		note /NOCR WV, num2str(X_pixels+1)+" pixels - "+num2str(Y_pixels+1)+" pixels"
	endif
	if (dimsize(WV, 2))
		note /NOCR WV, num2str((Z_Upper-Z_Lower)/Z_step+1)+" pixels"
	endif
		note /NOCR WV, "\r"
	if(dimsize(WV, 2))
		Nvar F_PiezoZScan, F_ObjectiveLocked
		note /NOCR WV, "[ZscanMode]\r"
		note /NOCR WV, "ZscanResolution:	"+num2str(Z_step)+"um\r"
		note /NOCR WV, "ZscanRange:	from"+num2str(Z_Lower)+" to "+num2str(Z_upper)+"um\r"
		if(F_ObjectiveLocked)
			note /NOCR WV, "Minimum resolution	:0.005 um/bit (12bit)\r"
		else
			note /NOCR WV, "Minimum resolution	:"+num2str(V_resolution)+" um/step\r"
		endif
		if(F_PiezoZScan)
			if(F_ObjectiveLocked)
				note /NOCR WV, "PiezoDrive\r"
			else
				note /NOCR WV, "ObvectiveDrives With Piezo\r"
			endif
		else
			if(F_ObjectiveLocked)
				note /NOCR WV, "NoDriving...\r"
			else
				note /NOCR WV, "Objective Drive\r"
			endif
		endif
	endif
	
	if(dimsize(WV, 3))
		Nvar V_ImageThreshold
		note /NOCR WV, "[4-D matrix]\r"
		note /NOCR WV, "Sreshold of retio image	:"+num2str(V_ImageThreshold)+"\r"
		note /NOCR WV, "M_4D[x][y][z][0]	:LP00\r"
		note /NOCR WV, "M_4D[x][y][z][1]	:LP90\r"
		note /NOCR WV, "M_4D[x][y][z][2]	:RP\r"
		note /NOCR WV, "M_4D[x][y][z][3]	:LP00/LP90\r"
		note /NOCR WV, "M_4D[x][y][z][4]	:RP/LP90\r"
		note /NOCR WV, "M_4D[x][y][z][5]	:RP/LP00\r"
		note /NOCR WV, "M_4D[x][y][z][6]	:(RP-LP)/(RP+LP)\r"
	endif
		note /NOCR WV,  "[ScanConfig]\r"
	
	if(F_PiezoMode)
		note /NOCR WV,  "Piezo-Scan\r"
	else
		note /NOCR WV,  "Galvano-Scan\r"
	endif
	if(F_VscanMode)
		note /NOCR WV,  "Vertical-Scanning\r"
	else
		note /NOCR WV,  "Horizontal-Scanning\r"
	endif
	if(F_TwoWay)
		note /NOCR WV,  "Two-Way\r"
	else
		note /NOCR WV,  "One-Way\r"
	endif
	
	if(F_PintScan)
		note /NOCR WV,  "Point-Scan\r"
	else
		note /NOCR WV,  "Line-Scan\r"
	endif

	if(F_lines)
		note /NOCR WV,  "Update per Lines\r"
	else
		note /NOCR WV,  "Updata per Plane\r"
	endif
	
end

Function wavescaling(ctrlName, L_wavename, F_axis, F_dim)
	string ctrlName, L_wavename
	variable F_axis, F_dim
	string S_wavename
	variable i
	NVAR F_PiezoMode=F_PiezoMode
	NVAR X_amplitude, Y_amplitude
	NVAR X_Offset, Y_Offset
	NVAR Z_Upper=Z_Upper
	NVAR Z_Lower=Z_Lower
	NVAR Z_step=Z_step
	NVAR F_piezoZscan
	string S_dim
//	wave WV=$S_wavename
	for(i=0; i<ItemsInList(L_wavename); i+=1)
		S_wavename=StringFromList(i, L_wavename)
		switch(F_axis)
			case 0:
				S_dim="x"
				break
			case 1:
				S_dim="y"
				break
			case 2:
				S_dim="z"
				break
			default:
				print "BadParameter"
				return 0
		endswitch
		switch(F_dim)
			case 0:
				if(F_PiezoMode)
					Execute "SetScale /I  "+S_dim+" -X_amplitude*1e-5, X_amplitude*1e-5,\"m\", "+S_wavename
				else
					Execute "SetScale /I  "+S_dim+" -X_amplitude, X_amplitude,\"V\", "+S_wavename
				endif
				break
			case 1:
				if(F_PiezoMode)
					Execute "SetScale /I  "+S_dim+" -Y_amplitude*1e-5, Y_amplitude*1e-5,\"m\", "+S_wavename
				else
					Execute "SetScale /I  "+S_dim+" -Y_amplitude, Y_amplitude,\"V\", "+S_wavename
				endif
				break
			case 2:
					Execute "SetScale /I "+S_dim+" Z_Lower*1e-6, Z_Upper*1e-6,\"m\", "+S_wavename
				break
			default:
				print "BadParameter"
		endswitch
	endfor
end









Function ButtonProc_RP1(ctrlName) : ButtonControl
	String ctrlName
	NVAR V_x1=V_x1
	NVAR V_y1=V_y1
	NVAR V_x2=V_x2
	NVAR V_y2=V_y2
	NVAR V_r1=V_r1
	Nvar LCD_Ctrl_Status
	Execute "RP1("+num2str(V_x1)+","+num2str(V_y1)+","+num2str(V_x2)+","+num2str(V_y2)+","+num2str(V_r1)+")"
	//if(LCD_Ctrl_Status)//turn OFF LCD wavegeneration
		LCD_Ctrl_ButtonProc("RP1")
	//endif
	LCD_Control_pol("ButtonProc_RP1",1,"Radial")	//"Radial;Xpol;Ypol"
	LCD_Ctrl_ButtonProc("Slice6D")
end









Function Slice1(ctrlName) : ButtonControl
	String ctrlName
	NVAR Z_Current=Z_Current
	NVAR Z_Temp=Z_Temp
	NVAR V_resolution=V_resolution
	NVAR Z_Upper=Z_Upper
	NVAR Z_Lower=Z_Lower
	wave CLMS_XYwave_avr
	SVAR S_Format
	SVAR S_fileName
	Nvar F_make3Dwave
	variable i=0
	wave M_3D, CLMS_XYwave_avr
	//Goto LowerPoint
	if (Z_Current>Z_Lower)
		MoveStp(-1,(Z_Current-Z_Lower)/V_resolution+100)
		MoveStp(1,100)
	elseif(Z_Current<Z_Lower)
		MoveStp(1,(Z_Lower-Z_Current)/V_resolution)	
	endif

	wavescaling("Slice", "M_3D", 0, 0)
	wavescaling("Slice", "M_3D", 1, 1)
	wavescaling("Slice", "M_3D", 2, 2)

	for(;Z_Current<=Z_Upper;i+=1)
		//Scanning
		Navrage(ctrlName)
		if(abs(Z_Temp)<0.000001)
			Z_Current=0
			Z_Temp=0
		endif

		if(F_make3Dwave)
			M_3D[][][i]=CLMS_XYwave_avr[p][q]
		else
			strswitch(S_Format)	// string switch
				case "GenTxT":		// execute if case matches expression
					save /O/G /W /M="\r\n" /P=Home CLMS_XYwave_avr as S_fileName+"_"+num2str(Z_Current)+".dat"
					break						// exit from switch
				case "IgorTxT":		// execute if case matches expression
					save /O/T/M="\r\n" /P=Home CLMS_XYwave_avr as S_fileName+"_"+num2str(Z_Current)+".itx"
					break
				case "Bin":		// execute if case matches expression
					save/O/C /P=Home CLMS_XYwave_avr as S_fileName+"_"+num2str(Z_Current)+".ibw"
					break
				default:							// optional default expression executed
					print "Data Format Error"					// when no case matches
			endswitch
		endif
		UP1stp("")//GoUpOneStep
		doupdate
	endfor
End


Function PM_RatioImg(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	wave W_Ratio2D, CLMS_XYwave_LP00, CLMS_XYwave_LP90, CLMS_XYwave_RP1
	Nvar V_ImageThreshold
	variable V_maximum
	wavestats /Q CLMS_XYwave_LP00
	V_maximum=V_max
	wavestats /Q CLMS_XYwave_LP90
	V_maximum=max(V_max, V_maximum)
	wavestats /Q CLMS_XYwave_RP1
	V_maximum=max(V_max, V_maximum)
	
	variable i,j
	
	duplicate /O CLMS_XYwave_RP1 W_Ratio2D
	//print ctrlName,popNum,popStr
	//print "00/90"
	switch(popNum)
		case 1:
			//W_Ratio2D=CLMS_XYwave_LP00/CLMS_XYwave_LP90
			W_Ratio2D=(CLMS_XYwave_LP00-CLMS_XYwave_LP90)/(CLMS_XYwave_LP90+CLMS_XYwave_LP90)			
			//print "00/90"
			break
		case 2:
			//W_Ratio2D=CLMS_XYwave_RP1/CLMS_XYwave_LP00
			W_Ratio2D=(CLMS_XYwave_RP1-CLMS_XYwave_LP00)/(CLMS_XYwave_RP1+CLMS_XYwave_LP00)
			//print "RP/00"
			break
		case 3:
			//W_Ratio2D=CLMS_XYwave_RP1/CLMS_XYwave_LP90
			W_Ratio2D=(CLMS_XYwave_RP1-CLMS_XYwave_LP90)/(CLMS_XYwave_RP1+CLMS_XYwave_LP90)
			//print "RP/90"
			break
		case 4:
			//W_Ratio2D=(CLMS_XYwave_RP1-CLMS_XYwave_LP90)/(CLMS_XYwave_RP1+CLMS_XYwave_LP90)+(CLMS_XYwave_RP1-CLMS_XYwave_LP00)/(CLMS_XYwave_RP1+CLMS_XYwave_LP00)
			W_Ratio2D=(CLMS_XYwave_RP1-CLMS_XYwave_LP90)/(CLMS_XYwave_RP1+CLMS_XYwave_LP90)+(CLMS_XYwave_RP1-CLMS_XYwave_LP00)/(CLMS_XYwave_RP1+CLMS_XYwave_LP00)
			break
		default:
			print "RatioImage no change"
	endswitch
	
	for(i=0; i<dimsize(W_Ratio2D,0); i+=1)
		for(j=0; j<dimsize(W_Ratio2D,1); j+=1)
			if((CLMS_XYwave_LP00[i][j]+CLMS_XYwave_LP90[i][j]+CLMS_XYwave_RP1[i][j])/3<V_maximum*V_ImageThreshold)
				W_Ratio2D[i][j]=inf
			endif
		endfor
	endfor

End


Function Slice6D(ctrlName) : ButtonControl
	String ctrlName
	variable i, j
	NVAR Z_Current=Z_Current
	NVAR Z_Temp=Z_Temp
	NVAR Z_step=Z_step
	NVAR V_resolution=V_resolution
	NVAR Z_Upper=Z_Upper
	NVAR Z_Lower=Z_Lower
	Nvar V_compmin
	Nvar F_repeat
	wave CLMS_XYwave_avr
	SVAR S_Format
	SVAR S_fileName
	wave M_4D
	wave CLMS_XYwave_LP00, CLMS_XYwave_LP90, CLMS_XYwave_RP1, W_Ratio2D, W_3int
	make /O /N=((Z_Upper-Z_Lower)/Z_step+1) W_RPZprof, W_LP00Zprof, W_LP90Zprof, W_RLratio
	wavescaling("Slice6D", "W_RPZprof", 0, 2)
	wavescaling("Slice6D", "W_LP00Zprof", 0, 2)
	wavescaling("Slice6D", "W_LP90Zprof", 0, 2)
	wavescaling("Slice6D", "W_RLratio", 0, 2)
	Make4DMatrix("Slice6D")
	if(F_repeat)//inhibit endless repeat mode
		F_repeat=0
	endif
	//Goto LowestPoint
	if (Z_Current>Z_Lower)
		MoveStp(-1,(Z_Current-Z_Lower)/V_resolution+100)
		MoveStp(1,100)
	elseif(Z_Current<Z_Lower)
		MoveStp(1,(Z_Lower-Z_Current)/V_resolution)	
	endif
	Waiting(5000, 3e6)//waiting for positional stabilization
	//i=0
	//do
	//	 i+=1
	//while(i<=10000)
	//W_RPZprof, W_L00Zprof, W_L90Zprof
	ScanConfig("Navrage")
	for(i=0;Z_Current<=Z_Upper;i+=1)
		print i
		scan3DP("Slice6D")
		W_RPZprof[i]=W_3int[0]
		W_LP00Zprof[i]=W_3int[1]
		W_LP90Zprof[i]=W_3int[2]
		If(V_compmin==1)
			W_RLratio[i]=W_RPZprof[i]/min(W_LP00Zprof[i], W_LP90Zprof[i])
		else
			W_RLratio[i]=W_RPZprof[i]/max(W_LP00Zprof[i], W_LP90Zprof[i])
		endif
		if(abs(Z_Temp)<0.000001)
			Z_Current=0
			Z_Temp=0
		endif
			M_4D[][][i][0]=CLMS_XYwave_LP00[p][q]
			M_4D[][][i][1]=CLMS_XYwave_LP90[p][q]
			M_4D[][][i][2]=CLMS_XYwave_RP1[p][q]
		for(j=1;j<5;j+=1)
			PM_RatioImg("Slice6D",j,"")
			M_4D[][][i][2+j]=W_Ratio2D[p][q]
		endfor
		//
		UP1stp("Slice6D")

		waiting(5000, 5e6)
	endfor
End


Function scan3DP(ctrlName) : ButtonControl
	String ctrlName
	NVAR Z_Current=Z_Current
	NVAR Z_Temp=Z_Temp
	NVAR V_resolution=V_resolution
	NVAR Z_Upper=Z_Upper
	NVAR Z_Lower=Z_Lower
	NVAR X_Pixels=X_Pixels
	NVAR Y_Pixels=Y_Pixels
	wave CLMS_XYwave_avr
	Nvar V_deg1=V_deg1
	Nvar F_repeat
	SVAR S_Format
	SVAR S_fileName
	wave mglay
	variable i
	if(cmpstr(ctrlName,"Scan3Dpol")==0)
		ScanConfig("scan3DP")
	endif
	make /O /N=3 W_3int
	do
	print "RP_Scanning"
	ButtonProc_RP1(ctrlName)
	doupdate
	Waiting(5000, 1e6)
	Navrage(ctrlName)
	duplicate/O CLMS_XYwave_avr CLMS_XYwave_RP1
	print "00deg_Scanning"
	//mglay=155.652
	///V_deg1=90
	///ButtonProc_plane(ctrlName)
	LP00(ctrlName)
	doupdate
	W_3int[0]=makehistogram("CLMS_XYwave_RP1", 10)
	Waiting(5000, 1e6)
	Navrage(ctrlName)
	duplicate/O CLMS_XYwave_avr CLMS_XYwave_LP00
	//V_deg1=288
	//ButtonProc_plane(ctrlName)
	print "90deg_Scanning"
	//mglay=61.6427
	LP90(ctrlName)
	doupdate
	W_3int[1]=makehistogram("CLMS_XYwave_LP00", 10)
	Waiting(5000, 1e6)
	Navrage(ctrlName)
	duplicate/O CLMS_XYwave_avr CLMS_XYwave_LP90
	W_3int[2]=makehistogram("CLMS_XYwave_LP90", 10)
	
	SVP_IntensityCompensation("",0,"","")
	PM_RatioImg("SP_moveZSispPoint",4,"RP_LPratio")
	while(F_repeat)
End




Function Navrage(ctrlName) : ButtonControl
	String ctrlName
	NVAR navr
	wave CLMS_XYwave1
	print ctrlName
	if(CmpStr(ctrlName,"Scan2D")==0)
		ScanConfig("Navrage")
	print "config"
	endif
	Variable i=0
	
	do
		Scaning_One("Navrage")
		duplicate /O CLMS_XYwave1, CLMS_XYwave_avr
		CLMS_XYwave_avr=0
		CLMS_XYwave_avr+=CLMS_XYwave1/navr
		doupdate
		i+=1
	while(i<navr)
	return MakeHistogram("CLMS_XYwave_avr", 10)
End

Function BP_Cont2DScan(ctrlName) : ButtonControl
	String ctrlName
	wave CLMS_XYwave1
	ScanConfig(ctrlName)
	duplicate /O CLMS_XYwave1, CLMS_XYwave2,CLMS_XYwave3,CLMS_XYwave4,CLMS_XYwave5,CLMS_XYwave6,CLMS_XYwave7,CLMS_XYwave8,CLMS_XYwave9,CLMS_XYwave10,CLMS_XYwave_avr

	do
	CLMS_XYwave2=CLMS_XYwave1
	CLMS_XYwave3=CLMS_XYwave2
	CLMS_XYwave4=CLMS_XYwave3
	CLMS_XYwave5=CLMS_XYwave4
	CLMS_XYwave6=CLMS_XYwave5
	CLMS_XYwave7=CLMS_XYwave6
	CLMS_XYwave8=CLMS_XYwave7
	CLMS_XYwave9=CLMS_XYwave8
	CLMS_XYwave10=CLMS_XYwave9
	Scaning_One(ctrlName)
	CLMS_XYwave_avr = (CLMS_XYwave1+ CLMS_XYwave2+CLMS_XYwave3+CLMS_XYwave4+CLMS_XYwave5+CLMS_XYwave6+CLMS_XYwave7+CLMS_XYwave8+CLMS_XYwave9+CLMS_XYwave10)/10
	doupdate
	while(1)

End

Function ButtonProc_Initialize(ctrlName) : ButtonControl
//| Initialization for PCI-6024E/6025E
//| Device number of this board must be 1.
	String ctrlName
	Nvar F_TwoWay
	//fNIDAQ_Mode(2)
	//fNIDAQ_BoardReset(1)
	//fNIDAQ_SetInputChans(1, 16, 12, 1, 1)
	//fNIDAQ_SetInputTrigger(1, 1, 1, 1, 1, 1)
	//fNIDAQ_InputConfig(1, 0, 0, 20.000000)
	//fNIDAQ_SetOutputChans(1, 2, 12, 0, 0, 0)
	//fNIDAQ_OutputConfig(1, 0, 0, 20.000000)	//Device, Channel, bipolar, OutputRange
	//fNIDAQ_OutputConfig(1, 1, 0, 20.000000)	//Device, Channel, bipolar, OutputRange
	//fNIDAQ_SetCounters(1, 0, 0, 0)
	//fNIDAQ_DIG_Line_Config(1,0,0,1)
	//fNIDAQ_DIG_Line_Config(1,0,1,1)
	//fNIDAQ_DIG_Line_Config(1,0,2,1)
	//fNIDAQ_Mode(0)
	SVP_OutputX("ButtonProc_Initialize",0.1,"0V","")
	SVP_OutputY("ButtonProc_Initialize",0.1,"0V","")
	SVP_OutputX("ButtonProc_Initialize",0,"0V","")
	SVP_OutputY("ButtonProc_Initialize",0,"0V","")
	C_TwoWay("",F_TwoWay)
	//ScanConfig(ctrlName)
End
