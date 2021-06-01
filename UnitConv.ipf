#pragma rtGlobals=1		// Use modern global access method.
//UnitConversion Ver20100725


function eV2J(V_eV)
	variable V_eV
	variable V_e=1.60217646e-19//[C]: elementary charge 
	return V_e*V_eV
end

function J2nm(V_J)
	variable V_J
	variable V_h=6.626068e-34//[Js]: Plank's constant 
	variable V_c=299792458//[m/s]: velocity of light
	return V_h*V_c/V_J*1e9
end

function nm2J(V_nm)
	variable V_nm
	variable V_h=6.626068e-34//[Js]: Plank's constant 
	variable V_c=299792458//[m/s]: velocity of light
	return V_h*V_c/(V_nm/1e9)
end

function J2eV(V_J)
	variable V_J
	variable V_e=1.60217646e-19//[C]: elementary charge 
	return V_J/V_e
end

function eV2nm(V_eV)
	variable V_eV
	return J2nm(eV2J(V_eV))
end

function nm2eV(V_nm)
	variable V_nm
	return J2eV(nm2J(V_nm))
end