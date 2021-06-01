#include "PiLabelGenerator"

function PSFdisplayLin()
	display 
	AppendImage/L=L_Lin/T=T_Lin linear
	AppendImage/L=L_Linxx/T=T_Linxx M_Linear_Ixx
	AppendImage/L=L_P/T=T_P M_Pinhole
	AppendImage/L=L_LinP/T=T_LinP M_Lin_Pinhole
	//execute "GraphShaper()"
	DelMargin()
	ModifyGraph width={Aspect,4}
	ModifyGraph fSize=12,font="Verdana"
	ModifyGraph axisEnab(T_Lin)={0,0.25},axisEnab(T_Linxx)={0.25,0.5};DelayUpdate
	ModifyGraph axisEnab(T_P)={0.5,0.75},axisEnab(T_LinP)={0.75,1}
	ModifyImage linear cindex=$Gen_Modified_SpectrumBlack("MC_linear", linear, 1, 0, 0)
	ModifySpectrumBlack(MC_linear, linear,0, 0, 1, 30)
	ModifyImage M_Linear_Ixx cindex=$Gen_Modified_SpectrumBlack("MC_Linear_Ixx", M_Linear_Ixx, 1, 0, 0)
	ModifySpectrumBlack(MC_Linear_Ixx, M_Linear_Ixx, 25, 0, 1, 30)
	ModifyImage M_Pinhole cindex=$Gen_Modified_SpectrumBlack("MC_Pinhole", M_Pinhole, 1, 0, 0)
	ModifySpectrumBlack(MC_Pinhole, M_Pinhole, 50, 0, 1, 30)
	ModifyImage M_Lin_Pinhole cindex=$Gen_Modified_SpectrumBlack("MC_Lin_Pinhole", M_Lin_Pinhole, 1, 0, 0)
	ModifySpectrumBlack(MC_Lin_Pinhole, M_Lin_Pinhole, 75, 0, 1, 30)
end

function MakeImageArray(V_nRaws, V_nColumns, L_images, L_text)
	variable V_nRaws, V_nColumns
	string L_images, L_text
	variable i, j
	string S_WN_image, S_text, S_Leftaxis, S_Topaxis, S_ColorScale_image
	variable, V_margin=1//%
	variable V_RawSize=1/V_nRaws
	variable V_ColumnSize=1/V_nColumns
	variable V_RawMargin=V_RawSize*(V_margin/100)/2
	variable V_ColumnMargin=V_ColumnSize*(V_margin/100)/2
	V_RawSize*=1-V_margin/100
	V_ColumnSize*=1-V_margin/100
	variable V_heightPct=V_ColumnSize*150/V_nRaws
	variable V_widthPct=V_RawSize*5/V_nColumns
	//print V_heightPct, V_widthPct
	variable V_RawPos
	variable V_ColumnPos
	display
	DelMargin()
	
	ModifyGraph fSize=12,font="default"
	for(j=0; j<V_nColumns ; j+=1)
		for(i=0; i<V_nRaws ; i+=1)
			S_WN_image=StringFromList(i+j*V_nRaws, L_images)
			S_text=StringFromList(i+j*V_nRaws, L_text)
			S_ColorScale_image="CM_"+S_WN_image
			if(stringmatch(S_WN_image, ""))
			else
				S_Leftaxis="L_"+S_WN_image
				S_Topaxis="T_"+S_WN_image
				AppendImage /L=$S_Leftaxis /T=$S_Topaxis $S_WN_image
				V_RawPos=V_RawMargin+(V_RawMargin*2+V_RawSize)*i
				V_ColumnPos=V_ColumnMargin+(V_ColumnMargin*2+V_ColumnSize)*j
				//print V_RawPos, V_ColumnPos
				ModifyGraph axisEnab($S_Leftaxis)={V_RawPos, V_RawPos+V_RawSize}
				ModifyGraph axisEnab($S_Topaxis)={V_ColumnPos, V_ColumnPos+V_ColumnSize}
				ModifyImage $S_WN_image cindex=$Gen_Modified_SpectrumBlack(S_ColorScale_image, $S_WN_image, 1, 0, 0)
				Gen_Modified_SpectrumBlack(S_ColorScale_image, $S_WN_image, 1, 0, 0)
				ModifySpectrumBlack($S_ColorScale_image, $S_WN_image, V_ColumnPos*100, V_RawPos*100, V_heightPct, V_widthPct)
				Gen_Subcaption("Txt_"+num2str(i+j*V_nRaws), S_text, V_ColumnPos*100, V_RawPos*100)
			endif
		endfor
	endfor
	DelMargin()
	ModifyGraph width={Aspect, (V_nColumns/V_nRaws)}
end

function /S MakeImageArrayR(V_nRaws, V_nColumns, L_images, L_text, F_alignment, F_RefWave)
	variable V_nRaws, V_nColumns
	string L_images, L_text
	variable  F_alignment, F_RefWave

	variable i, j
	string S_WN_image, S_text, S_Leftaxis, S_Topaxis, S_ColorScale_image
	variable, V_margin=1//%
	variable V_RawSize=1/V_nRaws
	variable V_ColumnSize=1/V_nColumns
	variable V_RawMargin=V_RawSize*(V_margin/100)/2
	variable V_ColumnMargin=V_ColumnSize*(V_margin/100)/2
	V_RawSize*=1-V_margin/100
	V_ColumnSize*=1-V_margin/100
	variable V_heightPct=V_ColumnSize*150/V_nRaws
	variable V_widthPct=V_RawSize*5/V_nColumns
	//print V_heightPct, V_widthPct
	variable V_RawPos
	variable V_ColumnPos
	variable V_ListMember
	display /N=ImagearrayR

	string S_Wstats=MaxMinSumAvgOfWaveList(L_images)
	variable V_Scale_max=str2num(stringfromlist(0, S_Wstats))
	variable V_Scale_min=str2num(stringfromlist(1, S_Wstats))
	//print V_Scale_max, V_Scale_min
	
	DelMargin()
	ModifyGraph fSize=12,font="default"
	for(j=0; j<V_nColumns ; j+=1)
		for(i=0; i<V_nRaws; i+=1)//V_nRaws*V_nColumns-i*(V_nColumns*1)+j
			V_ListMember=ChangeSequence_GraphArray(i, j, V_nRaws, V_nColumns, F_alignment)
			S_WN_image=StringFromList(V_ListMember, L_images)
			S_text=StringFromList(V_ListMember, L_text)
			//
			S_ColorScale_image="CM_"+S_WN_image
			if(stringmatch(S_WN_image, ""))
			else
				S_Leftaxis="L_"+S_WN_image
				S_Topaxis="T_"+S_WN_image
				AppendImage /L=$S_Leftaxis /T=$S_Topaxis $S_WN_image
				V_RawPos=V_RawMargin+(V_RawMargin*2+V_RawSize)*i
				V_ColumnPos=V_ColumnMargin+(V_ColumnMargin*2+V_ColumnSize)*j
				//print V_RawPos, V_ColumnPos
				ModifyGraph axisEnab($S_Leftaxis)={V_RawPos, V_RawPos+V_RawSize}
				ModifyGraph axisEnab($S_Topaxis)={V_ColumnPos, V_ColumnPos+V_ColumnSize}
				ModifyImage $S_WN_image cindex=$Gen_Modified_SpectrumBlack(S_ColorScale_image, $S_WN_image, F_RefWave, V_Scale_min, V_Scale_max)
				Gen_Modified_SpectrumBlack(S_ColorScale_image, $S_WN_image, F_RefWave, V_Scale_min, V_Scale_max)
				ModifySpectrumBlack($S_ColorScale_image, $S_WN_image, V_ColumnPos*100, V_RawPos*100, V_heightPct, V_widthPct)
				Gen_Subcaption("Txt_"+num2str(i+j*V_nRaws), S_text, V_ColumnPos*100+V_ColumnSize, V_RawPos*100+V_RawSize*90)
			endif
		endfor
	endfor
	DelMargin()
	ModifyGraph width={Aspect, (V_nColumns/V_nRaws)}
	return S_name
end

function /S MakeGraphArrayRXY(V_nRaws, V_nColumns, L_Xlocus, L_Ylocus, L_text, F_alignment)
	variable V_nRaws, V_nColumns
	string , L_Xlocus, L_Ylocus, L_text
	variable  F_alignment

	variable i, j
	string S_WN_Xlocis, S_WN_Ylocis, S_text, S_Leftaxis, S_Btmaxis
	variable, V_margin=1//%
	variable V_RawSize=1/V_nRaws
	variable V_ColumnSize=1/V_nColumns
	variable V_RawMargin=V_RawSize*(V_margin/100)/2
	variable V_ColumnMargin=V_ColumnSize*(V_margin/100)/2
	V_RawSize*=1-V_margin/100
	V_ColumnSize*=1-V_margin/100
	variable V_heightPct=V_ColumnSize*150/V_nRaws
	variable V_widthPct=V_RawSize*5/V_nColumns
	//print V_heightPct, V_widthPct
	variable V_RawPos
	variable V_ColumnPos
	variable V_ListMember
	display /N=GrapharrayR

	string S_XWstats=MaxMinSumAvgOfWaveList(L_Xlocus)
	string S_YWstats=MaxMinSumAvgOfWaveList(L_Ylocus)
	variable V_XScale_max=str2num(stringfromlist(0, S_XWstats))
	variable V_YScale_max=str2num(stringfromlist(1, S_YWstats))
	variable V_XScale_min=str2num(stringfromlist(0, S_XWstats))
	variable V_YScale_min=str2num(stringfromlist(1, S_YWstats))
	//print V_Scale_max, V_Scale_min
	
	DelMargin()
	ModifyGraph fSize=12,font="default"
	for(j=0; j<V_nColumns ; j+=1)
		for(i=0; i<V_nRaws; i+=1)//V_nRaws*V_nColumns-i*(V_nColumns*1)+j
			V_ListMember=ChangeSequence_GraphArray(i, j, V_nRaws, V_nColumns, F_alignment)
			S_WN_Xlocis=StringFromList(V_ListMember, L_Xlocus)
			S_WN_Ylocis=StringFromList(V_ListMember, L_Ylocus)
			S_text=StringFromList(V_ListMember, L_text)
			
			//
//			S_ColorScale_image="CM_"+S_WN_image
			if(stringmatch(S_WN_Ylocis, ""))
			else
				S_Leftaxis="L_"+S_WN_Ylocis
				S_Btmaxis="B_"+S_WN_Xlocis
//				AppendImage /L=$S_Leftaxis /T=$S_Topaxis $S_WN_image
				AppendToGraph /W=GrapharrayR /L=$S_Leftaxis/B=$S_Btmaxis $S_WN_Ylocis vs $S_WN_Xlocis
				V_RawPos=V_RawMargin+(V_RawMargin*2+V_RawSize)*i
				V_ColumnPos=V_ColumnMargin+(V_ColumnMargin*2+V_ColumnSize)*j
				//print V_RawPos, V_ColumnPos
				ModifyGraph axisEnab($S_Leftaxis)={V_RawPos, V_RawPos+V_RawSize}
				ModifyGraph axisEnab($S_Btmaxis)={V_ColumnPos, V_ColumnPos+V_ColumnSize}
				SetAxis $S_Leftaxis -1,1
				SetAxis $S_Btmaxis -1,1
				ModifyGraph rgb($S_WN_Ylocis)=(0,0,0)
				Gen_Subcaption("Txt_"+num2str(i+j*V_nRaws), S_text, V_ColumnPos*100+V_ColumnSize, V_RawPos*100+V_RawSize*90)
			endif
		endfor
	endfor
	DelMargin()
	ModifyGraph width={Aspect, (V_nColumns/V_nRaws)}
	return S_name
end


				


function ChangeSequence_GraphArray(V_ir, V_ic, V_nr, V_nc, F_alignment)
	variable V_ir, V_ic, V_nr, V_nc, F_alignment
//                 ic
//             0..........nc
//         nr x, x, x,.... 
//     ir  :   x, x, x,....
//         0  x, x, x,....
//F_alignment:
//	[0]　　	　[1]
// 0→		0  1… n
// 1→		↓↓　↓
// ：			
// n→		
	switch(F_alignment)
		case 0:
			return V_nr*V_nc-(V_ir+1)*(V_nc)+V_ic
			break
		case 1:
			return V_nr*V_ic+(V_nr-V_ir-1)
			break
		default:
			
	endswitch
	
end

function MakeImageArrayC(V_nRaws, V_nColumns, L_images, L_text)
	variable V_nRaws, V_nColumns
	string L_images, L_text
	variable i, j
	string S_WN_image, S_text, S_Leftaxis, S_Topaxis, S_ColorScale_image
	variable, V_margin=1//%
	variable V_RawSize=1/V_nRaws
	variable V_ColumnSize=1/V_nColumns
	variable V_RawMargin=V_RawSize*(V_margin/100)/2
	variable V_ColumnMargin=V_ColumnSize*(V_margin/100)/2
	V_RawSize*=1-V_margin/100
	V_ColumnSize*=1-V_margin/100
	variable V_heightPct=V_ColumnSize*150/V_nRaws
	variable V_widthPct=V_RawSize*5/V_nColumns
	//print V_heightPct, V_widthPct
	variable V_RawPos
	variable V_ColumnPos
	display
	DelMargin()
	
	ModifyGraph fSize=12,font="default"
	for(j=0; j<V_nColumns ; j+=1)
		for(i=0; i<V_nRaws ; i+=1)
			S_WN_image=StringFromList(i+j*V_nRaws, L_images)
			S_text=StringFromList(i+j*V_nRaws, L_text)
			S_ColorScale_image="CM_"+S_WN_image
			if(stringmatch(S_WN_image, ""))
			else
				S_Leftaxis="L_"+S_WN_image
				S_Topaxis="T_"+S_WN_image
				AppendImage /L=$S_Leftaxis /T=$S_Topaxis $S_WN_image
				V_RawPos=V_RawMargin+(V_RawMargin*2+V_RawSize)*i
				V_ColumnPos=V_ColumnMargin+(V_ColumnMargin*2+V_ColumnSize)*j
				//print V_RawPos, V_ColumnPos
				ModifyGraph axisEnab($S_Leftaxis)={V_RawPos, V_RawPos+V_RawSize}
				ModifyGraph axisEnab($S_Topaxis)={V_ColumnPos, V_ColumnPos+V_ColumnSize}
				ModifyImage $S_WN_image cindex=$Gen_Modified_SpectrumBlack(S_ColorScale_image, $S_WN_image, 1, 0, 0)
				Gen_Modified_SpectrumBlack(S_ColorScale_image, $S_WN_image, 1, 0, 0)
				ModifySpectrumBlack($S_ColorScale_image, $S_WN_image, V_ColumnPos*100, V_RawPos*100, V_heightPct, V_widthPct)
				Gen_Subcaption("Txt_"+num2str(i+j*V_nRaws), S_text, V_ColumnPos*100, V_RawPos*100)
			endif
		endfor
	endfor
	DelMargin()
	ModifyGraph width={Aspect, (V_nColumns/V_nRaws)}
end

function Gen_Subcaption(S_TboxName, S_text, V_Xpos, V_Ypos)
	string S_TboxName, S_text
	variable V_Xpos, V_Ypos
	TextBox /C/N=$S_TboxName /A=LB /F=0 /B=1 /G=(60928,60928,60928) /X=(V_Xpos) /Y=(V_Ypos) S_text
end

function /S Gen_Modified_SpectrumBlack(S_M_color, RefWave, F_RefWave, V_Scale_min, V_Scale_max)
	string S_M_color
	wave RefWave
	variable F_RefWave, V_Scale_min, V_Scale_max
	ColorTab2Wave SpectrumBlack
	DeletePoints 348,128, M_colors
	DeletePoints 290,58, M_colors
	Duplicate /O M_colors, $S_M_color
	if(F_RefWave)
		wavestats /M=1/Q RefWave
		V_Scale_min=V_min
		V_Scale_max=V_max
	endif
		SetScale/I x (V_Scale_min),(max(V_Scale_max, 1e-23)),"", $S_M_color
	killwaves M_colors
	return S_M_color
end

function ModifySpectrumBlack(M_ColorScale, M_target, V_Xpos, V_Ypos, V_heightPct, V_widthPct)
	wave M_ColorScale, M_target
	variable V_Xpos, V_Ypos, V_heightPct, V_widthPct
	string S_CSname="SC_"+NameOfWave(M_ColorScale)
	ColorScale /C/N=$S_CSname /F=0/B=1 cindex=M_ColorScale;DelayUpdate
	ColorScale /C/N=$S_CSname /F=0/B=1/G=(65535,65535,65535)/A=MC heightPct=V_heightPct, widthPct=V_widthPct;DelayUpdate
	ColorScale /C/N=$S_CSname font="default", lowTrip=1e-05;DelayUpdate
	ColorScale /C/N=$S_CSname image=$NameOfWave(M_target)};DelayUpdate
	ColorScale /C/N=$S_CSname/G=(60928,60928,60928) frameRGB=(65535,65535,65535);DelayUpdate
	ColorScale /C/N=$S_CSname /A=LB /X=(V_Xpos) /Y=(V_Ypos);DelayUpdate
end

function DelMargin()
	PauseUpdate; Silent 1		// modifying window...
	//ModifyGraph/Z margin(left)=-1,margin(bottom)=-1,margin(top)=-1,margin(right)=-1
	ModifyGraph/Z width={Aspect,1}
	ModifyGraph/Z tick=3
	ModifyGraph/Z mirror=0
	ModifyGraph/Z nticks=10
	ModifyGraph/Z minor=1
	ModifyGraph/Z noLabel=2
	ModifyGraph/Z fSize=8
	ModifyGraph/Z standoff=0
	ModifyGraph/Z axThick=0
	ModifyGraph/Z tkLblRot(left)=90
	ModifyGraph/Z btLen=3
	ModifyGraph/Z tlOffset=-2
	SetAxis/Z/A/R left
end