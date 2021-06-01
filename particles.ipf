#include <Peak AutoFind>
#pragma rtGlobals=1		// Use modern global access method.
#include <Percentile and Box Plot>
#include <Function Grapher>

#pragma rtGlobals=1		// Use modern global access method.
function RMV_isolatedpnts_2D(ctrlName, wname)
	string ctrlName, wname
	wave wv=$wname
	variable i,j
	for(j=0; j<dimsize(wv, 1); j+=1)
		for(i=0; i<dimsize(wv, 0); i+=1)
			if(wv[i+1][j]>0&&wv[i-1][j]>0&&wv[i][j+1]>0&&wv[i][j-1]>0)
				wv[i][j]=255
			endif
		endfor
	endfor
end

function Cmp_polarization(ctrlName, L_wavelist)
	string ctrlName, L_wavelist
	string S_ROIname="M_ROI"
	display
	Add_ParticlesROI("Cmp_polarization", S_ROIname, L_wavelist)
	variable i_w
	variable n_waves=ItemsInList(L_wavelist)
	for(i_w=0; i_w<n_waves; i_w+=1)
		string S_OrgWname=StringFromList(i_w, L_wavelist)+"_Ref"
		appendtograph $ParticleIntensity("Cmp_polarization", S_OrgWname, S_ROIname)
	endfor
	ModifyGraph mode=4,marker=19,rgb(W_X_RefM_ROI_pInt)=(0,12800,52224);ModifyGraph rgb(W_Y_RefM_ROI_pInt)=(0,39168,0)
end

function Add_ParticlesROI(ctrlName, S_wnameROI, L_wavelist)
	string ctrlName, S_wnameROI, L_wavelist
	variable n_waves=ItemsInList(L_wavelist)
	variable i_w
	string S_wname
	make /O/B/U /n=(dimsize($StringFromList(0, L_wavelist), 0), dimsize($StringFromList(1, L_wavelist), 0)), $S_wnameROI
	wave M_ROI=$S_wnameROI
	M_ROI=1
	for(i_w=0; i_w<n_waves; i_w+=1)
		S_wname=StringFromList(i_w, L_wavelist)
		print S_wname,": Add_ParticlesROI Operated"
		doupdate
		S_wname=RMV_backgroud_2D("Cmp_polarization", S_wname, 5, nan)
		doupdate
		wave wv=$GenParticleROI(ctrlName, S_wname, 5, nan)
		M_ROI*=wv
	endfor
end

function /S RMV_backgroud_2D(ctrlName, S_wname, F_TresholdingMethod, V_Thredhhold)//バックグラウンド除去
	string ctrlName, S_wname
	variable F_TresholdingMethod//2 is recommended
	variable V_Thredhhold
	wave wv=$S_wname
	//wave M_ImageThresh
	variable V_PolynomialOrder=3//近似局面の次数
	if(F_TresholdingMethod)//粒子が存在している空間を排除したROIを作る
		ImageThreshold /M=(F_TresholdingMethod)/I /C wv//M_RemovedBackground//Automatical Thresholding
	else
		ImageThreshold /M=(F_TresholdingMethod) /I /C /T=(V_Thredhhold) wv//M_RemovedBackground//Manual Threshold
	endif
	Redimension/B/U M_ImageThresh
	doupdate
	RMV_isolatedpnts_2D("RMV_backgroud_2D", "M_ImageThresh")//ROIからノイズ由来の孤立点を除去
	ImageRemoveBackground /P=(V_PolynomialOrder) /R=M_ImageThresh wv//バックグラウンドを信号の分布を3次局面近似したあと除去
	duplicate /O M_RemovedBackground, $S_wname+"_Ref"
	return S_wname+"_Ref"
end
	wavetransform
function /S GenParticleROI(ctrlName, S_OrgWname, F_TresholdingMethod, V_Thredhhold)
	string ctrlName, S_OrgWname
	variable F_TresholdingMethod//2 is recommended
	variable V_Thredhhold
	wave W_org=$S_OrgWname
	if(F_TresholdingMethod)//粒子が存在している空間を排除したROIを作る
		ImageThreshold /M=(F_TresholdingMethod)/I /C W_org//Automatical Thresholding
	else
		ImageThreshold /M=(F_TresholdingMethod) /I /C /T=(V_Thredhhold) W_org//Manual Threshold
	endif
	RMV_isolatedpnts_2D("RMV_backgroud_2D", "M_ImageThresh")//ROIからノイズ由来の孤立点を除去
	//バックグラウンドの標準偏差をとって，それより大きい領域を閾値とする．
	imagetransform invert M_ImageThresh//ROIのロジックを反転させる
	ImageStats /R=M_Inverted  W_org //バックグラウンド部分の統計データを取る
	print "V_avg: ", V_avg, ", V_sdev: ", V_sdev
	ImageThreshold /M=0 /I /C /T=(V_sdev*2) W_org//標準偏差を閾値にしてバックグラウンドをとる
	RMV_isolatedpnts_2D("RMV_backgroud_2D", "M_ImageThresh")//ROIからノイズ由来の孤立点を除去
	ImageAnalyzeParticles /A=5 /M=2 stats M_ImageThresh
	wave M_ParticleArea
	M_ParticleArea=M_ParticleArea*255/64
	duplicate /O M_ParticleArea, $S_OrgWname+"_ROI"
	//duplicate /O M_ImageThresh, $S_OrgWname+"_ROI"
	doupdate
	return S_OrgWname+"_ROI" 
end
	
function /S ParticleIntensity(ctrlName, S_OrgWname, S_ROIWname)
	string ctrlName, S_OrgWname, S_ROIWname
	string S_WN_ParticleIntensity=S_OrgWname+S_ROIWname+"_pInt"
	wave M_ORG=$S_OrgWname
	wave M_ROI=$S_ROIWname
	print S_ROIWname
	//ImageAnalyzeParticlesで粒子の強度の積算を求める．
	ImageAnalyzeParticles /A=20 /D=M_ORG stats M_ROI
	wave W_IntAvg
	duplicate /O W_IntAvg, $S_WN_ParticleIntensity
	wave W_Intsum=$S_WN_ParticleIntensity
	wave W_ImageObjArea
	W_Intsum*=W_ImageObjArea
	return S_WN_ParticleIntensity
end