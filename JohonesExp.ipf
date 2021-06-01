#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
threadsafe function /S JohnesExp_incidentVecror(ctrlName, S_wname V_magnitude, V_angle, V_phaseV)
	string ctrlName, S_wname
	variable V_magnitude, V_angle, V_phaseV//V_angle is in radian unit
	Make/O/N=2/D/C $S_wname
	wave /C wv=$S_wname
	 wv = {cmplx(cos(V_angle)*cos(-V_phaseV/2), cos(V_angle)*sin(-V_phaseV/2)), cmplx(sin(V_angle)*cos(V_phaseV/2), sin(V_angle)*sin(V_phaseV/2))}
	return S_wname
end

threadsafe function /S JohnesExp_rotation(ctrlName, S_wname, V_angle)
	string ctrlName, S_wname
	variable V_angle
	Make/O/N=(2, 2)/D/C $S_wname
	wave /C wv=$S_wname
	 wv={{cos(V_angle), sin(V_angle)}, {-sin(V_angle), cos(V_angle)}}
	return S_wname
end

threadsafe function /S JohnesExp_WavePlate(ctrlName, S_wname, V_phaseHrz)
	string ctrlName, S_wname
	variable V_phaseHrz
	Make/O/N=(2, 2)/D/C $S_wname
	wave /C wv=$S_wname
	 wv={{exp(cmplx(0, V_phaseHrz)), 0}, {0, 1}}
	return S_wname
end

threadsafe function /S JohnesExp_RotatedWP(ctrlName, S_wname, V_RotAngle, V_phaseHrz)
	string ctrlName, S_wname
	variable V_RotAngle, V_phaseHrz
	wave /C W_RET=$JohnesExp_rotation(ctrlName, S_wname+"RET", V_RotAngle)
	wave /C W_WP=$JohnesExp_WavePlate(ctrlName, S_wname, V_phaseHrz)
	wave /C W_ROT=$JohnesExp_rotation(ctrlName, S_wname+"ROT", -V_RotAngle)
	MatrixMultiply W_RET,W_WP,W_ROT
	wave M_product
	multithread W_WP=M_product
	// KillWaves  W_ROT, W_RET
	return S_wname
end

threadsafe function /S JohnesExp_refi(ctrlName, S_wname)
	string ctrlName, S_wname
	variable V_phaseHrz
	Make/O/N=(2, 2)/D/C $S_wname
	wave /C wv=$S_wname
	//multithread wv={{1, 0}, {0, 1}}	
	 wv={{exp(cmplx(0, pi)), 0}, {0, 1}}
	return S_wname
end

threadsafe function /S JohnesExp_Polx(ctrlName, S_wname)
	string ctrlName, S_wname
	variable V_phaseHrz
	Make/O/N=(2, 2)/D/C $S_wname
	wave /C wv=$S_wname
	 wv={{1, 0}, {0, 0}}
	return S_wname
end