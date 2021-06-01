#pragma rtGlobals=1		// Use modern global access method.
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

//function Reduction(V_devided, V_devide, F_output)
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
//end