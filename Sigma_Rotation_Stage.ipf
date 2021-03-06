
#pragma rtGlobals=1		// Use modern global access method.

Function Sigma_RStage_Init_Val()
	variable/G V_Sigma_Rotation_Stage_SSpeed	=1000	//Start speed of stepping motor control pulses
	variable/G V_Sigma_Rotation_Stage_FSpeed	=10000	//Finish speed of stepping motor control pulses
	variable/G V_Sigma_Rotation_Stage_ASpeed	=100		//Acceleration speed of stepping motor control pulses
	variable/G V_Sigma_Rotation_Stage_Port		=1		//port: 1 or 2    port of Mark202
	variable/G V_Sigma_Rotation_Stage_MSte                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                tep=$"V_Sigma_Rotation_Stage_MStep"
	num=round((degree)*200*MStep)
	do
		VDTWrite2/O=1/Q "!:\r\n"
		VDTRead2/t=",\n"/O=1/Q ans
	while(cmpstr(ans, "B\r")==0)
	do
		VDTWrite2/O=1/Q "A:"+num2str(port)+"+P"+num2str(num)+"\r\n"
		VDTRead2/t=",\n"/O=1/Q ans
	while(cmpstr(ans, "OK\r")!=0)
	do
		VDTWrite2/O=1/Q "G:\r\n"
		VDTRead2/t=",\n"/O=1/Q ans
	while(cmpstr(ans, "OK\r")!=0)
	do
		VDTWrite2/O=1/Q "!:\r\n"
		VDTRead2/t=",\n"/O=1/Q ans
	while(cmpstr(ans, "B\r")==0)
End

Window Sigma_Rotation_Stage() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(158,92,461,205)
	SetVariable Sigma_Rotation_Stage_SSpeed,pos={10,10},size={140,16},title="s speed"
	SetVariable Sigma_Rotation_Stage_SSpeed,font="Courier"
	SetVariable Sigma_Rotation_Stage_SSpeed,limits={0,200,1},value= V_Sigma_Rotation_Stage_SSpeed
	SetVariable Sigma_Rotation_Stage_FSpeed,pos={10,30},size={140,16},title="f speed"
	SetVariable Sigma_Rotation_Stage_FSpeed,font="Courier"
	SetVariable Sigma_Rotation_Stage_FSpeed,limits={0,20000,1},value= V_Sigma_Rotation_Stage_FSpeed
	SetVariable Sigma_Rotation_Stage_ASpeed,pos={10,50},size={140,16},title="a speed"
	SetVariable Sigma_Rotation_Stage_ASpeed,font="Courier"
	SetVariable Sigma_Rotation_Stage_ASpeed,limits={0,200,1},value= V_Sigma_Rotation_Stage_ASpeed
	PopupMenu Sigma_Rotation_Stage_Port,pos={203,8},size={80,21},proc=Sigma_RStage_Port_PopMenu,title="Port"
	PopupMenu Sigma_Rotation_Stage_Port,font="Courier"
	PopupMenu Sigma_Rotation_Stage_Port,mode=1,popvalue=num2str(V_Sigma_Rotation_Stage_Port) ,value= #"\"1;2\""
	Button Sigma_Rotation_Stage_Int,pos={231,80},size={50,20},proc=Sigma_RStage_Init_Button,title="Init"
	Button Sigma_Rotation_Stage_Int,font="Courier"
	PopupMenu Sigma_Rotation_Stagw_MStep,pos={155,42},size={128,21},proc=Sigma_RStage_MStep_PopMenu,title="micro step"
	PopupMenu Sigma_Rotation_Stagw_MStep,font="Courier"
	PopupMenu Sigma_Rotation_Stagw_MStep,mode=1,popvalue=num2str(V_Sigma_Rotation_Stage_MStep) ,value= #"\"1;2;4;5;8;10;20;40;80\""
	SetVariable Sigma_Rotation_Stage_Degree,pos={12,82},size={140,16},proc=Sigma_RStage_GotoVarProc,title="GoTo"
	SetVariable Sigma_Rotation_Stage_Degree,font="Courier",format="%g degree"
	SetVariable Sigma_Rotation_Stage_Degree,limits={0,360,0.1},value= V_Sigma_Rotation_Stage_Degree
EndMacro

Function Sigma_RStage_Port_PopMenu(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	Nvar port =$"V_Sigma_Rotation_Stage_Port"	
	port = str2num(popStr)
End

Function Sigma_RStage_Init_Button(ctrlName) : ButtonControl
	String ctrlName
	Nvar S=$"V_Sigma_Rotation_Stage_SSpeed"
	Nvar F=$"V_Sigma_Rotation_Stage_FSpeed"
	Nvar A=$"V_Sigma_Rotation_Stage_ASpeed"
	Nvar port=$"V_Sigma_Rotation_Stage_Port"
	Nvar MStep=$"V_Sigma_Rotation_Stage_MStep"
	variable/G V_RStage_ZeroPoint
	//Sigma_RStage_Init_Val()
	String ans1 
	//SKIDS-60YAW: max movement 30deg/s, 0.005deg/pulse
	//Fastmode:S=1000, F=10000, A=100
	//
	if( port !=1 && port!=2)
		port =1
	endif

	VDT2 /P=COM1 baud=38400, buffer=4096, databits=8, echo=0, in=1, killio, out=1, parity=0, rts=1, stopbits=1, terminalEOL=2
	VDTWrite2/O=1/Q "D:"+num2str(port)+"S"+num2str(S)+"F"+num2str(F)+"R"+num2str(A)+"\r\n"
	VDTRead2/t=",\n"/O=1/Q ans1
	do
		VDTWrite2/O=1/Q "H:"+num2str(port)+"\r\n"
		VDTRead2/t=",\n"/O=1/Q ans1
	while(cmpstr(ans1, "OK\r")!=0)
	do
		VDTWrite2/O=1/Q "!:\r\n"
		VDTRead2/t=",\n"/O=1/Q ans1
	while(cmpstr(ans1, "B\r")==0)

	do
		VDTWrite2/O=1/Q "S:"+num2str(port)+num2str(MStep)+"\r\n"
		VDTRead2/t=",\n"/O=1/Q ans1
	while(cmpstr(ans1, "OK\r")!=0)
	Sigma_Rotation_Stage_Goto(V_RStage_ZeroPoint,port)
	do
		VDTWrite2/O=1/Q "R:"+num2str(port)+"\r\n"
		VDTRead2/t=",\n"/O=1/Q ans1
	while(cmpstr(ans1, "OK\r")!=0)	
End

Function Sigma_RStage_MStep_PopMenu(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	NVar  MStep=$"V_Sigma_Rotation_Stage_MStep"

	MStep = str2num(popStr)
End

Function Sigma_RStage_GotoVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String ans1
	Variable num
	Nvar MStep	=$"V_Sigma_Rotation_Stage_MStep"
	Nvar port	=$"V_Sigma_Rotation_Stage_Port"
	Nvar degree	=$"V_Sigma_Rotation_Stage_Degree"

	num=round((varNum)*100*MStep)
	
	do
		VDTWrite2/O=1/Q "!:\r\n"
		VDTRead2/t=",\n"/O=1/Q ans1
	while(cmpstr(ans1, "B\r")==0)
	do
		VDTWrite2/O=1/Q "A:"+num2str(port)+"+P"+num2str(num)+"\r\n"
		VDTRead2/t=",\n"/O=1/Q ans1
	while(cmpstr(ans1, "OK\r")!=0)
	do
		VDTWrite2/O=1/Q "G:\r\n"
		VDTRead2/t=",\n"/O=1/Q ans1
	while(cmpstr(ans1, "OK\r")!=0)
	do
		VDTWrite2/O=1/Q "!:\r\n"
		VDTRead2/t=",\n"/O=1/Q ans1
	while(cmpstr(ans1, "B\r")==0)
	degree=varNum
End

