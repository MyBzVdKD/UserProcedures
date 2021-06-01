#pragma rtGlobals=1	// Use modern global access method.

Function error_function(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = Amplitude/2*(1+erf((x-Mu)/sqrt(2)/Sigma, 1e-36))+y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = Sigma
	//CurveFitDialog/ w[1] = Mu
	//CurveFitDialog/ w[2] = Amplitude
	//CurveFitDialog/ w[3] = y0

	return w[2]/2*(1+erf((x-w[1])/sqrt(2)/w[0], 1e-36))+w[3]
End
