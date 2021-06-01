#pragma rtGlobals=1		// Use modern global access method.
#include  <TransformAxis1.2>

// Load ICS/IDS ver. 1 file
// Produced by Mamoru Hashimoto 2009.2.11

Menu "Load Waves"
"ICS-IDS Open",  ICSIDS(, , )
End 

Macro ICSIDS(pathName, fileName, wName)
	String pathName, fileName, wname="data"
	Prompt pathName, "Enter Path: " ,popup,pathlist("*",";","")+";_none_"// set prompt for x param
	Prompt fileName, "Enter File Name (need not extention): " //
	Prompt wName, "Enter Wave Name : "
	ICSIDS_Open(pathName, fileName, wname)
End

Function ICSIDS_Open(pathName, fileName, wname)
	String pathName		// Name of symbolic path or "" for dialog.
	String fileName		// File name, partial path, full path
	String wname
	Variable refNum
	String str

	Make/O/T/N=200 ICSIDS_text
	
	// Open file for read.
	DoAlert 0, "Select ICS file"

	String ICSfileName="", IDSfileName=""
	if( stringmatch("", "")==1)
		ICSfileName=fileName+".ics"
		IDSfileName=fileName+".ids"
	endif
	print pathName, ICSfileName, IDSfileName
	Open/R/Z=2/P=$pathName refNum as ICSfileName

	// Store results from Open in a safe place.
	Variable err = V_flag
	String fullPath = S_fileName

	if (err == -1)
		Print "ICSIDS Open cancelled by user."
		return -1
	endif

	if (err != 0)
		DoAlert 0, "Error in ICSIDS Open"
		return err
	endif

	Variable i,j
	for(i=0; i<200; i+=1)
		FReadLine refNum, str		// Read first line into string variable
		ICSIDS_text[i]=str
	endfor
	Close refNum
	
	Variable paramNum
	paramNum= ICSIDS_GetParam(ICSIDS_text)

	if( paramNum > 5 )
		DoAlert 0, "ICSIDS paramNum Overflow"
		return err
	endif

	Make/N=(paramNum, 2)/T/O ICSIDS_tparam
		//ICSIDS_tparam[][0]  order
		//ICSIDS_tparam[][1]  unit
		
	Make/N=(paramNum, 4)/O ICSIDS_vparam
		//ICSIDS_param[][0]   sizes
		//ICSIDS_param[][1]   origin
		//ICSIDS_param[][2]   scale
		//ICSIDS_param[][3]   unit
	
	Variable ch			
	ch=ICSIDS_GetVal(ICSIDS_text, ICSIDS_Tparam, ICSIDS_Vparam, paramNum)
	
	Variable Dtype
	Dtype=ICSIDS_CheckFormat(ICSIDS_text, ICSIDS_Vparam[0][0])
	
	if(Dtype < 1)
		DoAlert 0, "Not supported data type"
		return err
	endif		

	DoAlert 0, "Select IDS file"
	if( ICSIDS_CheckByteOrder(ICSIDS_text) == 1)  //low byte first
		GBLoadWave/B/O/A=ICSIDS_data/T={Dtype,Dtype}/W=1 IDSfileName
	else										//high byte first
		GBLoadWave/O/A=ICSIDS_data/T={Dtype,Dtype}/W=1 IDSfileName
	endif
	
	Wave ICSIDS_data=$"ICSIDS_data0"
	
	variable data_start, xx, yy, zz
	data_start=ICSIDS_StartData(ICSIDS_Tparam, ICSIDS_Vparam, paramNum)
	xx=ICSIDS_Vparam[data_start][0]
	yy=ICSIDS_Vparam[data_start+1][0]
	zz=ICSIDS_Vparam[data_start+2][0]
	for(i=0; i<ch; i+=1)
		make/O/N=(xx,yy,zz) $wname+num2str(i)
		Wave w=$wname+num2str(i)
		SetScale/P x ICSIDS_Vparam[data_start][1]*ICSIDS_Vparam[data_start][3],ICSIDS_Vparam[data_start][2]*ICSIDS_Vparam[data_start][3], ICSIDS_Tparam[data_start][2], w
		SetScale/P y ICSIDS_Vparam[data_start+1][1]*ICSIDS_Vparam[data_start+1][3],ICSIDS_Vparam[data_start+1][2]*ICSIDS_Vparam[data_start+1][3], ICSIDS_Tparam[data_start+1][2], w
		SetScale/P z ICSIDS_Vparam[data_start+2][1]*ICSIDS_Vparam[data_start+2][3],ICSIDS_Vparam[data_start+2][2]*ICSIDS_Vparam[data_start+2][3], ICSIDS_Tparam[data_start+2][2], w
		w= ICSIDS_data[ch*(p+q*xx+r*yy*xx)+i]	
		for(j=0; j<200;j+=1)
			Note w, ICSIDS_text[j]
		endfor
	endfor
	
	//killwaves  ICSIDS_tparam,  ICSIDS_Vparam,  ICSIDS_data//, ICSIDS_text
	return 0
End

Function ICSIDS_CheckFormat(w, bit)
	// return byte format for Load General Binary File
	Wave/T w
	Variable bit
	Variable i
	Variable ret
	
	if(bit==8)
		ret=8
	elseif(bit==16)
		ret=16
	elseif(bit==32)
		ret=32
	elseif(bit==64)
		ret=64
	else
		return -1	//error
	endif
	
	String format, signv
	for(i=0; i<200; i+=1)
		if( stringmatch(w[i], "*representation	format*")==1)
			format=StringByKey("representation	format", w[i], "\t")
		endif
		if( stringmatch(w[i], "*representation	sign*")==1)
			signv=StringByKey("representation	sign", w[i], "\t")
		endif
	endfor
	
	if( stringmatch(format, "*real*")==1)
		ret/=16
	elseif( stringmatch(format, "*integer*")==1)
	else
		return -2  //error
	endif
	
	if( stringmatch(signv, "*unsigned*")==1)
		ret+=64
	endif
	return ret
End
	

Function ICSIDS_CheckByteOrder(w)
	// return byte order for Load General Binary File
	Wave/T w
	Variable i
	String byte_order

	for(i=0; i<200; i+=1)
		if( stringmatch(w[i], "*representation	byte_order*")==1)
			byte_order=StringByKey("representation	byte_order", w[i], "\t")
			if( str2num(StringFromList(0, byte_order, "\t"))!=1)
				return 0          //  high byte first
			else
				return 1          //  low byte first
			endif
		endif		
	endfor
	return 1
End

Function  ICSIDS_StartData(ICSIDS_Tparam, ICSIDS_Vparam, paramNum)
	// if ICSIDS_Tparam[1] == "x, y, z, time" return 1.  else return 2
	Wave/T ICSIDS_Tparam
	Wave ICSIDS_Vparam
	Variable paramNum

	if(stringmatch(ICSIDS_Tparam[1][0], "*x*")==1)
		return 1
	endif
	if(stringmatch(ICSIDS_Tparam[1][0], "*y*")==1)
		return 1
	endif
	if(stringmatch(ICSIDS_Tparam[1][0], "*z*")==1)
		return 1
	endif
	if(stringmatch(ICSIDS_Tparam[1][0], "*time*")==1)
		return 1
	endif
	return 2
End
	

Function ICSIDS_GetParam(w)
	Wave/T w
	Variable i
	for(i=0;i<200; i+=1)
		if( stringmatch(w[i], "*layout	parameters*")==1)
			return str2num(StringByKey("layout	parameters", w[i], "\t"))
		endif
	endfor
End

Function ICSIDS_GetVal(w, ICSIDS_Tparam, ICSIDS_Vparam, paramNum)
	Wave/T w
	Wave/T ICSIDS_Tparam
	Wave ICSIDS_Vparam
	Variable paramNum
	
	Variable i
	String order
	String sizes, origin, scale, units
	for(i=0; i<200; i+=1)
		if( stringmatch(w[i], "*layout	order*")==1)
			order=StringByKey("layout	order", w[i], "\t")
		endif
		if( stringmatch(w[i], "*layout	sizes*")==1)
			sizes=StringByKey("layout	sizes", w[i], "\t")
		endif
		if( stringmatch(w[i], "*parameter	origin*")==1)
			origin=StringByKey("parameter	origin", w[i], "\t")
		endif		
		if( stringmatch(w[i], "*parameter	scale*")==1)
			scale=StringByKey("parameter	scale", w[i], "\t")
		endif		
		if( stringmatch(w[i], "*parameter	units*")==1)
			units=StringByKey("parameter	units", w[i], "\t")
		endif		
	endfor
	for(i=0; i< paramNum; i+=1)
		ICSIDS_Tparam[i][0]=StringFromList(i, order, "\t")
		ICSIDS_Vparam[i][0]=str2num(StringFromList(i, sizes, "\t") )
		ICSIDS_Vparam[i][1]=str2num(StringFromList(i, origin, "\t") )
		ICSIDS_Vparam[i][2]=str2num(StringFromList(i, scale, "\t") )
		if( stringmatch(StringFromList(i, units, "\t"), "*mm*")==1)
			ICSIDS_Tparam[i][1]="m"
			ICSIDS_Vparam[i][3]=1.0e-3
		elseif( stringmatch(StringFromList(i, units, "\t"), "*um*")==1)
			ICSIDS_Tparam[i][1]="m"
			ICSIDS_Vparam[i][3]=1.0e-6
		else
			ICSIDS_Tparam[i][1]=StringFromList(i, units, "\t")
			ICSIDS_Vparam[i][3]=1		
		endif			
	endfor
	Variable ch=1
	for(i=0; i< paramNum; i+=1)
		if(stringmatch(ICSIDS_Tparam[i][0], "*x*")==1)
			return ch
		endif
		if(stringmatch(ICSIDS_Tparam[i][0], "*y*")==1)
			return ch
		endif
		if(stringmatch(ICSIDS_Tparam[i][0], "*z*")==1)
			return ch
		endif
		if(stringmatch(ICSIDS_Tparam[i][0], "*time*")==1)
			return ch
		endif
		if(stringmatch(ICSIDS_Tparam[i][0], "*bits*")==1)
			ch*=1
		else
			ch*=ICSIDS_Vparam[i][0]
		endif
	endfor
End