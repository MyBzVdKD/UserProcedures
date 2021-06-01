

Function GotoZ(ctrlName) : ButtonControl
	String ctrlName
	doupdate
End


Function SetZero(ctrlName) : ButtonControl
	String ctrlName
	NVAR Z_Current=Z_Current
	NVAR Z_Temp=Z_Temp
	Z_Current=0
	Z_Temp=0
End


Function UP1stp(ctrlName) : ButtonControl
	String ctrlName
	NVAR Z_Step=Z_Step
	NVAR V_resolution=V_resolution
	MoveStp(1,Z_Step/V_resolution)
End

Function DOWN1stp(ctrlName) : ButtonControl
	String ctrlName
	NVAR Z_Step=Z_Step
	NVAR V_resolution=V_resolution
	MoveStp(-1,Z_Step/V_resolution)

End

Function MoveStp(Direction,Steps) : ButtonControl
	Variable Direction,Steps
	NVAR Z_Temp=Z_Temp
	NVAR V_resolution=V_resolution
	NVAR Z_Current=Z_Current
	NVAR F_PiezoZscan, F_Objectivelocked
	NVAR V_CurPiezoZPos
	Nvar LCD_Ctrl_Status
	if(LCD_Ctrl_Status*F_PiezoZscan)//turn OFF LCD wavegeneration
		LCD_Ctrl_ButtonProc("Slice6D")
	endif

	switch(Direction)
		case 1:		//CW(moves Upword)
			Z_Temp+=V_resolution*Steps
			Z_Current=Z_Temp
			//DAQmx_DIO_Config /DEV="Dev1" /DIR=1 /LGRP=1 "/dev1/port0/line0"
			doupdate
			for(;Steps>0;steps-=1)	
				GenerateOneStepPulse("MoveStp(CW)",0)
				//fNIDAQ_DIG_Out_Line(1,0,0,0)
				//fNIDAQ_DIG_Out_Line(1,0,0,1)
				//fNIDAQ_DIG_Out_Line(1,0,0,0)
			endfor
			//DAQmxErrorReport("MoveStp",fDAQmx_DIO_finished("Dev1", V_DAQmx_DIO_TaskNumber))
			break
		case -1:		//CCW
			Z_Temp-=V_resolution*Steps
			Z_Current=Z_Temp
			//DAQmx_DIO_Config /DEV="Dev1" /DIR=1 /LGRP=1 "/dev1/port0/line1"
			doupdate
			for(;Steps>0;Steps-=1)	
				GenerateOneStepPulse("MoveStp(CCW)", 1)
				//fNIDAQ_DIG_Out_Line(1,0,1,0)
				//fNIDAQ_DIG_Out_Line(1,0,1,1)
				//fNIDAQ_DIG_Out_Line(1,0,1,0)
			endfor
			//DAQmxErrorReport("MoveStp", fDAQmx_DIO_finished("Dev1", V_DAQmx_DIO_TaskNumber))
			break
	endswitch
	if(LCD_Ctrl_Status==0&&F_PiezoZscan!=0)//turn ON LCD wavegeneration
		LCD_Ctrl_ButtonProc("Slice6D")
	endif
End

function GenerateOneStepPulse(ctrlName, F_DirRotation)
	string ctrlName
	variable F_DirRotation
	NVAR F_PiezoZscan, F_Objectivelocked
	NVAR V_CurPiezoZPos, V_resolution
	wave M_MotorTaskIndex
	DAQmxErrorReport("GenerateOneStepPulse_"+ctrlName, fDAQmx_DIO_Write( "Dev1", M_MotorTaskIndex[F_DirRotation], 1-F_Objectivelocked))
	V_CurPiezoZPos=PiezoZPositioning("GenerateOneStepPulse", V_CurPiezoZPos-(1-2*F_DirRotation)*F_PiezoZscan*V_resolution*(1-2*F_Objectivelocked))
		//print V_CurPiezoZPos-(1-2*F_DirRotation)*F_PiezoZscan*V_resolution*(1-2*F_Objectivelocked)
	Waiting(5000, 1e3)
	DAQmxErrorReport("GenerateOneStepPulse_"+ctrlName, fDAQmx_DIO_Write( "Dev1", M_MotorTaskIndex[F_DirRotation], 0))
	Waiting(5000, 1e3)
end

Function PiezoZPositioning(ctrlName, V_pos_um)
	string ctrlName
	variable V_pos_um
	variable V_Vol
	variable /G V_PiezoCh=6
	variable /G V_Mag_um2V=0.5
	if(abs(V_pos_um)>10)
		print "PiezoZPositioning at "+ctrlName+"OVER RANGE"
		V_Vol=sign(V_pos_um)*10*V_Mag_um2V
		NIDAQ_6723_Wri( 6, V_Vol)
		return V_pos_um
	else
		V_Vol=V_pos_um*V_Mag_um2V
		NIDAQ_6723_Wri( 6, V_Vol)
		return V_pos_um
	endif
end

function DAQmxErrorReport(ctrlName, F_functionReturn)
	string ctrlName
	variable F_functionReturn
	if(F_functionReturn)
	print "[in function "+ctrlName+"]\r"+fDAQmx_ErrorString()
	endif
end

Function SC_ZCurrentPosition(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved
	NVAR Z_Current=Z_Current
	NVAR Z_Temp=Z_Temp
	NVAR V_resolution=V_resolution
	if(event %& 0x1)	// bit 0, value set
		if (Z_Current>sliderValue)
			Z_Temp=Z_Current
			MoveStp(-1,(Z_Current-sliderValue)/V_resolution)
		elseif(Z_Current<sliderValue)
			Z_Temp=Z_Current
			MoveStp(1,(sliderValue-Z_Current)/V_resolution)
		endif
	endif

	return 0
End



Function ReturnToZero(ctrlName) : ButtonControl
	String ctrlName
	NVAR Z_Current=Z_Current
	NVAR Z_Temp=Z_Temp
	NVAR V_resolution=V_resolution
	if (Z_Current>0)
		MoveStp(-1,Z_Current/V_resolution)					// execute if condition 1 is TRUE
	elseif (Z_Current<0)
		MoveStp(1,-Z_Current/V_resolution)					// execute if condition 2 is TRUE and condition 1 is FALSE
	endif
	
End

Function Zposition(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	NVAR Z_Current=Z_Current
	NVAR Z_Temp=Z_Temp
	NVAR V_resolution=V_resolution
		if (Z_Current>varNum)
			Z_Temp=Z_Current
			MoveStp(-1,(Z_Current-varNum)/V_resolution)
		elseif(Z_Current<varNum)
			Z_Temp=Z_Current
			MoveStp(1,(varNum-Z_Current)/V_resolution)	
		endif

End


Function C_Fine(ctrlName,checked) : CheckBoxControl//tobe converted Mx
	String ctrlName
	Variable checked
	NVAR V_resolution=V_resolution
	NVAR micron_rev=micron_rev
	NVAR Deg_Step1=Deg_Step1
	NVAR Deg_Step2=Deg_Step2
	Svar deviceName=$"NIDAQ6025_Dev"
	wave M_MotorTaskIndex
	if (checked)//FineMode
		V_resolution=(micron_rev/360.0)*Deg_Step2
		DAQmxErrorReport("C_Fine", fDAQmx_DIO_Write( "Dev1", M_MotorTaskIndex[2], 1))
		//fNIDAQ_DIG_Out_Line(1,0,2,1)
		///DAQmx_DIO_Config /Dev=deviceName /DIR=direction
		///fDAQmx_DIO_Write(Device, TaskIndex, OutputValue)
	else
		V_resolution=(micron_rev/360.0)*Deg_Step1
		DAQmxErrorReport("C_Fine", fDAQmx_DIO_Write( "Dev1", M_MotorTaskIndex[2], 0))
		//fNIDAQ_DIG_Out_Line(1,0,2,0)
		///DAQmx_DIO_Config/Dev=deviceName
		///fDAQmx_DIO_Write
	endif
End

Function C_LockObjective(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

End
Function C_PiezoZscan(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	Nvar V_CurPiezoZPos
	print "Current piezo position = ", V_CurPiezoZPos

	
End

Function C_ObjectiveLock(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

End

function Init_SteppingMotorController(ctrlName) : ButtonControl
	string ctrlName//	
	make /O /n=3 M_MotorTaskIndex
	DAQmx_DIO_Config /DEV="Dev1" /DIR=1 /LGRP=1 "/dev1/port0/line0"//CW
	M_MotorTaskIndex[0]=V_DAQmx_DIO_TaskNumber
	DAQmx_DIO_Config /DEV="Dev1" /DIR=1 /LGRP=1 "/dev1/port0/line1"//CCW
	M_MotorTaskIndex[1]=V_DAQmx_DIO_TaskNumber
	DAQmx_DIO_Config /DEV="Dev1" /DIR=1 /LGRP=1 "/dev1/port0/line2"//Finemode
	M_MotorTaskIndex[2]=V_DAQmx_DIO_TaskNumber
end

function Fin_SteppingMotorController(ctrlName) : ButtonControl
	string ctrlName
	wave M_MotorTaskIndex
	DAQmxErrorReport("MoveStp", fDAQmx_DIO_finished("Dev1", M_MotorTaskIndex[0]))
	DAQmxErrorReport("MoveStp", fDAQmx_DIO_finished("Dev1", M_MotorTaskIndex[1]))
	DAQmxErrorReport("MoveStp", fDAQmx_DIO_finished("Dev1", M_MotorTaskIndex[2]))
end