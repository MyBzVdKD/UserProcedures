Function sin4(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = A*(sin(f*x+phi))^4+B
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = B
	//CurveFitDialog/ w[2] = f
	//CurveFitDialog/ w[3] = phi

	return w[0]*(sin(w[2]*x+w[3]))^4+w[1]
End
